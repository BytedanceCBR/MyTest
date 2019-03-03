//
//  TTAdCanvasViewController.m
//  Article
//
//  Created by yin on 2017/1/4.
//
//

#import "TTAdCanvasViewController.h"

#import "SSAppStore.h"
#import "TTAdCanvasManager.h"
#import "TTAdCanvasModel.h"
#import "TTAdCanvasNavigationBar.h"
#import "TTAdCanvasTracker.h"
#import "TTImageView.h"
//#import "TTRNBridge+Call.h"
//#import "TTRNView.h"
#import "TTRoute.h"
#import "UIView+CustomTimingFunction.h"
#import "UIViewController+NavigationBarStyle.h"
#import <AVFoundation/AVFoundation.h>

NSString * const kTTAdCanvasNotificationViewDidDisappear   = @"kTTAdCanvasNotificationViewDidDisappear";

@interface TTAdCanvasViewController ()

@property (nonatomic, strong) TTAdCanvasNavigationBar *naviView;

@property (nonatomic, strong) NSDictionary *baseCondition;
@property (nonatomic, strong) UIView *screenShotView;

@property (nonatomic, assign) BOOL loadRnEnd;
@property (nonatomic, assign) BOOL animateStart;
@property (nonatomic, assign) BOOL animateEnd;

//@property (nonatomic, strong) TTRNView *rnView;
@property (nonatomic, assign) UIEdgeInsets safeEdgeInsets;

@end

@implementation TTAdCanvasViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.baseCondition = paramObj.allParams;
        [self buildup];
    }
    return self;
}

- (instancetype)initWithViewModel:(TTAdCanvasViewModel *)viewModel {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.viewModel = viewModel;
        [self buildup];
    }
    return self;
}

- (void)buildup {
    self.hidesBottomBarWhenPushed = YES;
    self.loadRnEnd = NO;
    self.animateStart = NO;
    self.animateEnd = NO;
    
    if (@available(iOS 11.0, *)) {
        self.safeEdgeInsets = [UIApplication sharedApplication].keyWindow.safeAreaInsets;
    } else {
        self.safeEdgeInsets = UIEdgeInsetsZero;
    }
}

- (void)dealloc {
    [self.tracker wap_staypage];
    [self.tracker trackLeave];
//    [_rnView removeFromSuperview];
    [[TTAdCanvasManager sharedManager] destroyRNView];
}

#pragma mark --life cyle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustormNavigationBar];
    [self reloadState:self.viewModel];
    
    if (self.viewModel.animationStyle != TTAdCanvasOpenAnimationPush) {
        [self setShotScreen];
        [self showStartAnimation];
    } else {
        [self commitShowRNViewAnimation];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTAdCanvasVideoNotificationResume object:nil];
    [self.tracker wap_load];
    [self addNotification];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTAdCanvasVideoNotificationPause object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTAdCanvasNotificationViewDidDisappear object:nil];
    [self removeNotification];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    });
}

- (void)reloadState:(TTAdCanvasViewModel *)viewModel {
    if (viewModel == nil) {
        return;
    }
//    [self.rnView removeFromSuperview];
//
//    self.rnView = [[TTAdCanvasManager sharedManager] createRNView];
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    [props setValue:self.viewModel.layoutInfo forKey:@"json"];
    [props setValue:self.viewModel.adInfo forKey:@"adInfo"];
    [props setValue:self.viewModel.createFeedData forKey:@"createFeedData"];
//    [self.rnView loadModule:kTTAdCanvasReatModule initialProperties:props];
//    [self.view addSubview:self.rnView];
//    self.rnView.hidden = self.viewModel.animationStyle != TTAdCanvasOpenAnimationPush;
//    WeakSelf;
//    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
//        StrongSelf;
//        self.loadRnEnd = YES;
//        if (self.animateStart && !self.animateEnd) {
//            [self commitShowRNViewAnimation];
//        }
//        [self.tracker wap_loadfinish];
//        [self.tracker native_page];
//    } forMethod:@"load_finish_ad"];
    
//    if (self.viewModel.rootViewColor != nil) {
//        self.rnView.backgroundColor = self.viewModel.rootViewColor;
//    }
    
    [self.view bringSubviewToFront:self.naviView];
}

- (void)setShotScreen {
    UITabBarController *tabBarController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if (tabBarController&&[tabBarController isKindOfClass:[UITabBarController class]]) {
        self.screenShotView = [tabBarController.view snapshotViewAfterScreenUpdates:NO];
        [self.view  addSubview:self.screenShotView];
        [self.view sendSubviewToBack:self.screenShotView];
    }
}

