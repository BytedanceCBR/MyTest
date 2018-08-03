//
//  TSVFeedFollowCell.m
//  Article
//
//  Created by dingjinlu on 2017/12/7.
//

#import "TSVFeedFollowCell.h"
#import "ArticleImpressionHelper.h"
#import "TTHorizontalHuoShanVideoOptimizeCollectionCell.h"
#import "TTHorizontalHuoShanCollectionCellProtocol.h"
#import "TSVFeedFollowCellTopInfoView.h"
#import "TSVFeedFollowCellTopInfoViewModel.h"
#import "TSVCardBottomInfoView.h"
#import <TTUIWidget/TTAlphaThemedButton.h>
#import "TSVShortVideoOriginalData.h"
#import "TTRouteService.h"
#import "TSVShortVideoDetailExitManager.h"
#import "TSVShortVideoCategoryFetchManager.h"
#import <HTSVideoPlay/HTSVideoPageParamHeader.h>
#import <TTUIWidget/TTNavigationController.h>
#import "TSVShortVideoOriginalData.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TSVFeedFollowCellContentView.h"
#import "TSVTransitionAnimationManager.h"
#import "TTRelevantDurationTracker.h"
#import "NSObject+FBKVOController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "AWEVideoDetailTracker.h"
#import "TSVChannelDecoupledConfig.h"
#import "TSVShortVideoDecoupledFetchManager.h"
#import <TSVPrefetchVideoManager.h>
#import <ReactiveObjC.h>

#define kCardRectPadding            6
#define kMoreArrowW                 6
#define kMoreArrowH                 10
#define kMoreArrowLeftGap           4
#define kBottomHeight               40
#define kCoverAspectRatio           (335.f / 247.f)
#define kMaskAspectRatio            (68.f  / 247.f)
#define kItemWidthRatio             (247.f / 375.f)
#define kLeftPadding                15
#define kTopPadding                 15

static NSString * const kTSVOpenTabHost = @"ugc_video_tab";

@implementation TSVFeedFollowCell

+ (Class)cellViewClass
{
    return [TSVFeedFollowCellView class];
}

- (void)willAppear
{
    if ([self.cellView isKindOfClass:[TSVFeedFollowCellView class]]) {
        [((TSVFeedFollowCellView *)self.cellView) willDisplay];
    }
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    if ([self.cellView isKindOfClass:[TSVFeedFollowCellView class]]) {
        [((TSVFeedFollowCellView *)self.cellView) didEndDisplaying];
    }
    
}

- (void)willDisplay
{
    if ([self.cellView isKindOfClass:[TSVFeedFollowCellView class]]) {
        [((TSVFeedFollowCellView *)self.cellView) willDisplay];
    }
}

- (void)didEndDisplaying
{
    if ([self.cellView isKindOfClass:[TSVFeedFollowCellView class]]) {
        [((TSVFeedFollowCellView *)self.cellView) didEndDisplaying];
    }
}

@end

@interface  TSVFeedFollowCellView()
//  ui
@property (nonatomic, strong) TSVFeedFollowCellContentView  *contentView;
@property (nonatomic, strong) TSVFeedFollowCellTopInfoView  *topInfoView;
@property (nonatomic, strong) SSThemedView                  *topRect;
@property (nonatomic, strong) SSThemedView                  *bottomRect;
@property (nonatomic, strong) UIView                        *bottomInfoView;
@property (nonatomic, strong) SSThemedLabel                 *moreLabel;
@property (nonatomic, strong) SSThemedImageView             *moreArrow;
@property (nonatomic, strong) TTAlphaThemedButton           *moreButton;

//  data
@property (nonatomic, strong) ExploreOrderedData            *orderedData;
@property (nonatomic, strong) TTShortVideoModel             *model;

@property (nonatomic, assign) BOOL isDisplaying;

@property (nonatomic, strong) RACDisposable *prefetchVideoDisposable;

@end

@implementation TSVFeedFollowCellView
#pragma mark - class method
+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        if ([orderedData.originalData isKindOfClass:[TSVShortVideoOriginalData class]]) {
            
            CGFloat itemHeight = [self itemHeightWithCellWidth:width];
            
            CGFloat height = itemHeight + 2 * kCardRectPadding;
            
            if ([orderedData nextCellHasTopPadding]){
                height -= kCardRectPadding;
            }
            if ([orderedData preCellHasBottomPadding]) {
                height -= kCardRectPadding;
            }
            
            BOOL shouldShowTopInfoView = [TSVFeedFollowCellTopInfoViewModel shouldShowTopInfoViewWithData:data];
            if (shouldShowTopInfoView) {
                height += [TSVFeedFollowCellTopInfoViewModel heightWithData:orderedData];
            } else {
                height += kTopPadding;
            }
            
            if ([TTShortVideoHelper canOpenShortVideoTab]) {
                height += kBottomHeight;
            } else {
                height += kTopPadding;
            }
            
            if (height > 0) {
                return height;
            }
        }
    }
    return 0.f;
}

