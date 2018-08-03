//
//  VideoLocalServer.m
//  Video
//
//  Created by 于 天航 on 12-8-16.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoLocalServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface VideoLocalServer ()

@end


@implementation VideoLocalServer

static VideoLocalServer *_localServer = nil;
+ (VideoLocalServer *)localServer
{
    @synchronized(self) {
        if (!_localServer) {
            _localServer = [[self alloc] init];
        }
    }
    return _localServer;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Configure our logging framework.
        // To keep things simple and fast, we're just going to log to the Xcode console.
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        // Tell the server to broadcast its presence via Bonjour.
        // This allows browsers such as Safari to automatically discover our service.
        [self setType:@"_http._tcp."];
        
        // Normally there's no need to run our server on any specific port.
        // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
        // However, for easy testing you may want force a certain port so you can just hit the refresh button.
        [self setPort:SSLogicIntNODefault(@"vlHTTPServerPort")];
        
        // Serve files from our embedded Web folder
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDirectory = [paths objectAtIndex:0];
        [self setDocumentRoot:docDirectory];
    }
    return self;
}

- (void)startLocalServer
{
    if (_localServer) {
        // Start the server (and check for problems)
        NSError *error;
        
        if([_localServer start:&error]) {
            DDLogInfo(@"Started HTTP Server on port %hu", [_localServer listeningPort]);
        }
        else {
            DDLogError(@"Error starting HTTP Server: %@", error);
        }
    }
}

@end
