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
#import "TTFeedDislikeView.h"
#import "ExploreMixListDefine.h"
#import "TTHorizontalHuoShanVideoOptimizeCollectionCell.h"
#import "TSVShortVideoDetailExitManager.h"
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
#import <TTRelevantDurationTracker.h>
#import "TSVChannelDecoupledConfig.h"
#import "TSVShortVideoDecoupledFetchManager.h"
#import <ReactiveObjC.h>
#import <TSVPrefetchVideoManager.h>
#import "TTUISettingHelper.h"
//#import "ExploreOrderDataSimpleWitnessRecorder.h"
#import "TSVHorizontalCardCellInfoView.h"
#import "TTStringHelper.h"
#import "ExploreCellHelper.h"
#import "TSVHorizontalCardViewModel.h"

#define kLeft                   15
#define kCardRectPadding        6
#define kCollectionViewPadding  12
#define kAspectRatio            (247.f / 354.f)

static CGFloat const kMinimumLineSpacing = 6;

@implementation TTHorizontalCardCell

+ (Class)cellClassWithData:(ExploreOrderedData *)orderedData
{
    return [self class];
}

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

@interface TTHorizontalCardCellView()<UICollectionViewDelegate, UICollectionViewDataSource, SSImpressionProtocol>

///ui
@property (nonatomic, strong) UICollectionView      *collectionView;
@property (nonatomic, strong) SSThemedView          *topRect;
@property (nonatomic, strong) SSThemedView          *bottomRect;
@property (nonatomic, strong) SSThemedView          *bottomLineView;
@property (nonatomic, strong) TSVHorizontalCardCellInfoView *cardInfoView;
///data
@property (nonatomic, strong) TSVHorizontalCardViewModel *viewModel;
@property (nonatomic, strong) ExploreOrderedData    *orderedData;
@property (nonatomic, strong) HorizontalCard        *horizontalCard;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) CGFloat beginDragX;
@property (nonatomic, assign) BOOL isDisplaying;

@property (nonatomic, strong) RACDisposable *prefetchVideoDisposable;

@end

@implementation TTHorizontalCardCellView

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        if ([orderedData.originalData isKindOfClass:[HorizontalCard class]]) {
        
            CGFloat itemHeight = [self collectionViewCellHeightForData:orderedData cardWitdh:width];
            
            CGFloat height = itemHeight + 40 + 2 * kCardRectPadding + kCollectionViewPadding;
            
            if ([orderedData nextCellHasTopPadding]) {
                height -= kCardRectPadding;
            }
            if ([orderedData preCellHasBottomPadding]) {
                height -= kCardRectPadding;
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
    return (width - kLeft - 6.f) * kAspectRatio;
}

+ (CGFloat)collectionViewCellHeightForData:(ExploreOrderedData *)data cardWitdh:(CGFloat)width
{
    Class<TTHorizontalHuoShanCollectionCellProtocol> cls = [self collectionViewCellClassForData:data];

    return [cls heightForHuoShanVideoWithCellWidth:[self collectionViewCellWidthForData:data cardWidth:width]];
}

+ (Class<TTHorizontalHuoShanCollectionCellProtocol>)collectionViewCellClassForData:(ExploreOrderedData *)data
{
    return [TTHorizontalHuoShanVideoOptimizeCollectionCell class];
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

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self bindRAC];
    }
    
    return self;
}

- (void)bindRAC
{
    @weakify(self);
    [RACObserve(self, viewModel.isLoadingRequest) subscribeNext:^(NSNumber *isLoadingRequest) {
        @strongify(self);
        if (![isLoadingRequest boolValue]) {
            [self.collectionView reloadData];
            [self startPrefetchVideo];
        }
    }];
    
    [RACObserve(self, viewModel.listCellIndex) subscribeNext:^(NSNumber *index) {
        @strongify(self);
        if (index.integerValue != NSNotFound) {
            [self scrollToIndex:index.integerValue animated:YES];
            
            NSIndexPath *exitIndexPath = [NSIndexPath indexPathForItem:index.integerValue inSection:0];
            
            self.selectedIndexPath = exitIndexPath;
        } else {
            self.selectedIndexPath = nil;
        }
    }];
}

