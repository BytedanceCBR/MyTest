//
//  TTHorizontalCardCell.m
//  Article
//
//  Created by 王双华 on 2017/5/16.
//
//

#import "TTHorizontalCardCell.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "HorizontalCard.h"
#import "TSVShortVideoOriginalData.h"
#import "SSThemed.h"
#import "UIViewAdditions.h"
#import <TTUIWidget/TTAlphaThemedButton.h>
#import "TTArticleCellHelper.h"
#import "TTFeedDislikeView.h"
#import "ExploreMixListDefine.h"
#import "TTHorizontalHuoShanVideoCollectionCell.h"
#import "TTHorizontalHuoShanVideoOptimizeCollectionCell.h"
#import "TSVShortVideoDetailExitManager.h"
#import "NSObject+FBKVOController.h"
#import <TTRoute/TTRoute.h>
#import <HTSVideoPlay/HTSVideoPageParamHeader.h>
#import <TTUIWidget/TTNavigationController.h>
#import "TTHorizontalHuoShanCollectionCellProtocol.h"
#import "TSVShortVideoCategoryFetchManager.h"
#import "TTDeviceUIUtils.h"
#import "TSVTransitionAnimationManager.h"
#import "TTHorizontalHuoShanLoadingCell.h"
#import <extobjc.h>
#import "ArticleImpressionHelper.h"
#import "TTDeviceHelper.h"
#import "TTShortVideoHelper.h"
#import "ExploreOrderedData+TTAd.h"
#import "TSVCardBottomInfoViewModel.h"
#import "TSVCardBottomInfoView.h"
#import "TSVCardTopInfoViewModel.h"
#import "TSVCardTopInfoView.h"
#import <TTRelevantDurationTracker.h>
#import "TSVCardCellNormalViewFlowLayout.h"
#import "TSVCardCellQuadraViewFlowLayout.h"
#import "TSVChannelDecoupledConfig.h"
#import "TSVShortVideoDecoupledFetchManager.h"
#import <ReactiveObjC.h>
#import <TSVPrefetchVideoManager.h>

#define kLeft   15
#define kUnInterestedButtonW    60
#define kUnInterestedButtonH    44
#define kUnInterestedIconW    17
#define kBottom 9
#define kPadding    6
#define kCellGap    8
#define ktopMoreArrowW     6
#define ktopMoreArrowH     10
#define ktopMoreArrowLeftGap    4
#define kTopInfoIconW       14
#define kTopInfoIconH       16
#define kTopInfoIconRightGap    6
#define kCollectionViewTopPadding   14
#define kCardRectPadding     6

@implementation TTHorizontalCardCell

+ (Class)cellViewClass
{
    return [TTHorizontalCardCellView class];
}

- (void)willAppear
{
    if ([self.cellView isKindOfClass:[TTHorizontalCardCellView class]]) {
        [((TTHorizontalCardCellView *)self.cellView) willDisplay];
    }
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    if ([self.cellView isKindOfClass:[TTHorizontalCardCellView class]]) {
        [((TTHorizontalCardCellView *)self.cellView) didEndDisplaying];
    }
    
}

- (void)willDisplay
{
    if ([self.cellView isKindOfClass:[TTHorizontalCardCellView class]]) {
        [((TTHorizontalCardCellView *)self.cellView) willDisplay];
    }
}

- (void)didEndDisplaying
{
    if ([self.cellView isKindOfClass:[TTHorizontalCardCellView class]]) {
        [((TTHorizontalCardCellView *)self.cellView) didEndDisplaying];
    }
}

@end

#pragma mark - TTHorizontalCardCellView

@interface  TTHorizontalCardCellView()<UICollectionViewDelegate, UICollectionViewDataSource, SSImpressionProtocol>

///ui
@property (nonatomic, strong) UICollectionView      *collectionView;
@property (nonatomic, strong) SSThemedView          *topRect;
@property (nonatomic, strong) SSThemedView          *bottomRect;
@property (nonatomic, strong) TSVCardBottomInfoView       *cardBottomInfoView;
@property (nonatomic, strong) TSVCardTopInfoView          *cardTopInfoView;

///data
@property (nonatomic, strong) ExploreOrderedData    *orderedData;
@property (nonatomic, strong) HorizontalCard        *horizontalCard;

@property (nonatomic, strong) TSVShortVideoCategoryFetchManager *fetchManager;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) BOOL isHorizontalScrollEnabled;
@property (nonatomic, assign) BOOL isLoadMoreForLastForthForbidden;
@property (nonatomic, assign) BOOL isFinishFirstPrefetch;
@property (nonatomic, assign) CGFloat beginDragX;

