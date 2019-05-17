//
//  TTFantasyWindowManager.m
//  Article
//
//  Created by chenren on 2018/01/17.
//

#import "TTFantasyWindowManager.h"
#import "TTFantasyTimeCountDownManager.h"
#import "TTFantasyService.h"
#import "TtfCommon.pbobjc.h"
#import <CoreText/CoreText.h>
#import <sys/sysctl.h>

#import "TTFNavigationController.h"
#import "TTFCommonDefine.h"
#import "TTNetworkManager.h"
#import "TTFURLSetting.h"
#import "TTFShareSettingsManager.h"
#import "UIView+CustomTimingFunction.h"


#import "TTAccountAlertView.h"
#import "TTAccountLoginPCHHeader.h"
#import <TTKeyboardListener.h>
#import <NSStringAdditions.h>
#import <UIViewAdditions.h>
#import <TTNavigationController.h>
#import <TTAlphaThemedButton.h>
#import <TTDeviceHelper.h>
#import "TTAccountNavigationController.h"
#import "TTAccountLoginManager.h"
#import "TTTrackerWrapper.h"
#import "TTVDemandPlayer.h"
#import "TTVAudioActiveCenter.h"
#import "TTVVideoPlayerStateStore.h"

@implementation TTFDashboardViewController (TT_Close)

+ (void)load
{
    method_exchangeImplementations(class_getInstanceMethod([self class], @selector(closeDashboard:)),
                                   class_getInstanceMethod([self class], @selector(tt_closeDashboard:)));
}

- (void)tt_closeDashboard:(id)sender
{
    if ([SSCommonLogic fantasyWindowResizeable]) {
        if ([[TTFantasyTimeCountDownManager sharedManager] isShowingTime] || [SSCommonLogic fantasyWindowAlwaysResizeable]) {
            [[TTFantasyWindowManager sharedManager] changeWindowSize];
        } else {
            [[TTFantasyWindowManager sharedManager] dismiss];
            //[[TTFantasyWindowManager sharedManager] changeWindowSize];
        }
    } else {
        [self tt_closeDashboard:sender];
    }
}

@end


@implementation TTFQuizShowLiveRoomViewController (TT_Close)

+ (void)load
{
    method_exchangeImplementations(class_getInstanceMethod([self class], @selector(closeLiveRoom)),
                                   class_getInstanceMethod([self class], @selector(tt_closeLiveRoom)));
    
//    method_exchangeImplementations(class_getInstanceMethod([self class], @selector(keyboardWillShow:)),
//                                   class_getInstanceMethod([self class], @selector(tt_keyboardWillShow:)));
//
//    method_exchangeImplementations(class_getInstanceMethod([self class], @selector(keyboardWillHide:)),
//                                   class_getInstanceMethod([self class], @selector(tt_keyboardWillHide:)));
}

- (void)tt_closeLiveRoom
{
    if ([SSCommonLogic fantasyWindowResizeable]) {
        if ([[TTFantasyTimeCountDownManager sharedManager] isShowingTime] || [SSCommonLogic fantasyWindowAlwaysResizeable]) {
            [[TTFantasyWindowManager sharedManager] changeWindowSize];
        } else {
            [self tt_closeLiveRoom];
            //[[TTFantasyWindowManager sharedManager] changeWindowSize];
        }
    } else {
        [self tt_closeLiveRoom];
    }
}

@end

@implementation TTFTalkBoardViewController (TT_Login)

//+ (void)load
//{
//    method_exchangeImplementations(class_getInstanceMethod([self class], @selector(viewWillLayoutSubviews)),
//                                   class_getInstanceMethod([self class], @selector(tt_viewWillLayoutSubviews)));
//}
//
//- (void)tt_viewWillLayoutSubviews
//{
//    if ([TTFantasyWindowManager sharedManager].isAnimating) {
//        [super viewWillLayoutSubviews];
//    } else {
//        [self tt_viewWillLayoutSubviews];
//    }
//}

@end


@implementation TTUIResponderHelper (TT_Login)

+ (void)load
{
    method_exchangeImplementations(class_getClassMethod([self class], @selector(topmostViewController)),
                                   class_getClassMethod([self class], @selector(tt_topmostViewController)));
}

