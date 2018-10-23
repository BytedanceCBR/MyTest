//
//  ArticleWebListView.m
//  Article
//
//  Created by Zhang Leonardo on 13-6-7.
//
//

#import "ArticleWebListView.h"
#import "SSWebViewContainer.h"
//#import "TTCategoryStayTrackManager.h"
#import "TTArticleCategoryManager.h"
#import "UIScrollView+Refresh.h"
#import "TTViewWrapper.h"
#import "TTThemeManager.h"
#import "TTStringHelper.h"
#import "TTDeviceHelper.h"
#import "UIView+Refresh_ErrorHandler.h"

#import "NewsListLogicManager.h"

@interface ArticleWebListView()<YSWebViewDelegate>
@property(nonatomic, retain)SSWebViewContainer * webContainer;
@property(nonatomic, copy)NSString * categoryID;  // 频道ID
@end

@implementation ArticleWebListView

@synthesize isVisible = _isVisible;

- (void)dealloc
{
    self.webContainer = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame topInset:(CGFloat)topInset bottomInset:(CGFloat)bottomInset
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];

        self.webContainer = [[SSWebViewContainer alloc] initWithFrame:[self frameForListView]];
        [_webContainer.ssWebView addDelegate:self];
        [_webContainer hiddenProgressView:YES];
        _webContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _webContainer.ssWebView.opaque = NO;
        _webContainer.ssWebView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
        
        if ([TTDeviceHelper isPadDevice]) {
            TTViewWrapper *wrapperView = [[TTViewWrapper alloc] initWithFrame:self.bounds];
            [wrapperView addSubview:self.webContainer];
            wrapperView.targetView = self.webContainer;
            [self addSubview:wrapperView];
        }
        else {
            [self addSubview:_webContainer];
        }

        WeakSelf;
        NSString *loadingText = [SSCommonLogic isNewPullRefreshEnabled] ? nil : @"推荐中";
        [_webContainer.ssWebView.scrollView addPullDownWithInitText:@"下拉推荐"
                                  pullText:@"松开推荐"
                               loadingText:loadingText
                                noMoreText:@"暂无新数据"
                                  timeText:nil
                               lastTimeKey:nil
                             actionHandler:^{
            StrongSelf;
            NSString * url = self.currentCategory.webURLStr;
            if (isEmptyString(url)) {
                return;
            }
            
            // 频道下拉刷新统计
            if (self.webContainer.ssWebView.scrollView.pullDownView.isUserPullAndRefresh) {
                [self trackPullDownEventForLabel:@"refresh_pull"];
            }
            
            if ([self supportJS]) {//支持js
                
                if ([url rangeOfString:@"#"].location == NSNotFound) {
                    url = [NSString stringWithFormat:@"%@#tt_from=app&tt_daymode=%i", url, [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? 1 : 0];
                }
                else {
                    url = [NSString stringWithFormat:@"%@&tt_daymode=%i", url, [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? 1 : 0];
                }
            }
            NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[TTStringHelper URLWithURLString:url]];
            [self.webContainer.ssWebView loadRequest:request];

        }];
        
        [_webContainer setTtContentInset:UIEdgeInsetsMake(topInset, 0, bottomInset, 0)];
        [_webContainer.ssWebView.scrollView setContentInset:UIEdgeInsetsMake(topInset, 0, bottomInset, 0)];
        
        [self registerIsVisibleJSBridgeHandler];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.webContainer.frame = [self frameForListView];
    
}

- (BOOL)needTrackVisibleInvisibleByJS
{
    return [self.currentCategory.categoryID isEqualToString:kTTTeMaiCategoryID];
}

- (void)registerIsVisibleJSBridgeHandler
{
    [self.webContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        if (callback) {
            callback(TTRJSBMsgSuccess, @{@"code": @(_isVisible)});
        }
    } forMethodName:@"is_visible"];
}

- (void)setIsVisible:(BOOL)isVisible
{
    if (_isVisible != isVisible) {
        _isVisible = isVisible;
        [self invokeVisibleInVisibleJS];
    }
}

