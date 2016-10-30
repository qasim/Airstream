//
//  AppDelegate.m
//  Airstream macOS Example
//
//  Created by Qasim Iqbal on 10/30/16.
//  Copyright © 2016 Qasim Iqbal. All rights reserved.
//

#import "AppDelegate.h"

@import Airstream;

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic) Airstream *airstream;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  self.airstream = [[Airstream alloc] init];
  self.airstream.name = @"My AirPlay Server";

  [self.airstream startServer];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  [self.airstream stopServer];
}

@end
