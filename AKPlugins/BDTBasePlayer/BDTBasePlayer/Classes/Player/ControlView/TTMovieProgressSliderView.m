//
//  TTMovieProgressSliderView.m
//  Article
//
//  Created by songxiangwu on 16/9/20.
//
//

#import "TTMovieProgressSliderView.h"
#import "SSThemed.h"

@interface TTMovieProgressSliderView ()

@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, assign) CGFloat progressPercentage;

@end

@implementation TTMovieProgressSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIColor *color = [UIColor tt_defaultColorForKey:kColorBackground6];
        self.backgroundColor = [color colorWithAlphaComponent:0.8];
        self.layer.cornerRadius = 1;
        self.layer.masksToBounds = YES;
        
        _progressView = [[UIView alloc] init];
        color = [UIColor tt_defaultColorForKey:kColorBackground7];
        _progressView.backgroundColor = [color colorWithAlphaComponent:0.8];
        _progressView.layer.cornerRadius = 1;
        _progressView.layer.masksToBounds = YES;
        [self addSubview:_progressView];
    }
    return self;
}

- (void)setProgressPercentage:(CGFloat)progressPercentage {
    if (progressPercentage > 1) {
        progressPercentage = 1;
    }
    _progressPercentage = progressPercentage;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.frame.size.width * _progressPercentage;
    CGFloat h = self.frame.size.height;
    _progressView.frame = CGRectMake(0, 0, w, h);
}

@end
