//
//  DKSWebViewController.h
//  DKSWebView
//
//  Created by aDu on 2017/2/14.
//  Copyright © 2017年 DuKaiShun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTStartupWebViewController : UIViewController<UIWebViewDelegate>

//定义一个属性，方便外接调用
@property (nonatomic, strong) UIWebView *webView;
/** HTML的URL*/
@property (nonatomic, copy) NSString *htmlUrl;

@end
