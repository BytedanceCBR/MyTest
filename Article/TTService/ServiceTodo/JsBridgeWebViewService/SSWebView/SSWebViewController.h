//
//  SSWebViewController.h
//  Article
//
//  Created by Zhang Leonardo on 13-8-21.
//
//

#import "SSViewControllerBase.h"
#import "SSWebViewControllerView.h"

@interface SSWebViewController : SSViewControllerBase

+ (void)openWebViewForNSURL:(NSURL *)requestURL title:(NSString *)title navigationController:(UINavigationController *)navigationController supportRotate:(BOOL)supportRotate;
+ (void)openWebViewForNSURL:(NSURL *)requestURL title:(NSString *)title navigationController:(UINavigationController *)navigationController supportRotate:(BOOL)supportRotate conditions:(NSDictionary *)parameters;

- (id)initWithSupportIPhoneRotate:(BOOL)supportIPhone;
- (void)setTitleText:(NSString *)title;
- (void)requestWithURLString:(NSString *)urlString;
- (void)requestWithURL:(NSURL *)url;
- (void)setDismissType:(SSWebViewDismissType)type;
- (void)setUpBackBtnControlForWeb:(NSNumber *)isWebControl;
- (void)setUpCloseBtnControlForWeb:(NSNumber *)isShow;
- (void)setupCloseCallBackPreviousVC:(NSDictionary *)params;
- (void)setupOpenPageTagStr:(NSString *)tagStr;
- (NSString *)getOpenPageTagStr;
/// 如果有adid，则上报impression
@property (nonatomic, copy) NSString        *adID;
@property (nonatomic, copy) NSString        *logExtra;
@property (nonatomic, copy) NSString         *webViewTrackKey;
@property (nonatomic, strong) NSString         *tagStr;
/// 问答在库中，无法继承这个类，暂时污染这里，到时候沉库的时候请一并带走，联系一下问答的人
@property (nonatomic, copy) NSDictionary *gdExtJsonDict;

@property (nonatomic, strong, readonly) SSWebViewControllerView * ssWebView;
@property (nonatomic, copy) NSString * titleImageName;

@property (nonatomic, assign, readonly) BOOL iphoneSupportRotate;
@property (nonatomic, assign, readonly) BOOL supportLandscapeOnly;

@property (nonatomic, assign) BOOL useSystemNavigationbarHeight; // 为了登录界面用户协议trick加的

@end

extern NSString *const  SSViewControllerBaseConditionADIDKey;

/**
 *  打开webview
 *
 *  @param requestURL     请求的连接
 *  @param title          title
 *  @param naviController navigation Controller
 *  @param supportRotate  是否支持旋转
 */
static inline void ssOpenWebView(NSURL * requestURL, NSString * title, UINavigationController * naviController, BOOL supportRotate, NSDictionary *parameters) {
    [SSWebViewController openWebViewForNSURL:requestURL title:title navigationController:naviController supportRotate:supportRotate conditions:parameters];
}