@property (nonatomic, assign) BOOL isDisplaying;
@property (nonatomic, assign) BOOL shouldShowLoadingCell;

@property (nonatomic, strong) RACDisposable *prefetchVideoDisposable;

@end

@implementation TTHorizontalCardCellView

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        if ([orderedData.originalData isKindOfClass:[HorizontalCard class]]) {
            
            HorizontalCard *horizontalCard = (HorizontalCard *)orderedData.originalData;

            CGFloat itemHeight = [self collectionViewCellHeightForData:orderedData cardWitdh:width];
            
            TTHorizontalCardStyle cardStyle = [TTShortVideoHelper cardStyleWithData:orderedData];
            if (cardStyle == TTHorizontalCardStyleFour) {
                itemHeight = itemHeight * 2 + 3;
            }
            
            CGFloat height = itemHeight + 2 * kCardRectPadding;
            
            if ([orderedData nextCellHasTopPadding]){
                height -= kCardRectPadding;
            }
            if ([orderedData preCellHasBottomPadding]) {
                height -= kCardRectPadding;
            }
            
            BOOL shouldShowBottomInfoView = [self shouldShowBottomInfoViewForData:horizontalCard];
            if (shouldShowBottomInfoView) {
                height += [TSVCardBottomInfoViewModel heightForData:horizontalCard];
            } else {
                height += kBottom;
            }
            
            BOOL shouldShowTopInfoView = [self shouldShowTopInfoViewForData:horizontalCard];
            if (shouldShowTopInfoView) {
                height += [TSVCardTopInfoViewModel heightForData:horizontalCard];
            } else {
                height += kCollectionViewTopPadding;
            }
            
            if (height > 0) {
                return height;
            }
        }
    }
    return 0.f;
}

+ (CGFloat)collectionViewCellWidthForData:(ExploreOrderedData *)data cardWidth:(CGFloat)width
{

    TTHorizontalCardStyle cardStyle = [TTShortVideoHelper cardStyleWithData:data];
    CGFloat cellGap = [self collectionViewCellGapForData:data];

    if (cardStyle == TTHorizontalCardStyleOne) {
        return (width - kLeft - cellGap) * 2 / 3;
    } else if (cardStyle == TTHorizontalCardStyleThree){
        return (width - kLeft * 2 - cellGap * 2) / 3;
    } else if (cardStyle == TTHorizontalCardStyleFour){
        return (width - kLeft * 2 - cellGap) / 2;
    } else {
        return (width - kLeft * 2 - cellGap) / 2;
    }
}

// 判断双图卡片是否两个都有标题
+ (BOOL)cardItemsHasTitleForData:(ExploreOrderedData *)data
{
    BOOL hasTitle = NO;
    
    for (ExploreOrderedData *item in data.horizontalCard.originalCardItems) {
        hasTitle = (hasTitle || !isEmptyString(item.shortVideoOriginalData.shortVideo.title));
    }
    return hasTitle;
}

+ (CGFloat)collectionViewCellHeightForData:(ExploreOrderedData *)data cardWitdh:(CGFloat)width
{
    Class<TTHorizontalHuoShanCollectionCellProtocol> cls = [self collectionViewCellClassForData:data];

    TTHorizontalCardStyle cardStyle = [TTShortVideoHelper cardStyleWithData:data];
    return [cls heightForHuoShanVideoWithCellWidth:[self collectionViewCellWidthForData:data cardWidth:width] inScrollCard:[data.horizontalCard isHorizontalScrollEnabled] originalCardItemsHasTitle:[self cardItemsHasTitleForData:data] cellStyle:cardStyle];
}

+ (Class<TTHorizontalHuoShanCollectionCellProtocol>)collectionViewCellClassForData:(ExploreOrderedData *)data
{
    HorizontalCard *horizontalCard = data.horizontalCard;
    ExploreOrderedData *itemData = [horizontalCard.originalCardItems firstObject];
    TTHorizontalCardContentCellStyle cellStyle = [TTShortVideoHelper contentCellStyleWithItemData:itemData];
    if (cellStyle == TTHorizontalCardContentCellStyle1 || cellStyle == TTHorizontalCardContentCellStyle2) {
        return [TTHorizontalHuoShanVideoCollectionCell class];
    } else {
        return [TTHorizontalHuoShanVideoOptimizeCollectionCell class];
    }
}

+ (CGFloat)collectionViewCellGapForData:(ExploreOrderedData *)data
{
    TTHorizontalCardStyle cardStyle = [TTShortVideoHelper cardStyleWithData:data];
    if (cardStyle == TTHorizontalCardStyleThree || cardStyle == TTHorizontalCardStyleFour) {
        return 1;
    } else {
        return 1;
    }
}

