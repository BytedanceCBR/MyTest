//
//  TTVPlayerModel.m
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVVideoPlayerModel.h"

@implementation TTVVideoPlayerModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.enableCommonTracker = YES;
        self.enableChangeResolutionAlert = YES;
    }
    return self;
}
@end
