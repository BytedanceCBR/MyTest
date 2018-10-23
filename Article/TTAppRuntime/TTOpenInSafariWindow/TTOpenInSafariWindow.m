//
//  TTOpenInSafariWindow.m
//  Article
//
//  Created by chenjiesheng on 2017/3/11.
//
//

#import "TTOpenInSafariWindow.h"
#import <TTRoute.h>
#import <TTRouteDefine.h>
#import <TTUIWidget/SSViewControllerBase.h>
#import <TTStringHelper.h>
#define rightButtonpadding 4.f

@interface TTOpenInSafariWindow ()

@property (nonatomic, strong) UIButton *statusRightButton;
@property (nonatomic, assign) CGSize    buttonSize;
@property (nonatomic, copy)   NSString *openURL;
@end

@implementation TTOpenInSafariWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.hidden = NO;
        self.windowLevel = UIWindowLevelStatusBar + 1;
        self.backgroundColor = [UIColor clearColor];
        self.rootViewController = [SSViewControllerBase new];
        [self addSubview:self.statusRightButton];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//用来解决在选择keyWindow的时候，层级较高的window会被选择为keyWindow的问题
- (BOOL)canBecomeKeyWindow
{
    return NO;
}

#pragma mark - notification

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification{
    instanceWindow = nil;
}

- (void)interfaceChangeNotification:(NSNotification *)notification
{
    //有可能手动更改statusBar，所以这边延迟修改布局
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        switch ([[UIApplication sharedApplication] statusBarOrientation]) {
            case UIInterfaceOrientationLandscapeRight:
                _statusRightButton.frame = CGRectMake(self.width - _buttonSize.height, self.height - _buttonSize.width - rightButtonpadding, _buttonSize.height, _buttonSize.width);
                break;
            case UIInterfaceOrientationLandscapeLeft:
                _statusRightButton.frame = CGRectMake(0,rightButtonpadding, _buttonSize.height, _buttonSize.width);
                break;
            case UIInterfaceOrientationPortrait:
                _statusRightButton.frame = CGRectMake(self.width - _buttonSize.width - rightButtonpadding, 0, _buttonSize.width, _buttonSize.height);
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                _statusRightButton.frame = CGRectMake(rightButtonpadding, self.height - _buttonSize.height, _buttonSize.width, _buttonSize.height);
            default:
                break;
        }
    });
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (CGRectContainsPoint(_statusRightButton.frame, point) && ![UIApplication sharedApplication].statusBarHidden){
        return _statusRightButton;
    }
    return nil;
}

#pragma mark - Action

static TTOpenInSafariWindow *instanceWindow;
+ (void)showQuickGotoWindowWithOpenURL:(NSString *)openURL
{
    CGSize buttonSize = [self getButtonSize];
    if (CGSizeEqualToSize(buttonSize, CGSizeZero)){
        return;
    }
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    if (keyWindow == nil){
        keyWindow = [[UIApplication sharedApplication] keyWindow];
    }
    CGSize windowSize = keyWindow.bounds.size;
    if (windowSize.width > windowSize.height){
        windowSize.width = windowSize.width + windowSize.height;
        windowSize.height = windowSize.width - windowSize.height;
        windowSize.width = windowSize.width - windowSize.height;
    }
    
    instanceWindow = [[TTOpenInSafariWindow alloc] initWithFrame:
                      CGRectMake(0, 0, windowSize.width, windowSize.height)];
    instanceWindow.buttonSize = buttonSize;
    instanceWindow.openURL = [self suitableOpenURLWithURL:openURL];
    [instanceWindow interfaceChangeNotification:nil];
}

+ (NSString *)suitableOpenURLWithURL:(NSString *)url{
    TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:[TTStringHelper URLWithURLString:url]];
    NSMutableString *openURL = [@"https://m.toutiao.com/" mutableCopy];
    if (paramObj.allParams){
        NSString *groupID = [paramObj.allParams tt_stringValueForKey:@"groupid"];
        NSString *itemID = [paramObj.allParams tt_stringValueForKey:@"item_id"];
        NSString *dest = @"";
        
        if (!isEmptyString(itemID)){
            dest = [NSString stringWithFormat:@"i%@/",itemID];
        }else if (!isEmptyString(groupID)){
            dest = [NSString stringWithFormat:@"a%@/",groupID];
        }
        
        if (!isEmptyString(dest)){
            [openURL appendString:dest];
        }
        
        return openURL;
    }
    return openURL;
}

+ (CGSize)getButtonSize
{
    NSString *statusBarString = [NSString stringWithFormat:@"_statusBarWindow"];
    UIView *statusBarWindow = [[UIApplication sharedApplication] valueForKey:statusBarString];
    CGSize buttonSize = CGSizeZero;
    if (statusBarWindow){
        UIView *statusBar = nil;
        for (UIView *view in statusBarWindow.subviews){
            if ([NSStringFromClass([view class]) isEqualToString:@"UIStatusBar"]){
                statusBar = view;
                break;
            }
        }
        if (!statusBar){
            return buttonSize;
        }
        
        for (UIView *view in statusBar.subviews){
            if ([NSStringFromClass([view class]) isEqualToString:@"UIStatusBarForegroundView"]){
                statusBar = view;
                break;
            }
        }
        
        for (UIView *view in statusBar.subviews){
            if ([NSStringFromClass([view class]) isEqualToString:@"UIStatusBarOpenInSafariItemView"]){
                buttonSize = view.size;
                break;
            }
        }
        return buttonSize;
    }
    return CGSizeZero;
}

- (void)statusButtonClick
{
    NSURL *openURL = [NSURL URLWithString:self.openURL];
    if([[UIApplication sharedApplication] canOpenURL:openURL]){
         [[UIApplication sharedApplication] openURL:openURL];
    }
}

#pragma mark- Getter

- (UIButton *)statusRightButton
{
    if (!_statusRightButton){
        _statusRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _statusRightButton.frame = CGRectZero;
        [_statusRightButton addTarget:self action:@selector(statusButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _statusRightButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    }
    return _statusRightButton;
}

@end
