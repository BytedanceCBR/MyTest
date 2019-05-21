//
//  TTRexxarWebViewAdapter.h
//  TTBridgeUnify
//
//  Created by 李琢鹏 on 2019/3/29.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TTWebViewBridgeEngine;

@interface WKWebView (TTRexxarAdapter)

- (void)tt_enableRexxarAdapter;

@end

@interface UIWebView (TTRexxarAdapter)

- (void)tt_enableRexxarAdapter;

@end

@protocol TTRexxarWebViewAdapterFilter <NSObject>

+ (BOOL)shouldAdaptBridge:(NSDictionary *)bridgeMessage engine:(TTWebViewBridgeEngine *)engine;

@end

@interface TTRexxarWebViewAdapter : NSObject

+ (BOOL)handleBridgeRequest:(NSURLRequest *)request engine:(TTWebViewBridgeEngine *)engine;
+ (void)fireEvent:(NSString *)eventName data:(NSDictionary *)data engine:(TTWebViewBridgeEngine *)engine;

/**
 只能赋值一次
 */
@property(nonatomic, copy, class) Class<TTRexxarWebViewAdapterFilter> bridgeFilter;

@end

NS_ASSUME_NONNULL_END
