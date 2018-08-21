//
//  TTUIResponderHelper.m
//  Pods
//
//  Created by 冯靖君 on 17/2/15.
//
//

#import "TTUIResponderHelper.h"

@implementation TTUIResponderHelper

+ (CGRect)splitViewFrameForView:(UIView *)view {
    if ([self _isPadDevice]) {
        CGFloat padding = [self paddingForViewWidth:0];
        CGSize windowSize = [self windowSize];
        
        CGRect frame = CGRectMake(0, view.bounds.origin.y, windowSize.width, view.bounds.size.height);
        frame = CGRectInset(frame, padding, 0);
        
        return frame;
    }
    return view.frame;
}

+ (CGFloat)paddingForViewWidth:(CGFloat)viewWidth {
    if (![self _isPadDevice]) {
        return 0;
    }
    else {
        
        if (viewWidth<=0) {
            viewWidth = [self windowSize].width;
        }
        CGFloat midDivideAspect = 1.f/2.f;
        CGFloat rightDivideAspect = 1.f/3.f;
        CGFloat deviceWidth = [self screenSize].width;
        CGFloat deviceHeight = [self screenSize].height;
        
        //这里用device的宽高判断orientation 是否是Portrait
        if (deviceHeight > deviceWidth) {
            if (viewWidth == deviceWidth) {
                //全屏
                if ([self _isPadProDevice]) {
                    return 200.f;
                }
                else {
                    return 119.f;
                }
            }
            else if (viewWidth > deviceWidth * midDivideAspect) {
                //左屏
                if ([self _isPadProDevice]) {
                    return 26.f;
                }
                else {
                    return 20.f;
                }
            }
            else {
                //右屏(竖屏没有中屏)
                if ([self _isPadProDevice]) {
                    return 13.f;
                }
                else {
                    return 10.f;
                }
            }
        }
        else {
            if (viewWidth == deviceWidth) {
                //全屏
                if ([self _isPadProDevice]) {
                    return 265.f;
                }
                else {
                    return 200.f;
                }
            }
            else if (viewWidth > deviceWidth * midDivideAspect) {
                //左屏
                if ([self _isPadProDevice]) {
                    return 45.f;
                }
                else {
                    return 35.f;
                }
            }
            else if (viewWidth > deviceWidth * rightDivideAspect) {
                //中屏
                if ([self _isPadProDevice]) {
                    return 26.f;
                }
                else {
                    return 20.f;
                }
            }
            else {
                //右屏
                if ([self _isPadProDevice]) {
                    return 13.f;
                }
                else {
                    return 10.f;
                }
            }
        }
    }
}

+ (BOOL)_isPadDevice
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (BOOL)_isPadProDevice
{
    CGFloat height = [UIScreen mainScreen].currentMode.size.height;
    CGFloat width = [UIScreen mainScreen].currentMode.size.width;
    BOOL isPro = (height == 2732 || width == 2732);
    return [self _isPadDevice] && isPro;
}

@end

@implementation TTUIResponderHelper (TTWindowHelper)

+ (UIWindow *)mainWindow
{
    UIWindow * window = nil;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        window = [[UIApplication sharedApplication].delegate window];
    }
    if (![window isKindOfClass:[UIView class]]) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    return window;
}

+ (UIViewController*)mainWindowRootViewController
{
    return [[self mainWindow] rootViewController];
}

+ (CGSize)windowSize
{
    UIWindow *window = [self mainWindow];
    CGSize windowSize = window.bounds.size;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGSizeMake(windowSize.height, windowSize.width);
    }
    return windowSize;
}

+ (CGSize)screenSize {
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGSize screenSize = mainScreen.bounds.size;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGSizeMake(screenSize.height, screenSize.width);
    }
    return screenSize;
}

+ (CGSize)screenResolution
{
    float scale = [[UIScreen mainScreen] scale];
    return CGSizeMake([self screenSize].width * scale, [self screenSize].height * scale);
}

