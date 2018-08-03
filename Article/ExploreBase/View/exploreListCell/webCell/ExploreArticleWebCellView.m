//
//  ExploreArticleWebCellView.m
//  Article
//
//  Created by Chen Hong on 15/1/8.
//
//

#import "ExploreArticleWebCellView.h"
#import "ExploreArticleCellViewConsts.h"
#import "SSThemed.h"

#import "TTRoute.h"
#import <TTBaseLib/JSONAdditions.h>
#import "ExploreWebCellManager.h"
#import "SSJSBridgeWebView.h"
#import "ArticleJSManager.h"
#import "ExploreMixListDefine.h"
#import "TTCategoryDefine.h"
#import "ArticleCityView.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTUISettingHelper.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"
#import "SSWebViewUtil.h"
//#import "TTRedPacketManager.h"

@interface ExploreArticleWebCellView () <YSWebViewDelegate>

@property(nonatomic,strong)SSJSBridgeWebView *webView;
@property(nonatomic,strong)SSThemedView *bottomLineView;
@property(nonatomic,strong)UIView *maskView;
@property(nonatomic,strong)SSThemedLabel *infoLabel;
@property(nonatomic,strong)NSMutableData *receivedData;
@property(nonatomic,copy)NSString *htmlString;
@property(nonatomic,copy)NSString *jsonString;
@property(nonatomic,assign)BOOL isLoading;
@property(nonatomic,assign)BOOL isCellDisplay;

@property(nonatomic,strong)ExploreOrderedData *orderedData;
@property(nonatomic,strong)WapData *wapData;
@property(nonatomic,strong)NSDate *lastUpdateTime;
@property(nonatomic,copy)NSString *categoryID;

@end


@implementation ExploreArticleWebCellView

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        WapData *wapData = orderedData.wapData;
        if (wapData && !isEmptyString(wapData.templateContent)) {
            if (orderedData.cellHeightChanged > 0) {
                return orderedData.cellHeightChanged;
            }
            return MAX(orderedData.cellHeight, 0);
        }
    }
    return 0.f;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
    [self.webView removeDelegate:self];
    self.webView.delegate = nil;
    self.webView = nil;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
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
//        [self registerPanelRedpacket];
        [self addSubview:_webView];
        
        [SSWebViewUtil registerUserAgent:YES];
        
//        WeakSelf;
//        [_webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
//            //此处添加js记录选取的词
//            if ([result isKindOfClass:[NSDictionary class]] && result.count > 0) {
//                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//                [userDefault setValue:result forKey:kExploreWebCellNewUserActionInterestWordsDictionary];
//                [userDefault synchronize];
//            }
//            return nil;
//        } forMethodName:@"syncFeedInterestWords"];
//        
//        [_webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
//            //此处添加js记录选取的词
//            StrongSelf;
//            [self reloadListView];
//            return nil;
//        } forMethodName:@"refreshFeedList"];
        
        [_webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
        self.maskView = [[UIView alloc] initWithFrame:self.bounds];
        _maskView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _maskView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        _maskView.hidden = NO;
        [self addSubview:_maskView];
        
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveRedpacketCloseNotification:)
                                                     name:@"TTCloseRedPackertNotification"
                                                   object:nil];
        
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    _maskView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    if (!isEmptyString(self.wapData.templateContent)) {
        [self refreshDayMode];
    }
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
        
        NSNumber *gid = [result objectForKey:@"id"];
        NSString* gidStr = [NSString stringWithFormat:@"%@", gid];
        
        //        NSArray *orderedDataArray = [[[SSDataContext sharedContext] mainThreadModelManager] entitiesWithQuery:@{@"originalData.uniqueID": gidStr} entityClass:[ExploreOrderedData class] error:nil];
        
        NSArray *orderedDataArray = [ExploreOrderedData objectsWithQuery:@{@"uniqueID": gidStr}];
        
        [orderedDataArray enumerateObjectsUsingBlock:^(ExploreOrderedData * obj, NSUInteger idx, BOOL *stop) {
            [weakSelf receiveRefreshWebCellNotification:obj];
        }];
        
    } forMethodName:@"panelRefresh"];
}

