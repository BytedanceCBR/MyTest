//
//  TTUIResponderHelper.h
//  Pods
//
//  Created by 冯靖君 on 17/2/15.
//
//

#import <Foundation/Foundation.h>

@interface TTUIResponderHelper : NSObject

+ (CGRect)splitViewFrameForView:(nonnull UIView *)view;
+ (CGFloat)paddingForViewWidth:(CGFloat)viewWidth;

@end

@interface TTUIResponderHelper (TTWindowHelper)

// 获取当前应用的广义mainWindow
+ (nullable UIWindow *)mainWindow;

// 获取广义mainWindow的rootViewController
+ (nullable UIViewController*)mainWindowRootViewController;

// 广义mainWindow的大小（兼容iOS7）
+ (CGSize)windowSize;

// UIScreen大小（兼容iOS7）
+ (CGSize)screenSize;

// 屏幕像素点大小
+ (CGSize)screenResolution;

// 根据横竖屏返回当前屏幕的宽高
+ (CGSize)applicationSize;

@end

// app主动提供当前topNav，通常由appDelegate类实现
@protocol TTAppTopNavigationControllerDatasource <NSObject>

@required
- (UINavigationController *_Nonnull)appTopNavigationController;

@end

@interface TTUIResponderHelper (TTHierarchy)

/**
 获取指定UIResponder的响应链下游第一个UIViewController对象，注意有可能返回childViewController
 如果想取parentViewController，就用correctTopViewControllerFor:
 如果想取view所在的ViewController，直接使用view.viewController(在SSViewControllerBase中)
 @warning 当responder是UINavigationController或者UITabBarController时，会查找其childViewController而非parentViewController
 @param responder responder
 @return UIViewController
 */
+ (nullable UIViewController*)topViewControllerFor:(UIResponder* _Nullable)responder;
/** 获取指定UIResponder的顶层UIViewController对象 */
+ (nullable UIViewController*)correctTopViewControllerFor:(UIResponder* _Nullable)responder;

/** 获取指定UIResponder的响应链下游第一个UINavigationController对象，使用topViewControllerFor: */
+ (nullable UINavigationController*)topNavigationControllerFor:(UIResponder* _Nullable)responder;
/** 获取指定UIResponder的顶层UINavigationController对象，使用correctTopViewControllerFor: */
+ (nullable UINavigationController*)correctTopNavigationControllerFor:(UIResponder* _Nullable)responder;

/** 获取当前应用响应链最上游的UIViewController对象，使用topViewControllerFor: */
+ (nullable UIViewController*)topmostViewController;
/** 获取当前应用的顶层UIViewController对象，使用correctTopViewControllerFor: */
+ (nullable UIViewController*)correctTopmostViewController;

/** 获取当前应用响应链最上游的UIView对象，使用topViewControllerFor: */
+ (nullable UIView*)topmostView;
/** 获取当前应用顶层的UIView对象，使用correctTopViewControllerFor: */
+ (nullable UIView*)correctTopmostView;

@end