+ (CGSize)applicationSize
{
    CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
    float width = 0, height = 0;
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        width = MAX(screenSize.width, screenSize.height);
        height = MIN(screenSize.width, screenSize.height);
    }
    else
    {
        width = MIN(screenSize.width, screenSize.height);
        height = MAX(screenSize.width, screenSize.height);
    }
    
    return CGSizeMake(width, height);
}

@end

@implementation TTUIResponderHelper (TTHierarchy)

+ (UIViewController*)topViewControllerFor:(UIResponder*)responder
{
    UIResponder *topResponder = responder;
    while(topResponder &&
          ![topResponder isKindOfClass:[UIViewController class]])
    {
        topResponder = [topResponder nextResponder];
    }
    
    if(!topResponder)
    {
        topResponder = [[[UIApplication sharedApplication] delegate].window rootViewController];
    }
    
    return (UIViewController*)topResponder;
}

+ (UIViewController*)correctTopViewControllerFor:(UIResponder*)responder
{
    UIResponder *topResponder = responder;
    for (; topResponder; topResponder = [topResponder nextResponder]) {
        if ([topResponder isKindOfClass:[UIViewController class]]) {
            UIViewController *viewController = (UIViewController *)topResponder;
            while (viewController.parentViewController && viewController.parentViewController != viewController.navigationController && viewController.parentViewController != viewController.tabBarController) {
                viewController = viewController.parentViewController;
            }
            return viewController;
        }
    }
    if(!topResponder)
    {
        topResponder = [[[UIApplication sharedApplication] delegate].window rootViewController];
    }
    
    return (UIViewController*)topResponder;
}

+ (UINavigationController*)topNavigationControllerFor:(UIResponder*)responder
{
    UIViewController *top = [self topViewControllerFor:responder];
    if (top.presentedViewController && [top.presentedViewController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)(top.presentedViewController);
    }
    else if ([top isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)top;
    }
    else if (top.navigationController) {
        return top.navigationController;
    }
    else if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(appTopNavigationController)]) {
        return [[[UIApplication sharedApplication] delegate] performSelector:@selector(appTopNavigationController)];
    }
    else {
        return nil;
    }
}

+ (UINavigationController *)correctTopNavigationControllerFor:(UIResponder *)responder
{
    UIViewController *top = [self correctTopViewControllerFor:responder];
    if (top.presentedViewController && [top.presentedViewController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)(top.presentedViewController);
    }
    else if ([top isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)top;
    }
    else if (top.navigationController) {
        return top.navigationController;
    }
    else if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(appTopNavigationController)]) {
        return [[[UIApplication sharedApplication] delegate] performSelector:@selector(appTopNavigationController)];
    }
    else {
        return nil;
    }
}

+ (UIView*)topmostView
{
    UIView *topView = [[[UIApplication sharedApplication] keyWindow] subviews].lastObject;
    UIViewController *topController = [self topViewControllerFor:topView];
    return topController.view;
}

+ (UIView *)correctTopmostView
{
    UIView *topView = [[[UIApplication sharedApplication] keyWindow] subviews].lastObject;
    UIViewController *topController = [self correctTopViewControllerFor:topView];
    return topController.view;
}

+ (UIViewController*)topmostViewController
{
    UIWindow * window = nil;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        window = [[UIApplication sharedApplication].delegate window];
    }
    if (![window isKindOfClass:[UIView class]]) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    UIView *topView = window.subviews.lastObject;
    UIViewController *topController = [self topViewControllerFor:topView];
    return topController;
}

+ (UIViewController *)correctTopmostViewController
{
    UIWindow * window = nil;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        window = [[UIApplication sharedApplication].delegate window];
    }
    if (![window isKindOfClass:[UIView class]]) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    UIView *topView = window.subviews.lastObject;
    UIViewController *topController = [self correctTopViewControllerFor:topView];
    return topController;
}

@end

