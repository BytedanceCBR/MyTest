//
//  HTSVideoPlayUserInfoManager.h
//  LiveStreaming
//
//  Created by Quan Quan on 16/2/28.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTSVideoPlayUserModel.h"
@class AWEUserModel;

@interface AWEVideoUserInfoManager : NSObject

/**
 *  @param userId 将作为请求参数上报
 */
+ (void)followUser:(NSString *)userId completion:(void(^)(AWEUserModel *user, NSError *error))block;

/**
 *  @param userId 将作为请求参数上报
 */
+ (void)unfollowUser:(NSString *)userId completion:(void(^)(AWEUserModel *user, NSError *error))block;

@end
