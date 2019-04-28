//
//  TTVPlayerFullScreenState.m
//  TTVPlayer
//
//  Created by lisa on 2019/1/13.
//

#import "TTVFullScreenState.h"

@implementation TTVFullScreenState

- (instancetype)copyWithZone:(NSZone *)zone {
    TTVFullScreenState * copy = [TTVFullScreenState allocWithZone:zone];
    copy.fullScreen = self.isFullScreen;
    return copy;
}

@end
