//
//  FHNeighborhoodDetailCommentAndQuestionSC.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/12.
//

#import "FHNeighborhoodDetailCommentAndQuestionSC.h"
#import "FHNeighborhoodDetailCommentAndQuestionSM.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHAssociateIMModel.h"
#import "FHNewHouseDetailViewController.h"
#import "FHNewHouseDetailViewModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHHouseIMClueHelper.h"
#import "FHNeighborhoodDetailCommentHeaderCell.h"
#import "FHNeighborhoodDetailQuestionHeaderCell.h"
#import "FHUGCFeedDetailJumpManager.h"
#import "FHRealtorEvaluatingPhoneCallModel.h"
#import "FHRealtorEvaluatingTracerHelper.h"
#import "FHNeighborhoodDetailQuestionCell.h"
#import "FHNeighborhoodDetailPostCell.h"
#import "FHNeighborhoodDetailSpaceCell.h"
#import "FHNeighborhoodDetailCommentTagsCell.h"

@interface FHNeighborhoodDetailCommentAndQuestionSC () <IGListSupplementaryViewSource, IGListDisplayDelegate>

@property (nonatomic, strong) FHUGCFeedDetailJumpManager *detailJumpManager;
@property (nonatomic, strong) FHRealtorEvaluatingTracerHelper *tracerHelper;
@property (nonatomic, assign) BOOL canElementShow;

@end

@implementation FHNeighborhoodDetailCommentAndQuestionSC

- (instancetype)init
{
    if (self = [super init]) {
        //        self.minimumLineSpacing = 20;
        self.inset = UIEdgeInsetsMake(0, 15, 12, 15);
        self.supplementaryViewSource = self;
        self.displayDelegate = self;
        self.detailJumpManager = [[FHUGCFeedDetailJumpManager alloc] init];
        self.detailJumpManager.refer = 1;
        self.tracerHelper = [[FHRealtorEvaluatingTracerHelper alloc] init];
        _canElementShow = YES;
    }
    return self;
}

#pragma mark - Action

- (void)gotoLinkUrl:(FHFeedUGCCellModel *)cellModel url:(NSURL *)url {
    // PM要求点富文本链接也进入详情页
    [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];

}

- (void)clickRealtorHeader:(FHFeedUGCCellModel *)cellModel {
//    FHNewHouseDetailRGCListSM *sectionModel = (FHNewHouseDetailRGCListSM *)self.sectionModel;
//    NSDictionary *houseInfo = sectionModel.extraDic;
//    if ([houseInfo[@"houseType"] integerValue] == FHHouseTypeSecondHandHouse) {
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//         dict[@"element_from"] = @"old_detail_related";
//        dict[@"enter_from"] = [self.detailViewController.viewModel pageTypeString];
//        [self.realtorPhoneCallModel jump2RealtorDetailWithPhone:cellModel.realtor isPreLoad:NO extra:dict];
//    }
}

- (void)moreButtonClick {
//    FHNewHouseDetailRGCListSM *sectionModel = (FHNewHouseDetailRGCListSM *)self.sectionModel;
//    NSDictionary *houseInfo = sectionModel.extraDic;
//    NSMutableDictionary *tracer = @{}.mutableCopy;
//    [tracer addEntriesFromDictionary:sectionModel.detailTracerDic];
//    [tracer setValue:houseInfo[@"houseId"] forKey:@"from_gid"];
//    [tracer setValue:tracer[@"page_type"] forKey:@"enter_from"];
//    NSDictionary *dict = @{@"tracer":tracer};
//    TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
//    NSURL *openURL = [NSURL URLWithString:sectionModel.contentModel.schema];
//    if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
//        [[TTRoute sharedRoute] openURLByPushViewController:openURL userInfo:userInfo];
//    }
}

