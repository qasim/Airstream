//
//  Airstream.h
//  Airstream
//
//  Created by Qasim Iqbal on 10/29/16.
//  Copyright © 2016 Qasim Iqbal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/// Shairplay headers
static void *audio_init(void *context, int bitsPerChannel, int channelsPerFrame, int sampleRate);
static void audio_flush(void *context, void *session);
static void audio_process(void *context, void *opaque, const void *buffer, int bufferLength);
static void audio_destroy(void *context, void *opaque);
static void audio_set_volume(void *context, void *opaque, float volume);
static void audio_set_metadata(void *context, void *session, const void *buffer, int bufferLength);
static void audio_set_coverart(void *context, void *session, const void *buffer, int bufferLength);
static void audio_set_progress(void *context, void *session, unsigned int start, unsigned int curr, unsigned int end);

@class Airstream;

@protocol AirstreamDelegate <NSObject>

@optional

// MARK: Stream setup / teardown

/// Called right before a device has connected
- (void)airstream:(Airstream *)airstream willStartStreamingWithStreamFormat:(AudioStreamBasicDescription)streamFormat;

/// Called right after a device has disconnected
- (void)airstreamDidStopStreaming:(Airstream *)airstream;

// MARK: Audio processing

/// Flush any audio output buffers, as a new audio source will begin to broadcast
- (void)airstreamFlushAudio:(Airstream *)airstream;

/// Process the linear PCM audio streamed from a device
- (void)airstream:(Airstream *)airstream processAudio:(char *)buffer length:(int)length;

// MARK: AirPlay data listeners

- (void)airstream:(Airstream *)airstream didSetVolume:(float)volume;
- (void)airstream:(Airstream *)airstream didSetMetaData:(NSDictionary<NSString *, NSString *> *)metaData;
- (void)airstream:(Airstream *)airstream didSetCoverArt:(NSData *)coverArt;
- (void)airstream:(Airstream *)airstream didSetPosition:(NSUInteger)position duration:(NSUInteger)duration;

@end

@interface Airstream : NSObject

@property (nonatomic, weak) id <AirstreamDelegate> delegate;

/// AirPlay server configuration
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *password;
@property (nonatomic) NSUInteger port;

/// AirPlay streaming configuration
@property (nonatomic, readonly) NSUInteger bitsPerChannel;
@property (nonatomic, readonly) NSUInteger channelsPerFrame;
@property (nonatomic, readonly) NSUInteger sampleRate;

/// AirPlay data
@property (nonatomic, readonly) float volume;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *metaData;
@property (nonatomic, readonly) NSData *coverArt;
@property (nonatomic, readonly) NSUInteger position;
@property (nonatomic, readonly) NSUInteger duration;

/// Determines if the AirPlay server is running
@property (nonatomic, readonly) BOOL running;

/// Basic operations
- (void)startServer;
- (void)stopServer;

@end
