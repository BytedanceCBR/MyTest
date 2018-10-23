//
//  TTRNCellView.m
//  Article
//
//  Created by Chen Hong on 16/7/14.
//
//

#import "TTRNCellView.h"
#import "TTRNView.h"
#import "ExploreArticleCellViewConsts.h"
#import "SSThemed.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"
#import "TTUISettingHelper.h"
#import "ExploreMixListDefine.h"
#import "ExploreArticleWebCellView.h"
#import "RNData.h"
#import <TTAccountBusiness.h>
#import "TTRNBridge+Cell.h"
#import <TTUserSettingsManager+FontSettings.h>
#import "TTDeviceHelper.h"
#import "TTThemeManager.h"
#import "TTPlatformSwitcher.h"
#import "TTFeedDislikeView.h"
#import "TTRNBundleManager.h"
#import "ExploreOrderedData+TTAd.h"

// rncell高度缓存
static NSMutableDictionary *rnCellHeightCache = nil;

@implementation TTRNCell
+ (Class)cellViewClass {
    return [TTRNCellView class];
}
@end

@interface TTRNCellView () <TTRNViewDelegate>
@property(nonatomic,strong)TTRNView *rnView;
@property(nonatomic,strong)SSThemedView *loadingView;
@property(nonatomic,strong)SSThemedView *bottomLineView;
@property(nonatomic,strong)ExploreOrderedData *orderedData;
@property(nonatomic,copy)NSString *dislikeAction;
@end

@implementation TTRNCellView

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        
        if (rnCellHeightCache == nil) rnCellHeightCache = [NSMutableDictionary dictionary];
        
        if (orderedData.rnData) {
            NSString *uniqueID = [NSString stringWithFormat:@"%lld", orderedData.rnData.uniqueID];
            NSNumber *cellH = [rnCellHeightCache valueForKey:uniqueID];
            return [cellH doubleValue];
        }
//        
//        NSUInteger cellViewType = [self cellTypeForCacheHeightFromOrderedData:data];
//        CGFloat cacheH = [orderedData cacheHeightForListType:listType cellType:cellViewType];
//        if (cacheH > 0) {
//            return cacheH;
//        }
    }
    return 0.f;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.rnView = [[TTRNView alloc] initWithFrame:self.bounds];
        self.rnView.delegate = self;
        [self.rnView loadModule:@"RNCellView" initialProperties:nil];
        
        [self addSubview:self.rnView];
        [self.rnView setLoadingView:self.loadingView];
        [self.rnView setSizeFlexibility:TTRNViewSizeFlexibilityHeight];
        
        self.bottomLineView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        self.bottomLineView.backgroundColorThemeKey = kColorLine1;
        [self addSubview:self.bottomLineView];
        
        [self addObservers];
    }
    
    return self;
}

- (void)addObservers {
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
}

- (SSThemedView *)loadingView {
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

- (void)fontSizeChanged {
    [self updateProperties];
}

//服务端控制webcell的部分UI
- (void)refreshCustomStyle {
//    NSDictionary * cellViewUICustomStyleDictionary = [[TTUISettingHelper sharedInstance_tt] cellViewUISettingsDictionary];
//    if ([cellViewUICustomStyleDictionary isKindOfClass:[NSDictionary class]] && [cellViewUICustomStyleDictionary count] > 0) {
//        NSString *json = [cellViewUICustomStyleDictionary JSONRepresentation];
//        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"TouTiao.setCustomStyle(%@)", json] completionHandler:nil];
//    }
}

- (void)refreshUI {
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

- (void)refreshWithData:(id)data {
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
    
//    NSUInteger cellViewType = [[self class] cellTypeForCacheHeightFromOrderedData:data];
//    CGFloat cacheH = [self.orderedData cacheHeightForListType:self.listType cellType:cellViewType];
//    if (cacheH == 0) {
//        [self.rnView reload];
//    }
//    if (needReload) {
//        [self.rnView loadModule:@"RNCellView" initialProperties:nil];
//        [self.rnView setLoadingView:self.loadingView];
//    }
//    NSString *uniqueID = [NSString stringWithFormat:@"%@", self.orderedData.rnData.uniqueID];
//    NSNumber *cellH = [rnCellHeightCache valueForKey:uniqueID];
//    if ([cellH intValue] == 0) {
//        [self.rnView loadModule:@"RNCellView" initialProperties:nil];
//    }
    
    //[self.rnView loadRNViewWithBundleUrl:@"http://s0.pstatp.com/site/download/app/apk/news_article/reactnative_bundles/jsbundle.zip" moduleName:@"RNCellView" initialProperties:nil];
    
    [self updateProperties];
}

- (void)updateProperties {
    NSString *daymode = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? @"day" : @"night";
    NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
    BOOL isLogin =[TTAccountManager isLogin];

    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithDictionary:self.orderedData.rnData.data];
    [props setValue:daymode forKey:@"daymode"];
    [props setValue:@(isLogin) forKey:@"islogin"];
    [props setValue:fontSizeType forKey:@"font"];
    [props setValue:@(self.orderedData.originalData.uniqueID) forKey:@"uniqueID"];
    
//    if (self.height == 0) {
//        static int i = 0;
//        [props setValue:@(i++) forKey:@"counter"];
//    }
    
    [self.rnView updateProperties:props];
}

- (id)cellData {
    return self.orderedData;
}

- (void)refreshFeedList
{
    self.orderedData.cellDeleted = YES;
    [self.orderedData save];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTRNCellActiveRefreshListViewNotification object:nil userInfo:nil];
    });
}

- (void)reloadCell
{
    ExploreOrderedData *orderedData = self.orderedData;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kExploreWebCellDidUpdateNotification object:nil userInfo:@{@"orderedData":orderedData}];
    });
    
}

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

#pragma mark TTFeedDislikeView
- (void)exploreDislikeViewOKBtnClicked:(nonnull TTFeedDislikeView *)dislikeView {
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

#pragma mark - TTRNViewDelegate

- (void)rootViewDidChangeIntrinsicSize:(CGSize)size {
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

- (NSURL *)RNBundleUrl
{
    // FIXME: `RNCellView`和`Profile`共用同一个Bundle
    return [[TTRNBundleManager sharedManager] localBundleURLForModuleName:@"Profile"];
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
