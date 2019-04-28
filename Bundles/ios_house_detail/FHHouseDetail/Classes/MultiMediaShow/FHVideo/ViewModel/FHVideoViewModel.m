//
//  FHVideoViewModel.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/16.
//

#import "FHVideoViewModel.h"

@interface FHVideoViewModel ()

@property(nonatomic, strong) FHVideoView *view;
@property(nonatomic, weak) FHVideoViewController *viewController;
@property(nonatomic, weak) TTVPlayer *player;

@end

@implementation FHVideoViewModel

- (instancetype)initWithView:(FHVideoView *)view controller:(FHVideoViewController *)viewController player:(nonnull TTVPlayer *)player {
    self = [super init];
    if (self) {
        _view = view;
        _viewController = viewController;
        _player = player;
    }
    return self;
}

- (void)didFinishedWithStatus:(TTVPlayFinishStatus *)finishStatus {
    //用户正常停止播放视频
    if(!finishStatus.playError){
        self.view.coverView.hidden = NO;
        [self.view bringSubviewToFront:self.view.coverView];
    }
}

@end
