//
//  TTFantasyWebviewAdaptor.h
//  Article
//
//  Created by 钟少奋 on 2017/12/23.
//

#import <Foundation/Foundation.h>
#import "TTFWebviewController.h"
#import "YSWebView.h"

@interface TTFantasyWebviewAdaptor : NSObject <TTFWebViewProtocol, YSWebViewDelegate>

@property (nonatomic, weak) id<UIWebViewDelegate>delegate;

@end