+ (BOOL)shouldShowBottomInfoViewForData:(HorizontalCard *)data
{
    ExploreOrderedData *itemData = [data.originalCardItems firstObject];
    TTHorizontalCardContentCellStyle cellStyle = [TTShortVideoHelper contentCellStyleWithItemData:itemData];
    return [TSVCardBottomInfoViewModel shouldShowBottomInfoViewForData:data collectionViewCellStyle:cellStyle];
}

+ (BOOL)shouldShowTopInfoViewForData:(HorizontalCard *)data
{
    ExploreOrderedData *itemData = [data.originalCardItems firstObject];
    TTHorizontalCardContentCellStyle cellStyle = [TTShortVideoHelper contentCellStyleWithItemData:itemData];
    return [TSVCardTopInfoViewModel shouldShowTopInfoViewForCollectionViewCellStyle:cellStyle];
}

+ (TTHorizontalHuoShanLoadingCellStyle)loadingCellStyleForData:(ExploreOrderedData *)data
{
    Class<TTHorizontalHuoShanCollectionCellProtocol> cls = [self collectionViewCellClassForData:data];
    
    if (cls == [TTHorizontalHuoShanVideoCollectionCell class]) {
        return TTHorizontalHuoShanLoadingCellStyle1;
    } else {
        return TTHorizontalHuoShanLoadingCellStyle2;
    }
}

#pragma mark -

- (void)dealloc
{
    [[SSImpressionManager shareInstance] removeRegist:self];
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_prefetchVideoDisposable dispose];
}

#pragma mark - UI

- (SSThemedView *)topRect{
    if (!_topRect){
        _topRect = [[SSThemedView alloc] init];
        _topRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_topRect];
    }
    return _topRect;
}

- (SSThemedView *)bottomRect{
    if (!_bottomRect){
        _bottomRect = [[SSThemedView alloc] init];
        _bottomRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_bottomRect];
    }
    return _bottomRect;
}

- (UIView *)cardTopInfoView
{
    if (!_cardTopInfoView) {
        _cardTopInfoView = [[TSVCardTopInfoView alloc] initWithFrame:CGRectZero];
        [self addSubview:_cardTopInfoView];
    }
    return _cardTopInfoView;
}

- (UIView *)cardBottomInfoView
{
    if (!_cardBottomInfoView) {
        _cardBottomInfoView = [[TSVCardBottomInfoView alloc] initWithFrame:CGRectZero];
        [self addSubview:_cardBottomInfoView];
    }
    return _cardBottomInfoView;
}

- (void)refreshUI
{
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
        bounds.origin.y = -kCardRectPadding;
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
    
    ExploreOrderedData *itemData = [self.horizontalCard.originalCardItems firstObject];
    TTHorizontalCardContentCellStyle style = [TTShortVideoHelper contentCellStyleWithItemData:itemData];
    TTHorizontalCardStyle cardStyle = [TTShortVideoHelper cardStyleWithData:self.orderedData];
    
    [self p_refreshTopInfoViewForCellstyle:style];
    [self p_refreshContentViewForCellStyle:cardStyle];
    [self p_refreshBottomInfoViewForCellstyle:style];

    [self adjustContentOffsetIfNeeded];
    [self reloadThemeUI];
}

- (void)p_refreshTopInfoViewForCellstyle:(TTHorizontalCardContentCellStyle)style
{
    BOOL shouldShowTopInfoView = [TSVCardTopInfoViewModel shouldShowTopInfoViewForCollectionViewCellStyle:style];
    if (shouldShowTopInfoView) {
        self.cardTopInfoView.hidden = NO;
        CGFloat cardTopInfoViewHeight = [TSVCardTopInfoViewModel heightForData:self.horizontalCard];
        self.cardTopInfoView.frame = CGRectMake(0, 0, self.width, cardTopInfoViewHeight);
    } else {
        self.cardTopInfoView.hidden = YES;
    }
}

- (void)p_refreshBottomInfoViewForCellstyle:(TTHorizontalCardContentCellStyle)style
{
    BOOL shouldShowBottomInfoView = [[self class] shouldShowBottomInfoViewForData:self.horizontalCard];
    
    if (shouldShowBottomInfoView) {
        self.cardBottomInfoView.hidden = NO;
        CGFloat cardBottomInfoViewHeight = [TSVCardBottomInfoViewModel heightForData:self.horizontalCard];
        self.cardBottomInfoView.frame = CGRectMake(0, self.collectionView.bottom, self.width, cardBottomInfoViewHeight);
        [self.cardBottomInfoView setNeedsLayout];
    } else {
        self.cardBottomInfoView.hidden = YES;
    }
}

