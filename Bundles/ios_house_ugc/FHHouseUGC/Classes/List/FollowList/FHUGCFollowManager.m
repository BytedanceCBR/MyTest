//
//  FHUGCFollowManager.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/16.
//

#import "FHUGCFollowManager.h"

@interface FHUGCFollowManager ()

@end

@implementation FHUGCFollowManager

+ (instancetype)sharedInstance {
    static FHUGCFollowManager *_sharedInstance = nil;
    if (!_sharedInstance) {
        _sharedInstance = [[FHUGCFollowManager alloc] init];
    }
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
