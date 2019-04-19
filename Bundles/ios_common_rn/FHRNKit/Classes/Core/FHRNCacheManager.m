//
//  FHRNCacheManager.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/4/19.
//

#import "FHRNCacheManager.h"

@interface FHRNCacheManager()
@end

@implementation FHRNCacheManager

+(instancetype)sharedInstance
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (void)addObjectCountforChannel:(NSString *)channel
{
    if ([channel isKindOfClass:[NSString class]]) {
        if (!_channelCache) {
            _channelCache = [NSMutableDictionary new];
        }
        NSNumber *countNum = _channelCache[channel];
        if ([countNum isKindOfClass:[NSNumber class]]) {
            NSInteger count = [countNum integerValue];
            count ++;
            [_channelCache setValue:@(count) forKey:channel];
        }else
        {
            [_channelCache setValue:@(1) forKey:channel];
        }
    }
    
}

- (void)removeCountChannel:(NSString *)channel
{
    if ([channel isKindOfClass:[NSString class]]) {
        if (!_channelCache) {
            _channelCache = [NSMutableDictionary new];
        }
        NSNumber *countNum = _channelCache[channel];
        if ([countNum isKindOfClass:[NSNumber class]]) {
            NSInteger count = [countNum integerValue];
            count --;
            if (count < 0) {
                count = 0;
            }
            [_channelCache setValue:@(count) forKey:channel];
        }else
        {
            [_channelCache setValue:@(0) forKey:channel];
        }
    }
}

- (BOOL)isNeedCleanCacheForChannel:(NSString *)channel
{
    NSNumber *countNum = _channelCache[channel];
    if ([countNum isKindOfClass:[NSNumber class]]) {
        return countNum.integerValue <= 0;
    }
    return YES;
}

@end
