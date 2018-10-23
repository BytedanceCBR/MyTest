//
//  TTUIResponderHelper.h
//  Pods
//
//  Created by 冯靖君 on 17/2/15.
//
//

#import <Foundation/Foundation.h>

@interface TTUIResponderHelper : NSObject
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

@end

// app主动提供当前topNav，通常由appDelegate类实现
@protocol TTAppTopNavigationControllerDatasource <NSObject>

@required
- (UINavigationController *)appTopNavigationController;

@end

@interface TTUIResponderHelper (TTHierarchy)

// 获取指定UIResponder的链下游第一个ViewController对象
+ (nullable UIViewController*)topViewControllerFor:(UIResponder* _Nullable)responder;

// 获取指定UIResponder的链下游第一个UINavigationController对象
+ (nullable UINavigationController*)topNavigationControllerFor:(UIResponder* _Nullable)responder;

// 获取当前应用响应链最上游的ViewController对象
+ (nullable UIViewController*)topmostViewController;

// 获取当前应用响应链最上游的UIView对象
+ (nullable UIView*)topmostView;

@end
