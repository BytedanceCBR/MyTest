//
//  TTVFeedWebCellContentView.m
//  Article
//
//  Created by panxiang on 2017/4/19.
//
//

#import "TTVFeedWebCellContentView.h"
#import <libextobjc/extobjc.h>
#import "ExploreArticleWebCellView.h"
#import "ArticleCityView.h"
#import "ExploreMixListDefine.h"
#import "TTVTopWebCell+Extension.h"
#import "TTVFeedItem+Extension.h"
#import "TTVFeedListWebCellService.h"
#import "TTVideoDislikeMessage.h"
#import "TTMessageCenter.h"
#import "TTRoute.h"
#import <AKWebViewBundlePlugin/SSJSBridgeWebView.h>

extern NSDictionary *tt_ttuisettingHelper_cellViewUISettingsDictionary(void);

@interface TTVFeedWebCellContentView () <YSWebViewDelegate>

@property(nonatomic,strong)SSJSBridgeWebView *webView;
@property(nonatomic,strong)SSThemedView *bottomLineView;
@property(nonatomic,strong)UIView *maskView;
@property(nonatomic,strong)SSThemedLabel *infoLabel;

@property(nonatomic,strong)NSMutableData *receivedData;
@property(nonatomic,copy)NSString *htmlString;
@property(nonatomic,copy)NSString *jsonString;
@property(nonatomic,assign)BOOL isLoading;
@property(nonatomic,assign)BOOL isCellDisplay;

@property (nonatomic, strong) TTVTopWebCell *wapData;
@property(nonatomic,strong)NSDate *lastUpdateTime;
@property(nonatomic,copy)NSString *categoryID;

@property (nonatomic, strong) TTVFeedListWebCellService *webCellService;

@end

@implementation TTVFeedWebCellContentView

+ (CGFloat)obtainHeightForFeed:(TTVFeedListWebItem *)cellEntity cellWidth:(CGFloat)width
{
    TTVTopWebCell *wapData = cellEntity.originData.webCell;
    if (wapData && !isEmptyString(wapData.templateContent)) {
        if (wapData.cellHeightChanged) {
            return wapData.cellHeightChanged;
        }
    }
    return MAX(wapData.cellHeight, 0);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.webView.scrollView removeObserver:self forKeyPath:@keypath(self.webView.scrollView, contentSize)];
    [self.webView removeDelegate:self];
    self.webView.delegate = nil;
    self.webView = nil;
}

- (void)setWebItem:(TTVFeedListWebItem *)webItem
{
    _webItem = webItem;
    _wapData = webItem.originData.webCell;
    _categoryID = webItem.categoryId;
    
    [self configureUI];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _webCellService = [[TTVFeedListWebCellService alloc] init];
        
        self.webView = [[SSJSBridgeWebView alloc] initWithFrame:self.bounds];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _webView.scrollView.scrollEnabled = YES;
        _webView.scrollView.scrollsToTop = NO;
        _webView.scrollView.bounces = NO;
        _webView.backgroundColor = [UIColor clearColor];
        _webView.opaque = NO;
        _webView.userInteractionEnabled = YES;
        [_webView addDelegate:self];
        [self registerPanelClose];
        [self registerPanelHeight];
        [self registerPanelDislike];
        [self registerPanelRefresh];
        [self addSubview:_webView];
        
        [_webView.scrollView addObserver:self forKeyPath:@keypath(self.webView.scrollView, contentSize) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
        self.infoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, 120, 14)];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.textColors = @[@"999999", @"707070"];
        _infoLabel.font = [UIFont systemFontOfSize:12.f];
        [_maskView addSubview:_infoLabel];
        _infoLabel.center = CGPointMake(self.width/2, self.height/2);
        _infoLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        self.bottomLineView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_bottomLineView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCityDidChangedNotification:) name:kArticleCityDidChangedNotification object:nil];
    }
    return self;
}