#pragma mark - UI

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, kLeft, 0, kLeft);
        layout.minimumLineSpacing = kMinimumLineSpacing;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        _collectionView.scrollsToTop = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        [_collectionView registerClass:[TTHorizontalHuoShanVideoOptimizeCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([TTHorizontalHuoShanVideoOptimizeCollectionCell class])];
        [_collectionView registerClass:[TTHorizontalHuoShanLoadingCell class] forCellWithReuseIdentifier:NSStringFromClass([TTHorizontalHuoShanLoadingCell class])];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (SSThemedView *)topRect
{
    if (!_topRect){
        _topRect = [[SSThemedView alloc] init];
        _topRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_topRect];
    }
    return _topRect;
}

- (SSThemedView *)bottomRect
{
    if (!_bottomRect){
        _bottomRect = [[SSThemedView alloc] init];
        _bottomRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_bottomRect];
    }
    return _bottomRect;
}

- (SSThemedView *)bottomLineView
{
    if (!_bottomLineView) {
        _bottomLineView = [[SSThemedView alloc] init];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_bottomLineView];
    }
    return _bottomLineView;
}

-(TSVHorizontalCardCellInfoView *)cardInfoView
{
    if (!_cardInfoView) {
        _cardInfoView = [[TSVHorizontalCardCellInfoView alloc] initWithFrame:CGRectZero];
        [self addSubview:_cardInfoView];
    }
    return _cardInfoView;
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
        self.bottomLineView.hidden = YES;
    } else {
        self.bottomRect.hidden = YES;
        self.bottomLineView.frame = CGRectMake(kLeft, self.height - [TTDeviceHelper ssOnePixel], self.width - 2 * kLeft, [TTDeviceHelper ssOnePixel]);
        self.bottomLineView.hidden = NO;
    }
    
    NSUInteger cardType = [self.horizontalCard.cardType integerValue];
    CGFloat collectionViewHeight = [[self class] collectionViewCellHeightForData:self.orderedData cardWitdh:self.width];
    if (cardType == 0) {
        self.collectionView.frame = CGRectMake(0, self.top + kCollectionViewPadding , self.width, collectionViewHeight);
        self.cardInfoView.frame = CGRectMake(0, self.collectionView.bottom, self.width, 40);
    } else if (cardType == 1) {
        self.cardInfoView.frame = CGRectMake(0, 0, self.width, 40);
        self.collectionView.frame = CGRectMake(0, self.cardInfoView.bottom, self.width, collectionViewHeight);
    }
    [self.collectionView.collectionViewLayout invalidateLayout];

    [self adjustContentOffsetIfNeeded];
    [self reloadThemeUI];
}

#pragma mark -

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [self configureBackgroundColor];
}

#pragma mark -

- (void)refreshWithData:(id)data
{
    if (![data isKindOfClass:[ExploreOrderedData class]] ||
        ![((ExploreOrderedData *)data).originalData isKindOfClass:[HorizontalCard class]] ||
        ((ExploreOrderedData *)data).originalData == self.orderedData.originalData) {
        return;
    }
    
    self.viewModel = [[TSVHorizontalCardViewModel alloc] initWithData:data];
    self.orderedData = data;
    self.horizontalCard = (HorizontalCard *)self.orderedData.originalData;
    [self.cardInfoView refreshWithData:self.orderedData];
    
    [self.collectionView reloadData];
    [self scrollToIndex:0 animated:NO];
    [self refreshUI];
}

