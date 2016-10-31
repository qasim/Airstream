//
//  AirstreamRemote.m
//  Airstream
//
//  Created by Qasim Iqbal on 10/31/16.
//  Copyright © 2016 Qasim Iqbal. All rights reserved.
//

#import "AirstreamRemote.h"

@interface AirstreamRemote ()

@property (nonatomic, readwrite) NSString *dacpID;
@property (nonatomic, readwrite) NSString *activeRemoteHeader;

@property (nonatomic, readwrite) NSString *hostName;
@property (nonatomic, readwrite) NSInteger port;

@end

@implementation AirstreamRemote

- (instancetype)initWithHostName:(NSString *)hostName port:(NSUInteger)port dacpID:(NSString *)dacpID activeRemoteHeader:(NSString *)activeRemoteHeader {
  self = [super init];

  if (!self) {
    return nil;
  }

  self.hostName = hostName;
  self.port = port;
  self.dacpID = dacpID;
  self.activeRemoteHeader = activeRemoteHeader;

  return self;
}

- (void)sendCommand:(NSString *)command {
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%lu/ctrl-int/1/%@", self.hostName, self.port, command]];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

  [request setHTTPMethod:@"GET"];
  [request addValue:self.activeRemoteHeader forHTTPHeaderField:@"Active-Remote"];

  NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];

  NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
      NSLog(@"Error: Could not perform remote command %@", error);
    }
  }];

  [dataTask resume];
}

- (void)play {
  [self sendCommand:@"play"];
}

- (void)pause {
  [self sendCommand:@"pause"];
}

- (void)stop{
  [self sendCommand:@"stop"];
}

- (void)playPause {
  [self sendCommand:@"playpause"];
}

- (void)playResume{
  [self sendCommand:@"playresume"];
}

- (void)forward {
  [self sendCommand:@"beginff"];
}

- (void)rewind {
  [self sendCommand:@"beginrew"];
}

- (void)nextItem {
  [self sendCommand:@"nextitem"];
}

- (void)previousItem {
  [self sendCommand:@"previtem"];
}

- (void)shuffle {
  [self sendCommand:@"shuffle_songs"];
}

- (void)increaseVolume {
  [self sendCommand:@"volumeup"];
}

- (void)decreaseVolume {
  [self sendCommand:@"volumedown"];
}

- (void)toggleMute {
  [self sendCommand:@"mutetoggle"];
}

@end
