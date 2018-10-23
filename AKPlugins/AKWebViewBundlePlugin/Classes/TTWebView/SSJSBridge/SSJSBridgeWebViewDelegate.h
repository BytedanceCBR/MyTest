//
//  JSBridgeWebViewDelegate.h
//  Article
//
//  Created by Dianwei on 14-10-11.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YSWebView.h"

@interface SSJSBridgeWebViewDelegate : NSProxy<YSWebViewDelegate>
@property(nonatomic, strong)NSMutableArray *delegates;
+ (instancetype)JSBridgeWebViewDelegateWithMainDelegate:(NSObject<YSWebViewDelegate> *)tMainDelegate;
@end
