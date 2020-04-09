//
//  FHVRCacheManager.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/8.
//

#import "FHVRCacheManager.h"

@interface FHVRCacheManager()
@property(nonatomic,assign)NSInteger hashCode;
@end

@implementation FHVRCacheManager

+(instancetype)sharedInstance{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (BOOL)isCanCacheVRPreload
{
    if (self.currentVRPreloadCount < 0) {
        self.currentVRPreloadCount  = 0;
    }
    return self.currentVRPreloadCount <= 0;
}

- (void)addVRPreloadCache:(NSInteger)hashCode{
    self.hashCode = hashCode;
    self.currentVRPreloadCount += 1;
}

- (void)removeVRPreloadCache:(NSInteger)hashCode{
    if (self.hashCode == hashCode) {
        self.currentVRPreloadCount -= 1;
    }
}
@end
