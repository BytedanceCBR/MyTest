//
//  TTDetailWebviewContainer.m
//  Article
//
//  Created by yuxin on 4/7/16.
//
//

#import "TTDetailWebviewContainer.h"

#import "TTNewDetailWebviewContainer.h"
#import "TTOriginalDetailWebviewContainer.h"

@implementation TTDetailWebviewContainer

- (id)initWithFrame:(CGRect)frame disableWKWebView:(BOOL)disableWKWebView hiddenWebView:(SSJSBridgeWebView *)hiddenWebView webViewDelegate:(SSJSBridgeWebViewDelegate *)jsBridgeDelegate {

    return [self initWithFrame:frame disableWKWebView:disableWKWebView ignoreGlobalSwitchKey:NO hiddenWebView:hiddenWebView webViewDelegate:jsBridgeDelegate];

    return self;
}

- (nullable id)initWithFrame:(CGRect)frame disableWKWebView:(BOOL)disableWKWebView ignoreGlobalSwitchKey:(BOOL)ignore hiddenWebView:(SSJSBridgeWebView * _Nullable)hiddenWebView webViewDelegate:(SSJSBridgeWebViewDelegate * _Nullable)jsBridgeDelegate {

    if ([self.class newNatantStyleEnabled]) {
        self = [[TTNewDetailWebviewContainer alloc] initWithFrame:frame disableWKWebView:disableWKWebView ignoreGlobalSwitchKey:ignore hiddenWebView:hiddenWebView webViewDelegate:jsBridgeDelegate];
    } else {
        self = [[TTOriginalDetailWebviewContainer alloc] initWithFrame:frame disableWKWebView:disableWKWebView ignoreGlobalSwitchKey:ignore hiddenWebView:hiddenWebView webViewDelegate:jsBridgeDelegate];
    }
    return self;
}
- (void)addFooterView:(nonnull UIView<TTDetailFooterViewProtocol> *)footerView detailFooterAddType:(TTDetailNatantStyle)natantStyle {
    
}

- (void)setWebContentOffset:(CGPoint)offset {
    
}

- (void)removeFooterView {

}

- (void)openFooterView:(BOOL)isSendComment{

}

- (void)closeFooterView {
    
}

- (void)openFirstCommentIfNeed {
    
}

- (void)insertDivToWebViewIfNeed {
    
}

- (void)removeDivFromWebViewIfNeeded {
    
}

- (BOOL)isNatantViewVisible {
    return NO;
}

- (BOOL)isCommentVisible {
    return NO;
}

- (BOOL)isNatantViewOnOpenStatus {
    return NO;
}

- (BOOL)isManualPullFooter {
    return NO;
}

- (void)removeNatantLoadingView {
}

- (BOOL)isNewWebviewContainer {
    return NO;
}
//获取最大进度
- (float)readPCTValue {
    return 0.f;
}

//webview页数
- (NSInteger)pageCount {
    return 0;
}

// 获取文章（分段后）每段内容的停留时长（格式：item_impression）
- (nonnull NSMutableDictionary *)readUnitStayTimeImpressionGroup {
    return nil;
}

- (void)refreshNatantLocation {
    
}

+ (BOOL)newNatantStyleEnabled {
    
    //settings没有下发 默认为YES
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"SSCommonLogicNewNatantStyleServerSettingKey"]) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"SSCommonLogicNewNatantStyleServerSettingKey"];
}
@end