+ (UIViewController*)tt_topmostViewController
{
    if ([UIApplication sharedApplication].keyWindow == [TTFantasyWindowManager sharedManager].fantasyWindow) {
        return [TTFantasyWindowManager sharedManager].fantasyWindow.rootViewController;
    } else {
        return [self tt_topmostViewController];
    }
}

@end


@implementation TTAccountAlertView (TT_Login)

+ (void)load
{
    method_exchangeImplementations(class_getInstanceMethod([self class], @selector(showInView:)),
                                   class_getInstanceMethod([self class], @selector(tt_showInView:)));
}

- (void)tt_showInView:(UIView *)superView
{
    if ([UIApplication sharedApplication].keyWindow == [TTFantasyWindowManager sharedManager].fantasyWindow) {
        UIView *selfSuperView = superView;
        
        UIWindow *window = [TTFantasyWindowManager sharedManager].fantasyWindow;
        UIViewController *vc = window.rootViewController;
        while (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)vc).topViewController;
        }
        selfSuperView = vc.view;;
        
        // ajust layout before any animations
        self.alpha = 0.0f;
        self.frame = selfSuperView.bounds;
        if ([[TTKeyboardListener sharedInstance] isVisible]) {
            CGFloat keyboardTop = self.frame.size.height - [TTKeyboardListener sharedInstance].keyboardHeight;
            CGPoint center = CGPointMake(self.centerX,  keyboardTop/2 - self.superview.frame.origin.y);
            self.centerView.center = center;
        } else {
            self.centerView.center = self.center;
        }
        
        // add self to window hierarchy
        [selfSuperView addSubview:self];
        
        self.centerView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        [UIView animateWithDuration:0.13 animations:^{
            self.alpha = 1.0f;
            self.centerView.transform = CGAffineTransformMakeScale(1.03, 1.03);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.07 animations:^{
                self.centerView.transform = CGAffineTransformIdentity;
            } completion:nil];
        }];
        
        UINavigationController *topNaviVC = self.window.navigationController;
        
        if ([topNaviVC isKindOfClass:[TTAccountNavigationController class]]) {
            if (![TTNavigationController refactorNaviEnabled]) {
                topNaviVC.navigationBar.userInteractionEnabled = NO;
            } else {
                topNaviVC.topViewController.ttNavigationBar.userInteractionEnabled = NO;
            }
        }
    } else {
        [self tt_showInView:superView];
    }
    
}

@end


@implementation TTFantasyWindow

- (void)makeKeyAndVisible
{
    if ([TTFantasyWindowManager sharedManager].isSmallMode) {
        [[TTFantasyWindowManager sharedManager].parentKeyWindow makeKeyAndVisible];
    } else {
        [super makeKeyAndVisible ];
    }
}

- (void)makeKeyWindow
{
    if ([TTFantasyWindowManager sharedManager].isSmallMode) {
        [[TTFantasyWindowManager sharedManager].parentKeyWindow makeKeyWindow];
    } else {
        [super makeKeyWindow ];
    }
}

@end


@interface TTFantasyWindowManager()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) CGFloat smallScale;
@property (nonatomic, assign) CGFloat largeScale;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) UIStatusBarStyle originalStatusBarStyle;
@property (nonatomic, assign) BOOL originalHideStatusBar;

@property (nonatomic, assign) NSTimeInterval openTime;
@property (nonatomic, assign) NSTimeInterval closeTime;

@property (nonatomic, strong) UIImageView *parentMaskView;

@end

