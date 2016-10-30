//
//  AppDelegate.h
//  Airstream iOS Example
//
//  Created by Qasim Iqbal on 10/30/16.
//  Copyright © 2016 Qasim Iqbal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@import Airstream;

@interface AppDelegate : UIResponder <UIApplicationDelegate, AirstreamDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

/// Callback for AudioUnit streaming to output device
OSStatus OutputRenderCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData);
