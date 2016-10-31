//
//  Airstream.h
//  Airstream
//
//  Created by Qasim Iqbal on 10/29/16.
//  Copyright © 2016 Qasim Iqbal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "AirstreamRemote.h"

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

/// Called right after remote control has been setup
- (void)airstream:(Airstream *)airstream didGainAccessToRemote:(AirstreamRemote *)remote;

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

/// Server configuration
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *password;
@property (nonatomic) NSUInteger port;

/// Streaming configuration
@property (nonatomic, readonly) NSUInteger bitsPerChannel;
@property (nonatomic, readonly) NSUInteger channelsPerFrame;
@property (nonatomic, readonly) NSUInteger sampleRate;

/// Data
@property (nonatomic, readonly) float volume;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *metadata;
@property (nonatomic, readonly) NSData *coverart;
@property (nonatomic, readonly) NSUInteger position;
@property (nonatomic, readonly) NSUInteger duration;

/// Remote control
@property (nonatomic, readonly) AirstreamRemote *remote;

/// Determines if server is running
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
void *audio_init(void *context, int bitsPerChannel, int channelsPerFrame, int sampleRate);
void audio_process(void *context, void *opaque, const void *buffer, int bufferLength);
void audio_flush(void *context, void *session);
void audio_destroy(void *context, void *opaque);
void audio_remote_control_id(void *context, const char *dacpID, const char *activeRemoteHeader);
void audio_set_volume(void *context, void *opaque, float volume);
void audio_set_metadata(void *context, void *session, const void *buffer, int bufferLength);
void audio_set_coverart(void *context, void *session, const void *buffer, int bufferLength);
void audio_set_progress(void *context, void *session, unsigned int start, unsigned int curr, unsigned int end);