@implementation TTFantasyWindowManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static TTFantasyWindowManager * sharedManager;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _smallScale = 100.0 /  [UIScreen mainScreen].bounds.size.width;
        _largeScale = [UIScreen mainScreen].bounds.size.width / 100.0;
        _screenWidth = [UIScreen mainScreen].bounds.size.width;
        _screenHeight = [UIScreen mainScreen].bounds.size.height;
        @weakify(self);
        [[NSNotificationCenter defaultCenter] addObserverForName:@"kTTVPlaybackState" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            @strongify(self);
            if ([[note object] isKindOfClass:[TTVDemandPlayer class]]) {
                TTVDemandPlayer *player = [note object];
                if (player.playerStateStore.state.muted && (player.playerStateStore.state.playbackState == TTVVideoPlaybackStateFinished || player.playerStateStore.state.playbackState == TTVVideoPlaybackStateBreak || player.playerStateStore.state.error)) {
                    [TTVAudioActiveCenter setupAudioSessionIsMuted:NO];
                }
            }
        }];
        [self prepare];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepare
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)themeChanged:(NSNotification *)notification
{
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        if ([TTDeviceHelper isIPhoneXDevice]) {
            _parentMaskView.image = [UIImage imageNamed:@"fantasy_window_mask_x_night"];
        } else {
            _parentMaskView.image = [UIImage imageNamed:@"fantasy_window_mask_night"];
        }
    } else {
        if ([TTDeviceHelper isIPhoneXDevice]) {
            _parentMaskView.image = [UIImage imageNamed:@"fantasy_window_mask_x"];
        } else {
            _parentMaskView.image = [UIImage imageNamed:@"fantasy_window_mask"];
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    //[self ddk];
    //获取键盘的高度
    if (_isSmallMode) {
        NSDictionary *userInfo = [notification userInfo];
        NSValue *keyboardInfo = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardRect = [keyboardInfo CGRectValue];
        CGFloat keyboardHeight = keyboardRect.size.height;
        
        if (self.fantasyWindow.bottom + keyboardHeight > _screenHeight) {
            CGPoint fantasyWindowCenter = self.fantasyWindow.center;
            CGPoint parentMaskViewCenter = self.fantasyWindow.center;
            CGFloat offset = self.fantasyWindow.bottom + keyboardHeight - _screenHeight + 50;
            UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
            UIViewAnimationOptions options = UIViewAnimationCurveEaseIn | UIViewAnimationCurveEaseOut | UIViewAnimationCurveLinear;
            switch (animationCurve) {
                case UIViewAnimationCurveEaseInOut:
                    options = UIViewAnimationOptionCurveEaseInOut;
                    break;
                case UIViewAnimationCurveEaseIn:
                    options = UIViewAnimationOptionCurveEaseIn;
                    break;
                case UIViewAnimationCurveEaseOut:
                    options = UIViewAnimationOptionCurveEaseOut;
                    break;
                case UIViewAnimationCurveLinear:
                    options = UIViewAnimationOptionCurveLinear;
                    break;
                default:
                    options = animationCurve << 16;
                    break;
            }
            
            CGFloat duration = [[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
            [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
                _fantasyWindow.center = CGPointMake(fantasyWindowCenter.x, fantasyWindowCenter.y - offset);
                _parentMaskView.center = CGPointMake(parentMaskViewCenter.x, parentMaskViewCenter.y - offset);
            } completion:^(BOOL finished) {
                
            }];
//            [UIView animateWithDuration:0.65 customTimingFunction:CustomTimingFunctionExpoOut animation:^{
//                _fantasyWindow.center = CGPointMake(fantasyWindowCenter.x, fantasyWindowCenter.y - offset);
//                _parentMaskView.center = CGPointMake(parentMaskViewCenter.x, parentMaskViewCenter.y - offset);
//            } completion:^(BOOL finished) {
//
//            }];
        }
    }
}

- (void)show
{
    static NSTimeInterval lastActionTime = 0;
    NSTimeInterval currentActionTime = [[NSDate date] timeIntervalSince1970];
    if (currentActionTime - lastActionTime < 1.2f) {
        return;
    } else {
        lastActionTime = currentActionTime;
    }
    
    if (_isSmallMode) {
        [self changeWindowSize];
        
        return;
    }
    self.fantasyWindow.hidden = NO;
    TTFDashboardViewController *dashboardVC  = [[TTFDashboardViewController alloc] init];
    dashboardVC.trackerDescriptor = self.trackerDescriptor;
    //dashboardVC.enterFromStr = descriptor[kTTFEnterFromTypeKey];
    TTFNavigationController *nav = [[TTFNavigationController alloc] initWithRootViewController:dashboardVC];
    
    if (!_parentKeyWindow) {
        self.parentKeyWindow = [UIApplication sharedApplication].keyWindow;
    }
    
    if (!_parentMaskView) {
        
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
            if ([TTDeviceHelper isIPhoneXDevice]) {
                _parentMaskView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 108, 168)];
                _parentMaskView.image = [UIImage imageNamed:@"fantasy_window_mask_x_night"];
            } else {
                _parentMaskView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 108, 148)];
                _parentMaskView.image = [UIImage imageNamed:@"fantasy_window_mask_night"];
            }
        } else {
            if ([TTDeviceHelper isIPhoneXDevice]) {
                _parentMaskView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 108, 168)];
                _parentMaskView.image = [UIImage imageNamed:@"fantasy_window_mask_x"];
            } else {
                _parentMaskView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 108, 148)];
                _parentMaskView.image = [UIImage imageNamed:@"fantasy_window_mask"];
            }
        }
        
        //_parentMaskView.backgroundColor = [UIColor redColor];
        [self.parentKeyWindow addSubview:_parentMaskView];
    }
    
    CGFloat offset = 44.f;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        offset = 78.f;
    } else {
        offset = 44.f;
    }
    
    if ([TTDeviceHelper isIPhoneXDevice]) {
        _parentMaskView.frame = CGRectMake(_screenWidth - 108 - 1, _screenHeight - offset - 168 - 1, 108, 168);
    } else {
        _parentMaskView.frame = CGRectMake(_screenWidth - 108 - 1, _screenHeight - offset - 148 - 1, 108, 148);
    }
    _parentMaskView.alpha = 0;
    
    if (!_fantasyWindow) {
        _fantasyWindow = [[TTFantasyWindow alloc] initWithFrame:CGRectMake(0, _screenHeight, _screenWidth, _screenHeight)];//[[UIScreen mainScreen] bounds]];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
        pan.delaysTouchesBegan = NO;
        
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionkkk:)];
        [swipe setDirection:( UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown)];
        