+ (CGFloat)itemHeightWithCellWidth:(CGFloat)width
{
    return width * kItemWidthRatio * kCoverAspectRatio;
}

#pragma mark -

- (void)dealloc
{
    [_prefetchVideoDisposable dispose];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerEnterForegroundNotification];
    }
    return self;
}

- (void)refreshWithData:(id)data
{
    self.orderedData = data;
    self.model = self.orderedData.shortVideoOriginalData.shortVideo;
    
    [self.topInfoView refreshWithData:data];
    
    [self.contentView setupWithData:self.orderedData];
    
    self.moreLabel.text = self.model.showMoreModel.title?:@"精彩小视频";
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.topRect.width = self.width;
    self.topRect.height = kCardRectPadding;
    
    self.bottomRect.width = self.width;
    self.bottomRect.height = kCardRectPadding;
    
    if ([self.orderedData preCellHasBottomPadding]) {
        CGRect bounds = self.bounds;
        bounds.origin.y = 0;
        self.bounds = bounds;
        self.topRect.hidden = YES;
    } else {
        CGRect bounds = self.bounds;
        bounds.origin.y = - kCardRectPadding;
        self.bounds = bounds;
        self.topRect.bottom = 0;
        self.topRect.width = self.width;
        self.topRect.hidden = NO;
    }
    
    if (!([self.orderedData nextCellHasTopPadding])) {
        self.bottomRect.bottom = self.height + self.bounds.origin.y;
        self.bottomRect.width = self.width;
        self.bottomRect.hidden = NO;
    } else {
        self.bottomRect.hidden = YES;
    }
    
    [self refreshTopInfoView];
    [self refreshContentView];
    [self refreshBottomInfoView];
    
    [self reloadThemeUI];
}

- (void)refreshTopInfoView
{
    BOOL shouldShowTopInfoView = [TSVFeedFollowCellTopInfoViewModel shouldShowTopInfoViewWithData:self.orderedData];
    if (shouldShowTopInfoView) {
        self.topInfoView.hidden = NO;
        CGFloat topInfoViewHeight = [TSVFeedFollowCellTopInfoViewModel heightWithData:self.orderedData];
        
        self.topInfoView.frame = CGRectMake(0, 0, self.width, topInfoViewHeight);
        [self.topInfoView setNeedsLayout];
    } else {
        self.topInfoView.hidden = YES;
    }
}

- (void)refreshContentView
{
    BOOL shouldShowTopInfoView = [TSVFeedFollowCellTopInfoViewModel shouldShowTopInfoViewWithData:self.orderedData];
    CGFloat contentY;
    if (shouldShowTopInfoView) {
        contentY = self.topInfoView.bottom;
    } else {
        contentY = kLeftPadding;
    }
    self.contentView.frame = CGRectMake(kLeftPadding, contentY, self.width * kItemWidthRatio, self.width * kItemWidthRatio * kCoverAspectRatio);
}

