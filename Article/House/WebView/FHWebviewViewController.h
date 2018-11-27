//
//  FHWebviewController.h
//  Article
//
//  Created by 张元科 on 2018/11/26.
//

#import <UIKit/UIKit.h>
#import <TTRWebViewController.h>

NS_ASSUME_NONNULL_BEGIN

//  Route传参：TTRouteParamObj中的TTRouteUserInfo
/*
 url:请求地址
 title:标题
 jsParams:["methodName":JsonModel] // JS数据传递
 */
@interface FHWebviewViewController : TTRWebViewController

@end

NS_ASSUME_NONNULL_END
