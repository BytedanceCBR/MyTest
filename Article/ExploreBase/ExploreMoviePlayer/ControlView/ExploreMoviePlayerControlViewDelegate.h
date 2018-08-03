//
//  ExploreMoviePlayerControlViewDelegate.h
//  Article
//
//  Created by panxiang on 2017/2/17.
//
//

#import <Foundation/Foundation.h>

@protocol ExploreMoviePlayerControlViewDelegate <NSObject>

@property (nonatomic) BOOL isFullScreenButtonAction;

- (void)controlViewRetryButtonClicked:(UIView *)controlView;
- (void)controlViewPlayButtonClicked:(UIView *)controlView replay:(BOOL)replay;
- (void)controlViewShareButtonClicked:(UIView *)controlView;
- (void)controlViewFullScreenButtonClicked:(UIView *)controlView;
- (void)controlView:(UIView *)controlView willAppear:(BOOL)appear;
- (void)controlView:(UIView *)controlView didAppear:(BOOL)appear;
- (void)controlViewWillDisappear:(UIView *)controlView;
- (void)controlViewResolutionButtonClicked:(UIView *)controlView ;
- (void)controlView:(UIView *)controlView touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
@optional
- (void)controlViewMoreButtonClicked:(UIView *)controlView;
- (void)controlViewShareActionClicked:(UIView *)controlView withActivityType:(NSString *)activityType;
- (BOOL)shouldControlViewHaveAdButton;
- (BOOL)movieHasFirstFrame;
@optional
// 播放上一个
- (void)controlViewPrePlayButtonClicked:(UIView *)controlView;

/**
 *  跳转进度
 *
 *  @param controlView 播放器
 *  @param progress    0 - 100
 */

- (void)controlView:(UIView *)controlView changeCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime totalTime:(NSTimeInterval)totalTime;

- (void)controlView:(UIView *)controlView seekProgress:(CGFloat)progress;

- (BOOL)controlViewCanRotate;

- (void)controlViewFullScreenLandscapeLeftRightRotate;

- (BOOL)controlViewShouldPauseWhenEnterForeground;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end