//        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionkkk:)];
//        [swipe setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft |UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown)];
        
        
        
       // [pan requireGestureRecognizerToFail:swipe];
        
        [_fantasyWindow addGestureRecognizer:pan];
       // [_fantasyWindow addGestureRecognizer:swipe];
        
        self.fantasyWindow.windowLevel = UIWindowLevelAlert + 1;
    }
    
    if (!_button) {
        //_button = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 175, 5, 32, 30)];
        _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
        _button.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.01];//[UIColor whiteColor];
        //_button.alpha = 0;
        [_button addTarget:self action:@selector(changeWindowSize) forControlEvents:UIControlEventTouchUpInside];
        //_button.hidden = YES;
    }
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_screenWidth - 121, 1, 120, 113)];
        _imageView.image = [UIImage imageNamed:@"fantasy_close"];
        _imageView.userInteractionEnabled = YES;
        //_imageView.alpha = 0;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeFantasyWindow)];
        [_imageView addGestureRecognizer:tapGestureRecognizer];
        //_imageView.hidden = YES;
    }
    
    self.fantasyWindow.rootViewController = nav;
    
    //[[UIApplication sharedApplication].keyWindow addSubview:self.window];
    [self.fantasyWindow makeKeyAndVisible];
    
    self.openTime = [[NSDate date] timeIntervalSince1970];
    [TTTrackerWrapper eventV3:@"open_fantasy_window" params:@{@"open_time": @(self.openTime)}];
    
    [self.fantasyWindow addSubview:_button];
    [self.fantasyWindow addSubview:_imageView];
    //_button.hidden = YES;
    //_imageView.hidden = YES;
    
    _button.alpha = 0;
    _imageView.alpha = 0;
    
    self.fantasyWindow.clipsToBounds = YES;
    
    self.originalHideStatusBar = [UIApplication sharedApplication].statusBarHidden;
    self.originalStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    _fantasyWindow.frame = CGRectMake(0, _screenHeight, _screenWidth, _screenHeight);
    [UIView animateWithDuration:0.4 customTimingFunction:CustomTimingFunctionExpoOut animation:^{
        _fantasyWindow.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss
{
    static NSTimeInterval lastActionTime = 0;
    NSTimeInterval currentActionTime = [[NSDate date] timeIntervalSince1970];
    if (currentActionTime - lastActionTime < 1.2f) {
        return;
    } else {
        lastActionTime = currentActionTime;
    }
    
    _fantasyWindow.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
    [UIView animateWithDuration:0.4 customTimingFunction:CustomTimingFunctionExpoOut animation:^{
        _fantasyWindow.frame = CGRectMake(0, _screenHeight, _screenWidth, _screenHeight);
        [[UIApplication sharedApplication] setStatusBarStyle:self.originalStatusBarStyle animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:self.originalHideStatusBar withAnimation:YES];
    } completion:^(BOOL finished) {
        self.fantasyWindow.rootViewController = nil;
        self.fantasyWindow.hidden = YES;
        if (_isSmallMode) {
            self.fantasyWindow.transform = CGAffineTransformScale(self.fantasyWindow.transform, _largeScale, _largeScale);
            self.fantasyWindow.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
        }
        _isSmallMode = NO;
        [self.parentKeyWindow makeKeyAndVisible];
        
        self.closeTime = [[NSDate date] timeIntervalSince1970];
        [TTTrackerWrapper eventV3:@"close_fantasy_window" params:@{@"open_time": @(self.openTime), @"close_time": @(self.closeTime), @"duration": @(self.closeTime - self.openTime)}];
    }];
}

- (void)statusBarOrientationChange:(NSNotification *)notification
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation != UIDeviceOrientationPortrait)
    {
        [self closeFantasyWindow];
    }
}