- (void)p_refreshContentViewForCellStyle:(TTHorizontalCardStyle)style
{
    BOOL shouldShowTopInfoView = [[self class] shouldShowTopInfoViewForData:self.horizontalCard];
    CGFloat collectionViewHeight = [[self class] collectionViewCellHeightForData:self.orderedData cardWitdh:self.width];
    if (style == TTHorizontalCardStyleFour) {
        collectionViewHeight = collectionViewHeight * 2 + 3;
    }
    if (shouldShowTopInfoView) {
        self.collectionView.frame = CGRectMake(0, self.cardTopInfoView.bottom, self.width, collectionViewHeight);
    } else {
        self.collectionView.frame = CGRectMake(0, self.top + kCollectionViewTopPadding , self.width, collectionViewHeight);
    }
    
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)p_changeCollectionViewLayout
{
    TTHorizontalCardStyle cardStyle = [TTShortVideoHelper cardStyleWithData:self.orderedData];
    
    //  暂时没找到合适时机直接切换layout，先采用这种方式更新样式布局
    [self.collectionView removeFromSuperview];
     if (cardStyle == TTHorizontalCardStyleFour) {
        TSVCardCellQuadraViewFlowLayout *layout = [[TSVCardCellQuadraViewFlowLayout alloc] init];
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    } else {
        TSVCardCellNormalViewFlowLayout *layout = [[TSVCardCellNormalViewFlowLayout alloc] init];
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    }
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.collectionView.scrollsToTop = NO;
    self.collectionView.alwaysBounceHorizontal = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    [self.collectionView registerClass:[TTHorizontalHuoShanVideoCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([TTHorizontalHuoShanVideoCollectionCell class])];
    [self.collectionView registerClass:[TTHorizontalHuoShanVideoOptimizeCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([TTHorizontalHuoShanVideoOptimizeCollectionCell class])];
    [self.collectionView registerClass:[TTHorizontalHuoShanLoadingCell class] forCellWithReuseIdentifier:NSStringFromClass([TTHorizontalHuoShanLoadingCell class])];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    [self addSubview:self.collectionView];
}

#pragma mark -

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    _collectionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

#pragma mark -

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        return;
    }
    if ([self.orderedData.originalData isKindOfClass:[HorizontalCard class]]) {
        [self.KVOController unobserveAll];
        
        self.horizontalCard = (HorizontalCard *)self.orderedData.originalData;
        
        if ([[self class] shouldShowTopInfoViewForData:self.horizontalCard]) {
            [self.cardTopInfoView refreshWithData:self.orderedData];
        }
        
        if ([[self class] shouldShowBottomInfoViewForData:self.horizontalCard]) {
            [self.cardBottomInfoView refreshWithData:self.orderedData];
        }
        
        self.isHorizontalScrollEnabled = [self.horizontalCard isHorizontalScrollEnabled];
        if (self.isHorizontalScrollEnabled) {
            self.fetchManager = self.horizontalCard.prefetchManager;
            
            // 判断是不是因为倒数第一个加载而出现的失败
            WeakSelf;
            self.fetchManager.cardItemsShouldLoadMore = ^ BOOL (){
                StrongSelf;
                NSArray<NSIndexPath *> *visibileIndexPath = [[self.collectionView indexPathsForVisibleItems] sortedArrayUsingSelector:@selector(compare:)];
                
                NSIndexPath *maxVisibleIndexPath = [visibileIndexPath lastObject];
                NSIndexPath *thresholdIndexPath = [NSIndexPath indexPathForItem:[[self.horizontalCard allCardItems] count] - 1 inSection:0];
                
                if ([maxVisibleIndexPath compare:thresholdIndexPath] == NSOrderedAscending) {
                    self.isLoadMoreForLastForthForbidden = YES;
                    return YES;
                } else {
                    return NO;
                }
            };
            
            [self.KVOController observe:self.fetchManager
                                keyPath:@keypath(self.fetchManager, isLoadingRequest)
                                options:NSKeyValueObservingOptionNew
                                  block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                                      StrongSelf;
                                      
                                      if (!self.fetchManager.isLoadingRequest) {
                                          [self.collectionView reloadData];
                                          [self startPrefetchVideo];
                                      }
                                  }];
            [self.KVOController observe:self.fetchManager
                                keyPath:@keypath(self.fetchManager, listCellCurrentIndex)
                                options:NSKeyValueObservingOptionNew
                                  block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                                      StrongSelf;
                                      NSInteger listCellCurrentIndex = self.fetchManager.listCellCurrentIndex;
                                      NSIndexPath *exitIndexPath = [NSIndexPath indexPathForItem:self.fetchManager.listCellCurrentIndex inSection:0];
                                      if (listCellCurrentIndex >= 0 || listCellCurrentIndex < self.fetchManager.horizontalCardItems.count) {
                                          [self scrollToIndex:listCellCurrentIndex animated:YES];
                                      }
                                      self.selectedIndexPath = exitIndexPath;
                                  }];
        }
        
    }
    else {
        return;
    }
    [self p_changeCollectionViewLayout];
    [self refreshUI];
    [self.collectionView reloadData];
}