- (void)refreshBottomInfoView
{
    self.bottomInfoView.hidden = NO;
    self.bottomInfoView.frame = CGRectMake(0, self.contentView.bottom, self.width, kBottomHeight);
    
    [self.moreLabel sizeToFit];
    self.moreLabel.hidden = NO;
    self.moreLabel.left = kLeftPadding;
    self.moreLabel.centerY = self.bottomInfoView.height / 2;
    
    if ([TTShortVideoHelper canOpenShortVideoTab]) {
        self.moreArrow.hidden = NO;
        self.moreArrow.left = self.moreLabel.right + kMoreArrowLeftGap;
        self.moreArrow.centerY = self.moreLabel.centerY;
        
        self.moreButton.width = self.moreLabel.width + self.moreArrow.width + kMoreArrowLeftGap;
        self.moreButton.height = kBottomHeight;
        self.moreButton.centerY = self.moreLabel.centerY;
        self.moreButton.left = self.moreLabel.left;
    } else {
        self.bottomInfoView.hidden = YES;
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)didSelectWithContext:(nullable TTFeedCellSelectContext *)context
{
    [super didSelectWithContext:context];
    [[TTRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];
    
    [TSVTransitionAnimationManager sharedManager].listSelectedCellFrame = [self convertRect:self.contentView.frame toView:nil];
    NSURL *url = [TTStringHelper URLWithURLString:self.model.detailSchema];
    [self openShortVideoByUrl:url index:0];
}

#pragma mark - Accessibility

- (void)openShortVideoByUrl:(NSURL *)url index:(NSInteger)index
{
    if ([[TTRoute sharedRoute] canOpenURL:url]) {
        
        id<TSVShortVideoDataFetchManagerProtocol> fetchManager;
        
        if ([TSVChannelDecoupledConfig strategy] == TSVChannelDecoupledStrategyDisabled) {
            fetchManager = [[TSVShortVideoCategoryFetchManager alloc] initWithOrderedDataArray:@[self.orderedData] cardID:nil];
            fetchManager.currentIndex = index;
        } else {
            if (self.orderedData.shortVideoOriginalData.shortVideo) {
                TTShortVideoModel *model = self.orderedData.shortVideoOriginalData.shortVideo;
                model.listIndex = @0;
                NSDictionary *trackParams = [self trackParamsDictForData:self.orderedData];
                model.categoryName = trackParams[@"category_name"];
                model.enterFrom = trackParams[@"enter_from"];
                fetchManager = [[TSVShortVideoDecoupledFetchManager alloc] initWithItems:@[model]
                                                                       requestCategoryID:[NSString stringWithFormat:@"%@_feed_detail_draw", kTTUGCVideoCategoryID]
                                                                      trackingCategoryID:kTTUGCVideoCategoryID
                                                                            listEntrance:@"more_shortvideo"];
            }
        }
        
        WeakSelf;
        TSVShortVideoDetailExitManager *exitManager = [[TSVShortVideoDetailExitManager alloc] initWithUpdateBlock:^CGRect{
            StrongSelf;
            return [self selectedViewFrameWithFetchManager:fetchManager];
        } updateTargetViewBlock:^UIView *{
            StrongSelf;
            return [self selectedViewWithFetchManager:fetchManager];
        }];
        
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];
        [info setValue:fetchManager forKey:HTSVideoListFetchManager];
        [info setValue:exitManager forKey:HTSVideoDetailExitManager];
        
        //自定义push方式打开火山详情页
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(info) pushHandler:^(UINavigationController *nav, TTRouteObject *routeObj) {
            if ([nav isKindOfClass:[TTNavigationController class]] &&
                [routeObj.instance isKindOfClass:[UIViewController class]]) {
                [(TTNavigationController *)nav pushViewControllerByTransitioningAnimation:((UIViewController *)routeObj.instance) animated:YES];
            }
        }];
    } else {
        NSAssert(NO, @"url can't enter detail VC");
    }
}

- (CGRect)selectedViewFrameWithFetchManager:(id<TSVShortVideoDataFetchManagerProtocol>)fetchManager
{
    if (fetchManager.currentIndex != 0) {
        return CGRectZero;
    }
    return self.contentView.frame;
}

- (UIView *)selectedViewWithFetchManager:(id<TSVShortVideoDataFetchManagerProtocol>)fetchManager
{
    if (fetchManager.currentIndex != 0) {
        return nil;
    }
    return self;
}

#pragma mark - click more

- (void)handleClickWithModel:(TTShortVideoModel *)model
{
    NSString *urlStr = model.showMoreModel.url;
    NSURL *url = [TTStringHelper URLWithURLString:urlStr];
    
    if (url) {
        TTRouteParamObj *params = [[TTRoute sharedRoute] routeParamObjWithURL:url];
        NSString *host = params.host;
        
        if ([host isEqualToString:kTSVOpenTabHost]) {
            [TTShortVideoHelper openShortVideoTab];
        } else if ([[TTRoute sharedRoute] canOpenURL:url]) {
            [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
    }
}

#pragma mark - ui

- (TSVFeedFollowCellTopInfoView *)topInfoView
{
    if (!_topInfoView) {
        _topInfoView = [[TSVFeedFollowCellTopInfoView alloc] initWithFrame:CGRectZero];
        [self addSubview:_topInfoView];
    }
    return _topInfoView;
}

- (UIView *)bottomInfoView
{
    if (!_bottomInfoView) {
        _bottomInfoView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_bottomInfoView];
    }
    return _bottomInfoView;
}

- (SSThemedLabel *)moreLabel
{
    if (!_moreLabel) {
        _moreLabel = [[SSThemedLabel alloc] init];
        _moreLabel.backgroundColorThemeKey = kColorBackground4;
        _moreLabel.textColorThemeKey = kColorText1;
        _moreLabel.numberOfLines = 1;
        _moreLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _moreLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        [self.bottomInfoView addSubview:_moreLabel];
    }
    return _moreLabel;
}

- (TTAlphaThemedButton *)moreButton
{
    if (!_moreButton) {
        _moreButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectZero];
        _moreButton.backgroundColor = [UIColor clearColor];
        WeakSelf;
        [_moreButton addTarget:self withActionBlock:^{
            StrongSelf;
            [self handleClickWithModel:self.model];
            [self sendClickMoreEventWithData:self.orderedData];
        } forControlEvent:UIControlEventTouchUpInside];
        [self.bottomInfoView addSubview:_moreButton];
    }
    return _moreButton;
}

