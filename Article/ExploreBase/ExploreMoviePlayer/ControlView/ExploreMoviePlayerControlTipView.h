//
//  ExploreMoviePlayerControlTipView.h
//  Article
//
//  Created by Chen Hong on 15/9/21.
//
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, ExploreMoviePlayerControlViewTipType)
{
    ExploreMoviePlayerControlViewTipTypeNotAssign = 0,
    ExploreMoviePlayerControlViewTipTypeLoading,
    ExploreMoviePlayerControlViewTipTypeRetry,
    ExploreMoviePlayerControlViewTipTypeLiveWaiting,
    ExploreMoviePlayerControlViewTipTypeLiveOver
};

@class ExploreMovieLoadingView;
@class ExploreMoviePlayerControlView;

@interface ExploreMoviePlayerControlTipView : UIView
{
    ExploreMoviePlayerControlViewTipType _tipType;
}
@property(nonatomic, strong) UIImageView *liveImageView;
@property(nonatomic, strong)UILabel *liveTipLabel;
@property(nonatomic, strong)UIButton *retryButton;
@property(nonatomic, strong)UILabel *retryLabel;
@property(nonatomic, assign)ExploreMoviePlayerControlViewTipType tipType;
@property(nonatomic, assign)BOOL isFullScreen;
@property(nonatomic, strong)ExploreMovieLoadingView * loadingView;
@property(nonatomic, weak)UIView * movieControlView;
@property(nonatomic, strong)UIView *backView;
@property(nonatomic, assign)BOOL forbidLayout;

- (ExploreMoviePlayerControlViewTipType)tipType;
- (BOOL)hasTipType;
- (void)showTipView:(ExploreMoviePlayerControlViewTipType)type;
- (void)showTipView:(ExploreMoviePlayerControlViewTipType)type andTipString:(NSString *)tipString;

- (void)dismissTipViewAnimation;
- (BOOL)hasShowTipView;
- (void)updateFrame;

@end