- (void)invokeVisibleInVisibleJS
{
    if ([self needTrackVisibleInvisibleByJS])
    {
        if (_isVisible) {
            [self.webContainer.ssWebView ttr_fireEvent:@"visible" data:@{@"code": @1}];
        } else {
            [self.webContainer.ssWebView ttr_fireEvent:@"invisible" data:@{@"code": @1}];
        }
    }
}

- (CGRect)frameForListView
{
    CGRect rect = self.bounds;
    rect.size.height -= self.bottomInset;
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat padding = [TTUIResponderHelper paddingForViewWidth:0];
        return CGRectInset(rect, padding, 0);
    }
    return rect;
}

- (void)refreshListViewForCategory:(TTCategory *)category isDisplayView:(BOOL)display fromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote reloadFromType:(ListDataOperationReloadFromType)fromType
{
    BOOL needReload = NO;
    if (![self.currentCategory.categoryID isEqualToString:category.categoryID] || fromRemote) {
        needReload = YES;
    }
    [super refreshListViewForCategory:category isDisplayView:display fromLocal:fromLocal fromRemote:fromRemote reloadFromType:fromType];
    
    if (![self.categoryID isEqualToString:self.currentCategory.categoryID]) {
        // 清空页面
        [_webContainer.ssWebView stringByEvaluatingJavaScriptFromString:@"document.write('')" completionHandler:nil];
        needReload = YES;
        
        self.categoryID = self.currentCategory.categoryID;
        
        self.modeChangeActionType = [self supportJS] ? ModeChangeActionTypeCustom : ModeChangeActionTypeMask;
        
        [self reloadThemeUI];
    }
    
    if (self.currentCategory.listDataType == ListDataTypeWeb && needReload) {
        NSString * url = self.currentCategory.webURLStr;
        if (isEmptyString(url)) {
            return;
        }
        if ([self supportJS]) {//支持js

            if ([url rangeOfString:@"#"].location == NSNotFound) {
                url = [NSString stringWithFormat:@"%@#tt_from=app&tt_daymode=%i", url, [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? 1 : 0];
            }
            else {
                url = [NSString stringWithFormat:@"%@&tt_daymode=%i", url, [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? 1 : 0];
            }
        }
        
        NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[TTStringHelper URLWithURLString:url]];
        [_webContainer.ssWebView loadRequest:request];
        
        
        //记录用户下拉刷新时间
        [[NewsListLogicManager shareManager] saveHasReloadForCategoryID:self.currentCategory.categoryID];
    }
}

- (void)willAppear
{
    [super willAppear];
}

- (void)willDisappear
{
    [super willDisappear];
}

- (BOOL)supportJS
{
    if ((self.currentCategory.flags & TTCategoryModelFlagTypeWapCategorySupportJS) > 0) {//支持js
        return YES;
    }
    if ([self.currentCategory.categoryID isEqualToString:@"worldcup_subject"]) {
        return YES;
    }
    return NO;
}

- (void)themeChanged:(NSNotification *)notification
{
    if ([self supportJS]) {//支持js
        [_webContainer.ssWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.TouTiao && TouTiao.setDayMode(%i)", [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? 1 : 0] completionHandler:nil];
    }
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    _webContainer.ssWebView.backgroundColor = self.backgroundColor;
}

- (void)pullAndRefresh
{
    //[_webContainer.ssWebView reload];
    [_webContainer.ssWebView.scrollView triggerPullDown];
}


- (void)scrollToTopEnable:(BOOL)enable
{
    _webContainer.ssWebView.scrollView.scrollsToTop = enable;
}


#pragma mark -- UIWebViewDelegate

- (void)webViewDidFinishLoad:(YSWebView *)webView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(listViewStopLoading:)]) {
        [self.delegate listViewStopLoading:self];
    }
    [_webContainer.ssWebView.scrollView  finishPullDownWithSuccess:YES];
}

- (void)webViewDidStartLoad:(YSWebView *)webView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(listViewStartLoading:)]) {
        [self.delegate listViewStartLoading:self];
    }
}

- (void)webView:(YSWebView *)webView didFailLoadWithError:(NSError *)error {

    [_webContainer.ssWebView.scrollView  finishPullDownWithSuccess:YES];
}

@end
