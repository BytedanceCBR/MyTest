//
// Created by zhulijun on 2019-06-14.
//

#import <Foundation/Foundation.h>

@protocol FHUGCFollowObserver

@optional

-(void)onFollowStatusChange:(NSString *)communityId followStatus:(BOOL)followStatus;

@end

@interface FHUGCFollowHelper : NSObject
+(void)registerFollowStatusObserver:(id<FHUGCFollowObserver>) observer;

+(void)unregisterFollowStatusObserver:(id<FHUGCFollowObserver>) observer;

+(void)followCommunity:(NSString *)communityId userInfo:(NSDictionary *)userInfo;
@end