- (id)cellData {
    return self.orderedData;
}

- (BOOL)shouldShowHorizontalLoadingCell
{
    if (self.isHorizontalScrollEnabled) {
        return [self.fetchManager shouldShowLoadingCell];
    } else {
        return NO;
    }
}

#pragma mark - UICollectionViewDataSource
//展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = [[self.horizontalCard allCardItems] count];
    self.shouldShowLoadingCell = [self shouldShowHorizontalLoadingCell];
    if (self.shouldShowLoadingCell) {
        return count + 1;
    } else {
        return count;
    }
}

//展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (indexPath.item < [[self.horizontalCard allCardItems] count]) {
        NSString *cellIdentifier = NSStringFromClass([[self class] collectionViewCellClassForData:self.orderedData]);
        ExploreOrderedData *cellData = [[self.horizontalCard allCardItems] objectAtIndex:indexPath.item];
        NSAssert(!isEmptyString(cellIdentifier), @"reuseIdentifier must not be nil");
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if ([cell conformsToProtocol:@protocol(TTHorizontalHuoShanCollectionCellProtocol)]) {
            [((id<TTHorizontalHuoShanCollectionCellProtocol>)cell) setupDataSourceWithData:cellData inScrollCard:self.isHorizontalScrollEnabled];
        }
    } else if (indexPath.item == [[self.horizontalCard allCardItems] count]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TTHorizontalHuoShanLoadingCell class]) forIndexPath:indexPath];
        if ([cell isKindOfClass:[TTHorizontalHuoShanLoadingCell class]]) {
            [((TTHorizontalHuoShanLoadingCell *)cell) setStyle:[[self class] loadingCellStyleForData:self.orderedData]];
            [((TTHorizontalHuoShanLoadingCell *)cell) setLoading:self.fetchManager.isLoadingRequest];
            [((TTHorizontalHuoShanLoadingCell *)cell) setDataFetchManager:self.fetchManager];
        }
    }
    NSAssert(cell, @"UICollectionCell must not be nil");
    return cell != nil ? cell : [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
}

#pragma mark UICollectionViewDelegateFlowLayout

