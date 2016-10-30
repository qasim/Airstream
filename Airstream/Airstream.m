//
//  Airstream.m
//  Airstream
//
//  Created by Qasim Iqbal on 10/29/16.
//  Copyright © 2016 Qasim Iqbal. All rights reserved.
//

#import "Airstream.h"
#import "Airport.h"

@implementation Airstream {
  dnssd_t *dnssd;
  raop_t *raop;
}

// MARK: - Init

- (instancetype)init {
  self = [super init];

  if (!self) {
    return nil;
  }

  // Set defaults
  self.name = @"Airstream";
  self.password = nil;
  self.port = 5000;

  return self;
}

// MARK: Server actions

- (void)startServer {
  if (self.running) {
    return;
  }

  // Register RAOP callbacks
  raop_callbacks_t raopCallbacks;
  raopCallbacks.cls = (__bridge void *)(self);
  raopCallbacks.audio_init = audio_init;
  raopCallbacks.audio_process = audio_process;
  raopCallbacks.audio_destroy = audio_destroy;
  raopCallbacks.audio_set_volume = audio_set_volume;
  raopCallbacks.audio_set_progress = audio_set_progress;
  raopCallbacks.audio_set_metadata = audio_set_metadata;
  raopCallbacks.audio_set_coverart = audio_set_coverart;

  // Server settings
  const char address[] = { 0x48, 0x5d, 0x60, 0x7c, 0xee, 0x22 };
  const char *name = [self.name UTF8String];
  const char *password = [self.password UTF8String];
  unsigned short port = self.port;

  // Start RAOP server
  raop = raop_init(10, &raopCallbacks, AIRPORT_KEY, NULL);
  if (raop == NULL) {
    // TODO: error handling
    exit(-1);
  }

  raop_set_log_level(raop, RAOP_LOG_INFO);
  raop_start(raop, &port, address, sizeof(address), password);

  // Start DNS-SD service
  int error;
  dnssd = dnssd_init(&error);
  if (error) {
    // TODO: error handling
    raop_destroy(raop);
    exit(-1);
  }

  dnssd_register_raop(dnssd, name, port, address, sizeof(address), 0);

  self.running = YES;
}

- (void)stopServer {
  if (!self.running) {
    return;
  }

  // Tear down DNS-SD service
  dnssd_unregister_raop(dnssd);
  dnssd_destroy(dnssd);

  // Tear down RAOP server
  raop_stop(raop);
  raop_destroy(raop);

  self.running = NO;
}

- (void)restartServer {
  [self stopServer];
  [self startServer];
}

@end

static void *audio_init(void *context, int bitsPerChannel, int channelsPerFrame, int sampleRate) {
  Airstream *airstream = (__bridge Airstream *)context;
  AudioStreamBasicDescription streamFormat = {0};

  streamFormat.mFormatID = kAudioFormatLinearPCM;
  streamFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;

  streamFormat.mSampleRate = sampleRate;
  streamFormat.mBitsPerChannel = bitsPerChannel;
  streamFormat.mChannelsPerFrame = channelsPerFrame;
  streamFormat.mFramesPerPacket = 1;

  int bytes = (bitsPerChannel / 8) * channelsPerFrame;
  streamFormat.mBytesPerFrame = bytes;
  streamFormat.mBytesPerPacket = bytes;

  airstream.bitsPerChannel = bitsPerChannel;
  airstream.channelsPerFrame = channelsPerFrame;
  airstream.sampleRate = sampleRate;
  [airstream.delegate airstream:airstream willStartStreamingWithStreamFormat:streamFormat];

  return NULL;
}

static void audio_process(void *context, void *opaque, const void *buffer, int bufferLength) {
  Airstream *airstream = (__bridge Airstream *)context;
  [airstream.delegate airstream:airstream processAudio:buffer length:bufferLength];
}

static void audio_destroy(void *context, void *opaque) {
  Airstream *airstream = (__bridge Airstream *)context;
  [airstream.delegate airstreamWillStopStreaming:airstream];
}

static void audio_set_volume(void *context, void *opaque, float volume) {
  Airstream *airstream = (__bridge Airstream *)context;

  volume = pow(10.0, 0.05 * volume);

  airstream.volume = volume;
  [airstream.delegate airstream:airstream didSetVolume:volume];
}

static void audio_set_metadata(void *context, void *session, const void *buffer, int bufferLength) {
  Airstream *airstream = (__bridge Airstream *)context;
  NSMutableDictionary *metaData = [[NSMutableDictionary alloc] init];

  int offset = 8;
  while (offset < bufferLength) {
    char tag[5];
    strncpy(tag, buffer + offset, 4);
    tag[4] = '\0';
    offset += 4;

    uint32_t length = *(uint32_t *)(buffer + offset);
    length = CFSwapInt32BigToHost(length);
    offset += sizeof(uint32_t);

    char content[length + 1];
    strncpy(content, buffer + offset, length);
    content[length] = '\0';
    offset += length;

    NSString *key = [NSString stringWithUTF8String:tag];
    NSString *value = [NSString stringWithUTF8String:content];
    if (key != nil && value != nil) {
      [metaData setObject:value forKey:key];
    }
  }

  airstream.metaData = metaData;
  [airstream.delegate airstream:airstream didSetMetaData:metaData];
}

static void audio_set_coverart(void *context, void *session, const void *buffer, int bufferLength) {
  Airstream *airstream = (__bridge Airstream *)context;

  NSData *data = [NSData dataWithBytes:buffer length:bufferLength];
  NSImage *coverArt = [[NSImage alloc] initWithData:data];

  airstream.coverArt = coverArt;
  [airstream.delegate airstream:airstream didSetCoverArt:coverArt];
}

static void audio_set_progress(void *context, void *session, unsigned int start, unsigned int curr, unsigned int end) {
  Airstream *airstream = (__bridge Airstream *)context;

  NSUInteger position = (curr - start) / airstream.sampleRate;
  NSUInteger duration = (end - start) / airstream.sampleRate;

  airstream.position = position;
  airstream.duration = duration;
  [airstream.delegate airstream:airstream didSetPosition:position duration:duration];
}
