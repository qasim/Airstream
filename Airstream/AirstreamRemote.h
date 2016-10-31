//
//  AirstreamRemote.h
//  Airstream
//
//  Created by Qasim Iqbal on 10/31/16.
//  Copyright © 2016 Qasim Iqbal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AirstreamRemote : NSObject

@property (nonatomic, readonly) NSString *dacpID;
@property (nonatomic, readonly) NSString *activeRemoteHeader;

@property (nonatomic, readonly) NSString *hostName;
@property (nonatomic, readonly) NSInteger port;

- (instancetype)initWithHostName:(NSString *)hostName port:(NSUInteger)port dacpID:(NSString *)dacpID activeRemoteHeader:(NSString *)activeRemoteHeader;

/// Start playback
- (void)play;

/// Pause playback
- (void)pause;

/// Stop playback
- (void)stop;

/// Toggle between play and pause
- (void)playPause;

/// Play after fast forward or rewing
- (void)playResume;

/// Begin fast forward
- (void)forward;

/// Begin rewind
- (void)rewind;

/// Play next item in playlist
- (void)nextItem;

/// Play previous item in playlist
- (void)previousItem;

/// Shuffle playlist
- (void)shuffle;

/// Turn audio volume up
- (void)increaseVolume;

/// Turn audio volume down
- (void)decreaseVolume;

/// Toggle mute status
- (void)toggleMute;

@end
