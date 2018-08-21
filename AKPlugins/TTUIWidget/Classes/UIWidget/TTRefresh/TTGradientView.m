//
//  TTGradientView.m
//  TestUniversaliOS6
//
//  Created by yuxin on 3/31/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import "TTGradientView.h"
#import "SSThemed.h"
#import <Lottie/Lottie.h>
@interface TTGradientView ()

@property (nonatomic, strong)LOTAnimationView       *loadingView;

@end

@implementation TTGradientView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if(newSuperview) {
        [self setUpLayers];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [self startAnimation];
}

- (void)setUpLayers
{
    NSString *bundlePath = [[NSBundle mainBundle]
                            pathForResource:@"TTUIWidgetResources" ofType:@"bundle"];
    if (bundlePath) {
        NSBundle *bunle = [NSBundle bundleWithPath:bundlePath];
        LOTAnimationView *loadingView = [LOTAnimationView animationNamed:@"loading.json" inBundle:bunle];
        loadingView.frame = self.bounds;
        loadingView.contentMode = UIViewContentModeScaleAspectFit;
        loadingView.loopAnimation = YES;
        [self addSubview:loadingView];
        self.loadingView = loadingView;
    }
    
    [self startAnimation];
    
}

- (void)startAnimation {
    [self.loadingView play];
}


@end