//每个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = [[self class] collectionViewCellWidthForData:self.orderedData cardWidth:self.width];
    
    CGFloat cellHeight = [[self class] collectionViewCellHeightForData:self.orderedData cardWitdh:self.width];
    
    return CGSizeMake(cellWidth, cellHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return [[self class] collectionViewCellGapForData:self.orderedData];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return [[self class] collectionViewCellGapForData:self.orderedData];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (indexPath.item < [[self.horizontalCard allCardItems] count]) {
        id obj = [[self.horizontalCard allCardItems] objectAtIndex:indexPath.item];
        
        if (![obj isKindOfClass:[ExploreOrderedData class]]) {
            return;
        }
        
        self.selectedIndexPath = indexPath;
        ExploreOrderedData *orderedData = (ExploreOrderedData *)obj;
        
        if ([orderedData.originalData isKindOfClass:[TSVShortVideoOriginalData class]]) {
            TSVShortVideoOriginalData *shortVideoOriginalData = orderedData.shortVideoOriginalData;
            [[TTRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];
            NSURL *url = [TTStringHelper URLWithURLString:shortVideoOriginalData.shortVideo.detailSchema];
            [self openShortVideoByUrl:url index:indexPath.item item:orderedData];
        }
    } else if (indexPath.item == [[self.horizontalCard allCardItems] count]) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        if ([cell isKindOfClass:[TTHorizontalHuoShanLoadingCell class]]) {
            if (![((TTHorizontalHuoShanLoadingCell *)cell) isLoading] && [TTShortVideoHelper canOpenShortVideoTab]) {
                [TTShortVideoHelper openShortVideoTab];
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfItemsLeft = [[self.horizontalCard allCardItems] count] - indexPath.item;
    
    if (self.isFinishFirstPrefetch) {
        if (numberOfItemsLeft == 4 && !self.isLoadMoreForLastForthForbidden) {
            [self loadMoreDataIfNeeded:YES];
        } else if (numberOfItemsLeft == 1){
            self.isLoadMoreForLastForthForbidden = NO;
            [self loadMoreDataIfNeeded:YES];
        }
    } else if ([cell isKindOfClass:[TTHorizontalHuoShanLoadingCell class]]) {
        self.isFinishFirstPrefetch = YES;
        [self loadMoreDataIfNeeded:YES];
    }
    
    [self processImpressionForItemAtIndexPath:indexPath status:_isDisplaying ? SSImpressionStatusRecording : SSImpressionStatusSuspend];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self processImpressionForItemAtIndexPath:indexPath status:SSImpressionStatusEnd];
}

- (void)openShortVideoByUrl:(NSURL *)url index:(NSInteger)index item:(ExploreOrderedData *)orderedData
{
    if ([[TTRoute sharedRoute] canOpenURL:url]) {
        WeakSelf;
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];
        
        TSVShortVideoDetailExitManager *exitManager = [[TSVShortVideoDetailExitManager alloc] initWithUpdateBlock:^CGRect{
            StrongSelf;
            CGRect imageFrame = [self selectedImageViewFrame];
            imageFrame.origin = CGPointZero;
            return imageFrame;
        } updateTargetViewBlock:^UIView *{
            StrongSelf;
            return [self selectedCollectionViewCell];
        }];
        [info setValue:exitManager forKey:HTSVideoDetailExitManager];
        
        if ([TSVChannelDecoupledConfig strategy] == TSVChannelDecoupledStrategyDisabled) {
            if (!self.isHorizontalScrollEnabled) {
                [self.KVOController unobserve:self.fetchManager];
                TSVShortVideoCategoryFetchManager *fetchManager = [[TSVShortVideoCategoryFetchManager alloc]initWithOrderedDataArray:self.horizontalCard.originalCardItems cardID:[NSString stringWithFormat:@"%lld", self.horizontalCard.uniqueID]];
                fetchManager.currentIndex = [fetchManager indexOfItem:orderedData];
                self.fetchManager = fetchManager;
                [self.KVOController observe:self.fetchManager
                                    keyPath:@keypath(self.fetchManager, listCellCurrentIndex)
                                    options:NSKeyValueObservingOptionNew
                                      block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                                          StrongSelf;
                                          NSIndexPath *exitIndexPath = [NSIndexPath indexPathForItem:self.fetchManager.listCellCurrentIndex inSection:0];
                                          self.selectedIndexPath = exitIndexPath;
                                      }];
            } else {
                self.fetchManager.cardID = [NSString stringWithFormat:@"%lld", self.horizontalCard.uniqueID];
                self.fetchManager.currentIndex = [self.fetchManager indexOfItem:orderedData];
            }
            [info setValue:self.fetchManager forKey:HTSVideoListFetchManager];
        } else {
            TSVShortVideoDecoupledFetchManager *fetchManager = [self decoupledFetchManagerWithClickIndex:index];
            @weakify(self);
            [RACObserve(fetchManager, listCellCurrentIndex) subscribeNext:^(NSNumber *listCellCurrentIndex) {
                @strongify(self);
                
                if ([listCellCurrentIndex integerValue] == NSNotFound) {
                    self.selectedIndexPath = nil;
                    return;
                }
                
                [self scrollToIndex:[listCellCurrentIndex integerValue] animated:YES];
                
                NSIndexPath *exitIndexPath = [NSIndexPath indexPathForItem:[listCellCurrentIndex integerValue] inSection:0];
             
                self.selectedIndexPath = exitIndexPath;
            }];
            [info setValue:fetchManager forKey:HTSVideoListFetchManager];
        }
        
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

- (UICollectionViewCell *)selectedCollectionViewCell
{
    NSIndexPath *indexPath = self.selectedIndexPath;
    
    if (!indexPath) {
        return nil;
    }
    
    if (indexPath.item < [self.collectionView numberOfItemsInSection:0]) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        return cell;
    }
    return nil;
}

- (CGRect)selectedImageViewFrame
{
    UICollectionViewCell *cell = [self selectedCollectionViewCell];
    if ([cell conformsToProtocol:@protocol(TTHorizontalHuoShanCollectionCellProtocol)]) {
        CGRect frame = [cell convertRect:[((id<TTHorizontalHuoShanCollectionCellProtocol>)cell) coverImageViewFrame] toView:nil];
        return frame;
    }
    return CGRectZero;
}

- (void)setSelectedIndexPath:(NSIndexPath *)selectedIndexPath
{
    _selectedIndexPath = selectedIndexPath;
    [TSVTransitionAnimationManager sharedManager].listSelectedCellFrame = [self selectedImageViewFrame];
}

- (NSString *)enterFrom
{
    if ([self.orderedData.categoryID isEqualToString:@"__all__"]) {
        return @"click_headline";
    } else {
        return @"click_category";
    }
}

- (NSString *)categoryName
{
    return self.orderedData.categoryID;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.beginDragX = scrollView.contentOffset.x;
    
    if (self.isHorizontalScrollEnabled && !self.isFinishFirstPrefetch) {
        [self loadMoreDataIfNeeded:YES];
        self.isFinishFirstPrefetch = YES;
    }
    
    [self cancelPrefetchVideo];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (!self.isHorizontalScrollEnabled) {
        return;
    }
    
    CGFloat endTargetX = targetContentOffset->x;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat maxScrollOffsetX = flowLayout.collectionViewContentSize.width - self.collectionView.width;
    
    if (endTargetX <= 0 || endTargetX >= maxScrollOffsetX) {
        return;
    }
    
    CGSize itemSize = [self collectionView:self.collectionView layout:flowLayout sizeForItemAtIndexPath:nil];
    CGFloat minimumInteritemSpacing = [self collectionView:self.collectionView layout:flowLayout minimumInteritemSpacingForSectionAtIndex:0];
    
    CGFloat gap = itemSize.width + minimumInteritemSpacing;
    NSUInteger index = endTargetX / gap;
    
    CGFloat contentX = 0;
    CGFloat fullShownCellsOffsetX = gap * index;
    
    if (endTargetX > self.beginDragX) { //左滑
        if (endTargetX < fullShownCellsOffsetX + gap * 1 / 5) {
            contentX = gap * index;
        } else {
            contentX = gap * (index + 1);
        }
    } else { //右滑
        if (endTargetX > fullShownCellsOffsetX + gap * 4 / 5) {
            contentX = gap * (index + 1);
        } else {
            contentX = gap * index;
        }
    }
    
    contentX = MIN(contentX, maxScrollOffsetX);
    contentX = MAX(0, contentX);
    
    (*targetContentOffset).x = contentX;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self adjustContentOffsetIfNeeded];
        [self startPrefetchVideo];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self adjustContentOffsetIfNeeded];
    [self startPrefetchVideo];
}

