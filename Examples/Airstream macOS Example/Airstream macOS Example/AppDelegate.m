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

@property (weak) IBOutlet NSButton *serverButton;
@property (weak) IBOutlet NSButton *previousButton;
@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSTextField *titleField;
@property (weak) IBOutlet NSTextField *artistField;
@property (weak) IBOutlet NSTextField *albumField;

@property (nonatomic) Airstream *airstream;
@property (nonatomic) BOOL buffering;

@end

@implementation AppDelegate {
  AudioComponentInstance audioUnit;
  TPCircularBuffer circularBuffer;
}

// MARK: - Application lifetime

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  TPCircularBufferInit(&circularBuffer, 131072);

  self.airstream = [[Airstream alloc] initWithName:@"My Mac Airstream"];
  self.airstream.delegate = self;

  [self.serverButton setTarget:self];
  [self.serverButton setAction:@selector(handleServerButtonClicked:)];

  [self.previousButton setTarget:self];
  [self.previousButton setAction:@selector(handlePreviousButtonClicked:)];

  [self.nextButton setTarget:self];
  [self.nextButton setAction:@selector(handleNextButtonClicked:)];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  [self.airstream stopServer];
}

// MARK: - Helpers

- (TPCircularBuffer *)circularBuffer {
  return &circularBuffer;
}

- (void)handleCoreAudioError:(OSStatus)err {
  NSLog(@"Error: %@ (CoreAudio)", [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil]);
}

- (void)handleServerButtonClicked:(NSNotification *)notification {
  if (self.airstream.running) {
    self.serverButton.title = @"Stopping...";
    self.serverButton.enabled = NO;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
      // Stop the server on high priority thread
      [self.airstream stopServer];

      // Update UI on main thread
      dispatch_async(dispatch_get_main_queue(), ^{
        self.serverButton.title = @"Start server";
        self.serverButton.enabled = YES;
      });
    });
  } else {
    [self.airstream startServer];
    self.serverButton.title = @"Stop server";
  }
}

- (void)handlePreviousButtonClicked:(NSNotification *)notification {
  if (self.airstream.remote != nil) {
    [self.airstream.remote previousItem];
  }
}

- (void)handleNextButtonClicked:(NSNotification *)notification {
  if (self.airstream.remote != nil) {
    [self.airstream.remote nextItem];
  }
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
    return;
  }

  // Enable input
  status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamFormat, sizeof(streamFormat));
  if (status != noErr) {
    [self handleCoreAudioError:status];
    return;
  }

  // Set up callbacks
  AURenderCallbackStruct renderCallback = {
    .inputProc = OutputRenderCallback,
    .inputProcRefCon = (__bridge void *)(self)
  };
  status = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, 0, &renderCallback, sizeof(renderCallback));
  if (status != noErr) {
    [self handleCoreAudioError:status];
    return;
  }

  // Initialize audio unit
  status = AudioUnitInitialize(audioUnit);
  if (status != noErr) {
    [self handleCoreAudioError:status];
    return;
  }

  // Start audio unit
  status = AudioOutputUnitStart(audioUnit);
  if (status != noErr) {
    [self handleCoreAudioError:status];
    return;
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
  // Empty our buffer
  TPCircularBufferClear(&circularBuffer);

  // Stop audio unit
  OSStatus status = AudioOutputUnitStop(audioUnit);
  if (status != noErr) {
    [self handleCoreAudioError:status];
  }
  audioUnit = NULL;

  // Clear all the UI elements
  self.imageView.image = nil;
  self.previousButton.enabled = NO;
  self.nextButton.enabled = NO;
  self.titleField.stringValue = @"";
  self.artistField.stringValue = @"";
  self.albumField.stringValue = @"";
}

- (void)airstream:(Airstream *)airstream didSetCoverart:(NSData *)coverart {
  NSImage *image = [[NSImage alloc] initWithData:coverart];
  [self.imageView setImage:image];
}

- (void)airstream:(Airstream *)airstream didSetMetadata:(NSDictionary<NSString *,NSString *> *)metadata {
  self.titleField.stringValue = [metadata objectForKey:ASMetadataSongTitleKey];
  self.artistField.stringValue = [metadata objectForKey:ASMetadataSongArtistKey];
  self.albumField.stringValue = [metadata objectForKey:ASMetadataSongAlbumKey];
}

- (void)airstream:(Airstream *)airstream didGainAccessToRemote:(AirstreamRemote *)remote {
  self.previousButton.enabled = YES;
  self.nextButton.enabled = YES;
}

@end

// MARK: - CoreAudio

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
  int32_t amount = MIN(ioData->mBuffers[0].mDataByteSize, availableBytes);

  // Copy data from our buffer to audio unit buffer
  memcpy(ioData->mBuffers[0].mData, sourceBuffer, amount);

  TPCircularBufferConsume(circularBuffer, amount);

  return noErr;
}