//增加红包
//- (void)registerPanelRedpacket {
//    __weak __typeof(self) weakSelf = self;
//    [self.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse completion) {
//        NSError *error = nil;
//        FRRedpackStructModel *redpacketModel = [[FRRedpackStructModel alloc] initWithDictionary:[params tt_dictionaryValueForKey:@"redpacket"] error:&error];
//        if (redpacketModel) {
//            TTRedPacketTrackModel * redPacketTrackModel = [TTRedPacketTrackModel new];
//            redPacketTrackModel.userId = [params tt_stringValueForKey:@"userid"];
//            redPacketTrackModel.categoryName = weakSelf.orderedData.categoryID;
//            redPacketTrackModel.source = [params tt_stringValueForKey:@"source"];
//            redPacketTrackModel.position = [params tt_stringValueForKey:@"position"];
//            [[TTRedPacketManager sharedManager] presentRedPacketWithRedpacket:redpacketModel
//                                                                       source:redPacketTrackModel
//                                                               viewController:[TTUIResponderHelper topmostViewController]];
//        }
//    } forMethodName:@"panelRedPacket"];
//}

- (void)refreshDayMode {
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.TouTiao && TouTiao.setDayMode(%d)", isDayModel] completionHandler:nil];
}
//服务端控制webcell的部分UI
- (void)refreshCunstomStyle{
    NSDictionary * cellViewUICustomStyleDictionary = [[TTUISettingHelper sharedInstance_tt] cellViewUISettingsDictionary];
    if ([cellViewUICustomStyleDictionary isKindOfClass:[NSDictionary class]] && [cellViewUICustomStyleDictionary count] > 0) {
        NSString *json = [cellViewUICustomStyleDictionary tt_JSONRepresentation];
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.TouTiao && TouTiao.setCustomStyle(%@)", json] completionHandler:nil];
    }
}

- (void)refreshUI {
    if ([self.orderedData nextCellHasTopPadding]) {
        if (!_bottomLineView.hidden) {
            _bottomLineView.hidden = YES;
            [self setNeedsDisplay];
        }
    } else {
        if (_bottomLineView.hidden) {
            _bottomLineView.hidden = NO;
            [self setNeedsDisplay];
        }
    }
    
    /* iPad上cell整体有缩进，分割线如果再缩进就会比其他文章类型cell短一些，
        所以webCell不缩进分割线
     */
    
    CGFloat linePadding = 0;
    
    //现行的都是没有间隔的
//    if ([TTDeviceHelper isPadDevice]) {
//        linePadding = 0;
//    } else {
//        linePadding = kCellLeftPadding;
//    }
    
    self.bottomLineView.frame = CGRectMake(linePadding,  self.height-[TTDeviceHelper ssOnePixel], self.width - linePadding * 2, [TTDeviceHelper ssOnePixel]);
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
    }
    
    _isCellDisplay = YES;
    
    if (!_htmlString || !self.wapData.templateContent || ![_htmlString isEqualToString:self.wapData.templateContent] || !self.wapData.hasTemplateLoaded) {
        if (!isEmptyString(self.wapData.templateContent)) {
            [self loadHTMLString:self.wapData.templateContent baseURL:[TTStringHelper URLWithURLString:self.wapData.baseUrl]];
        } else {
            [[ExploreWebCellManager sharedManager] startGetTemplateFromWapData:self.wapData completion:^(WapData *wapData, NSString *htmlStr, NSError *error) {
                if (self.wapData.uniqueID == wapData.uniqueID) {
                    if (!error && !isEmptyString(htmlStr)) {
                        [self loadHTMLString:htmlStr baseURL:[TTStringHelper URLWithURLString:self.wapData.baseUrl]];
                    }
                }
            }];
        }
    } else {
        if (!isEmptyString(self.wapData.dataUrl)) {
            if (!self.lastUpdateTime) {
                [self refreshWebData];
            } else {
                if ((self.lastUpdateTime && fabs([self.lastUpdateTime timeIntervalSinceNow]) > [self.wapData.refreshInterval doubleValue]) || self.wapData.needRefreshUI) {
                    [self refreshWebData];
                }
            }
        }
    }
}

- (void)setOrderedData:(ExploreOrderedData *)orderedData
{
    _orderedData = orderedData;
    _wapData = _orderedData.wapData;
    _categoryID = _orderedData.categoryID;

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
}

- (id)cellData {
    return self.orderedData;
}

