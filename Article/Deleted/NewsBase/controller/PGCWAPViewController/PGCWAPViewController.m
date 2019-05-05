//
//  PGCWAPViewController.m
//  Article
//
//  Created by hudianwei on 15-1-19.
//
//

#import "PGCWAPViewController.h"
#import "ArticleJSBridgeWebView.h"
//#import "NSLayoutConstraint+Addtion.h"
#import "SSWebViewUtil.h"
#import "SSNavigationBar.h"
#import "ArticleTitleImageView.h"
#import "ExploreEntryHelper.h"
#import "ArticleURLSetting.h"
#import "SSWebViewController.h"
#import "ExploreEntryManager.h"

#import "NetworkUtilities.h"
#import "ExploreFetchEntryManager.h"
#import "SSWebViewContainer.h"
#import "SSWebViewControllerView.h"
#import "NewsUserSettingManager.h"
#import "TTViewWrapper.h"

#import "TTNavigationController.h"
#import "SSTracker.h"
#import "PGCAccountManager.h"
#import "TTToolService.h"
#import "TTFirstConcernManager.h"
#import <TTNetworkManager/TTNetworkManager.h>

#import "TTDeviceHelper.h"
#import "TTThemeManager.h"
#import "TTStringHelper.h"
#import "WDParseHelper.h"


@interface PGCWAPViewController ()<YSWebViewDelegate>
@property(nonatomic, strong)SSWebViewControllerView *webViewContainer;
@property(nonatomic, strong)ExploreFetchEntryManager *fetchEntryManager;
@property(nonatomic, strong)ExploreEntry *entry;
@property(nonatomic, copy)NSString *mediaID;

//page_type参数控制从视频列表进入pgc落地页只显示视频
@property (nonatomic, assign) NSInteger pageType;
@property (nonatomic, assign) BOOL pageTypeEnabled;
@property (nonatomic, copy) NSString *reuqestUrlString;
@property (nonatomic, strong) NSTimer * countDownTimer;
@property (nonatomic, strong) NSString *enterItemId;
@end


// 文章详情页右上角「…」
NSString * const kPGCProfileEnterSourceArticleMore = @"article_more";
// 文章详情页标题下
NSString * const kPGCProfileEnterSourceArticleTopAuthor = @"article_top_author";
// 文章详情页文末
NSString * const kPGCProfileEnterSourceArticleBottomAuthor = @"article_bottom_author";
// 订阅频道-已订阅的头条号
NSString * const kPGCProfileEnterSourceChannelSubscriptionSubscribed = @"channel_subscription_subscribed";
// 订阅频道-「订阅更多头条号页」-分类页
NSString * const kPGCProfileEnterSourceChannelSubscriptionCategory = @"channel_subscription_category";
// 视频详情页
NSString * const kPGCProfileEnterSourceVideoArticleTopAuthor = @"video_article_top_author";
// 视频频道feed右下角「…」
NSString * const kPGCProfileEnterSourceVideoFeedMore = @"video_feed_more";
// 视频频道feed中的头条号icon
NSString * const kPGCProfileEnterSourceVideoFeedAuthor = @"video_feed_author";
// 我的（作者看自己的头条号）
NSString * const kPGCProfileEnterSourceAccount = @"account";
// 我的（作者看自己的头条号的作品管理）
NSString * const kPGCProfileEnterWorkLibrarySourceAccount = @"work_library";

// 图集详情页右上角「...」
NSString * const kPGCProfileEnterSourceGalleryArticleMore = @"gallery_article_more";
// 图集详情页右上角的头条号icon
NSString * const kPGCProfileEnterSourceGalleryArticleTopAuthor = @"gallery_article_top_author";

NSString * const kPGCProfileEnterSourceVideoFloat = @"video_float_author";
// 从消息通知中的通知进入头条号首页
NSString * const kPGCProfileEnterSourceNotification = @"notification";
// 从我的主页订阅列表中进入
NSString * const kPGCProfileEnterSourceSocial = @"social";


@implementation PGCWAPViewController

