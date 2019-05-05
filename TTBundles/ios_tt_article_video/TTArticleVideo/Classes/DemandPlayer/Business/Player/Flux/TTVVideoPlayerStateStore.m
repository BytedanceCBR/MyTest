//
//  TTVPlayerStateStore.m
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVVideoPlayerStateStore.h"
#import "TTVVideoPlayerStateModel.h"
#import "TTVPlayerStateAction.h"
#import "TTVPlayerSettingUtility.h"

@interface TTVVideoPlayerStateStore ()
@property (nonatomic, strong) TTVVideoPlayerStateModel *state;
@end

@implementation TTVVideoPlayerStateStore
@dynamic state;

- (TTVVideoPlayerStateModel *)defaultState
{
    TTVVideoPlayerStateModel *model = [[TTVVideoPlayerStateModel alloc] init];
    return model;
}

@end