- (BOOL)webView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType {
    
    
    
    if ([request.URL.scheme isEqualToString:@"sslocal"]) {
        
        self.wapData.needRefreshUI = YES;
        /// 如果是SSLocal的，则统一处理
        if ([TTDeviceHelper isPadDevice] && [[request.URL absoluteString] hasPrefix:@"sslocal://choose_city"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kExploreWebCellChooseCityNotification object:nil userInfo:@{@"categoryID":self.orderedData.categoryID}];
        } else {
            [[TTRoute sharedRoute] openURLByPushViewController:request.URL];
        }
        
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

}

- (void)reloadCellIfNeeded {
    if (self.height <= 1 && self.wapData.uniqueID > 0) {
        float changedCellH = self.orderedData.cellHeightChanged;
        float origCellH = self.orderedData.cellHeight;
        float destCellH = changedCellH > 0 ? changedCellH : origCellH;
        
        if (destCellH > 0 && destCellH != self.height) {
            // 模板加载完成后，如果当前view高度为0，表示是第一次加载模板，需要通知列表reload
            ExploreOrderedData *orderedData = self.orderedData;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kExploreWebCellDidUpdateNotification object:nil userInfo:@{@"orderedData":orderedData}];
            });
        }
    }
}

- (void)reloadCell
{
    ExploreOrderedData *orderedData = self.orderedData;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kExploreWebCellDidUpdateNotification object:nil userInfo:@{@"orderedData":orderedData}];
    });

}

//- (void)reloadListView
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:kExploreWebCellActiveRefreshListViewNotification object:nil userInfo:nil];
//    });
//}

- (void)refreshWebData {
    if (_isLoading) {
        return;
    }
    
    if (!_isCellDisplay) {
        if (self.lastUpdateTime && fabs([self.lastUpdateTime timeIntervalSinceNow]) > [self.wapData.refreshInterval doubleValue]) {
            return;
        }
    }

    _isLoading = YES;
    
    [[ExploreWebCellManager sharedManager] startGetDataFromWapData:self.wapData completion:^(WapData *wapData, NSDictionary *dict, NSError *error) {
        if (self.wapData.uniqueID == wapData.uniqueID) {
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
            _isLoading = NO;
        }
    }];
}

- (void)updateWebWithData:(NSDictionary *)dict {
    if ([self.lastUpdateTime isEqualToDate:self.wapData.lastUpdateTime]) {
        //NSLog(@"data update time is equal");
        return;
    }
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [mDict setValue:@(self.wapData.uniqueID) forKey:@"id"];
    [mDict setValue:self.orderedData.categoryID forKey:@"category"];

    NSString *messageJSON = [mDict tt_JSONRepresentation];
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

- (void)didEndDisplaying {
    _isCellDisplay = NO;
    
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

- (void)receiveRedpacketCloseNotification:(NSNotification *)notification {
    NSString *isOpened = @"0";
    NSString *token = @"0";
    NSString *redpacketId = @"0";
    if ([notification.userInfo isKindOfClass:[NSDictionary class]]) {
        isOpened = [notification.userInfo tt_boolValueForKey:@"packet_opened"]?@"1":@"0";
        token = [notification.userInfo tt_stringValueForKey:@"packet_token"]?:@"0";
        redpacketId = [notification.userInfo tt_stringValueForKey:@"packet_id"]?:@"0";
    }
    
    
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.updateRedPacketState({\"message\":\"success\", \"data\":\"%@\", \"packet_token\":\"%@\", \"packet_id\":\"%@\"})", isOpened, token, redpacketId] completionHandler:nil];
}

- (void)receiveRefreshWebCellNotification:(ExploreOrderedData *)data
{
    ExploreOrderedData *item = data;
    if ([item isKindOfClass:[ExploreOrderedData class]]) {
        if (item.wapData.uniqueID == self.wapData.uniqueID) {
            [self refreshWebData];
        }
    }
}

- (void)receiveWebCellHeightDidChangedNotification:(NSNumber *)cellHeight
{
    NSNumber *heightNum = cellHeight;
    
    if (heightNum && [heightNum isKindOfClass:[NSNumber class]] && self.orderedData.cellHeightChanged != [heightNum floatValue]) {
        self.orderedData.cellHeightChanged = [heightNum floatValue];
        [self.orderedData save];
        
        if (self.wapData.hasTemplateLoaded) {
            [self reloadCell];
        } else {
            self.wapData.shouldReloadCell = YES;
        }
    }
}

- (void)dislikeCell:(NSNotification *)notification
{
    NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:nil userInfo:userInfo];
}

- (void)closeCell:(NSNotification *)notification
{
    NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    [userInfo setValue:@(YES) forKey:kExploreMixListNotDisplayTipKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:nil userInfo:userInfo];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"] && ![[change objectForKey:NSKeyValueChangeOldKey] isEqualToValue:[change objectForKey:NSKeyValueChangeNewKey]] ) {
        _webView.scrollView.contentSize = CGSizeMake(_webView.scrollView.contentSize.width, self.height);
    }
}

@end
