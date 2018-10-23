//
//  TTDynamicRNCellView.m
//  Article
//
//  Created by yangning on 2017/9/10.
//
//

#import "TTDynamicRNCellView.h"
#import "TTRNView.h"
#import "ExploreArticleCellViewConsts.h"
#import "SSThemed.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreOrderedData+TTAd.h"
#import "Article.h"
#import "TTUISettingHelper.h"
#import "ExploreMixListDefine.h"
#import "ExploreArticleWebCellView.h"
#import "RNData.h"
#import <TTAccountBusiness.h>
#import "TTRNBridge+Cell.h"
#import "NewsUserSettingManager.h"
#import "TTDeviceHelper.h"
#import "TTThemeManager.h"
#import "TTPlatformSwitcher.h"
#import "TTFeedDislikeView.h"
#import "TTRNBundleManager.h"
#import "TTRNCellManager.h"
#import <TTBaseLib/JSONAdditions.h>
#import "RCTRootView.h"
#import <React/RCTEventDispatcher.h>
#import "TTRNBridge+Call.h"


@implementation TTDynamicRNCell

+ (Class)cellViewClass
{
    return [TTDynamicRNCellView class];
}

@end

//////////////////////////////////////////////////////////////////////

// rncell高度缓存
static NSMutableDictionary *rnCellHeightCache = nil;

static NSString *const kTTDynamicRNCellViewDataRefreshEvent = @"RNCellRefresh";

@interface TTDynamicRNCellView () <TTRNViewDelegate>

@property(nonatomic, strong) TTRNView *rnView;
@property(nonatomic, strong) SSThemedView *loadingView;
@property(nonatomic, strong) SSThemedView *bottomLineView;
@property(nonatomic, strong) ExploreOrderedData *orderedData;
@property(nonatomic, copy) NSString *dislikeAction;
@property(nonatomic, assign) BOOL isCellDisplay;
@property(nonatomic, strong) NSDate *lastUpdateTime;
@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, assign) BOOL isDataPending;
@property(nonatomic, strong) NSDate* rnStartTime;
@end

@implementation TTDynamicRNCellView

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        
        if (rnCellHeightCache == nil) rnCellHeightCache = [NSMutableDictionary dictionary];
        
        if (orderedData.rnData) {
            NSString *uniqueID = [NSString stringWithFormat:@"%lld", orderedData.rnData.uniqueID];
            NSNumber *cellH = [rnCellHeightCache valueForKey:uniqueID];
            return [cellH doubleValue];
        }
    }
    return 0.f;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bottomLineView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        self.bottomLineView.backgroundColorThemeKey = kColorLine1;
        [self addSubview:self.bottomLineView];
        
        [self addObservers];
    }
    
    return self;
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeCell:)
                                                 name:kExploreMixListCloseWebCellNotification
                                               object:self.rnView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showDislike:)
                                                 name:kExploreMixListShowDislikeNotification
                                               object:self.rnView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFeedList)
                                                 name:kTTRNBridgeActiveRefreshListViewNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (SSThemedView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[SSThemedView alloc] initWithFrame:self.bounds];
        _loadingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _loadingView.backgroundColorThemeKey = kColorBackground4;
        
        // 加载中
        SSThemedLabel *infoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, 120, 14)];
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.textColors = @[@"999999", @"707070"];
        infoLabel.font = [UIFont systemFontOfSize:12.f];
        infoLabel.text = NSLocalizedString(@"加载中……", nil);
        infoLabel.center = CGPointMake(_loadingView.width/2, _loadingView.height/2);
        infoLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin;
        [_loadingView addSubview:infoLabel];
    }
    
    return _loadingView;
}

- (void)themeChanged:(NSNotification *)notification
{
    [self updateProperties];
}

- (void)fontSizeChanged
{
    [self updateProperties];
}

- (void)refreshUI
{
    if ([self.orderedData nextCellHasTopPadding]) {
        if (!_bottomLineView.hidden) {
            _bottomLineView.hidden = YES;
        }
    } else {
        if (_bottomLineView.hidden) {
            _bottomLineView.hidden = NO;
        }
    }
    
    if (self.height == 0) {
        [self.rnView refreshSize];
    }
    
    /* iPad上cell整体有缩进，分割线如果再缩进就会比其他文章类型cell短一些，
     所以webCell不缩进分割线
     */
    CGFloat linePadding;
    
    if ([TTDeviceHelper isPadDevice]) {
        linePadding = 0;
    } else {
        linePadding = kCellLeftPadding;
    }
    
    self.bottomLineView.frame = CGRectMake(linePadding,  self.height-[TTDeviceHelper ssOnePixel], self.width - linePadding * 2, [TTDeviceHelper ssOnePixel]);
}

