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
#import "FHErrorView.h"
#import <FHEnvContext.h>
#import "Masonry.h"
#import "NewsListLogicManager.h"
#import <SSCommonLogic.h>
#import <TTUIResponderHelper.h>

@interface ArticleWebListView()<YSWebViewDelegate>
@property(nonatomic, retain)SSWebViewContainer * webContainer;
@property(nonatomic, copy)NSString * categoryID;  // 频道ID
@property(nonatomic, copy)NSString * currentRequestUrl;  // 当前频道链接
@property(nonatomic, strong)NSMutableDictionary *webContainerCache;
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
        
        self.webContainer = [[SSWebViewContainer alloc] initWithFrame:[self frameForListView] baseCondition:@{@"use_wk":@(YES)}];
        [_webContainer.ssWebView addDelegate:self];
        [_webContainer hiddenProgressView:YES];
        if (@available(iOS 11.0 , *)) {
            _webContainer.ssWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _webContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _webContainer.ssWebView.opaque = NO;
        _webContainer.ssWebView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
        _webContainer.disableEndRefresh = YES;
        _webContainer.disableConnectCheck = YES;
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
                                                          self.currentRequestUrl = url;
                                                          [self.webContainer.ssWebView loadRequest:request];
                                                          if (self.delegate && [self.delegate respondsToSelector:@selector(listViewStartLoading:)]) {
                                                              [self.delegate listViewStartLoading:self];
                                                          }
                                                          
                                                      }];
        
//        [_webContainer setTtContentInset:UIEdgeInsetsMake(topInset, 0, bottomInset, 0)];
//        [_webContainer.ssWebView.scrollView setContentInset:UIEdgeInsetsMake(topInset, 0, bottomInset, 0)];
        
        [self registerIsVisibleJSBridgeHandler];
        
        
        if (![FHEnvContext isNetworkConnected]) {
            FHErrorView * noDataErrorView = [[FHErrorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.7)];
            //        [noDataErrorView setBackgroundColor:[UIColor redColor]];
            [self addSubview:noDataErrorView];
            
            __weak typeof(self) weakSelf = self;
            FHErrorView * noDataErrorViewWeak = noDataErrorView;
            noDataErrorView.retryBlock = ^{
                if (weakSelf.webContainer.ssWebView.request && [FHEnvContext isNetworkConnected]) {
                    [noDataErrorViewWeak hideEmptyView];
                    [weakSelf.webContainer.ssWebView loadRequest:weakSelf.webContainer.ssWebView.request];
                }
            };
            
            [noDataErrorView showEmptyWithTip:@"网络异常,请检查网络链接" errorImageName:@"group-4"
                                    showRetry:YES];
            noDataErrorView.retryButton.userInteractionEnabled = YES;
            [noDataErrorView.retryButton setTitle:@"刷新" forState:UIControlStateNormal];
            [noDataErrorView setBackgroundColor:self.backgroundColor];
            [noDataErrorView.retryButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(104, 30));
            }];
        }
        
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.webContainer.frame = [self frameForListView];
    
}

- (BOOL)needTrackVisibleInvisibleByJS
{
    return YES;
    //    return [self.currentCategory.categoryID isEqualToString:kTTTeMaiCategoryID];
}

- (void)registerIsVisibleJSBridgeHandler
{
    [self.webContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        if (callback) {
            callback(TTRJSBMsgSuccess, @{@"code": @(_isVisible)});
        }
    } forMethodName:@"is_visible"];
    
    [self.webContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(listViewStopLoading:)]) {
            [self.delegate listViewStopLoading:self];
        }
        [_webContainer tt_endUpdataData];
        [_webContainer.ssWebView.scrollView  finishPullDownWithSuccess:YES];
        if (callback) {
            callback(TTRJSBMsgSuccess, @{@"code": @(1)});
        }
        
    } forMethodName:@"hideLoading"];
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
    _webContainer.ssWebView.scrollView.bounces = NO;
    if (![self.currentCategory.categoryID isEqualToString:category.categoryID] || fromRemote || ![self.currentCategory.webURLStr isEqualToString:category.webURLStr]) {
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
        
        if(![self.currentRequestUrl isEqualToString:url])
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(listViewStartLoading:)]) {
                [self.delegate listViewStartLoading:self];
            }
            [_webContainer tt_startUpdate];
            [_webContainer.ssWebView loadRequest:request];
            [ _webContainer.ssWebView ttr_fireEvent:@"update" data:nil];
        }
        self.currentRequestUrl = url;
        //记录用户下拉刷新时间
        [[NewsListLogicManager shareManager] saveHasReloadForCategoryID:self.currentCategory.categoryID];
    }
    
    
}

- (void)finishLoadingWeb
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(listViewStopLoading:)]) {
        [self.delegate listViewStopLoading:self];
    }
    [_webContainer.ssWebView.scrollView  finishPullDownWithSuccess:YES];
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
    //      [_webContainer.ssWebView stringByEvaluatingJavaScriptFromString:@"window.TouTiao && TouTiao.update()" completionHandler:nil];
    //[_webContainer.ssWebView reload];
    //    [_webContainer.ssWebView.scrollView triggerPullDown];
    
    [ _webContainer.ssWebView ttr_fireEvent:@"update" data:nil];
    
}


- (void)scrollToTopEnable:(BOOL)enable
{
    _webContainer.ssWebView.scrollView.scrollsToTop = enable;
}


#pragma mark -- UIWebViewDelegate

- (void)webViewDidFinishLoad:(YSWebView *)webView
{
    //    if (self.currentRequestUrl) {
    //        if (self.delegate && [self.delegate respondsToSelector:@selector(listViewStopLoading:)]) {
    //            [self.delegate listViewStopLoading:self];
    //        }
    //        [_webContainer.ssWebView.scrollView  finishPullDownWithSuccess:YES];
    //    }
    //    [_webContainer.ssWebView.scrollView  finishPullDownWithSuccess:YES];
    
}

- (void)webViewDidStartLoad:(YSWebView *)webView
{
    //    if (self.delegate && [self.delegate respondsToSelector:@selector(listViewStartLoading:)]) {
    //        [self.delegate listViewStartLoading:self];
    //    }
}

- (void)webView:(YSWebView *)webView didFailLoadWithError:(NSError *)error {
    [_webContainer tt_endUpdataData];
    [_webContainer.ssWebView.scrollView  finishPullDownWithSuccess:YES];
}

@end
