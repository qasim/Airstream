//
//  AppDelegate.m
//  Airstream iOS Example
//
//  Created by Qasim Iqbal on 10/30/16.
//  Copyright © 2016 Qasim Iqbal. All rights reserved.
//

#import "AppDelegate.h"

@import Airstream;

@interface AppDelegate ()

@property (nonatomic) Airstream *airstream;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.airstream = [[Airstream alloc] init];
  [self.airstream startServer];

  return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
  [self.airstream stopServer];
}

@end
