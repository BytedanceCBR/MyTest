//
//  TTFontSettingController.m
//  TTShareService
//
//  Created by wangqi.kaisa on 2018/1/22.
//

#import "TTFontSettingController.h"
#import "TTFontSettingView.h"
#import "TTDeviceHelper.h"
#import "UIViewAdditions.h"

@interface TTFontSettingViewController : UIViewController

@end

@implementation TTFontSettingViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end

@interface TTFontSettingController ()

@property(nonatomic, strong) UIWindow *backWindow;
@property(nonatomic, strong) TTFontSettingViewController *fontSettingVC;
@property(nonatomic, strong) TTFontSettingView *activityView;

@end

@implementation TTFontSettingController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSubViews];
        [self addNotification];
    }
    return self;
}

- (void)initSubViews {
    _fontSettingVC = [[TTFontSettingViewController alloc] init];
    
    _backWindow = [[UIWindow alloc] init];
    _backWindow.frame = [UIApplication sharedApplication].keyWindow.bounds;
    _backWindow.windowLevel = UIWindowLevelStatusBar + 1;
    _backWindow.rootViewController = self.fontSettingVC;
    _backWindow.backgroundColor = [UIColor clearColor];
    _backWindow.hidden = YES;
    
    _activityView = [[TTFontSettingView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    WeakSelf;
    self.activityView.dismissHandler = ^{
        StrongSelf;
        [self fontSettingViewDismissTrigger];
    };
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationStautsBarDidRotate) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)applicationStautsBarDidRotate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self willTransitionToSize:[UIApplication sharedApplication].delegate.window.bounds.size];
    });
}

- (void)willTransitionToSize:(CGSize)size {
    if ([TTDeviceHelper OSVersionNumber] < 8){
        CGRect frame = CGRectZero;
        frame.size = size;
        self.backWindow.frame = frame;
    }
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat temp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = temp;
    }
    self.activityView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
}

- (void)show {
    [self.backWindow makeKeyAndVisible];
    [self.activityView showOnController:self.fontSettingVC];
}

- (void)fontSettingViewDismissTrigger {
    self.backWindow.hidden = YES;
}

@end
