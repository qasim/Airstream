//
//  Airstream.h
//  Airstream
//
//  Created by Qasim Iqbal on 10/29/16.
//  Copyright © 2016 Qasim Iqbal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>

#import <shairplay/dnssd.h>
#import <shairplay/raop.h>

#import <stdlib.h>
#import <stdio.h>
#import <math.h>
#import <string.h>
#import <unistd.h>
#import <assert.h>

static void *audio_init(void *context, int bitsPerChannel, int channelsPerFrame, int sampleRate);
static void audio_process(void *context, void *opaque, const void *buffer, int bufferLength);
static void audio_destroy(void *context, void *opaque);

static void audio_set_volume(void *context, void *opaque, float volume);
static void audio_set_metadata(void *context, void *session, const void *buffer, int bufferLength);
static void audio_set_coverart(void *context, void *session, const void *buffer, int bufferLength);
static void audio_set_progress(void *context, void *session, unsigned int start, unsigned int curr, unsigned int end);

@class Airstream;

@protocol AirstreamDelegate <NSObject>

@optional

- (void)airstream:(Airstream *)airstream willStartStreamingWithStreamFormat:(AudioStreamBasicDescription)streamFormat;
- (void)airstreamWillStopStreaming:(Airstream *)airstream;

- (void)airstream:(Airstream *)airstream processAudio:(const void *)buffer length:(int)length;

- (void)airstream:(Airstream *)airstream didSetVolume:(float)volume;
- (void)airstream:(Airstream *)airstream didSetMetaData:(NSDictionary<NSString *, NSString *> *)metaData;
- (void)airstream:(Airstream *)airstream didSetCoverArt:(NSData *)coverArt;
- (void)airstream:(Airstream *)airstream didSetPosition:(NSUInteger)position duration:(NSUInteger)duration;

@end

@interface Airstream : NSObject

@property (nonatomic, weak) id <AirstreamDelegate> delegate;

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *password;
@property (nonatomic) NSUInteger port;

@property (nonatomic) NSUInteger bitsPerChannel;
@property (nonatomic) NSUInteger channelsPerFrame;
@property (nonatomic) NSUInteger sampleRate;

@property (nonatomic) float volume;
@property (nonatomic) NSDictionary<NSString *, NSString *> *metaData;
@property (nonatomic) NSData *coverArt;

@property (nonatomic) NSUInteger position;
@property (nonatomic) NSUInteger duration;

@property (nonatomic) BOOL running;

@end