- (void)configureBackgroundColor
{
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.collectionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (id)cellData
{
    return self.orderedData;
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewModel numberOfItems];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    if (indexPath.item < [self.viewModel numberOfCardItems]) {
        NSString *cellIdentifier = NSStringFromClass([[self class] collectionViewCellClassForData:self.orderedData]);
        ExploreOrderedData *cellData = [self.viewModel itemAtIndexPath:indexPath];
        NSAssert(!isEmptyString(cellIdentifier), @"reuseIdentifier must not be nil");
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if ([cell conformsToProtocol:@protocol(TTHorizontalHuoShanCollectionCellProtocol)]) {
            [((id<TTHorizontalHuoShanCollectionCellProtocol>)cell) setupDataSourceWithData:cellData];
        }
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TTHorizontalHuoShanLoadingCell class]) forIndexPath:indexPath];
        if ([cell isKindOfClass:[TTHorizontalHuoShanLoadingCell class]]) {
            [((TTHorizontalHuoShanLoadingCell *)cell) setLoading:self.viewModel.isLoadingRequest];
            [((TTHorizontalHuoShanLoadingCell *)cell) setDataFetchManager:self.viewModel.cardFetchManager];
        }
    }
    
    NSAssert(cell, @"UICollectionCell must not be nil");
    return cell ?: [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = [[self class] collectionViewCellWidthForData:self.orderedData cardWidth:self.width];
    
    CGFloat cellHeight = [[self class] collectionViewCellHeightForData:self.orderedData cardWitdh:self.width];
    
    return CGSizeMake(cellWidth, cellHeight);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (indexPath.item < [self.viewModel numberOfCardItems]) {
        id obj = [self.viewModel itemAtIndexPath:indexPath];
        
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
    } else {
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
    if ([cell isKindOfClass:[TTHorizontalHuoShanLoadingCell class]]) {
        [self.viewModel loadMoreDataIfNeeded:YES];
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
        @weakify(self);
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:2];
        
        TSVShortVideoDetailExitManager *exitManager = [[TSVShortVideoDetailExitManager alloc] initWithUpdateBlock:^CGRect{
            @strongify(self);
            CGRect imageFrame = [self selectedImageViewFrame];
            imageFrame.origin = CGPointZero;
            return imageFrame;
        } updateTargetViewBlock:^UIView *{
            @strongify(self);
            return [self selectedCollectionViewCell];
        }];
        [info setValue:exitManager forKey:HTSVideoDetailExitManager];
        
        [info setValue:[self.viewModel detailDataFetchManagerWhenClickAtIndex:index item:orderedData] forKey:HTSVideoListFetchManager];
        
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.beginDragX = scrollView.contentOffset.x;
    
    [self.viewModel loadMoreDataIfNeeded:YES];
    
    [self cancelPrefetchVideo];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat endTargetX = targetContentOffset->x;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat maxScrollOffsetX = flowLayout.collectionViewContentSize.width - self.collectionView.width;
    
    if (endTargetX <= 0 || endTargetX >= maxScrollOffsetX) {
        return;
    }
    
    CGSize itemSize = [self collectionView:self.collectionView layout:flowLayout sizeForItemAtIndexPath:nil];
    
    CGFloat gap = itemSize.width + kMinimumLineSpacing;
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
    self.collectionView.contentOffset = [self adjustedContentOffsetForContentOffset:self.collectionView.contentOffset];
}

#pragma mark -

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
    CGSize itemSize = [self collectionView:self.collectionView layout:flowLayout sizeForItemAtIndexPath:nil];
    CGFloat contentX = (itemSize.width + kMinimumLineSpacing) * index;
    
    [self.collectionView setContentOffset:[self adjustedContentOffsetForContentOffset:CGPointMake(contentX, 0)] animated:animated];
}

// 水平卡片不支持切频道
- (CGPoint)adjustedContentOffsetForContentOffset:(CGPoint)contentOffset
{
    CGFloat contentX = contentOffset.x;
    
    contentX = MIN(contentX, floor(self.collectionView.collectionViewLayout.collectionViewContentSize.width) - self.collectionView.width - [TTDeviceHelper ssOnePixel]);
    contentX = MAX(contentX, [TTDeviceHelper ssOnePixel]);
    
    return CGPointMake(contentX, 0);
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
    if (indexPath.item >= [self.viewModel numberOfCardItems]) {
        return;
    }
    
    ExploreOrderedData *item = [self.viewModel itemAtIndexPath:indexPath];
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

#pragma mark - 视频预加载

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
        if (indexPath.item >= [self.viewModel numberOfCardItems]) {
            continue;
        }
        ExploreOrderedData *orderedData = [self.viewModel itemAtIndexPath:indexPath];

        [TSVPrefetchVideoManager startPrefetchShortVideo:orderedData.shortVideoOriginalData.shortVideo group:TSVVideoPrefetchShortVideoFeedCardGroup];
    }
}

- (void)cancelPrefetchVideo
{
    [self.prefetchVideoDisposable dispose];

    [TSVPrefetchVideoManager cancelPrefetchShortVideoForGroup:TSVVideoPrefetchShortVideoFeedCardGroup];
}

@end
