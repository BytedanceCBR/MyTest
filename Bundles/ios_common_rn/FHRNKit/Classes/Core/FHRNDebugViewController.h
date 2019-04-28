//
//  FHRNDebugViewController.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/27.
//

#import <UIKit/UIKit.h>
#import "TTRNKitBaseViewController.h"
#import "TTRNKit.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHRNDebugViewControllerProtocol <NSObject>
@optional
/**
 解析url时，当host是webview或react时，如果未实现handleWithWrapper:...方法，此方法可以返回一个ViewController以弹出一个包含viewWrapper的ViewController
 */
- (void)addViewWrapper:(TTRNKitViewWrapper *)viewWrapper;

@end

@interface FHRNDebugViewController : TTRNKitBaseViewController <TTRNKitObserverProtocol>
- (instancetype)initWithContentViewController:(UIViewController<FHRNDebugViewControllerProtocol> *)contentViewController initModuleParams:(NSDictionary *)initModuleParams;
@end

NS_ASSUME_NONNULL_END
