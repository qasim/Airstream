//
//  Airstream.m
//  Airstream
//
//  Created by Qasim Iqbal on 10/29/16.
//  Copyright © 2016 Qasim Iqbal. All rights reserved.
//

#import "Airstream.h"
#import "Airport.h"

#import <shairplay/dnssd.h>
#import <shairplay/raop.h>

/// RAOP server constants
NSUInteger const ASDefaultPort = 5000;
NSUInteger const ASMaxClients = 8;

/// Startup exceptions
NSString *const ASRAOPFailedInitException = @"ASRAOPInitFailedException";
NSString *const ASDNSSDFailedInitException = @"ASDNSSDFailedInitException";

@interface Airstream ()

/// AirPlay streaming configuration
@property (nonatomic, readwrite) NSUInteger bitsPerChannel;
@property (nonatomic, readwrite) NSUInteger channelsPerFrame;
@property (nonatomic, readwrite) NSUInteger sampleRate;

/// AirPlay data
@property (nonatomic, readwrite) float volume;
@property (nonatomic, readwrite) NSDictionary<NSString *, NSString *> *metadata;
@property (nonatomic, readwrite) NSData *coverart;
@property (nonatomic, readwrite) NSUInteger position;
@property (nonatomic, readwrite) NSUInteger duration;

/// Determines if the AirPlay server is running
@property (nonatomic, readwrite) BOOL running;

@end

@implementation Airstream {
  dnssd_t *dnssd;
  raop_t *raop;
}

// MARK: - Initializers

- (instancetype)init {
  return [self initWithName:nil password:nil port:ASDefaultPort];
}

- (instancetype)initWithName:(NSString *)name {
  return [self initWithName:name password:nil port:ASDefaultPort];
}

- (instancetype)initWithName:(NSString *)name password:(NSString *)password {
  return [self initWithName:name password:password port:ASDefaultPort];
}

- (instancetype)initWithName:(NSString *)name password:(NSString *)password port:(NSUInteger)port {
  self = [super init];

  if (!self) {
    return nil;
  }

  if (name != nil) {
    self.name = name;
  } else {
    self.name = @"My Airstream";
  }

  if (password != nil) {
    self.password = password;
  } else {
    self.password = nil;
  }

  self.port = port;

  self.running = NO;

  return self;
}

// MARK: Basic server operations

- (void)startServer {
  if (self.running) {
    return;
  }

  // Register RAOP callbacks
  raop_callbacks_t raopCallbacks;
  memset(&raopCallbacks, 0, sizeof(raopCallbacks));

  raopCallbacks.cls = (__bridge void *)(self);
  raopCallbacks.audio_init = audio_init;
  raopCallbacks.audio_flush = audio_flush;
  raopCallbacks.audio_process = audio_process;
  raopCallbacks.audio_destroy = audio_destroy;
  raopCallbacks.audio_set_volume = audio_set_volume;
  raopCallbacks.audio_set_progress = audio_set_progress;
  raopCallbacks.audio_set_metadata = audio_set_metadata;
  raopCallbacks.audio_set_coverart = audio_set_coverart;

  // Server settings
  const char address[] = {0x48, 0x5d, 0x60, 0x7c, 0xee, 0x22};
  const char *name = [self.name UTF8String];
  const char *password = [self.password UTF8String];
  unsigned short port = self.port;

  // Start RAOP server
  raop = raop_init(ASMaxClients, &raopCallbacks, AIRPORT_KEY, NULL);
  if (raop == NULL) {
    NSLog(@"Error: failed to initialize RAOP server");
    return;
  }

  raop_set_log_level(raop, RAOP_LOG_INFO);
  raop_start(raop, &port, address, sizeof(address), password);

  // Start DNS-SD service
  int error;
  dnssd = dnssd_init(&error);
  if (error) {
    raop_destroy(raop);
    NSLog(@"Error: failed to initialize DNS-SD service with error code %d", error);
    return;
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

  if ([airstream.delegate respondsToSelector:@selector(airstream:willStartStreamingWithStreamFormat:)]) {
    [airstream.delegate airstream:airstream willStartStreamingWithStreamFormat:streamFormat];
  }

  return NULL;
}

static void audio_flush(void *context, void *session) {
  Airstream *airstream = (__bridge Airstream *)context;

  if ([airstream.delegate respondsToSelector:@selector(airstreamFlushAudio:)]) {
    [airstream.delegate airstreamFlushAudio:airstream];
  }
}

static void audio_process(void *context, void *opaque, const void *buffer, int bufferLength) {
  Airstream *airstream = (__bridge Airstream *)context;

  if ([airstream.delegate respondsToSelector:@selector(airstream:processAudio:length:)]) {
    [airstream.delegate airstream:airstream processAudio:(char *)buffer length:bufferLength];
  }
}

static void audio_destroy(void *context, void *opaque) {
  Airstream *airstream = (__bridge Airstream *)context;

  if ([airstream.delegate respondsToSelector:@selector(airstreamDidStopStreaming:)]) {
    [airstream.delegate airstreamDidStopStreaming:airstream];
  }
}

static void audio_set_volume(void *context, void *opaque, float volume) {
  Airstream *airstream = (__bridge Airstream *)context;

  volume = pow(10.0, 0.05 * volume);
  airstream.volume = volume;

  if ([airstream.delegate respondsToSelector:@selector(airstream:didSetVolume:)]) {
    [airstream.delegate airstream:airstream didSetVolume:volume];
  }
}

static void audio_set_metadata(void *context, void *session, const void *buffer, int bufferLength) {
  Airstream *airstream = (__bridge Airstream *)context;
  NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];

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
      [metadata setObject:value forKey:key];
    }
  }

  airstream.metadata = metadata;

  if ([airstream.delegate respondsToSelector:@selector(airstream:didSetMetadata:)]) {
    [airstream.delegate airstream:airstream didSetMetadata:metadata];
  }
}

static void audio_set_coverart(void *context, void *session, const void *buffer, int bufferLength) {
  Airstream *airstream = (__bridge Airstream *)context;

  NSData *coverart = [NSData dataWithBytes:buffer length:bufferLength];
  airstream.coverart = coverart;

  if ([airstream.delegate respondsToSelector:@selector(airstream:didSetCoverart:)]) {
    [airstream.delegate airstream:airstream didSetCoverart:coverart];
  }
}

static void audio_set_progress(void *context, void *session, unsigned int start, unsigned int curr, unsigned int end) {
  Airstream *airstream = (__bridge Airstream *)context;

  NSUInteger position = (curr - start) / airstream.sampleRate;
  NSUInteger duration = (end - start) / airstream.sampleRate;

  airstream.position = position;
  airstream.duration = duration;

  if ([airstream.delegate respondsToSelector:@selector(airstream:didSetPosition:duration:)]) {
    [airstream.delegate airstream:airstream didSetPosition:position duration:duration];
  }
}
