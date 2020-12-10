//
//  FHNeighborhoodDetailCommentAndQuestionSC.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/12.
//

#import "FHNeighborhoodDetailCommentAndQuestionSC.h"
#import "FHNeighborhoodDetailCommentAndQuestionSM.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHNeighborhoodDetailCommentHeaderCell.h"
#import "FHNeighborhoodDetailQuestionHeaderCell.h"
#import "FHUGCFeedDetailJumpManager.h"
#import "FHNeighborhoodDetailQuestionCell.h"
#import "FHNeighborhoodDetailPostCell.h"
#import "FHNeighborhoodDetailSpaceCell.h"
#import "FHNeighborhoodDetailCommentTagsCell.h"

@interface FHNeighborhoodDetailCommentAndQuestionSC () <IGListSupplementaryViewSource, IGListDisplayDelegate>

@property (nonatomic, strong) FHUGCFeedDetailJumpManager *detailJumpManager;
@property (nonatomic, assign) BOOL canCommentElementShow;
@property (nonatomic, assign) BOOL canQuestionElementShow;

@end

@implementation FHNeighborhoodDetailCommentAndQuestionSC

- (instancetype)init
{
    if (self = [super init]) {
        self.supplementaryViewSource = self;
        self.displayDelegate = self;
        self.detailJumpManager = [[FHUGCFeedDetailJumpManager alloc] init];
        self.detailJumpManager.refer = 1;
        _canCommentElementShow = YES;
        _canQuestionElementShow = YES;
    }
    return self;
}

#pragma mark - Action

- (void)gotoLinkUrl:(FHFeedUGCCellModel *)cellModel url:(NSURL *)url {
    // PM要求点富文本链接也进入详情页
    [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];

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
        } else if (feedCellModel.cellType == FHUGCFeedListCellTypeAnswer || feedCellModel.cellType == FHUGCFeedListCellTypeQuestion) {
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
        } else if (feedCellModel.cellType == FHUGCFeedListCellTypeAnswer || feedCellModel.cellType == FHUGCFeedListCellTypeQuestion) {
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
    
    return [super defaultCellAtIndex:index];
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
    id cellModel = model.items[index];
    if([cellModel isKindOfClass:[FHNeighborhoodDetailCommentHeaderModel class]]){
        if (self.canCommentElementShow) {
            self.canCommentElementShow = NO;
            NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
            tracerDic[@"element_type"] = @"neighborhood_comment";
            [tracerDic removeObjectForKey:@"element_from"];
            [FHUserTracker writeEvent:@"element_show" params:tracerDic];
        }
    }else if([cellModel isKindOfClass:[FHNeighborhoodDetailQuestionHeaderModel class]]){
        if (self.canQuestionElementShow) {
            self.canQuestionElementShow = NO;
            NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
            tracerDic[@"element_type"] = @"neighborhood_question";
            [tracerDic removeObjectForKey:@"element_from"];
            [FHUserTracker writeEvent:@"element_show" params:tracerDic];
        }
    }else if([cellModel isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *feedCellModel = (FHFeedUGCCellModel *)cellModel;
        
        NSString *tempKey = [NSString stringWithFormat:@"%@_%ld", NSStringFromClass([self class]), index];
        if ([self.elementShowCaches valueForKey:tempKey]) {
            return;
        }
        [self.elementShowCaches setValue:@(YES) forKey:tempKey];

        NSMutableDictionary *tracerDic = @{}.mutableCopy;
        if(feedCellModel.tracerDic){
            [tracerDic addEntriesFromDictionary:feedCellModel.tracerDic];
        }
        [FHUserTracker writeEvent:@"feed_client_show" params:tracerDic];
    }
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