#pragma mark -
- (NSInteger)numberOfItems {
    FHNeighborhoodDetailCommentAndQuestionSM *model = (FHNeighborhoodDetailCommentAndQuestionSM *)self.sectionModel;
    return model.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index
{
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    FHNeighborhoodDetailCommentAndQuestionSM *model = (FHNeighborhoodDetailCommentAndQuestionSM *)self.sectionModel;
    id cellModel = model.items[index];
    CGSize size = CGSizeZero;
    if([cellModel isKindOfClass:[FHNeighborhoodDetailCommentHeaderModel class]]){
        size = [FHNeighborhoodDetailCommentHeaderCell cellSizeWithData:cellModel width:width];
    }else if([cellModel isKindOfClass:[FHNeighborhoodDetailQuestionHeaderModel class]]){
        size = [FHNeighborhoodDetailQuestionHeaderCell cellSizeWithData:cellModel width:width];
    }else if([cellModel isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *feedCellModel = (FHFeedUGCCellModel *)cellModel;
        if (feedCellModel.cellType == FHUGCFeedListCellTypeUGC) {
            size = [FHNeighborhoodDetailPostCell cellSizeWithData:cellModel width:width];
        } else if (feedCellModel.cellType == FHUGCFeedListCellTypeAnswer) {
            size = [FHNeighborhoodDetailQuestionCell cellSizeWithData:cellModel width:width];
        }
    }else if([cellModel isKindOfClass:[FHNeighborhoodDetailSpaceModel class]]){
        size = [FHNeighborhoodDetailSpaceCell cellSizeWithData:cellModel width:width];
    }else if([cellModel isKindOfClass:[FHNeighborhoodDetailCommentTagsModel class]]){
        size = [FHNeighborhoodDetailCommentTagsCell cellSizeWithData:cellModel width:width];
    }
    
    return size;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index
{
    FHNeighborhoodDetailCommentAndQuestionSM *model = (FHNeighborhoodDetailCommentAndQuestionSM *)self.sectionModel;
    id cellModel = model.items[index];

    if([cellModel isKindOfClass:[FHNeighborhoodDetailCommentHeaderModel class]]){
        FHNeighborhoodDetailCommentHeaderCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailCommentHeaderCell class] withReuseIdentifier:@"FHNeighborhoodDetailCommentHeaderCell" forSectionController:self atIndex:index];
        [cell refreshWithData:cellModel];
        return cell;
    }else if([cellModel isKindOfClass:[FHNeighborhoodDetailQuestionHeaderModel class]]){
        FHNeighborhoodDetailQuestionHeaderCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailQuestionHeaderCell class] withReuseIdentifier:@"FHNeighborhoodDetailQuestionHeaderCell" forSectionController:self atIndex:index];
        [cell refreshWithData:cellModel];
        return cell;
    }else if([cellModel isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *feedCellModel = (FHFeedUGCCellModel *)cellModel;
        if (feedCellModel.cellType == FHUGCFeedListCellTypeUGC) {
            __weak typeof(self) weakSelf = self;
            FHNeighborhoodDetailPostCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailPostCell class] withReuseIdentifier:@"FHNeighborhoodDetailPostCell" forSectionController:self atIndex:index];
            [cell setClickLinkBlock:^(FHFeedUGCCellModel * _Nonnull model, NSURL * _Nonnull url) {
                [weakSelf gotoLinkUrl:model url:url];
            }];
            [cell refreshWithData:cellModel];
            return cell;
        } else if (feedCellModel.cellType == FHUGCFeedListCellTypeAnswer) {
            FHNeighborhoodDetailQuestionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailQuestionCell class] withReuseIdentifier:@"FHNeighborhoodDetailQuestionCell" forSectionController:self atIndex:index];
            [cell refreshWithData:cellModel];
            return cell;
        }
    }else if([cellModel isKindOfClass:[FHNeighborhoodDetailSpaceModel class]]){
        FHNeighborhoodDetailSpaceCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailSpaceCell class] withReuseIdentifier:@"FHNeighborhoodDetailSpaceCell" forSectionController:self atIndex:index];
        [cell refreshWithData:cellModel];
        return cell;
    }else if([cellModel isKindOfClass:[FHNeighborhoodDetailCommentTagsModel class]]){
        FHNeighborhoodDetailCommentTagsCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailCommentTagsCell class] withReuseIdentifier:@"FHNeighborhoodDetailCommentTagsCell" forSectionController:self atIndex:index];
        [cell refreshWithData:cellModel];
        return cell;
    }
    
    return nil;
}