-(void)actionkkk:(UIPanGestureRecognizer *)recognizer
{
    
}

- (void)closeFantasyWindow
{
    static NSTimeInterval lastActionTime = 0;
    NSTimeInterval currentActionTime = [[NSDate date] timeIntervalSince1970];
    if (currentActionTime - lastActionTime < 1.2f) {
        return;
    } else {
        lastActionTime = currentActionTime;
    }
    
    [UIView animateWithDuration:0.4 customTimingFunction:CustomTimingFunctionExpoOut animation:^{
        if (_fantasyWindow.center.x > _screenWidth / 2) {
            _fantasyWindow.center = CGPointMake(_fantasyWindow.center.x + 108, _fantasyWindow.center.y);
            _parentMaskView.center = CGPointMake(_fantasyWindow.center.x + 108, _fantasyWindow.center.y);
        } else {
            _fantasyWindow.center = CGPointMake(_fantasyWindow.center.x - 108, _fantasyWindow.center.y);
            _parentMaskView.center = CGPointMake(_fantasyWindow.center.x - 108, _fantasyWindow.center.y);
        }
        
    } completion:^(BOOL finished) {
        
        
        self.fantasyWindow.rootViewController = nil;
        self.fantasyWindow.hidden = YES;
        _parentMaskView.alpha = 0;
        if (_isSmallMode) {
            self.fantasyWindow.transform = CGAffineTransformScale(self.fantasyWindow.transform, _largeScale, _largeScale);
            self.fantasyWindow.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
        }
        _isSmallMode = NO;
        [self.parentKeyWindow makeKeyAndVisible];
        
        self.closeTime = [[NSDate date] timeIntervalSince1970];
        [TTTrackerWrapper eventV3:@"close_fantasy_window" params:@{@"open_time": @(self.openTime), @"close_time": @(self.closeTime), @"duration": @(self.closeTime - self.openTime)}];
    }];
}

