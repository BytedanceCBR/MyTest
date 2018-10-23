//
//  VideoLocalServer.h
//  Video
//
//  Created by 于 天航 on 12-8-16.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "HTTPServer.h"

@interface VideoLocalServer : HTTPServer

+ (VideoLocalServer *)localServer;
- (void)startLocalServer;

@end