- (void)didSelectItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailCommentAndQuestionSM *model = (FHNeighborhoodDetailCommentAndQuestionSM *)self.sectionModel;
    id cellModel = model.items[index];
    if([cellModel isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *feedCellModel = (FHFeedUGCCellModel *)cellModel;
        [self.detailJumpManager jumpToDetail:feedCellModel showComment:NO enterType:@"feed_content_blank"];
    }
}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds
{
    return @[];
}

- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index
{
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontMedium:20];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    __weak typeof(self) weakSelf = self;
    titleView.arrowsImg.hidden = NO;
    titleView.userInteractionEnabled = YES;
    [titleView setMoreActionBlock:^{
        [weakSelf moreButtonClick];
    }];

    FHNeighborhoodDetailCommentAndQuestionSM *sectionModel = (FHNeighborhoodDetailCommentAndQuestionSM *)self.sectionModel;
//    titleView.titleLabel.text = [NSString stringWithFormat:@"%@ (%@)",sectionModel.title,sectionModel.count];
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index
{
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 15 * 2, 61);
    }
    return CGSizeZero;
}

#pragma mark - IGListDisplayDelegate

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplaySectionController:(IGListSectionController *)sectionController {
    
}

/**
 Tells the delegate that the specified section controller is no longer being displayed.

 @param listAdapter       The list adapter for the section controller.
 @param sectionController The section controller that is no longer displayed.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController *)sectionController {
    
}

/**
 Tells the delegate that a cell in the specified list is about to be displayed.

 @param listAdapter The list adapter in which the cell will display.
 @param sectionController The section controller that is displaying the cell.
 @param cell The cell about to be displayed.
 @param index The index of the cell in the section.
 */

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplaySectionController:(IGListSectionController *)sectionController cell:(UICollectionViewCell *)cell atIndex:(NSInteger)index {
    FHNeighborhoodDetailCommentAndQuestionSM *model = (FHNeighborhoodDetailCommentAndQuestionSM *)self.sectionModel;
//    FHFeedUGCCellModel *cellModel = model.items[index];
//    NSString *tempKey = [NSString stringWithFormat:@"%@_%ld", NSStringFromClass([self class]), index];
//    if ([self.elementShowCaches valueForKey:tempKey]) {
//        return;
//    }
//    [self.elementShowCaches setValue:@(YES) forKey:tempKey];
//    NSDictionary *houseInfo = model.extraDic;
//    NSDictionary *extraDic = @{}.mutableCopy;
//    [extraDic setValue:self.detailTracerDict[@"page_type"] forKey:@"page_type"];
//    [extraDic setValue:[NSString stringWithFormat:@"%ld",(long)index] forKey:@"rank"];
//    [extraDic setValue:houseInfo[@"houseId"] forKey:@"from_gid"];
//    [extraDic setValue:cellModel.groupId forKey:@"group_id"];
//    [extraDic setValue:@"realtor_evaluate" forKey:@"element_type"];
//    [self.tracerHelper trackFeedClientShow:cellModel withExtraDic:extraDic];
//
//    if (self.canElementShow) {
//        self.canElementShow = NO;
//        NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
//        tracerDic[@"element_type"] = @"realtor_evaluate";
//        [tracerDic removeObjectForKey:@"element_from"];
//        tracerDic[@"page_type"] = @"new_detail";
//        [FHUserTracker writeEvent:@"element_show" params:tracerDic];
//    }
}

/**
 Tells the delegate that a cell in the specified list is no longer being displayed.

 @param listAdapter The list adapter in which the cell was displayed.
 @param sectionController The section controller that is no longer displaying the cell.
 @param cell The cell that is no longer displayed.
 @param index The index of the cell in the section.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController *)sectionController
               cell:(UICollectionViewCell *)cell
            atIndex:(NSInteger)index {
    
}

@end