// 关闭垂直频道内webview面板
- (void)registerPanelDislike
{
    __weak __typeof(self)weakSelf = self;
    
    //跟原有保持一致.. 不进行回调
    [self.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        
        // FIX: WapData有时候在数据库中查不到，实际上是在列表上的，这里先fix一下，
        // 直接给webCell发送通知，该webCell收到通知后发不感兴趣通知并附带itemKey
        [weakSelf dislikeCell:nil];
        
    } forMethodName:@"panelDislike"];
}

- (void)registerPanelClose
{
    __weak __typeof(self)weakSelf = self;
    
    [self.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        
        [weakSelf closeCell:nil];
        
    } forMethodName:@"panelClose"];
}

- (void)registerPanelHeight
{
    __weak __typeof(self)weakSelf = self;
    
    [self.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        
        float height = [result floatValueForKey:@"value" defaultValue:-1.0f];
        
        if (height >= 0) {
            [weakSelf receiveWebCellHeightDidChangedNotification:@(height)];
        }
        
    } forMethodName:@"panelHeight"];
}

// 主动刷新垂直频道内webview面板
- (void)registerPanelRefresh
{
    __weak __typeof(self)weakSelf = self;
    [self.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        
//        NSNumber *gid = [result objectForKey:@"id"];
        [weakSelf receiveRefreshWebCellNotification:result];
        
        
    } forMethodName:@"panelRefresh"];
}

- (void)configureUI
{
    BOOL shouldReloadTemplate = NO;
    
    if (!_wapData || !_wapData.templateContent || ![self.htmlString isEqualToString:_wapData.templateContent]) {
        shouldReloadTemplate = YES;
    }
    
    if (shouldReloadTemplate) {
        _isLoading = NO;
        _jsonString = nil;
        _lastUpdateTime = nil;
        
        if (_htmlString) {
            _htmlString = nil;
            //[self loadHTMLString:@"" baseURL:nil];
            _wapData.hasTemplateLoaded = NO;
        }
        _infoLabel.text = NSLocalizedString(@"加载中...", nil);
        _maskView.hidden = NO;
    }
    
    _isCellDisplay = YES;
    
    if (!_htmlString || !self.wapData.templateContent || ![_htmlString isEqualToString:self.wapData.templateContent] || !self.wapData.hasTemplateLoaded) {
        if (!isEmptyString(self.wapData.templateContent)) {
            [self loadHTMLString:self.wapData.templateContent baseURL:[TTStringHelper URLWithURLString:self.wapData.baseUrl]];
        } else {
            @weakify(self);
            [_webCellService startGetTemplateFromWapData:self.wapData completion:^(TTVTopWebCell *wapData, NSString *htmlStr, NSError *error) {
                @strongify(self);
                if (self.wapData.id_p == wapData.id_p) {
                    if (!error && !isEmptyString(htmlStr)) {
                        [self loadHTMLString:htmlStr baseURL:[TTStringHelper URLWithURLString:self.wapData.baseUrl]];
                    }
                }
            }];
        }
    } else {
        if (!isEmptyString(self.wapData.dataURL)) {
            if (!self.lastUpdateTime) {
                [self refreshWebData];
            } else {
                if ((self.lastUpdateTime && fabs([self.lastUpdateTime timeIntervalSinceNow]) > self.wapData.refreshInterval) || self.wapData.needRefreshUI) {
                    [self refreshWebData];
                }
            }
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat linePadding = 0;
    self.bottomLineView.frame = CGRectMake(linePadding,  self.height-[TTDeviceHelper ssOnePixel], self.width - linePadding * 2, [TTDeviceHelper ssOnePixel]);
    if (self.webItem.cellSeparatorStyle == TTVFeedListCellSeparatorStyleHas) {
        self.bottomLineView.hidden = NO;
    } else if (self.webItem.cellSeparatorStyle == TTVFeedListCellSeparatorStyleNone) {
        self.bottomLineView.hidden = YES;
    }
}

- (void)refreshDayMode {
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.TouTiao && TouTiao.setDayMode(%d)", isDayModel] completionHandler:nil];
}
//服务端控制webcell的部分UI
- (void)refreshCunstomStyle{
    NSDictionary * cellViewUICustomStyleDictionary = tt_ttuisettingHelper_cellViewUISettingsDictionary();
    if ([cellViewUICustomStyleDictionary isKindOfClass:[NSDictionary class]] && [cellViewUICustomStyleDictionary count] > 0) {
        NSString *json = [cellViewUICustomStyleDictionary JSONRepresentation];
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.TouTiao && TouTiao.setCustomStyle(%@)", json] completionHandler:nil];
    }
}

#pragma mark - YSWebViewDelegate

- (BOOL)webView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType {
    
    if ([request.URL.scheme isEqualToString:@"sslocal"]) {
        
        self.wapData.needRefreshUI = YES;
        /// 如果是SSLocal的，则统一处理
        if ([TTDeviceHelper isPadDevice] && [[request.URL absoluteString] hasPrefix:@"sslocal://choose_city"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kExploreWebCellChooseCityNotification object:nil userInfo:@{@"categoryID":self.categoryID}];
        } else {
            [[TTRoute sharedRoute] openURLByPushViewController:request.URL];
        }
        
        
        //点击wap_cell的统计
        
        NSString * screenName = [NSString stringWithFormat:@"channel_%@",self.categoryID];
        NSMutableDictionary * eventContext = [[NSMutableDictionary alloc] init];
        [eventContext setValue:@"wap_cell" forKey:@"cell_type"];
        [eventContext setValue:@(self.wapData.id_p) forKey:@"group_id"];
        [eventContext setValue:@(self.wapData.id_p) forKey:@"ad_id"];
//        [TTLogManager logEvent:@"click_cell" context:eventContext screenName:screenName];
        
        return NO;
        
    }
    else if([request.URL.scheme isEqualToString:@"bytedance"]) {
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(YSWebView *)webView {
    if (!isEmptyString(_htmlString)) {
        self.wapData.hasTemplateLoaded = YES;
        [self refreshCunstomStyle];
        [self refreshDayMode];
        
        // 加载缓存数据
        if (self.wapData.dataContent) {
            NSDictionary *content = self.wapData.dataContent;
            [self updateWebWithData:content];
        }
        
        //        [self reloadCellIfNeeded];
        if (!_maskView.hidden) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _maskView.hidden = YES;
            });
        }
        
        if (self.wapData.shouldReloadCell) {
            [self reloadCell];
            self.wapData.shouldReloadCell = NO;
        }
        
        [self refreshWebData];
    }
}

- (void)webView:(YSWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"WebView FailLoad...");
}