- (void)refreshWithData:(id)data
{
    BOOL needReload = YES;
    
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        if (orderedData.rnData.uniqueID == self.orderedData.rnData.uniqueID) {
            needReload = NO;
        }
        self.orderedData = data;
    } else {
        self.orderedData = nil;
    }
    
    self.isCellDisplay = YES;
    
    if (needReload) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:RCTJavaScriptDidLoadNotification object:self.rnView.rootView.bridge];
        [self.rnView removeFromSuperview];
        self.rnView = [[TTRNView alloc] initWithFrame:self.bounds];
        self.rnView.delegate = self;
        [self.rnView loadModule:self.orderedData.rnData.moduleName initialProperties:[self properties]];
        
        [self addSubview:self.rnView];
        [self monitorRNLoad:self.orderedData.rnData.moduleName pageName:self.orderedData.rnData.typeName];
        [self.rnView setLoadingView:self.loadingView];
        [self.rnView setSizeFlexibility:TTRNViewSizeFlexibilityHeight];
        WeakSelf;
        [self.rnView setFatalHandler:^{
            StrongSelf;
            [[TTRNBundleManager sharedManager] setLocalBundleDirty:YES forModuleName:self.orderedData.rnData.moduleName];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(javaScriptDidLoad:) name:RCTJavaScriptDidLoadNotification object:self.rnView.rootView.bridge];
    }
    
    if (!isEmptyString(self.orderedData.rnData.dataUrl)) {
        if (!self.lastUpdateTime) {
            [self fetchDynamicData];
        } else {
            if ((self.lastUpdateTime && fabs([self.lastUpdateTime timeIntervalSinceNow]) > [self.orderedData.rnData.refreshInterval doubleValue])) {
                [self fetchDynamicData];
            }
        }
    }
    
    [self updateProperties];
}

- (void)javaScriptDidLoad:(id)notify
{
    if (self.isDataPending) {
        [self.rnView.rootView.bridge.eventDispatcher sendDeviceEventWithName:kTTDynamicRNCellViewDataRefreshEvent body:self.orderedData.rnData.dataContent];
        self.isDataPending = NO;
    }
}

- (void)fetchDynamicData
{
    if (self.isLoading) {
        return;
    }
    
    if (!self.isCellDisplay) {
        if (self.lastUpdateTime && fabs([self.lastUpdateTime timeIntervalSinceNow]) > [self.orderedData.rnData.refreshInterval doubleValue]) {
            return;
        }
    }
    
    self.isLoading = YES;
    
    WeakSelf;
    [[TTRNCellManager sharedManager] startGetDataFromCellData:self.orderedData.rnData completion:^(RNData *cellData, NSDictionary *dict, NSError *error) {
        StrongSelf;
        self.isLoading = NO;
        if (self.orderedData.rnData.uniqueID == cellData.uniqueID) {
            NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:self.orderedData.rnData.dataContent];
            if (!error) {
                [mDict setValue:@"success" forKey:@"message"];
                [self refreshCellWithDynamicData:[mDict copy]];
            } else {
                [mDict setValue:@"error" forKey:@"message"];
                [self refreshCellWithDynamicData:[mDict copy]];
            }
        }
    }];
}

- (void)refreshCellWithDynamicData:(NSDictionary *)dict
{
    if ([self.lastUpdateTime isEqualToDate:self.orderedData.rnData.lastUpdateTime]) {
        //NSLog(@"data update time is equal");
        return;
    }
    self.lastUpdateTime = self.orderedData.rnData.lastUpdateTime;
    
    // 动态数据
    if (![self.rnView.rootView.bridge isLoading]) {
        [self.rnView.rootView.bridge.eventDispatcher sendDeviceEventWithName:kTTDynamicRNCellViewDataRefreshEvent body:dict];
    } else {
        self.isDataPending = YES;
    }
}

- (void)didEndDisplaying
{
    self.isCellDisplay = NO;
}

- (void)updateProperties
{
    NSString *daymode = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? @"day" : @"night";
    NSString *fontSizeType = [NewsUserSettingManager settedFontShortString];
    BOOL isLogin =[TTAccountManager isLogin];
    
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithDictionary:self.orderedData.rnData.data];
    [props setValue:daymode forKey:@"daymode"];
    [props setValue:@(isLogin) forKey:@"islogin"];
    [props setValue:fontSizeType forKey:@"font"];
    [props setValue:@(self.orderedData.originalData.uniqueID) forKey:@"uniqueID"];
    [props setValue:self.orderedData.rnData.rawData forKey:@"raw_data"];
    [props setValue:self.orderedData.rnData.dataContent forKey:@"dynamic_data"];
    
    [self.rnView updateProperties:[self properties]];
}

