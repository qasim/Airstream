//
//  AppDelegate.m
//  Airstream macOS Example
//
//  Created by Qasim Iqbal on 10/30/16.
//  Copyright © 2016 Qasim Iqbal. All rights reserved.
//

#import "AppDelegate.h"
#import "TPCircularBuffer.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic) Airstream *airstream;
@property (nonatomic) BOOL buffering;

@end

@implementation AppDelegate {
  AudioComponentInstance audioUnit;
  TPCircularBuffer circularBuffer;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  self.buffering = YES;

  self.airstream = [[Airstream alloc] init];
  self.airstream.delegate = self;
  self.airstream.name = @"My AirPlay Server2";

  [self.airstream startServer];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  [self.airstream stopServer];
}

// MARK: - Helpers

- (TPCircularBuffer *)circularBuffer {
  if (!circularBuffer.buffer) {
    TPCircularBufferInit(&circularBuffer, 24576*8);
  }
  return &circularBuffer;
}

- (void)handleCoreAudioError:(OSStatus)err {
  // TODO: Improve error handling
  NSLog(@"CoreAudio error: %@", [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil]);
  exit(-1);
}

// MARK: - AirstreamDelegate

- (void)airstream:(Airstream *)airstream willStartStreamingWithStreamFormat:(AudioStreamBasicDescription)streamFormat {
  // Create audio component
  AudioComponentDescription desc = {
    .componentType = kAudioUnitType_Output,
    .componentSubType = kAudioUnitSubType_DefaultOutput,
    .componentManufacturer = kAudioUnitManufacturer_Apple,
    .componentFlags = 0,
    .componentFlagsMask = 0
  };
  AudioComponent comp = AudioComponentFindNext(NULL, &desc);
  OSStatus status = AudioComponentInstanceNew(comp, &audioUnit);
  if (status != noErr) {
    [self handleCoreAudioError:status];
  }

  // Enable input
  status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamFormat, sizeof(streamFormat));
  if (status != noErr) {
    [self handleCoreAudioError:status];
  }

  // Set up callbacks
  AURenderCallbackStruct renderCallback = {
    .inputProc = OutputRenderCallback,
    .inputProcRefCon = (__bridge void *)(self)
  };
  status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, 0, &renderCallback, sizeof(renderCallback));
  if (status != noErr) {
    [self handleCoreAudioError:status];
  }

  // Initialize audio unit
  status = AudioUnitInitialize(audioUnit);
  if (status != noErr) {
    [self handleCoreAudioError:status];
  }

  // Start audio unit
  status = AudioOutputUnitStart(audioUnit);
  if (status != noErr) {
    [self handleCoreAudioError:status];
  }
}

- (void)airstream:(Airstream *)airstream processAudio:(char *)buffer length:(int)length {
  // Adjust volume if needed
  if (airstream.volume < 1.0) {
    short *shortData = (short *)buffer;
    for (int i = 0; i < length / 2; i++) {
      shortData[i] = shortData[i] * airstream.volume;
    }
  }

  AudioBuffer audioBuffer = {
    .mNumberChannels = (unsigned int)airstream.channelsPerFrame,
    .mDataByteSize = length,
    .mData = buffer
  };

  AudioBufferList bufferList;
  bufferList.mNumberBuffers = 1;
  bufferList.mBuffers[0] = audioBuffer;

  // Enqueue audio data to circular buffer
  TPCircularBufferProduceBytes(&circularBuffer, bufferList.mBuffers[0].mData, bufferList.mBuffers[0].mDataByteSize);

  // Determine if buffering is needed (are we falling behind?)
  self.buffering = circularBuffer.fillCount < 8192;
}

- (void)airstreamDidStopStreaming:(Airstream *)airstream {
  TPCircularBufferClear(&circularBuffer);

  OSStatus status = AudioOutputUnitStop(audioUnit);
  if (status != noErr) {
    [self handleCoreAudioError:status];
  }

  audioUnit = NULL;
}

@end

/// Callback for AudioUnit streaming to output device
OSStatus OutputRenderCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
  // Retrieve reference to Airstream instance
  AppDelegate *appDelegate = (__bridge AppDelegate*)inRefCon;
  TPCircularBuffer *circularBuffer = appDelegate.circularBuffer;

  // If no data is available or in a buffer state, send empty sound to audio device
  if (!circularBuffer || circularBuffer->fillCount == 0 || appDelegate.buffering) {
    for(UInt32 i = 0; i < ioData->mNumberBuffers; i++) {
      memset(ioData->mBuffers[i].mData, 0, ioData->mBuffers[i].mDataByteSize);
    }
    return noErr;
  }

  int32_t availableBytes;
  SInt16 *sourceBuffer = TPCircularBufferTail(circularBuffer, &availableBytes);

  // Copy data from our buffer to audio unit buffer
  int32_t amount = MIN(ioData->mBuffers[0].mDataByteSize, availableBytes);
  memcpy(ioData->mBuffers[0].mData, sourceBuffer, amount);

  TPCircularBufferConsume(circularBuffer, amount);

  return noErr;
}
