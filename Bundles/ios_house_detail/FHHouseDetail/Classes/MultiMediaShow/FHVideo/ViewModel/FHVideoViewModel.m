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

@end

@implementation FHVideoViewModel

- (instancetype)initWithView:(FHVideoView *)view controller:(FHVideoViewController *)viewController {
    self = [super init];
    if (self) {
        _view = view;
        _viewController = viewController;
    }
    return self;
}

- (void)didFinishedWithStatus:(TTVPlayFinishStatus *)finishStatus {
    //用户正常停止播放视频
    if(!finishStatus.playError){
        [self showCoverView];
    }
}

- (void)hideCoverView {
    if(self.view.coverView.alpha == 1){
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.view.coverView.alpha = 0;
        } completion:^(BOOL finished) {
            self.view.coverView.alpha = 0;
            self.view.coverView.coverView.hidden = YES;
        }];
    }
}

- (void)showCoverView {
    self.view.coverView.coverView.hidden = NO;
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.coverView.alpha = 1;
    } completion:^(BOOL finished) {
        self.view.coverView.alpha = 1;
        [self.view bringSubviewToFront:self.view.coverView];
    }];
}

- (void)showCoverViewStartBtn {
    self.view.coverView.alpha = 1;
}

- (void)hideCoverViewStartBtn {
//    self.view.coverView.alpha = 0;
}

@end
