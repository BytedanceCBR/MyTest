//
//  TSVRecUserCardCollectionViewCell.m
//  Article
//
//  Created by 王双华 on 2017/9/26.
//

#import "TSVRecUserCardCollectionViewCell.h"
#import <TTThemed/SSThemed.h>
#import <TTUIWidget/TTAlphaThemedButton.h>
#import "TSVRecUserCardModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TSVRecUserSinglePersonCollectionViewCell.h"
#import <TTImpression/SSImpressionManager.h>
#import <TTPlatformUIModel/TTFeedDislikeView.h>
#import "ExploreOrderedData.h"

@interface TSVRecUserCardCollectionViewCell()<UICollectionViewDelegate, UICollectionViewDataSource, SSImpressionProtocol>

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) TTAlphaThemedButton *unInterestedButton;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic) BOOL isOnScreen;

@end

@implementation TSVRecUserCardCollectionViewCell

@synthesize dislikeBlock;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.titleLabel = ({
            SSThemedLabel *label = [[SSThemedLabel alloc] init];
            label.font = [UIFont systemFontOfSize:14.f];
            label.textColorThemeKey = kColorText15;
            label;
        });
        [self.contentView addSubview:self.titleLabel];
        
        self.unInterestedButton = ({
            TTAlphaThemedButton *button = [[TTAlphaThemedButton alloc] init];
            button.imageName = @"add_textpage.png";
            button.backgroundColor = [UIColor clearColor];
            @weakify(self);
            [[[button rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal]
             subscribeNext:^(id x) {
                 @strongify(self);
                 [self unInterestButtonClicked:nil];
             }];
            button;
        });
        [self.contentView addSubview:self.unInterestedButton];
        
        self.collectionView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.itemSize = CGSizeMake(142, 175);
//            layout.minimumInteritemSpacing = 8;
            layout.minimumLineSpacing = 8;
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.headerReferenceSize = CGSizeMake(8, 175);
            layout.footerReferenceSize = CGSizeMake(8, 175);
            
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            collectionView.scrollsToTop = NO;
            collectionView.showsHorizontalScrollIndicator = NO;
            collectionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
            collectionView.dataSource = self;
            collectionView.delegate = self;
            [collectionView registerClass:[TSVRecUserSinglePersonCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([TSVRecUserSinglePersonCollectionViewCell class])];
            collectionView;
        });
        [self.contentView addSubview:self.collectionView];
        
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        @weakify(self);
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTThemeManagerThemeModeChangedNotification object:nil]
          takeUntil:self.rac_willDeallocSignal]
         subscribeNext:^(id x) {
             @strongify(self);
             self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
             self.collectionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
         }];
        
        [self bindViewModel];
        [CATransaction commit];
    }
    return self;
}

- (void)layoutSubviews
{
    [UIView performWithoutAnimation:^{
        [super layoutSubviews];
        self.titleLabel.left = 8;
        self.titleLabel.top = 9;
        self.titleLabel.width = self.width - 8 - 60;
        self.titleLabel.height = 20;
        
        self.unInterestedButton.width = 47;
        self.unInterestedButton.height = 40;
        self.unInterestedButton.right = self.width;
        self.unInterestedButton.centerY = self.titleLabel.centerY;
        
        self.collectionView.left = 0 ;
        self.collectionView.top = self.titleLabel.bottom + 10;
        self.collectionView.width = self.width;
        self.collectionView.height = 175;
    }];
}

- (void)bindViewModel
{
    RAC(self, titleLabel.text) = RACObserve(self, viewModel.title);
    @weakify(self);
    [RACObserve(self, viewModel) subscribeNext:^(id x) {
        @strongify(self);
        [self.collectionView reloadData];
        [self.collectionView setContentOffset:CGPointZero];
    }];
}

#pragma mark -- UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TSVRecUserSinglePersonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TSVRecUserSinglePersonCollectionViewCell class]) forIndexPath:indexPath];
    cell.viewModel = [self.viewModel singlePersonCollectionViewCellViewModelAtIndex:indexPath.item];
    @weakify(self);
    cell.handleFollowBtnTapBlock = ^{
        @strongify(self);
        [self.viewModel handleSinglePersonCollectionViewCellFollowBtnTapAtIndex:indexPath.item];
    };
    NSAssert(cell, @"UICollectionCell must not be nil");
    return cell != nil ? cell : [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewModel numberOfSinglePersonCollectionViewCellViewModel];
}

