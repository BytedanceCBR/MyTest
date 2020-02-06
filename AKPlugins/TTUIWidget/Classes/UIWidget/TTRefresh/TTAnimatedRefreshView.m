//
//  TTAnimatedRefreshView.m
//  Article
//
//  Created by 梁浩 on 2019/7/24.
//

#import "TTAnimatedRefreshView.h"
#import <BDWebImage/BDImage.h>
#import <Masonry/Masonry.h>
#import <Lottie/LOTAnimationView.h>
#import <BDWebImage/BDImageView.h>
#import <ByteDanceKit/NSString+BTDAdditions.h>
#import <TTBaseLib/UIViewAdditions.h>


@interface TTAnimatedRefreshView ()

@property (nonatomic, strong) BDImageView *imageView;
@property (nonatomic, strong) LOTAnimationView *lotAnimationView;
@property (nonatomic, strong) LOTComposition *lotComposition;

@end

@implementation TTAnimatedRefreshView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageStyle = TTAnimatedRefreshStyleWideImage;
        self.backgroundColorThemeKey = kColorBackground20;
        [self buildViews];
    }
    return self;
}

- (void)buildViews {
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.bottom.equalTo(self);
    }];
}

- (BOOL)configureImageFilePath:(NSString *)imageFilePath lotComposition:(LOTComposition *)lotComposition width:(CGFloat)width height:(CGFloat)height {
    if (self.imageStyle == TTAnimatedRefreshStyleWideImage) {
        BDImage *image = [BDImage imageWithContentsOfFile:imageFilePath];
        if (image) {
            self.imageView.image = image;
            [self.imageView startAnimation];
            [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(width));
                make.height.equalTo(@(height));
            }];
            return YES;
        }
    } else if (self.imageStyle == TTAnimatedRefreshStyleWideLottie) {
        if (self.lotComposition == lotComposition) {
            [self.lotAnimationView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(width));
                make.height.equalTo(@(height));
            }];
            return YES;
        } else {
            self.lotComposition = lotComposition;
            [self initLottieAnimationViewWithLOTComposition:lotComposition];
            [self.lotAnimationView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(width));
                make.height.equalTo(@(height));
            }];
        }

        return YES;
    }

    return NO;
}

- (void)initLottieAnimationViewWithLOTComposition:(LOTComposition *)lotComposition {
    if (self.lotAnimationView.superview) {
        [self.lotAnimationView removeFromSuperview];
    }

    self.lotAnimationView = [[LOTAnimationView alloc] init];
    self.lotAnimationView.sceneModel = lotComposition;
    self.lotAnimationView.loopAnimation = NO;
    self.lotAnimationView.clipsToBounds = YES;
    self.lotAnimationView.contentMode = UIViewContentModeScaleAspectFit;

    [self addSubview:self.lotAnimationView];
    [self.lotAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.bottom.equalTo(self);
    }];
}

- (void)updateAnimationWithScrollOffset:(CGFloat)offset {
    if (self.imageStyle == TTAnimatedRefreshStyleWideLottie) {
        CGFloat refreshHeight = self.lotAnimationView.height;
        if (refreshHeight <= 0) {
            return;
        }
        CGFloat fractionDragged = MIN(1, -offset / refreshHeight);
        if (fractionDragged > 0) {
            self.lotAnimationView.loopAnimation = NO;
            CGFloat progress = fractionDragged * self.lottieThreshold / 100;
            if (progress > 1) {
                progress = 1;
            }
            self.lotAnimationView.animationProgress = progress;
        }
    }
}

- (void)startAnimation {
    if (self.imageStyle == TTAnimatedRefreshStyleWideImage) {
        [self.imageView startAnimation];
    } else {
        self.lotAnimationView.animationProgress = self.lottieThreshold * 1.0 / 100;
        self.lotAnimationView.loopAnimation = YES;
        [self.lotAnimationView playFromProgress:self.lottieThreshold * 1.0 / 100
                                     toProgress:1.0
                                 withCompletion:nil];
    }
}

- (void)stopAnimation {
    if (self.imageStyle == TTAnimatedRefreshStyleWideImage) {
        [self.imageView stopAnimation];
    } else {
        [self.lotAnimationView pause];
    }
}

- (void)setImageStyle:(TTAnimatedRefreshStyle)imageStyle {
    _imageStyle = imageStyle;

    self.imageView.hidden = !(self.imageStyle == TTAnimatedRefreshStyleWideImage);
    self.lotAnimationView.hidden = self.imageStyle == TTAnimatedRefreshStyleWideImage;
}

- (BDImageView *)imageView {
    if (!_imageView) {
        _imageView = [[BDImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

@end
