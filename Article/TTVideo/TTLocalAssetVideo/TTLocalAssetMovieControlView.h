//
//  TTLocalAssetMovieControlView.h
//  Article
//
//  Created by xiangwu on 2016/12/8.
//
//

#import <UIKit/UIKit.h>
@class TTLocalAssetMovieControlView;

@protocol TTLocalAssetMovieControlViewDelegate <NSObject>

- (void)controlViewDidPressPlayButton:(TTLocalAssetMovieControlView *)controlView;
- (void)controlViewWillExitFullScreen:(TTLocalAssetMovieControlView *)controlView;
- (void)controlView:(TTLocalAssetMovieControlView *)controlView isSeekingToProgress:(CGFloat)progress totalTime:(NSTimeInterval)totalTime;
- (void)controlView:(TTLocalAssetMovieControlView *)controlView didSeekToProgress:(CGFloat)progress totalTime:(NSTimeInterval)totalTime;

@end

@interface TTLocalAssetMovieControlView : UIView

@property (nonatomic, weak) id<TTLocalAssetMovieControlViewDelegate> delegate;

- (void)setWatchedProgress:(CGFloat)progress;
- (void)setCachedProgress:(CGFloat)progress;
- (void)setTotalTime:(NSTimeInterval)totalTime;
- (void)updateTimeLabel:(NSString *)time durationLabel:(NSString *)duration;
- (void)refreshPlayButton:(BOOL)isPlaying;
- (void)refreshSliderFrame;

@end
