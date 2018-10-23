//
//  TTRNWebView.h
//  Article
//
//  Created by Chen Hong on 16/8/8.
//
//

#import "RCTView.h"

@class TTRNWebView;

@protocol TTRNWebViewDelegate <NSObject>

- (BOOL)webView:(TTRNWebView *)webView
shouldStartLoadForRequest:(NSMutableDictionary<NSString *, id> *)request
   withCallback:(RCTDirectEventBlock)callback;

@end


@interface TTRNWebView : RCTView

@property (nonatomic, weak) id<TTRNWebViewDelegate> delegate;

@property (nonatomic, copy) NSDictionary *source;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) BOOL automaticallyAdjustContentInsets;
@property (nonatomic, copy) NSString *injectedJavaScript;
@property (nonatomic, assign) BOOL scalesPageToFit;

- (void)goForward;
- (void)goBack;
- (void)reload;
- (void)stopLoading;

@end