- (void)changeWindowSize
{
    static NSTimeInterval lastActionTime = 0;
    NSTimeInterval currentActionTime = [[NSDate date] timeIntervalSince1970];
    if (currentActionTime - lastActionTime < 1.2f) {
        return;
    } else {
        lastActionTime = currentActionTime;
    }
    
    _isAnimating = YES;
    
    if (!_isSmallMode) {
        UIViewController *vc = self.fantasyWindow.rootViewController;
        while (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)vc).topViewController;
        }
        if ([vc isKindOfClass:[TTFQuizShowLiveRoomViewController class]]) {
            [[NSNotificationCenter defaultCenter] removeObserver:vc name:UIKeyboardWillShowNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:vc name:UIKeyboardWillHideNotification object:nil];
        }
        
        CGFloat offset = 44.f;
        if ([TTDeviceHelper isIPhoneXDevice]) {
            offset = 78.f;
        } else {
            offset = 44.f;
        }
        
        if ([TTDeviceHelper isIPhoneXDevice]) {
            _parentMaskView.frame = CGRectMake(_screenWidth - 108 - 1, _screenHeight - offset - 168 - 0, 108, 168);
        } else {
            _parentMaskView.frame = CGRectMake(_screenWidth - 108 - 1, _screenHeight - offset - 148 - 0, 108, 148);
        }
        
        _parentMaskView.alpha = 0;
        
        [UIView animateWithDuration:0.4 customTimingFunction:CustomTimingFunctionExpoOut animation:^{
            self.fantasyWindow.transform = CGAffineTransformScale(self.fantasyWindow.transform, _smallScale, _smallScale);
            CGFloat offset = 44.f;
            if ([TTDeviceHelper isIPhoneXDevice]) {
                offset = 78.f;
            } else {
                offset = 44.f;
            }
            
            if ([TTDeviceHelper isIPhoneXDevice]) {
                self.fantasyWindow.frame = CGRectMake(_screenWidth - 100 - 5, _screenHeight - offset - 160 - 5, 100, 160);
            } else {
                self.fantasyWindow.frame = CGRectMake(_screenWidth - 100 - 5, _screenHeight - offset - 140 - 5, 100, 140);
            }
            self.fantasyWindow.rootViewController.view.frame = CGRectMake(0, -offset, _screenWidth, _screenHeight);
//            _button.hidden = NO;
//            _imageView.hidden = NO;
            _button.alpha = 1;
            _imageView.alpha = 1;
            
            _parentMaskView.alpha = 1;
            
            [[UIApplication sharedApplication] setStatusBarStyle:self.originalStatusBarStyle animated:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:self.originalHideStatusBar withAnimation:YES];
            
        } completion:^(BOOL finished) {
            _isSmallMode = YES;

            [self.parentKeyWindow makeKeyAndVisible];
            
            _isAnimating = NO;

        }];
        
    } else {
        
        self.originalHideStatusBar = [UIApplication sharedApplication].statusBarHidden;
        self.originalStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
        
        //_button.alpha = 1;
        //_imageView.alpha = 1;
        [UIView animateWithDuration:0.4 customTimingFunction:CustomTimingFunctionExpoOut animation:^{
            self.fantasyWindow.transform = CGAffineTransformScale(self.fantasyWindow.transform, _largeScale, _largeScale);
            self.fantasyWindow.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
            self.fantasyWindow.rootViewController.view.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
//            _button.hidden = YES;
//            _imageView.hidden = YES;
            
            _button.alpha = 0;
            _imageView.alpha = 0;
            
            _parentMaskView.alpha = 0;
            
            //_fantasyWindow.layer.borderWidth = 0;
            self.fantasyWindow.layer.masksToBounds = YES;
            
        } completion:^(BOOL finished) {
            
            CGFloat offset = 44.f;
            if ([TTDeviceHelper isIPhoneXDevice]) {
                offset = 78.f;
            } else {
                offset = 44.f;
            }
            
            if ([TTDeviceHelper isIPhoneXDevice]) {
                _parentMaskView.frame = CGRectMake(_screenWidth - 108 - 1, _screenHeight - offset - 168 - 0, 108, 168);
            } else {
                _parentMaskView.frame = CGRectMake(_screenWidth - 108 - 1, _screenHeight - offset - 148 - 0, 108, 148);
            }

            _isSmallMode = NO;
            //_button.hidden = YES;
            //_imageView.hidden = YES;
            [self.fantasyWindow makeKeyAndVisible];
            
            UIViewController *vc = self.fantasyWindow.rootViewController;
            while (vc.presentedViewController) {
                vc = vc.presentedViewController;
            }
            if ([vc isKindOfClass:[UINavigationController class]]) {
                vc = ((UINavigationController *)vc).topViewController;
            }
            if ([vc isKindOfClass:[TTFQuizShowLiveRoomViewController class]]) {
                [[NSNotificationCenter defaultCenter] addObserver:vc
                                                         selector:@selector(keyboardWillShow:)
                                                             name:UIKeyboardWillShowNotification
                                                           object:nil];

                [[NSNotificationCenter defaultCenter] addObserver:vc
                                                         selector:@selector(keyboardWillHide:)
                                                             name:UIKeyboardWillHideNotification
                                                           object:nil];
            }
            
            _isAnimating = NO;

        }];
    }
}

