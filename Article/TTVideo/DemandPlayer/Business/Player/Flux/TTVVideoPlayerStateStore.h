//
//  TTVVideoPlayerStateStore.h
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import "TTVPlayerStateStore.h"
#import "TTVVideoPlayerStateModel.h"
@interface TTVVideoPlayerStateStore : TTVPlayerStateStore
@property (nonatomic, strong, readonly) TTVVideoPlayerStateModel *state;
@end
