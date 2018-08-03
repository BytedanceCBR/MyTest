//
//  SSWebViewContainer.h
//  Article
//
//  Created by Zhang Leonardo on 13-8-19.
//
//

#import "SSViewBase.h"

#import "SSWebViewUtil.h"
#import "SSJSBridgeWebView.h"
#import "SSThemed.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, SSWebViewStayStat) {
    SSWebViewStayStatCancel,
    SSWebViewStayStatLoadFinish,
    SSWebViewStayStatLoadFail,
};


@interface SSWebViewContainer : SSViewBase <YSWebViewDelegate>

@property (nonatomic, strong) SSJSBridgeWebView *ssWebView;

// 广告用的字段（到时候沉库可一并带走）
@property (nonatomic, copy) NSString *adID;
@property (nonatomic, copy) NSString *logExtra;
@property (nonatomic, copy) NSString *webViewTrackKey;
// 问答用的字段（到时候沉库后，问答可以继承而不污染这个类）
@property (nonatomic, copy) NSDictionary *gdExtJsonDict;

/**
 是否需要禁止头条UA, 默认为NO
 */
@property (nonatomic, assign) BOOL disableTTUserAgent;

- (instancetype)initWithFrame:(CGRect)frame baseCondition:(NSDictionary *)baseCondition NS_DESIGNATED_INITIALIZER;

/**
 加载一个普通请求, 不对Header进行处理

 @param request 请求
 */
- (void)loadRequest:(NSURLRequest *)request;
- (void)loadRequest:(NSURLRequest *)request shouldAppendQuery:(BOOL)shouldAppendQuery;

/**
 是否Loading动画

 @param hidden 是否隐藏
 */
- (void)hiddenProgressView:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END