- (void)locationChange:(UIPanGestureRecognizer*)p
{
    if (!_isSmallMode) {
        return;
    }
    
    CGPoint panPoint = [p translationInView:self.fantasyWindow];
    
    CGFloat x = self.fantasyWindow.center.x + panPoint.x * _smallScale;
    CGFloat y = self.fantasyWindow.center.y + panPoint.y * _smallScale;
    if (x > _screenWidth - self.fantasyWindow.frame.size.width / 2 - 5) {
        x = _screenWidth - self.fantasyWindow.frame.size.width / 2 - 5;
    }
    
    if (x < self.fantasyWindow.frame.size.width / 2 + 5) {
        x = self.fantasyWindow.frame.size.width / 2 + 5;
    }
    
    CGFloat offsetDown = 44.f;
    CGFloat offsetUp = 20.0;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        offsetUp = 40.f;
        offsetDown = 78.0;
    }
    
    if (y > _screenHeight - self.fantasyWindow.frame.size.height / 2 - 5 - offsetDown) {
        y = _screenHeight - self.fantasyWindow.frame.size.height / 2 - 5 - offsetDown;
    }
    
    if (y < self.fantasyWindow.frame.size.height / 2 + 5 + offsetUp) {
        y = self.fantasyWindow.frame.size.height / 2 + 5 + offsetUp;
    }
    
    self.fantasyWindow.center = CGPointMake(x, y);
    self.parentMaskView.center = CGPointMake(x, y + 1);
    
    
    [p setTranslation:CGPointMake(0, 0) inView:self.fantasyWindow];
    
    
    if (p.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [p velocityInView:self.fantasyWindow];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x * _smallScale) + (velocity.y * velocity.y * _smallScale));
        CGFloat slideMult = magnitude / 2000;
        
        NSLog(@"magnitude: %f, slideMult: %f", magnitude, slideMult);
        
        float slideFactor = 0.1 * slideMult; // Increase for more of a slide

        CGPoint finalPoint = CGPointMake(p.view.center.x + (velocity.x * slideFactor * _smallScale * 0.3),
                                         p.view.center.y + (velocity.y * slideFactor * _smallScale * 0.3));
        
        if (finalPoint.x > _screenWidth - self.fantasyWindow.frame.size.width / 2 - 5) {
            finalPoint.x = _screenWidth - self.fantasyWindow.frame.size.width / 2 - 5;
        }
        
        if (finalPoint.x < self.fantasyWindow.frame.size.width / 2 + 5) {
            finalPoint.x = self.fantasyWindow.frame.size.width / 2 + 5;
        }
        
        if (finalPoint.x > _screenWidth / 2) {
            finalPoint.x = _screenWidth - self.fantasyWindow.frame.size.width / 2 - 5;
        } else {
            finalPoint.x = self.fantasyWindow.frame.size.width / 2 + 5;
        }

        CGFloat offsetDown = 44.f;
        CGFloat offsetUp = 20.0;
        if ([TTDeviceHelper isIPhoneXDevice]) {
            offsetUp = 40.f;
            offsetDown = 78.0;
        }
        
        if (finalPoint.y > _screenHeight - self.fantasyWindow.frame.size.height / 2 - 5 - offsetDown) {
            finalPoint.y = _screenHeight - self.fantasyWindow.frame.size.height / 2 - 5 - offsetDown;
        }
        
        if (finalPoint.y < self.fantasyWindow.frame.size.height / 2 + 5 + offsetUp) {
            finalPoint.y = self.fantasyWindow.frame.size.height / 2 + 5 + offsetUp;
        }
        
        if (slideFactor < 0.2) {
            slideFactor = 0.2;
        }
        [UIView animateWithDuration:slideFactor*1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            p.view.center = finalPoint;
            self.parentMaskView.center = CGPointMake(finalPoint.x, finalPoint.y + 1);;
        } completion:^(BOOL finished) {
            [TTTrackerWrapper eventV3:@"drag_fantasy_window" params:@{@"pos_x": @(finalPoint.x), @"pos_y": @(finalPoint.y)}];
        }];
    }
}

@end