- (SSThemedImageView *)moreArrow
{
    if (!_moreArrow) {
        _moreArrow = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, kMoreArrowW, kMoreArrowH)];
        _moreArrow.backgroundColor = [UIColor clearColor];
        _moreArrow.imageName = @"horizontal_more_arrow";
        [self.bottomInfoView addSubview:_moreArrow];
    }
    return _moreArrow;
}

-(TSVFeedFollowCellContentView *)contentView
{
    if (!_contentView) {
        _contentView = [[TSVFeedFollowCellContentView alloc] initWithFrame:CGRectZero];
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (SSThemedView *)topRect
{
    if (!_topRect) {
        _topRect = [[SSThemedView alloc] init];
        _topRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_topRect];
    }
    return _topRect;
}

- (SSThemedView *)bottomRect
{
    if (!_bottomRect) {
        _bottomRect = [[SSThemedView alloc] init];
        _bottomRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_bottomRect];
    }
    return _bottomRect;
}

#pragma mark - TTTrack

- (void)sendEventWithEventName:(NSString *)eventName orderedData:(ExploreOrderedData *)orderedData;
{
    NSMutableDictionary *logParams = [[NSMutableDictionary alloc] initWithDictionary:[self trackParamsDictForData:orderedData]];
    [logParams setValue:@"video_feed" forKey:@"source"];
    [logParams setValue:@(orderedData.shortVideoOriginalData.shortVideo.author.isFollowing) forKey:@"is_follow"];
    [logParams setValue:@(orderedData.shortVideoOriginalData.shortVideo.author.isFriend) forKey:@"is_friend"];
    [logParams setValue:@"list" forKey:@"position"];
    
    [AWEVideoDetailTracker trackEvent:eventName
                                model:orderedData.shortVideoOriginalData.shortVideo
                      commonParameter:[logParams copy]
                       extraParameter:nil];
}

- (void)sendClickMoreEventWithData:(ExploreOrderedData *)orderedData
{
    NSMutableDictionary *logParams = [[NSMutableDictionary alloc] initWithDictionary:[self trackParamsDictForData:orderedData]];
    [logParams setValue:@"list" forKey:@"position"];
    [TTTrackerWrapper eventV3:@"click_more_shortvideo"
                       params:[logParams copy]];
}

- (NSDictionary *)trackParamsDictForData:(ExploreOrderedData *)data
{
    NSString *categoryName = data.categoryID ?: @"";
    
    NSString *enterFrom;
    if ([data.categoryID isEqualToString:@"__all__"]) {
        enterFrom = @"click_headline";
    } else {
        enterFrom = @"click_category";
    }
    
    return @{@"category_name" : categoryName,
             @"enter_from" : enterFrom,
             };
}

#pragma mark -

- (void)willDisplay
{
    _isDisplaying = YES;
    [self sendEventWithEventName:@"huoshan_video_show" orderedData:self.orderedData];
    
    [self startPrefetchVideo];
}

- (void)didEndDisplaying
{
    _isDisplaying = NO;
    
    [self cancelPrefetchVideo];
}

- (void)registerEnterForegroundNotification
{
    @weakify(self);
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillEnterForegroundNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        if (_isDisplaying) {
            [self sendEventWithEventName:@"huoshan_video_show" orderedData:self.orderedData];
        }
    }];
}

#pragma mark - 预加载视频

- (void)startPrefetchVideo
{
    if (![TSVPrefetchVideoManager isPrefetchEnabled]) {
        return;
    }
    
    [self.prefetchVideoDisposable dispose];
    
    @weakify(self);
    self.prefetchVideoDisposable = [[[[RACSignal return:nil]
                                            delay:0.3f]
                                        deliverOn:[RACScheduler mainThreadScheduler]]
                                    subscribeNext:^(id  _Nullable x) {
                                        @strongify(self);
                                        [self prefetchVideo];
                                    }];
}

- (void)prefetchVideo
{
    [TSVPrefetchVideoManager startPrefetchShortVideo:self.orderedData.shortVideoOriginalData.shortVideo group:TSVVideoPrefetchShortVideoFeedFollowGroup];
}

- (void)cancelPrefetchVideo
{    
    [self.prefetchVideoDisposable dispose];
    
    [TSVPrefetchVideoManager cancelPrefetchShortVideoForGroup:TSVVideoPrefetchShortVideoFeedFollowGroup];
}


@end
