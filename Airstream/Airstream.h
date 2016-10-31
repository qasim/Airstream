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

NS_ASSUME_NONNULL_BEGIN

/// RAOP server constants
extern NSUInteger const ASDefaultPort;
extern NSUInteger const ASMaxClients;

/// Startup exceptions
extern NSString *const ASRAOPFailedInitException;
extern NSString *const ASDNSSDFailedInitException;

/// Metadata dictionary keys
extern NSString *const ASMetadataSongTitleKey;
extern NSString *const ASMetadataSongAlbumKey;
extern NSString *const ASMetadataSongArtistKey;
extern NSString *const ASMetadataSongGenreKey;
extern NSString *const ASMetadataSongTrackCountKey;
extern NSString *const ASMetadataSongTrackNumberKey;
extern NSString *const ASMetadataSongDiscCountKey;
extern NSString *const ASMetadataSongDiscNumberKey;

NS_ASSUME_NONNULL_END

@class Airstream;

@protocol AirstreamDelegate <NSObject>

@optional

// MARK: Stream setup / teardown

/// Called right before a device has connected
- (void)airstream:(nonnull Airstream *)airstream willStartStreamingWithStreamFormat:(AudioStreamBasicDescription)streamFormat;

/// Called right after a device has disconnected
- (void)airstreamDidStopStreaming:(nonnull Airstream *)airstream;

/// Called right after remote control has been setup
- (void)airstream:(nonnull Airstream *)airstream didGainAccessToRemote:(nonnull AirstreamRemote *)remote;

// MARK: Audio processing

/// Process linear PCM audio data streamed from a device
- (void)airstream:(nonnull Airstream *)airstream processAudio:(nonnull char *)buffer length:(int)length;

/// Flush any audio output buffers
- (void)airstreamFlushAudio:(nonnull Airstream *)airstream;

// MARK: AirPlay data change listeners

- (void)airstream:(nonnull Airstream *)airstream didSetVolume:(float)volume;
- (void)airstream:(nonnull Airstream *)airstream didSetMetadata:(nonnull NSDictionary<NSString *, NSString *> *)metadata;
- (void)airstream:(nonnull Airstream *)airstream didSetCoverart:(nonnull NSData *)coverart;
- (void)airstream:(nonnull Airstream *)airstream didSetPosition:(NSUInteger)position duration:(NSUInteger)duration;

@end

@interface Airstream : NSObject

@property (nonatomic, weak, nullable) id <AirstreamDelegate> delegate;

/// Server configuration
@property (nonatomic, nonnull) NSString *name;
@property (nonatomic, nullable) NSString *password;
@property (nonatomic) NSUInteger port;

/// Streaming configuration
@property (nonatomic, readonly) NSUInteger bitsPerChannel;
@property (nonatomic, readonly) NSUInteger channelsPerFrame;
@property (nonatomic, readonly) NSUInteger sampleRate;

/// Data
@property (nonatomic, readonly) float volume;
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *metadata;
@property (nonatomic, readonly, nullable) NSData *coverart;
@property (nonatomic, readonly) NSUInteger position;
@property (nonatomic, readonly) NSUInteger duration;

/// Remote control
@property (nonatomic, readonly, nullable) AirstreamRemote *remote;

/// Determines if server is running
@property (nonatomic, readonly) BOOL running;

/// Initializers
- (nonnull instancetype)init;
- (nonnull instancetype)initWithName:(nullable NSString *)name;
- (nonnull instancetype)initWithName:(nullable NSString *)name password:(nullable NSString *)password;
- (nonnull instancetype)initWithName:(nullable NSString *)name password:(nullable NSString *)password port:(NSUInteger)port;

/// Basic operations
- (void)startServer;
- (void)stopServer;

@end

/// Shairplay headers
void *_Nullable audio_init(void *_Nullable context , int bitsPerChannel, int channelsPerFrame, int sampleRate);
void audio_process(void *_Nullable context, void *_Nullable opaque, const void *_Nullable buffer, int bufferLength);
void audio_flush(void *_Nullable context, void *_Nullable session);
void audio_destroy(void *_Nullable context, void *_Nullable opaque);
void audio_remote_control_id(void *_Nullable context, const char *_Nullable dacpID, const char *_Nullable activeRemoteHeader);
void audio_set_volume(void *_Nullable context, void *_Nullable opaque, float volume);
void audio_set_metadata(void *_Nullable context, void *_Nullable session, const void *_Nullable buffer, int bufferLength);
void audio_set_coverart(void *_Nullable context, void *_Nullable session, const void *_Nullable buffer, int bufferLength);
void audio_set_progress(void *_Nullable context, void *_Nullable session, unsigned int start, unsigned int curr, unsigned int end);