#pragma mark -- UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.viewModel didSelectSinglePersonCollectionViewCellAtIndex:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.viewModel willDisplaySinglePersonCollectionViewCellAtIndex:indexPath.item];
    // impression统计
    TSVRecUserSinglePersonCollectionViewCellViewModel *viewModel = [self.viewModel singlePersonCollectionViewCellViewModelAtIndex:indexPath.item];
    NSMutableDictionary *params = @{}.mutableCopy;
    if (!isEmptyString(viewModel.statsPlaceHolder)) {
        [params setValue:[NSString stringWithFormat:@"user_recommend_impression_event:%@", viewModel.statsPlaceHolder]
                  forKey:@"user_recommend_impression_event"];
    }
    NSAssert(viewModel.userID, @"userID should not be nil");
    [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:viewModel.userID
                                                                    categoryName:[self _categoryName]
                                                                          cellId:[self _cellID]
                                                                          status:self.isOnScreen? SSImpressionStatusRecording:SSImpressionStatusSuspend
                                                                           extra:params.copy];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    //埋点
    TSVRecUserSinglePersonCollectionViewCellViewModel *viewModel = [self.viewModel singlePersonCollectionViewCellViewModelAtIndex:indexPath.item];
   
    // impression统计
    NSMutableDictionary *params = @{}.mutableCopy;
    if (!isEmptyString(viewModel.statsPlaceHolder)) {
        [params setValue:[NSString stringWithFormat:@"user_recommend_impression_event:%@", viewModel.statsPlaceHolder]
                  forKey:@"user_recommend_impression_event"];
    }
    NSAssert(viewModel.userID, @"userID should not be nil");
    [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:viewModel.userID
                                                                    categoryName:[self _categoryName]
                                                                          cellId:[self _cellID]
                                                                          status:SSImpressionStatusEnd
                                                                           extra:params.copy];
}

#pragma mark -- SSImpressionProtocol

- (void)willDisplay {
    self.isOnScreen = YES;
    
    [[SSImpressionManager shareInstance] enterRecommendUserListWithCategoryName:[self _categoryName] cellId:[self _cellID]];
    [[SSImpressionManager shareInstance] addRegist:self];
}

- (void)didEndDisplaying {
    self.isOnScreen = NO;
    
    [[SSImpressionManager shareInstance] leaveRecommendUserListWithCategoryName:[self _categoryName] cellId:[self _cellID]];
}

- (void)needRerecordImpressions {
    if ([self.viewModel numberOfSinglePersonCollectionViewCellViewModel] == 0) {
        return;
    }
    
    for (NSIndexPath* indexPath in self.collectionView.indexPathsForVisibleItems) {
        if ([self.viewModel numberOfSinglePersonCollectionViewCellViewModel] > indexPath.row) {
            TSVRecUserSinglePersonCollectionViewCellViewModel *viewModel = [self.viewModel singlePersonCollectionViewCellViewModelAtIndex:indexPath.item];
            NSMutableDictionary *params = @{}.mutableCopy;
            if (!isEmptyString(viewModel.statsPlaceHolder)) {
                [params setValue:[NSString stringWithFormat:@"user_recommend_impression_event:%@", viewModel.statsPlaceHolder]
                          forKey:@"user_recommend_impression_event"];
            }
            NSAssert(viewModel.userID, @"userID should not be nil");
            [[SSImpressionManager shareInstance] recordRecommendUserListImpressionUserID:viewModel.userID
                                                                            categoryName:[self _categoryName]
                                                                                  cellId:[self _cellID]
                                                                                  status:self.isOnScreen? SSImpressionStatusRecording:SSImpressionStatusSuspend
                                                                                   extra:params.copy];
        }
    }
}

- (NSString *)_categoryName
{
    NSAssert(self.viewModel.categoryName, @"categoryName should not be nil");
    return self.viewModel.categoryName ?: @"";
}

- (NSString *)_cellID
{
    NSAssert(self.viewModel.cardID, @"cardID should not be nil");
    return self.viewModel.cardID ?: @"";
}

#pragma mark -- TSVWaterfallCollectionViewCellProtocol

- (void)refreshWithData:(ExploreOrderedData *)data
{
    self.viewModel = [[TSVRecUserCardCollectionViewCellViewModel alloc] initWithOrderedData:data];
}

- (ExploreOrderedData *)cellData
{
    return [self.viewModel cellData];
}

#pragma mark - unInterestButton action
- (void)unInterestButtonClicked:(id)sender
{
    [TTFeedDislikeView dismissIfVisible];
    [self showMenu];
}

- (void)showMenu
{
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.groupID = [self cellData].uniqueID;
    viewModel.logExtra = [self cellData].logExtra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = _unInterestedButton.center;
    [dislikeView showAtPoint:point
                    fromView:_unInterestedButton
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view];
             }];
}

#pragma mark TTFeedDislikeView

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)dislikeView {
    if (![self cellData]) {
        return;
    }
    else {
        if (self.dislikeBlock) {
            self.dislikeBlock();
        }
        [self.viewModel handleCardCollectionViewCellDislike];
    }
}
@end
