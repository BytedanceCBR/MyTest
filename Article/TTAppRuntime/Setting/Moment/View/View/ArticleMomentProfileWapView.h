//
//  ArticleMomentProfileWapView.h
//  Article
//
//  Created by Chen Hong on 16/1/19.
//
//

#import "TTMomentProfileBaseView.h"
#import "SSWebViewControllerView.h"


@interface ArticleMomentProfileWapView : TTMomentProfileBaseView<YSWebViewDelegate>

// wap样式
@property(nonatomic, strong) SSJSBridgeWebView *webViewContainer;
@property (nonatomic, copy) void (^updateBlock)(NSDictionary *result);
@property(nonatomic, copy) NSString *userID;
@property (nonatomic, assign) BOOL requestFailure;
- (void)hideNavBar;

@end
