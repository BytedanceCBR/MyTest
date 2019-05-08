//
//  TTVPlayerControlView.h
//  Article
//
//  Created by panxiang on 2017/5/16.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerControlTipView.h"
#import "TTMoviePlayerControlTopView.h"
#import "TTVPlayerControlBottomView.h"
#import "TTVPlayerControllerProtocol.h"
#import "ExploreMovieMiniSliderView.h"

@class TTVPlayerControlBottomView;

@interface TTVPlayerControlView : UIView<TTVPlayerViewControlView,TTVPlayerContext>
//protocol
@property(nonatomic, weak)NSObject <TTVPlayerControlViewDelegate> *delegate;
@property(nonatomic, strong)UIView <TTVPlayerControlBottomView, TTVPlayerContext> *bottomBarView;
@property(nonatomic, strong ,readonly)UIView *miniSlider;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, assign) UIEdgeInsets dimAreaEdgeInsetsWhenFullScreen;

- (void)setVideoTitle:(NSString *)title;
- (void)setVideoWatchCount:(NSInteger)watchCount playText:(NSString *)playText;
@end