- (void)dealloc
{
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

//- (id)initWithExploreEntry:(ExploreEntry *)aEntry enterSource:(NSString *)source {
//    NSString *mediaID = [NSString stringWithFormat:@"%@", aEntry.mediaID];
//    [PGCWAPViewController openWithMediaID:mediaID enterSource:source itemID:nil];
//    return self;
//}
//
//- (id)initWithPGCAccount:(PGCAccount *)account enterSource:(NSString *)source {
//    NSString *mediaID = [NSString stringWithFormat:@"%@", account.mediaID];
//    [PGCWAPViewController openWithMediaID:mediaID enterSource:source itemID:account.enterItemId];
//    return self;
//}

- (instancetype)initWithBaseCondition:(NSDictionary *)baseCondition
{
    self = [super initWithBaseCondition:baseCondition];
    if (self) {
        NSDictionary *params = [baseCondition objectForKey:kSSAppPageBaseConditionParamsKey];
        
        NSString *mediaID = [params tt_stringValueForKey:@"mediaid"];
        if (!mediaID) mediaID = [params tt_stringValueForKey:@"media_id"];
        if (!mediaID) mediaID = [params tt_stringValueForKey:@"entry_id"];
        
        if (mediaID) {
            self.mediaID = mediaID;
        } else {
            NSAssert(0, @"mediaID is empty");
            return nil;
        }
        
        if ([params.allKeys containsObject:@"page_type"]) {
            self.pageTypeEnabled = YES;
            self.pageType = [params[@"page_type"] integerValue];
        }
        
        self.enterItemId = [params valueForKey:@"item_id"];
        
        NSString *source = [params valueForKey:@"gd_ext_json"];
        
        if (![source isEqualToString:@"video_feed_author"]) {
            ssTrackEventWithCustomKeys(@"pgc_profile", @"enter", self.mediaID, nil, nil);
        }
        
        id sourceInfo = nil;
        
        if (!isEmptyString(source)) {
            sourceInfo = [NSJSONSerialization JSONObjectWithData:[source dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        }
        
        NSString *event = @"pgc_profile";
        
        BOOL isEnterMyPgc = NO;
        
        if ([mediaID isEqualToString:[[PGCAccountManager shareManager] currentLoginPGCAccount].mediaID]) {
            event = @"my_pgc_profile";
            isEnterMyPgc = YES;
        }
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:self.enterItemId forKey:@"item_id"];
        [dict setValue:[baseCondition valueForKey:@"group_id"] forKey:@"group_id"];

        if (!sourceInfo && !isEmptyString(source)) {//如果source是一个非json字符串
            sourceInfo = [WDParseHelper protectMethodGetDicFromString:source];
        }
        
        if ([sourceInfo isKindOfClass:[NSDictionary class]]) {
            [dict addEntriesFromDictionary:sourceInfo];
        }
        if (isEnterMyPgc) {
            [dict setValue:@"account" forKey:@"source"];
        }
        ssTrackEventWithCustomKeys(event, @"enter", mediaID, nil, dict);
    
    }
    return self;
}

+ (void)openWithMediaID:(NSString *)mediaID enterSource:(NSString *)source itemID:(NSString *)itemID {
    NSMutableString *linkURLString = [NSMutableString stringWithFormat:@"sslocal://media_account?media_id=%@", mediaID];
    if (!isEmptyString(source)) {
        [linkURLString appendFormat:@"&source=%@", source];
    }
    if (!isEmptyString(itemID)) {
        [linkURLString appendFormat:@"&item_id=%@", itemID];
    }
    NSURL *url = [TTStringHelper URLWithURLString:linkURLString];
    [[SSAppPageManager sharedManager] openURL:url];
}

- (CGRect)frameForWebView {
    
    CGFloat offsetY = 20;
    
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat padding = [SSCommonAppExtension paddingForViewWidth:0];
        CGRect rect = self.view.frame;
        rect.origin.y = offsetY;
        rect.size.height -= offsetY;
        return CGRectInset(rect, padding, 0);
    }
    return CGRectMake(0, offsetY,
                      CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - offsetY);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.webViewContainer.frame = [self frameForWebView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SSThemedView * baseView = [[SSThemedView alloc] initWithFrame:self.view.bounds];
    baseView.backgroundColorThemeKey = kColorBackground4;//@"BackgroundColor1";
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:baseView];
    
    self.webViewContainer = [[SSWebViewControllerView alloc] initWithFrame:self.view.bounds];
    [_webViewContainer.ssWebContainer.ssWebView addDelegate:self];
    _webViewContainer.showAddressBar = NO;
    [_webViewContainer enableMakeView:NO];
    _webViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if ([TTDeviceHelper isPadDevice]) {
        TTViewWrapper *wrapperView = [TTViewWrapper viewWithFrame:self.view.bounds targetView:_webViewContainer];
        [self.view addSubview:wrapperView];
    }
    else {
        [self.view addSubview:_webViewContainer];
    }
    
    self.ttHideNavigationBar = YES;
    UIView *backButtonView = self.webViewContainer.navigationBar.leftBarView;
    UIView *customeNavigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(backButtonView.frame), 44)];
    // customeNavigationBar.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:customeNavigationBar];
    [customeNavigationBar addSubview:backButtonView];
    backButtonView.left = 8;
    
    [self startLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSMutableDictionary * screenContext = [[NSMutableDictionary alloc] init];
    [screenContext setValue:self.mediaID forKey:@"media_id"];
    [TTLogManager logEvent:kEnterEvent context:nil screenName:kMediaHomeScreen screenContext:screenContext];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [TTLogManager logEvent:kLeaveEvent context:nil screenName:kMediaHomeScreen];
}

