//
//  FHNeighborhoodDetailStrategySC.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/13.
//

//#import "FHNeighborhoodDetailStrategySC.h"
//
//@implementation FHNeighborhoodDetailStrategySC
//
//@end

#import "FHNeighborhoodDetailStrategySC.h"
#import "FHNeighborhoodDetailStrategySM.h"
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
#import "FHNeighborhoodDetailStrategyArticleCell.h"
#import "FHNeighborhoodDetailSpaceCell.h"

@interface FHNeighborhoodDetailStrategySC () <IGListSupplementaryViewSource, IGListDisplayDelegate>

@property (nonatomic, strong) FHUGCFeedDetailJumpManager *detailJumpManager;
@property (nonatomic, strong) FHRealtorEvaluatingTracerHelper *tracerHelper;
@property (nonatomic, assign) BOOL canElementShow;

@end

@implementation FHNeighborhoodDetailStrategySC

- (instancetype)init
{
    if (self = [super init]) {
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

#pragma mark -
- (NSInteger)numberOfItems {
    FHNeighborhoodDetailStrategySM *model = (FHNeighborhoodDetailStrategySM *)self.sectionModel;
    return model.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index
{
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    FHNeighborhoodDetailStrategySM *model = (FHNeighborhoodDetailStrategySM *)self.sectionModel;
    id cellModel = model.items[index];
    CGSize size = CGSizeZero;
    if([cellModel isKindOfClass:[FHDetailNeighborhoodDataStrategyArticleListModel class]]){
        size = [FHNeighborhoodDetailStrategyArticleCell cellSizeWithData:cellModel width:width];
    }else if([cellModel isKindOfClass:[FHNeighborhoodDetailSpaceModel class]]){
        size = [FHNeighborhoodDetailSpaceCell cellSizeWithData:cellModel width:width];
    }
    
    return size;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index
{
    FHNeighborhoodDetailStrategySM *model = (FHNeighborhoodDetailStrategySM *)self.sectionModel;
    id cellModel = model.items[index];

    if([cellModel isKindOfClass:[FHDetailNeighborhoodDataStrategyArticleListModel class]]){
        FHNeighborhoodDetailStrategyArticleCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailStrategyArticleCell class] withReuseIdentifier:@"FHNeighborhoodDetailStrategyArticleCell" forSectionController:self atIndex:index];
        [cell refreshWithData:cellModel];
        return cell;
    }else if([cellModel isKindOfClass:[FHNeighborhoodDetailSpaceModel class]]){
        FHNeighborhoodDetailSpaceCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailSpaceCell class] withReuseIdentifier:@"FHNeighborhoodDetailSpaceCell" forSectionController:self atIndex:index];
        [cell refreshWithData:cellModel];
        return cell;
    }
    
    return nil;
}



- (void)didSelectItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailStrategySM *model = (FHNeighborhoodDetailStrategySM *)self.sectionModel;
    id cellModel = model.items[index];
    if([cellModel isKindOfClass:[FHDetailNeighborhoodDataStrategyArticleListModel class]]){
        FHDetailNeighborhoodDataStrategyArticleListModel *articleModel = (FHDetailNeighborhoodDataStrategyArticleListModel *)cellModel;
        if(articleModel.schema.length > 0){
            NSMutableDictionary *dict = @{}.mutableCopy;
            // 埋点
//            NSMutableDictionary *traceParam = @{}.mutableCopy;
//            traceParam[@"origin_from"] = self.tracerDic[@"origin_from"];
//            traceParam[@"enter_from"] = self.tracerDic[@"page_type"];
//            traceParam[@"element_type"] = self.tracerDic[@"element_type"];
//            traceParam[@"from_gid"] = self.tracerDic[@"from_gid"];
//            traceParam[@"group_id"] = cellModel.groupId;
//            if(cellModel.tracer[@"log_pb"][@"group_source"]){
//                traceParam[@"group_source"] = cellModel.tracer[@"log_pb"][@"group_source"];
//            }
//            if(cellModel.tracer[@"log_pb"][@"impr_id"]){
//                traceParam[@"impr_id"] = cellModel.tracer[@"log_pb"][@"impr_id"];
//            }
//            dict[@"tracer"] = traceParam;

            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            
            NSURL *url = [NSURL URLWithString:articleModel.schema];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds
{
    return @[ UICollectionElementKindSectionHeader ];
}

- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index
{
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontMedium:18];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    FHNeighborhoodDetailStrategySM *sectionModel = (FHNeighborhoodDetailStrategySM *)self.sectionModel;
    titleView.titleLabel.text = sectionModel.title;
    [titleView.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(titleView).offset(20);
    }];
    
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index
{
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 15 * 2, 45);
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
    FHNeighborhoodDetailStrategySM *model = (FHNeighborhoodDetailStrategySM *)self.sectionModel;
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
