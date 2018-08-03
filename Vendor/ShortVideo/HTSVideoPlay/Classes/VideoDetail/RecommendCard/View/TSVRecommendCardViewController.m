//
//  TSVRecommendCardViewController.m
//  HTSVideoPlay
//
//  Created by dingjinlu on 2018/1/15.
//

#import "TSVRecommendCardViewController.h"
#import "TSVRecommendCardViewModel.h"
#import "TSVRecommendCardModel.h"
#import "TSVUserRecommendationViewModel.h"
#import "TSVUserRecommendationModel.h"
#import "TSVRecommendCardCollectionViewCell.h"
#import "ReactiveObjC.h"
#import "TTDeviceUIUtils.h"
#import "UIViewAdditions.h"
#import "TTBaseMacro.h"

@interface TSVRecommendCardCollectionView : UICollectionView
@end

@implementation TSVRecommendCardCollectionView
/**
 *  嵌套 UIScrollView 时，子 scrollview 会通过 -(id)_containingScrollView; 方法得到父(祖先) scrollview
 *  然后利用该方法在 bounces 时一起带动父(祖先) scrollview
 *  这里需要保持父(祖先) scrollview 不动
**/
- (void)_attemptToDragParent:(id)parent forNewBounds:(CGRect)new oldBounds:(CGRect)old
{
    return;
}

@end

@interface TSVRecommendCardViewController() <UICollectionViewDelegate, UICollectionViewDataSource, SSImpressionProtocol>

@property (nonatomic, strong) TSVRecommendCardCollectionView *collectionView;

@end

@implementation TSVRecommendCardViewController

-(instancetype)init
{
    self = [super init];
    if (self) {
        @weakify(self);
        [[RACObserve(self, viewModel.userCards) distinctUntilChanged]
         subscribeNext:^(TSVRecommendCardModel *model) {
             @strongify(self);
             [self refreshData];
         }];
        
        [RACObserve(self, viewModel.scrollAfterFollowed) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            BOOL scrollAfterFollowed = [x boolValue];
            if (scrollAfterFollowed) {
                [self scrollAfterFollowed];
            }
        }];
        
        [RACObserve(self, viewModel.resetContentOffset) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            BOOL resetContentOffset = [x boolValue];
            if (resetContentOffset) {
                [self resetContentOffset];
            }
        }];
    }
    return self;
}

- (void)refreshData
{
    [self.collectionView reloadData];
    [self.collectionView setNeedsDisplay];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.viewModel didSelectItemAtIndex:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[TSVRecommendCardCollectionViewCell class]]) {
        [self.viewModel processImpressionAtIndex:indexPath status:self.viewModel.isRecommendCardShowing? SSImpressionStatusRecording:SSImpressionStatusSuspend];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[TSVRecommendCardCollectionViewCell class]]) {
        [self.viewModel processImpressionAtIndex:indexPath status:SSImpressionStatusEnd];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewModel.userCards count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TSVRecommendCardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TSVRecommendCardCollectionViewCell class]) forIndexPath:indexPath];
    cell.viewModel = [self.viewModel viewModelAtIndex:indexPath.item];
    NSAssert(cell, @"cell should not be nil");
    return cell != nil ? cell : [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        self.collectionView.contentOffset = [self adjustedContentOffsetForContentOffset:self.collectionView.contentOffset];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.collectionView.contentOffset = [self adjustedContentOffsetForContentOffset:self.collectionView.contentOffset];
}

- (CGPoint)adjustedContentOffsetForContentOffset:(CGPoint)contentOffset
{
    CGFloat contentX = contentOffset.x;
    
    contentX = MIN(contentX, self.collectionView.collectionViewLayout.collectionViewContentSize.width - self.collectionView.width - [TTDeviceHelper ssOnePixel]);
    contentX = MAX(contentX, [TTDeviceHelper ssOnePixel]);
    
    return CGPointMake(contentX, 0);
}

#pragma mark -

- (void)scrollAfterFollowed
{
    NSIndexPath* firstVisibleItem = nil;
    for (NSIndexPath* indexPath in self.collectionView.indexPathsForVisibleItems) {
        if (firstVisibleItem == nil || indexPath.section < firstVisibleItem.section || indexPath.item < firstVisibleItem.item) {
            firstVisibleItem = indexPath;
        }
    }
    if (firstVisibleItem != nil) {
        
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*) self.collectionView.collectionViewLayout;
        
        CGSize itemSize = flowLayout.itemSize;
        
        CGFloat minimumInteritemSpacing = flowLayout.minimumLineSpacing;
        CGFloat header = flowLayout.sectionInset.left;
        
        CGFloat gap = itemSize.width + minimumInteritemSpacing;
        
        CGFloat contentX = gap * (firstVisibleItem.item+1) + header - minimumInteritemSpacing;
        
        contentX = MIN(contentX, self.collectionView.contentSize.width - self.collectionView.width);
        if (contentX > 0) {
            [self.collectionView setContentOffset:[self adjustedContentOffsetForContentOffset:CGPointMake(contentX, 0)] animated:YES];
        }
    }
}

- (void)resetContentOffset
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView setContentOffset:[self adjustedContentOffsetForContentOffset:CGPointMake(0, 0)] animated:NO];
    });
}

#pragma mark -

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
        layout.minimumLineSpacing = 6;
        layout.itemSize = CGSizeMake(130,156);
        
        _collectionView = [[TSVRecommendCardCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.scrollsToTop = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        [_collectionView registerClass:[TSVRecommendCardCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TSVRecommendCardCollectionViewCell class])];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

#pragma mark -- SSImpressionProtocol

- (void)needRerecordImpressions
{
    if (self.viewModel.userCards.count <= 0) {
        return;
    }
    
    for (NSIndexPath* indexPath in self.collectionView.indexPathsForVisibleItems) {
        if (indexPath.item < self.viewModel.userCards.count) {
            [self.viewModel processImpressionAtIndex:indexPath status:self.viewModel.isRecommendCardShowing? SSImpressionStatusRecording:SSImpressionStatusSuspend];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.viewModel viewWillAppear];
    [[SSImpressionManager shareInstance] addRegist:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.viewModel viewWillDisappear];
}

- (void)dealloc
{
    [[SSImpressionManager shareInstance] removeRegist:self];
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

@end