- (void)createCustormNavigationBar {
    self.ttHideNavigationBar = YES;
    
    UIEdgeInsets safeEdgeInset = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeEdgeInset = self.view.safeAreaInsets;
    }
    CGFloat width = self.view.width - safeEdgeInset.left - safeEdgeInset.right;
    self.naviView = [[TTAdCanvasNavigationBar alloc] initWithFrame:CGRectMake(safeEdgeInset.left, safeEdgeInset.top, width, kNavigationBarHeight)];
    [self.view addSubview:self.naviView];
    
    
    self.naviView.leftButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    self.naviView.leftButton.enableNightMask = NO;
    self.naviView.leftButton.imageName = @"photo_detail_titlebar_close";
    [self.naviView.leftButton addTarget:self action:@selector(closeButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.naviView.rightButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    self.naviView.rightButton.enableNightMask = NO;
    self.naviView.rightButton.imageName = @"new_morewhite_titlebar";
    self.naviView.rightButton.enableNightMask = NO;
    [self.naviView.rightButton addTarget:self action:@selector(shareTouched:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -- 布局显示相关
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIEdgeInsets safeEdgeInset = self.safeEdgeInsets;
    CGFloat width = self.view.width - safeEdgeInset.left - safeEdgeInset.right;
//    self.rnView.frame = [self contentArea];
    self.naviView.frame = CGRectMake(safeEdgeInset.left, safeEdgeInset.top, width, kNavigationBarHeight);
    [self.view bringSubviewToFront:self.naviView];
}

- (CGRect)contentArea {
    UIEdgeInsets safeEdgeInset = self.safeEdgeInsets;
    const CGFloat width = self.view.width - safeEdgeInset.left - safeEdgeInset.right;
    const CGFloat height = self.view.height - safeEdgeInset.top;
    const CGRect contentArea = CGRectMake(safeEdgeInset.left, safeEdgeInset.top, width, height);
    return contentArea;
}

#pragma mark -- ButtonTouch

- (void)shareTouched:(UIButton *)button {
    [[TTAdCanvasManager sharedManager] canvasShare];
}

- (void)closeButtonTouched:(UIButton *)button {
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTAdCanvasNotificationExitCanvasPage object:nil];
    [self showEndAnimation];
}

#pragma mark -- Animation

- (void)showStartAnimation {
    CGRect sourceFrame = self.viewModel.soureImageFrame;
    TTImageInfosModel *sourceImageModel = self.viewModel.sourceImageModel;

    const CGFloat width = CGRectGetWidth(self.view.bounds);
    TTImageInfosModel *toImageModel = self.viewModel.canvasImageModel;
    CGRect toFrame = CGRectZero;
    
    if (self.viewModel.animationStyle == TTAdCanvasOpenAnimationScale) {
        toFrame = CGRectMake(self.safeEdgeInsets.left, self.safeEdgeInsets.top, self.view.width, self.view.height - self.safeEdgeInsets.top);
        [self startAnimationStyleScale:sourceFrame sourceImageModel:sourceImageModel toFrame:toFrame toImageModel:toImageModel];
    } else {
        if (toImageModel.width > FLT_EPSILON) {
            CGFloat height = ceilf(width * (toImageModel.height / toImageModel.width));
            toFrame = CGRectMake(self.safeEdgeInsets.left, self.safeEdgeInsets.top, width, height);
        }
        if (CGRectEqualToRect(toFrame, CGRectZero) && sourceFrame.size.width > 0) {
            CGFloat height = ceilf(width * (sourceFrame.size.height / sourceFrame.size.width));
            toFrame = CGRectMake(self.safeEdgeInsets.left, self.safeEdgeInsets.top, width, height);
        }
        [self startAnimationMoveUp:sourceFrame sourceImageModel:sourceImageModel toFrame:toFrame toImageModel:toImageModel];
    }
}

- (void)startAnimationMoveUp:(CGRect)sourceFrame sourceImageModel:(TTImageInfosModel *)souceImageModel toFrame:(CGRect)toFrame toImageModel:(TTImageInfosModel *)toImageInfoModel {
    __block TTImageView* toImageView = [[TTImageView alloc] initWithFrame:sourceFrame];
    toImageView.tag = toImageViewTag;
    toImageView.imageContentMode = TTImageViewContentModeScaleAspectFit;
    [toImageView setImageWithModel:toImageInfoModel];
    [self.view addSubview:toImageView];
    
    __block TTImageView* sourceImageView = [[TTImageView alloc] initWithFrame:sourceFrame];
    sourceImageView.tag = sourceImageViewTag;
    sourceImageView.imageContentMode = TTImageViewContentModeScaleAspectFit;
    [sourceImageView setImageWithModel:souceImageModel]; // SDWebImage 缓存
    [self.view addSubview:sourceImageView];
    
    [self.view bringSubviewToFront:self.naviView];
    
    WeakSelf;
    [UIView animateWithDuration:startAnimationDuration customTimingFunction:CustomTimingFunctionExpoOut animation:^{
        StrongSelf;
        sourceImageView.frame = toFrame;
        sourceImageView.alpha = 0;
        toImageView.frame = toFrame;
        toImageView.alpha = 1;
        self.screenShotView.alpha = 0;
    } completion:^(BOOL finished) {
        StrongSelf;
        self.animateStart = YES;
        if (self.loadRnEnd == YES) {
            [self commitShowRNViewAnimation];
        }
    }];
}

- (void)startAnimationStyleScale:(CGRect)sourceFrame sourceImageModel:(TTImageInfosModel*)souceImageModel toFrame:(CGRect)toFrame toImageModel:(TTImageInfosModel*)toImageInfoModel {
    __block TTImageView* toImageView = [[TTImageView alloc] initWithFrame:sourceFrame];
    toImageView.tag = toImageViewTag;
    toImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
    [toImageView setImageWithModel:toImageInfoModel];
    [self.view addSubview:toImageView];
    
    __block TTImageView* sourceImageView = [[TTImageView alloc] initWithFrame:sourceFrame];
    sourceImageView.tag = sourceImageViewTag;
    sourceImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
    [sourceImageView setImageWithModel:souceImageModel]; // SDWebImage 缓存
    [self.view addSubview:sourceImageView];

    [self.view bringSubviewToFront:self.naviView];
    
    WeakSelf;
    [UIView animateWithDuration:startAnimationDuration customTimingFunction:CustomTimingFunctionExpoOut animation:^{
        StrongSelf;
        sourceImageView.frame = toFrame;
        sourceImageView.alpha = 0;
        toImageView.frame = toFrame;
        toImageView.alpha = 1;
        self.screenShotView.alpha = 0;
    } completion:^(BOOL finished) {
        StrongSelf;
        self.animateStart = YES;
        if (self.loadRnEnd == YES) {
            [self commitShowRNViewAnimation];
        }
    }];
}

- (void)commitShowRNViewAnimation {
    UIView *sourceImageView = [self.view viewWithTag:sourceImageViewTag];
    UIView *toImageView = [self.view viewWithTag:toImageViewTag];
    
    void(^animationCompletion)(BOOL) = ^(BOOL finisfed){
            [sourceImageView removeFromSuperview];
            [toImageView removeFromSuperview];
            [self.screenShotView removeFromSuperview];
            self.animateEnd = YES;
    };
//    if (self.rnView != nil) {
//        self.rnView.hidden = NO;
//        self.rnView.alpha = 0;
//        self.rnView.frame = [self contentArea];
//        WeakSelf;
//        [UIView animateWithDuration:startAnimationDuration customTimingFunction:CustomTimingFunctionExpoOut animation:^{
//            StrongSelf;
//            self.rnView.alpha = 1;
//            self.rnView.frame = [self contentArea];
//        } completion:animationCompletion];
//    } else {
//        animationCompletion(NO);
//    }
}

//一定要关闭视图
- (void)showEndAnimation {
    if (self.viewModel.animationStyle == TTAdCanvasOpenAnimationPush) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    CGRect toFrame = self.viewModel.soureImageFrame;
    TTImageInfosModel *toImageModel = self.viewModel.sourceImageModel;
    if (CGRectEqualToRect(toFrame, CGRectZero)) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(canvasVCShowEndAnimation:sourceImageModel:toFrame:toImageModel:complete:)]) {
        CGRect sourceFrame = CGRectZero;
        if (self.viewModel.canvasImageModel != nil) {
            sourceFrame = CGRectMake(self.safeEdgeInsets.left, self.safeEdgeInsets.top, self.view.width, self.view.height);
        }
        [self.delegate canvasVCShowEndAnimation:sourceFrame sourceImageModel:self.viewModel.canvasImageModel toFrame:toFrame toImageModel:toImageModel complete:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

#pragma mark -- Notification
- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidAppear:) name:SKStoreProductViewDidAppearKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidDisappear:) name:SKStoreProductViewDidDisappearKey object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)skStoreViewDidAppear:(NSNotification*)noti
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTAdCanvasVideoNotificationPause object:nil];
}

- (void)skStoreViewDidDisappear:(NSNotification*)noti
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTAdCanvasVideoNotificationResume object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