- (void)reloadCellIfNeeded {
    if (self.height <= 1 && self.wapData.id_p > 0) {
        float changedCellH = self.wapData.cellHeightChanged;
        float origCellH = self.wapData.cellHeight;
        float destCellH = changedCellH > 0 ? changedCellH : origCellH;
        
        if (destCellH > 0 && destCellH != self.height) {
            // 模板加载完成后，如果当前view高度为0，表示是第一次加载模板，需要通知列表reload
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kTTVWebCellDidUpdateNotification object:self.webItem];
            });
        }
    }
}

- (void)reloadCell
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTVWebCellDidUpdateNotification object:self.webItem];
    });
    
}

- (void)refreshWebData {
    if (_isLoading) {
        return;
    }
    
    if (!_isCellDisplay) {
        if (self.lastUpdateTime && fabs([self.lastUpdateTime timeIntervalSinceNow]) > self.wapData.refreshInterval) {
            return;
        }
    }
    
    _isLoading = YES;
    
    @weakify(self);
    [_webCellService startGetDataFromWapData:self.wapData completion:^(TTVTopWebCell *wapData, NSDictionary *dict, NSError *error) {
        @strongify(self);
        if (self.wapData.id_p == wapData.id_p) {
            NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:self.wapData.dataContent];
            if (!error) {
                [mDict setValue:@"success" forKey:@"message"];
                [self updateWebWithData:[mDict copy]];
                
                // 防止模板加载后cell高度仍为0
                [self reloadCellIfNeeded];
            }
            else {
                [mDict setValue:@"error" forKey:@"message"];
                [self updateWebWithData:[mDict copy]];
            }
            self.isLoading = NO;
        }
    }];
}

