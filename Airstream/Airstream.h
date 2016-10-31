//
//  Airstream.h
//  Airstream
//
//  Created by Qasim Iqbal on 10/29/16.
//  Copyright © 2016 Qasim Iqbal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/// RAOP server constants
extern NSUInteger const ASDefaultPort;
extern NSUInteger const ASMaxClients;

/// Startup exceptions
extern NSString *const ASRAOPFailedInitException;
extern NSString *const ASDNSSDFailedInitException;

@class Airstream;

@protocol AirstreamDelegate <NSObject>

@optional

// MARK: Stream setup / teardown

/// Called right before a device has connected
- (void)airstream:(Airstream *)airstream willStartStreamingWithStreamFormat:(AudioStreamBasicDescription)streamFormat;

/// Called right after a device has disconnected
- (void)airstreamDidStopStreaming:(Airstream *)airstream;

// MARK: Audio processing

/// Process linear PCM audio data streamed from a device
- (void)airstream:(Airstream *)airstream processAudio:(char *)buffer length:(int)length;

/// Flush any audio output buffers
- (void)airstreamFlushAudio:(Airstream *)airstream;

// MARK: AirPlay data change listeners

- (void)airstream:(Airstream *)airstream didSetVolume:(float)volume;
- (void)airstream:(Airstream *)airstream didSetMetadata:(NSDictionary<NSString *, NSString *> *)metadata;
- (void)airstream:(Airstream *)airstream didSetCoverart:(NSData *)coverart;
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
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *metadata;
@property (nonatomic, readonly) NSData *coverart;
@property (nonatomic, readonly) NSUInteger position;
@property (nonatomic, readonly) NSUInteger duration;

/// Determines if the AirPlay server is running
@property (nonatomic, readonly) BOOL running;

/// Initializers
- (instancetype)init;
- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name password:(NSString *)password;
- (instancetype)initWithName:(NSString *)name password:(NSString *)password port:(NSUInteger)port;

/// Basic operations
- (void)startServer;
- (void)stopServer;

@end

/// Shairplay headers
static void *audio_init(void *context, int bitsPerChannel, int channelsPerFrame, int sampleRate);
static void audio_process(void *context, void *opaque, const void *buffer, int bufferLength);
static void audio_flush(void *context, void *session);
static void audio_destroy(void *context, void *opaque);
static void audio_set_volume(void *context, void *opaque, float volume);
static void audio_set_metadata(void *context, void *session, const void *buffer, int bufferLength);
static void audio_set_coverart(void *context, void *session, const void *buffer, int bufferLength);
static void audio_set_progress(void *context, void *session, unsigned int start, unsigned int curr, unsigned int end);
