//
//  PreloadManager.m
//  Article
//
//  Created by 朱斌 on 16/8/10.
//
//

#import "TTAdSiteWebPreloadManager.h"
#import "SSWebViewUtil.h"
#import <TTBaseLib/NetworkUtilities.h>

@implementation TTAdSiteWebPreloadManager

static TTAdSiteWebPreloadManager *preloadManager = nil;

void tt_ad_adSiteWebPreload(Article *article, UIView *listView) {
    [[TTAdSiteWebPreloadManager sharedManager] adSiteWebPreload:article listView:listView];
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        preloadManager = [[self alloc] init];
    });
    return preloadManager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        preloadManager = [super allocWithZone:zone];
    });
    return preloadManager;
}

- (NSMutableSet *)preloadURLSet {
    if (!_preloadURLSet) {
        _preloadURLSet = [[NSMutableSet alloc] init];
    }
    return _preloadURLSet;
}

- (void)adSiteWebPreload:(Article*)article listView:(UIView *)listView
{
    NSString *webURLString = article.articleURLString;
    // 如果预加载URL集合中不包含该URL，则进行预加载；如果已经预加载过，则不会再次进行预加载
    if (![[TTAdSiteWebPreloadManager sharedManager].preloadURLSet containsObject:webURLString]) {
        // 预加载建站广告时，将预加载URL加入set中
        [[TTAdSiteWebPreloadManager sharedManager].preloadURLSet addObject:webURLString];
        // 进行建站广告的预加载
        NSURL *webURL = [TTStringHelper URLWithURLString:webURLString];
        NSMutableDictionary *wapHeaders = [NSMutableDictionary dictionary];
        if ([article.wapHeaders isKindOfClass:[NSDictionary class]]) {
            [wapHeaders addEntriesFromDictionary:article.wapHeaders];
        }
        // 设置header，预加载资源数量设为*表示全部资源预加载
        [wapHeaders setObject:@"*" forKey:@"TOUTIAO-PRELOAD"];
        [SSWebViewUtil registerUserAgent:article.shouldUseCustomUserAgent];
        NSString *ua = [SSWebViewUtil userAgentString:article.shouldUseCustomUserAgent];
        [wapHeaders setValue:ua forKey:@"User-Agent"];
        
        NSURLRequest *request = nil;
        if (TTNetworkConnected()) {
            request = (NSMutableURLRequest *)[SSWebViewUtil requestWithURL:webURL httpHeaderDict:wapHeaders];
        } else {
            request = (NSMutableURLRequest *)[SSWebViewUtil requestWithURL:webURL httpHeaderDict:wapHeaders cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
        }
        // 预加载广告webview
        // WKWebView只能用于iOS8.0及以上系统的设备
        // 只有当WKWebView开关打开并且系统版本是8.0及以上，则使用WKWebView
        if ([SSCommonLogic WKWebViewEnabled] && [TTDeviceHelper OSVersionNumber] >= 8.0) {
            WKWebView *hiddenWebView = [[WKWebView alloc] initWithFrame:listView.frame];
            [hiddenWebView loadRequest:request];
            hiddenWebView.layer.opacity = 0.0;
            [listView addSubview:hiddenWebView];
        } else {
            for(UIView * view in listView.subviews){
                if (view.tag==1999) {
                    if ([view isKindOfClass:[UIWebView class]]) {
                        UIWebView * aWebView = (UIWebView *)view;
                        if (![aWebView isLoading]) {
                            aWebView.delegate = nil;
                            [aWebView removeFromSuperview];
                        }
                    }
                }
            }
            // 其它情况，所有版本的设备都采用UIWebView预加载
            UIWebView *hiddenWebView = [[UIWebView alloc] initWithFrame:listView.frame];
            [hiddenWebView loadRequest:request];
            hiddenWebView.layer.opacity = 0.0;
            hiddenWebView.tag = 1999;
            [listView addSubview:hiddenWebView];
        }
    }
}

@end