- (void)adjustContentOffsetIfNeeded
{
    if (!self.isHorizontalScrollEnabled) {
        return;
    }
    
    self.collectionView.contentOffset = [self adjustedContentOffsetForContentOffset:self.collectionView.contentOffset];
}

#pragma mark -
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    if (!self.isHorizontalScrollEnabled) {
        return;
    }
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    CGSize itemSize = [self collectionView:self.collectionView layout:flowLayout sizeForItemAtIndexPath:nil];
    CGFloat minimumInteritemSpacing = [self collectionView:self.collectionView layout:flowLayout minimumInteritemSpacingForSectionAtIndex:0];
    
    CGFloat contentX = (itemSize.width + minimumInteritemSpacing) * index;
    
    [self.collectionView setContentOffset:[self adjustedContentOffsetForContentOffset:CGPointMake(contentX, 0)] animated:animated];
}

// 水平卡片不支持切频道
- (CGPoint)adjustedContentOffsetForContentOffset:(CGPoint)contentOffset
{
    CGFloat contentX = contentOffset.x;
    
    contentX = MIN(contentX, self.collectionView.collectionViewLayout.collectionViewContentSize.width - self.collectionView.width - [TTDeviceHelper ssOnePixel]);
    contentX = MAX(contentX, [TTDeviceHelper ssOnePixel]);
    
    return CGPointMake(contentX, 0);
}

#pragma mark - preload moredata
- (void)loadMoreDataIfNeeded:(BOOL)isAuto
{
    if (self.isHorizontalScrollEnabled && self.fetchManager.cardItemsHasMoreToLoad && !self.fetchManager.isLoadingRequest) {
        [self.fetchManager requestDataAutomatically:isAuto refreshTyppe:ListDataOperationReloadFromTypeCardDraw finishBlock:nil];
    }
}

#pragma mark -

- (void)willDisplay
{
    _isDisplaying = YES;
    
    NSArray<NSIndexPath *> *visibileIndexPaths = [self.collectionView indexPathsForVisibleItems];
    
    for (NSIndexPath *indexPath in visibileIndexPaths) {
        [self processImpressionForItemAtIndexPath:indexPath status:SSImpressionStatusRecording];
    }
    [[SSImpressionManager shareInstance] addRegist:self];
    
    [self startPrefetchVideo];
}

