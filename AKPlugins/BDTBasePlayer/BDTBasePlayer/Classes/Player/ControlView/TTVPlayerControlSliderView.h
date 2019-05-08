//
//  TTMoviePlayerControlSliderView.h
//  Article
//
//  Created by xiangwu on 2016/12/28.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerControllerProtocol.h"
@class TTVPlayerControlSliderView;

@protocol TTVPlayerControlSliderViewDelegate <NSObject>

@required
- (void)sliderWatchedProgressWillChange:(TTVPlayerControlSliderView *)slider;
- (void)sliderWatchedProgressChanging:(TTVPlayerControlSliderView *)slider;
- (void)sliderWatchedProgressChanged:(TTVPlayerControlSliderView *)slider;

@end

@interface TTVPlayerControlSliderView : UIView<TTVPlayerContext>
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, strong ,readonly) UIView *watchedProgressView;
@property (nonatomic, strong ,readonly) UIView *cacheProgressView;
@property (nonatomic, strong ,readonly) UIView *backView;
@property (nonatomic, strong ,readonly) UIView *thumbView;
@property (nonatomic, strong ,readonly) UIView *pointView;
@property (nonatomic, assign) CGFloat cacheProgress;
@property (nonatomic, assign) CGFloat watchedProgress;
@property (nonatomic, assign) BOOL enableDrag;
@property (nonatomic, assign) BOOL duringDrag;
@property (nonatomic, assign) BOOL isFull;

@property (nonatomic, weak) id<TTVPlayerControlSliderViewDelegate> delegate;

- (void)updateFrame;

@end