- (NSDictionary *)properties
{
    NSString *daymode = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? @"day" : @"night";
    NSString *fontSizeType = [NewsUserSettingManager settedFontShortString];
    BOOL isLogin =[TTAccountManager isLogin];
    
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithDictionary:self.orderedData.rnData.data];
    [props setValue:daymode forKey:@"daymode"];
    [props setValue:@(isLogin) forKey:@"islogin"];
    [props setValue:fontSizeType forKey:@"font"];
    [props setValue:@(self.orderedData.originalData.uniqueID) forKey:@"uniqueID"];
    [props setValue:self.orderedData.rnData.rawData forKey:@"raw_data"];
    [props setValue:self.orderedData.rnData.dataContent forKey:@"dynamic_data"];
    return [props copy];
}

- (id)cellData
{
    return self.orderedData;
}

- (void)reloadCell
{
    ExploreOrderedData *orderedData = self.orderedData;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kExploreWebCellDidUpdateNotification object:nil userInfo:@{@"orderedData":orderedData}];
    });
}

#pragma mark - Notification

- (void)closeCell:(NSNotification *)notification
{
    NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    [userInfo setValue:@(YES) forKey:kExploreMixListNotDisplayTipKey];
    
    NSString *action = [notification.userInfo tt_stringValueForKey:@"action"];
    if ([action isEqualToString:@"close"]) {
        [userInfo setValue:@(YES) forKey:kExploreMixListNotDisplayTipKey];
        [userInfo setValue:action forKey:@"action"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:nil userInfo:userInfo];
}

- (void)showDislike:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat x = [userInfo tt_floatValueForKey:@"x"];
    CGFloat y = [userInfo tt_floatValueForKey:@"y"];
    self.dislikeAction = [userInfo tt_stringValueForKey:@"action"];
    
    if (x > 0 && y > 0) {
        TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
        TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
        viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.originalData.uniqueID];
        viewModel.logExtra = self.orderedData.log_extra;
        [dislikeView refreshWithModel:viewModel];
        CGPoint point = CGPointMake(x, y);
        [dislikeView showAtPoint:point
                        fromView:self.rnView
                 didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                     [self exploreDislikeViewOKBtnClicked:view];
                 }];
    }
}

- (void)refreshFeedList
{
    self.orderedData.cellDeleted = YES;
    [self.orderedData save];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTRNCellActiveRefreshListViewNotification object:nil userInfo:nil];
    });
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    if (_isCellDisplay) {
        [self fetchDynamicData];
    }
}

- (void)exploreDislikeViewOKBtnClicked:(nonnull TTFeedDislikeView *)dislikeView
{
    if (!self.orderedData) {
        return;
    }
    NSArray *filterWords = [dislikeView selectedWords];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    if (filterWords.count > 0) {
        [userInfo setValue:filterWords forKey:kExploreMixListNotInterestWordsKey];
    }
    if (!isEmptyString(self.dislikeAction)) {
        [userInfo setValue:self.dislikeAction forKey:@"action"];
    }
    
    // 通知RN
    [[self.rnView bridgeModule] dislikeConfirmed];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}


- (void)monitorRNLoad:(NSString *)moduleName pageName:(NSString *)pageName
{
    self.rnStartTime = [NSDate date];
    NSMutableDictionary* extra = [NSMutableDictionary dictionary];
    [extra setValue:moduleName forKey:@"module_name"];
    [extra setValue:pageName forKey:@"page_name"];
    [extra setValue:@"native_init_start_bundle" forKey:@"page_status"];
    [[TTMonitor shareManager] trackService:@"native_init_start_bundle" status:1 extra:extra];
    WeakSelf;
    [self.rnView.bridgeModule registerHandler:^(NSDictionary *result, RCTResponseSenderBlock callback) {
        StrongSelf;
        int time = (int)([[NSDate date] timeIntervalSinceDate:self.rnStartTime] * 1000);
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:result];
        [params setValue:@(time) forKey:@"duration"];
        NSString* seviceName = [result tt_stringValueForKey:@"page_status"];
        if (!isEmptyString(seviceName)) {
            [[TTMonitor shareManager] trackService:seviceName value:params extra:nil];
        }
    } forMethod:@"ReportPageStatus"];
}


#pragma mark - TTRNViewDelegate

- (void)rootViewDidChangeIntrinsicSize:(CGSize)size
{
    int height = (int)(floor(size.height));
    //NSUInteger cellViewType = [[self class] cellTypeForCacheHeightFromOrderedData:self.orderedData];
    //CGFloat cacheH = [self.orderedData cacheHeightForListType:self.listType cellType:cellViewType];
    NSString *uniqueID = [NSString stringWithFormat:@"%lld", self.orderedData.rnData.uniqueID];
    NSNumber *cellH = [rnCellHeightCache valueForKey:uniqueID];
    
    if ([cellH intValue] == height) {
        return;
    }
    
    //[self.orderedData saveCacheHeight:height forListType:self.listType cellType:cellViewType];
    
    [rnCellHeightCache setValue:@(height) forKey:uniqueID];
    
    [self reloadCell];
}

// RCTRootView会把点击事件传到TableViewCell上，这里做个特殊处理，所有touchEvent都不往cell上传
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