- (void)didEndDisplaying
{
    _isDisplaying = NO;
    
    NSArray<NSIndexPath *> *visibileIndexPaths = [self.collectionView indexPathsForVisibleItems];
    
    for (NSIndexPath *indexPath in visibileIndexPaths) {
        [self processImpressionForItemAtIndexPath:indexPath status:SSImpressionStatusEnd];
    }
    
    [self cancelPrefetchVideo];
}

#pragma mark - impression
- (void)processImpressionForItemAtIndexPath:(NSIndexPath *)indexPath status:(SSImpressionStatus)status
{
    if (indexPath.item >= [[self.horizontalCard allCardItems] count]) {
        return;
    }
    
    ExploreOrderedData *item = [self. horizontalCard allCardItems][indexPath.item];
    SSImpressionParams *params = [[SSImpressionParams alloc] init];
    SSImpressionGroupType groupType;
    
    if (indexPath.item < [[self.horizontalCard originalCardItems] count]) {
        params.categoryID = self.orderedData.categoryID;
        params.refer = self.cell.refer;
        groupType = SSImpressionGroupTypeGroupList;
    } else {
        params.categoryID = item.categoryID;
        params.refer = 1;
        groupType = SSImpressionGroupTypeHuoshanVideoList;
    }
    
    [[SSImpressionManager shareInstance] recordWithListKey:params.categoryID listType:groupType itemID:@(item.originalData.uniqueID).stringValue modelType:SSImpressionModelTypeUGCVideo adID:nil status:status userInfo:@{@"extra": @{@"refer": @(params.refer)}, @"params": params}];
}

- (void)needRerecordImpressions
{
    NSArray<NSIndexPath *> *visibileIndexPaths = [self.collectionView indexPathsForVisibleItems];
    
    for (NSIndexPath *indexPath in visibileIndexPaths) {
        [self processImpressionForItemAtIndexPath:indexPath status:_isDisplaying ? SSImpressionStatusRecording : SSImpressionStatusSuspend];
    }
}

#pragma mark - 解耦

- (TSVShortVideoDecoupledFetchManager *)decoupledFetchManagerWithClickIndex:(NSInteger)clickIndex
{
    NSInteger maxIndex;
    
    maxIndex = clickIndex + [TSVChannelDecoupledConfig numberOfExtraItemsTakenToDetailPage];
    
    NSMutableArray<TTShortVideoModel *> *mutArr = [NSMutableArray array];
    
    for (NSInteger index = clickIndex; index <= maxIndex; index++) {
        if (index < [self.horizontalCard allCardItems].count) {
            ExploreOrderedData *orderedData = [self.horizontalCard allCardItems][index];
            
            if ([orderedData isKindOfClass:[ExploreOrderedData class]] && orderedData.shortVideoOriginalData.shortVideo) {
                TTShortVideoModel *model = orderedData.shortVideoOriginalData.shortVideo;
                
                model.listIndex = @(index);
                if (index < [self.horizontalCard originalCardItems].count) {
                    model.cardID = [NSString stringWithFormat:@"%lld", self.horizontalCard.uniqueID];
                    model.cardPosition = [NSString stringWithFormat:@"%ld",index + 1];
                    model.categoryName = [self categoryName];
                    model.enterFrom = [self enterFrom];
                } else {
                    model.categoryName = kTTUGCVideoCategoryID;
                    model.enterFrom = @"click_category";
                    model.listEntrance = @"more_shortvideo";
                }
                
                [mutArr addObject:model];
            }
        }
    }
    
    return [[TSVShortVideoDecoupledFetchManager alloc] initWithItems:[mutArr copy]
                                                   requestCategoryID:[NSString stringWithFormat:@"%@_feed_detail_draw", kTTUGCVideoCategoryID]
                                                  trackingCategoryID:kTTUGCVideoCategoryID
                                                        listEntrance:@"more_shortvideo"];
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
    NSArray<NSIndexPath *> *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];

    for (NSIndexPath *indexPath in visibleIndexPaths) {
        if (indexPath.item >= [[self.horizontalCard allCardItems] count]) {
            continue;
        }

        ExploreOrderedData *data = [self.horizontalCard allCardItems][indexPath.item];

        if (![data isKindOfClass:[ExploreOrderedData class]]) {
            continue;
        }

        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;

        [TSVPrefetchVideoManager startPrefetchShortVideo:orderedData.shortVideoOriginalData.shortVideo group:TSVVideoPrefetchShortVideoFeedCardGroup];
    }
}

- (void)cancelPrefetchVideo
{
    [self.prefetchVideoDisposable dispose];

    [TSVPrefetchVideoManager cancelPrefetchShortVideoForGroup:TSVVideoPrefetchShortVideoFeedCardGroup];
}

@end
