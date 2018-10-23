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

@property (nonatomic,strong)  SSThemedImageView *image1;
@property (nonatomic,strong)  SSThemedImageView *image2;
@property (nonatomic,strong)  UIImageView *maskImage;
@property (nonatomic,assign)  SSThemeMode themeMode;
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

//- (void)willMoveToSuperview:(UIView *)newSuperview
//{
//    [super willMoveToSuperview:newSuperview];
//    if(newSuperview) {
//        [self setUpLayers];
//    }
//}
//
//- (void)willMoveToWindow:(UIWindow *)newWindow {
//    SSThemeMode newMode = SSThemeModeNone;
//    if ([self.superview isKindOfClass:[SSThemedView class]]) {
//        newMode = ((SSThemedView *)self.superview).themeMode;
//    }
//    if (newWindow && self.themeMode != newMode) {
//        self.themeMode = ((SSThemedView *)self.superview).themeMode;
//        [self changeImagesIfNeeded];
//    }
//    [self startAnimation];
//}

//- (void)setUpLayers
//{
//    if (!self.image1 && ![self.image1 isDescendantOfView:self]) {
//        self.image1 = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 120)];
//        self.image1.contentMode = UIViewContentModeScaleToFill;
//        [self addSubview:self.image1];
//    }
//
//    if (!self.image2 && ![self.image2 isDescendantOfView:self]) {
//        self.image2 = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 120)];
//        self.image2.contentMode = UIViewContentModeScaleToFill;
//
//
//        self.maskImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 120)];
//        self.maskImage.contentMode = UIViewContentModeScaleToFill;
//        self.maskImage.image =[UIImage imageNamed:@"details_slogan03"] ;
//        self.image2.layer.mask = self.maskImage.layer;
//
//        [self addSubview:self.image2];
//
//        self.themeMode = SSThemeModeNone;
//        [self changeImagesIfNeeded];
//    }
//
//    [self startAnimation];
//
//}
//
//- (void)startAnimation {
//    if([self.maskImage.layer animationForKey:@"loading"]) {
//        [self.maskImage.layer removeAnimationForKey:@"loading"];
//    }
//
//    NSArray *values = @[
//                        [NSNumber numberWithFloat:0.f],
//                        [NSNumber numberWithFloat:170.f],
//                        [NSNumber numberWithFloat:170.f]
//                        ];
//
//    //UE想要的效果：扫描动画时间800ms 停顿时间400ms
//    NSArray *keyTimes = @[
//                          [NSNumber numberWithFloat:0.f],
//                          [NSNumber numberWithFloat:0.667f],
//                          [NSNumber numberWithFloat:1.f],
//                          ];
//
//    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
//    [animation setValues:values];
//    [animation setKeyTimes:keyTimes];
//    [animation setCalculationMode:kCAAnimationLinear];
//    [animation setDuration:1.2f];
//    animation.repeatCount = CGFLOAT_MAX;
//    [self.maskImage.layer addAnimation:animation forKey:@"loading"];
//}
//
//- (void)changeImagesIfNeeded {
//    switch (self.themeMode) {
//        case SSThemeModeNone:
//            self.image1.imageName = @"details_slogan01";
//            break;
//        case SSThemeModeAlwaysDay:
//            self.image1.imageName = nil;
//            self.image1.image = [UIImage imageNamed:@"details_slogan01"];
//            break;
//        case SSThemeModeAlwaysNight:
//            self.image1.imageName = nil;
//            self.image1.image = [UIImage imageNamed:@"details_slogan01_night"];
//            break;
//        default:
//            self.image1.imageName = @"details_slogan01";
//            break;
//    }
//
//    switch (self.themeMode) {
//        case SSThemeModeNone:
//            self.image2.imageName = @"details_slogan01";
//            break;
//        case SSThemeModeAlwaysDay:
//            self.image2.imageName = nil;
//            self.image2.image = [UIImage imageNamed:@"details_slogan01"];
//            break;
//        case SSThemeModeAlwaysNight:
//            self.image2.imageName = nil;
//            self.image2.image = [UIImage imageNamed:@"details_slogan01_night"];
//            break;
//        default:
//            self.image2.imageName = @"details_slogan01";
//            break;
//    }
//}


@end
