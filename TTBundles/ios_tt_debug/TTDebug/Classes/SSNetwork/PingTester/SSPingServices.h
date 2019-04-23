//
//  SSPingServices.h
//  STKitDemo
//
//  Created by SunJiangting on 15-3-9.
//  Copyright (c) 2015年 SunJiangting. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimplePing.h"

typedef NS_ENUM(NSInteger, SSPingStatus) {
    SSPingStatusDidStart,
    SSPingStatusDidReceivePacket,
    SSPingStatusDidTimeout,
    SSPingStatusFinished,
};

@interface SSPingItem : NSObject

@property(nonatomic) NSString *originalAddress;
@property(nonatomic, copy) NSString *IPAddress;

@property(nonatomic) NSUInteger dateBytesLength;
@property(nonatomic) double     timeMilliseconds;
@property(nonatomic) NSInteger  timeToLive;
@property(nonatomic) NSInteger  ICMPSequence;

@property(nonatomic) SSPingStatus status;

+ (NSString *)statisticsWithPingItems:(NSArray *)pingItems;

@end

@interface SSPingServices : NSObject

/// 超时时间, default 500ms
@property(nonatomic) double timeoutMilliseconds;

+ (SSPingServices *)startPingAddress:(NSString *)address
                      callbackHandler:(void(^)(SSPingItem *pingItem, NSArray *pingItems))handler;

+ (void)getIPAddressWithDomain:(NSString *)domain completionHandler:(void(^)(NSString *IPAddress, NSInteger errorNumber))completionHandler;

@property(nonatomic) NSUInteger  maximumPingTimes;
- (void)cancel;

@end
