//
//  TTMovieAdjustView.h
//  Article
//
//  Created by songxiangwu on 16/9/20.
//
//

#import <UIKit/UIKit.h>
#import "TTMovieProgressSliderView.h"
@class SSThemedLabel;

typedef NS_ENUM(NSUInteger, TTMovieAdjustViewType) {
    TTMovieAdjustViewTypeProgress = 0,
    TTMovieAdjustViewTypeBrightness,
};

typedef NS_ENUM(NSUInteger, TTMovieAdjustViewMode) {
    TTMovieAdjustViewModeFullScreen = 0,
    TTMovieAdjustViewModeDetail,
};

@interface TTMovieAdjustView : UIView

@property (nonatomic, assign) TTMovieAdjustViewType type;
@property (nonatomic, assign) TTMovieAdjustViewMode mode;
@property (nonatomic, assign) NSInteger totalTime;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) SSThemedLabel *progressLabel;
@property (nonatomic, strong) TTMovieProgressSliderView *sliderView;

- (void)setProgressPercentage:(CGFloat)progressPercentage isIncrease:(BOOL)isIncrease type:(TTMovieAdjustViewType)type;
+ (CGFloat)heightWithMode:(TTMovieAdjustViewMode)mode;

@end
