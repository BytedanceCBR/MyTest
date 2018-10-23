//
//  ZDLoadingView.m
//  PullToRefreshControlDemo
//
//  Created by Nick Yu on 12/26/13.
//  Copyright (c) 2013 Zhang Kai Yu. All rights reserved.
//

#import "TTLoadingView.h"
#import "SSThemed.h"
#import "UIImage+TTThemeExtension.h"
#import "UIViewAdditions.h"


#define ArrowRotateAnimationDuration 0.18f

@interface TTLoadingView()

@property(nonatomic, strong)SSThemedImageView * iconImageView;
@property(nonatomic, assign)BOOL isLoading;
@property(nonatomic, strong)CABasicAnimation *rotateAnimation;
@property (nonatomic, strong)SSThemedImageView * arrowImage;
 
@end

@implementation TTLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _isLoading = NO;
    self.iconImageView = [[SSThemedImageView alloc] initWithImage:[UIImage themedImageNamed:@"loading.png"]];
    _iconImageView.imageName = @"loading.png";
    [_iconImageView sizeToFit];
    [self addSubview:_iconImageView];
    _iconImageView.center = CGPointMake(self.width / 2.f, self.height / 2.f);
    _iconImageView.hidden = YES;
    
    self.arrowImage = [[SSThemedImageView alloc] initWithImage:[UIImage themedImageNamed:@"dragrefresh_arrow.png"]];
    _arrowImage.imageName = @"dragrefresh_arrow.png";
    _arrowDirection = TTLoadingArrowDown;
    _arrowImage.transform = CGAffineTransformMakeRotation((180  * (float)M_PI) / 180.0f);
    [_arrowImage sizeToFit];
    [self addSubview:_arrowImage];
    _arrowImage.center = CGPointMake(self.width / 2.f, self.height / 2.f);
}

- (void)startLoading
{
    if(![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(startLoading) withObject:nil waitUntilDone:NO];
        return;
    }
    
    if(!_isLoading)
    {
        _iconImageView.hidden = NO;
        _arrowImage.hidden = YES;
        self.isLoading = YES;
        self.rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//        _rotateAnimation.delegate = self;
        _rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2];
        _rotateAnimation.duration = 1;
        _rotateAnimation.repeatCount = HUGE_VALF;
        [_iconImageView.layer addAnimation:_rotateAnimation forKey:@"rotateAnimation"];
    }
}

- (void)stopLoading
{
    if (!_isLoading) {
        return;
    }
    
    if(![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(stopLoading) withObject:nil waitUntilDone:NO];
        return;
    }
    [_iconImageView.layer removeAllAnimations];
    _isLoading = NO;
    _iconImageView.hidden = YES;
    //_arrowImage.hidden = NO;
}

- (void)setArrowDirection:(TTLoadingArrowDirectionType)arrowDirection
{
    if (arrowDirection != _arrowDirection && !_isLoading) {
        CGFloat arrowAngle;
        if (_arrowDirection == TTLoadingArrowDown) {
            arrowAngle = (180  * (float)M_PI) / 180.0f;
        } else if (_arrowDirection == TTLoadingArrowUp) {
            arrowAngle = (0  * (float)M_PI) / 180.0f;
        } else {
            return;
        }
        
        _arrowDirection = arrowDirection;
        if (_arrowImage.hidden) {
            _arrowImage.hidden = NO;
        }
        [UIView animateWithDuration:ArrowRotateAnimationDuration animations:^{
            _arrowImage.transform = CGAffineTransformMakeRotation(arrowAngle);
        }];
    }
}

@end