- (void)updateWebWithData:(NSDictionary *)dict {
    if ([self.lastUpdateTime isEqualToDate:self.wapData.lastUpdateTime]) {
        //NSLog(@"data update time is equal");
        return;
    }
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [mDict setValue:@(self.wapData.id_p) forKey:@"id"];
    [mDict setValue:self.categoryID forKey:@"category"];
    
    NSString *messageJSON = [mDict JSONRepresentation];
    NSString *jsMethod = self.wapData.dataCallback;
    if (!isEmptyString(jsMethod)) {
        self.jsonString = [NSString stringWithFormat:@"%@(%@)", jsMethod, messageJSON];
        if (!isEmptyString(self.htmlString)) {
            [self.webView stringByEvaluatingJavaScriptFromString:self.jsonString completionHandler:nil];
            self.lastUpdateTime = self.wapData.lastUpdateTime;
            //NSLog(@"jsonString: %@", self.jsonString);
        } else {
            //NSLog(@"html %@", self.htmlString);
        }
    }
}

- (BOOL)shouldRefresh {
    if (self.wapData) {
        return self.wapData.needRefreshUI;
    }
    return NO;
}

- (void)refreshDone {
    if (self.wapData) {
        self.wapData.needRefreshUI = NO;
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    [self.webView stopLoading];
    
    [self.webView loadHTMLString:string baseURL:baseURL];
    self.htmlString = string;
}

- (void)didEndDisplaying {
    _isCellDisplay = NO;
    
}

#pragma mark - notifications

- (void)themeChanged:(NSNotification *)notification
{
    _maskView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    if (!isEmptyString(self.wapData.templateContent)) {
        [self refreshDayMode];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    if (_isCellDisplay) {
        [self refreshWebData];
    }
}

/// 切换城市时标记一下需要更新数据（如果未来有类似的case，此处依旧是坑，根本原因是列表变化和wapData变化没有关联，wapData的id都是一样的）
- (void)receiveCityDidChangedNotification:(NSNotification *)notification
{
    if ([self.categoryID isEqualToString:kTTNewsLocalCategoryID]) {
        self.wapData.needRefreshUI = YES;
    }
}

- (void)receiveRefreshWebCellNotification:(NSDictionary *)result
{
    if ([result isKindOfClass:[NSDictionary class]] && [result[@"id"] isKindOfClass:[NSNumber class]]) {
        if ([result[@"id"] longLongValue] == self.wapData.id_p) {
            [self refreshWebData];
        }
    }
}

- (void)receiveWebCellHeightDidChangedNotification:(NSNumber *)heightNum
{
    if (heightNum && [heightNum isKindOfClass:[NSNumber class]] && self.wapData.cellHeightChanged != [heightNum floatValue]) {
        self.wapData.cellHeightChanged = [heightNum floatValue];
        [self.wapData saveIt];
        
        if (self.wapData.hasTemplateLoaded) {
            [self reloadCell];
        } else {
            self.wapData.shouldReloadCell = YES;
        }
    }
}

- (void)dislikeCell:(NSNotification *)notification
{
    SAFECALL_MESSAGE(TTVideoDislikeMessage, @selector(message_dislikeWithCellEntity:hideTip:), message_dislikeWithCellEntity:self.webItem hideTip:NO);
}

- (void)closeCell:(NSNotification *)notification
{
    SAFECALL_MESSAGE(TTVideoDislikeMessage, @selector(message_dislikeWithCellEntity:hideTip:), message_dislikeWithCellEntity:self.webItem hideTip:YES);
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@keypath(self.webView.scrollView, contentSize)] && ![[change objectForKey:NSKeyValueChangeOldKey] isEqualToValue:[change objectForKey:NSKeyValueChangeNewKey]] ) {
        _webView.scrollView.contentSize = CGSizeMake(_webView.scrollView.contentSize.width, self.height);
    }
}

@end
