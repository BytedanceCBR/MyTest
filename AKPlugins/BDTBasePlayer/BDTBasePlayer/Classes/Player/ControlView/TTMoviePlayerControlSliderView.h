//
//  TTMoviePlayerControlSliderView.h
//  Article
//
//  Created by xiangwu on 2016/12/28.
//
//

#import <UIKit/UIKit.h>
@class TTMoviePlayerControlSliderView;

@protocol TTMoviePlayerControlSliderViewDelegate <NSObject>

@required
- (void)sliderWatchedProgressWillChange:(TTMoviePlayerControlSliderView *)slider;
- (void)sliderWatchedProgressChanging:(TTMoviePlayerControlSliderView *)slider;
- (void)sliderWatchedProgressChanged:(TTMoviePlayerControlSliderView *)slider;

@end

@interface TTMoviePlayerControlSliderView : UIView
@property (nonatomic, strong) UIView *watchedProgressView;
@property (nonatomic, strong) UIView *cacheProgressView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *thumbView;
@property (nonatomic, assign) CGFloat cacheProgress;
@property (nonatomic, assign) CGFloat watchedProgress;
@property (nonatomic, assign) BOOL enableDrag;
@property (nonatomic, assign) BOOL duringDrag;
@property (nonatomic, assign) BOOL isFull;

@property (nonatomic, weak) id<TTMoviePlayerControlSliderViewDelegate> delegate;

- (void)updateFrame;

@end