- (BOOL)webView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidFinishLoad:(nullable YSWebView *)webView{
    [self stopCountDownTimer];
}

- (void)webView:(nullable YSWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    [self stopCountDownTimer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)startLoad
{
    NSString *urlString = [NSString stringWithFormat:@"http://i.snssdk.com/pgc/m%@/", self.mediaID];
    
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    NSString *fontSizeType = [NewsUserSettingManager settedFontShortString];
    NSString *clientDialogShow = [TTFirstConcernManager firstTimeFollowPGCGuideEnabledForPGCWapViewController]? @"?client_dialog_show=true" : @"?client_dialog_show=false";
    urlString =[urlString stringByAppendingString:clientDialogShow];
    if (self.pageTypeEnabled) {
        urlString = [urlString stringByAppendingFormat:@"&page_type=%ld", (long)self.pageType];
    }
    urlString = [urlString stringByAppendingFormat:@"&ab_client=%@",[TTToolService ABTestClient]];
    urlString = [urlString stringByAppendingFormat:@"#tt_daymode=%d&tt_font=%@", isDayModel, fontSizeType];
    NSURL *url = [TTStringHelper URLWithURLString:urlString];
    [_webViewContainer loadWithURL:url];
    self.reuqestUrlString = url.absoluteString;
    [self startCountDownTimer];
}


- (void)startCountDownTimer{
    if (![SSCommonLogic enabledWhitePageMonitor]) {
        return;
    }
    if (self.countDownTimer) {
        if ([self.countDownTimer isValid]) {
            [self.countDownTimer invalidate];
        }
        self.countDownTimer = nil;
    }
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(guardTimerExceeded:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.countDownTimer forMode:NSRunLoopCommonModes];
}

- (void)stopCountDownTimer{
    if (self.countDownTimer) {
        if ([self.countDownTimer isValid]) {
            [self.countDownTimer invalidate];
        }
        self.countDownTimer = nil;
    }
}

- (void)guardTimerExceeded:(id)sender{
//    NSLog(@"PGCWAPViewController guardTimer");
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:self.reuqestUrlString forKey:@"url"];
    NSURL * url = [NSURL URLWithString:self.reuqestUrlString];
    if (url) {
        [params setValue:[url host] forKey:@"hostname"];
    }
    [params setValue:@"media_profile" forKey:@"pathname"];
    [params setValue:@"fail" forKey:@"page_status"];
    [params setValue:[TTInfoHelper connectMethodName] forKey:@"net_type"];
    [self stopCountDownTimer];
//    [[TTMonitor shareManager] trackData:params logType:@"empty_webview"];
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:@"http://toutiao.com/__utm.gif" params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj) {
        if (error.code == TTNetworkErrorCodeSuccess) {
            NSString * decodeStr = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
            if (!isEmptyString(decodeStr)) {
            }
        }
    }];
}

@end

