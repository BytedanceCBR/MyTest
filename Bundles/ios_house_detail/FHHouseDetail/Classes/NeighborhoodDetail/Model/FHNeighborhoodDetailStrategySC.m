//
//  FHNeighborhoodDetailStrategySC.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/13.
//

#import "FHNeighborhoodDetailStrategySC.h"
#import "FHNeighborhoodDetailStrategySM.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHNeighborhoodDetailQuestionHeaderCell.h"
#import "FHRealtorEvaluatingPhoneCallModel.h"
#import "FHNeighborhoodDetailQuestionCell.h"
#import "FHNeighborhoodDetailStrategyArticleCell.h"
#import "FHNeighborhoodDetailSpaceCell.h"

@interface FHNeighborhoodDetailStrategySC () < IGListDisplayDelegate>

@property (nonatomic, assign) BOOL canElementShow;

@end

@implementation FHNeighborhoodDetailStrategySC

- (instancetype)init
{
    if (self = [super init]) {
//        self.supplementaryViewSource = self;
        self.displayDelegate = self;
        _canElementShow = YES;
    }
    return self;
}

#pragma mark -
- (NSInteger)numberOfItems {
    FHNeighborhoodDetailStrategySM *model = (FHNeighborhoodDetailStrategySM *)self.sectionModel;
    return model.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index
{
    CGFloat width = self.collectionContext.containerSize.width - 9 * 2;
    FHNeighborhoodDetailStrategySM *model = (FHNeighborhoodDetailStrategySM *)self.sectionModel;
    id cellModel = model.items[index];
    CGSize size = CGSizeZero;
    if([cellModel isKindOfClass:[NSDictionary class]]){
        if (model.cellHeight) {
            size = CGSizeMake(width, model.cellHeight);
        }else {
            size = [FHNeighborhoodDetailStrategyArticleCell cellSizeWithData:cellModel width:width];
        }
    }else if([cellModel isKindOfClass:[FHNeighborhoodDetailSpaceModel class]]){
        size = [FHNeighborhoodDetailSpaceCell cellSizeWithData:cellModel width:width];
    }
    
    return size;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index
{
    FHNeighborhoodDetailStrategySM *model = (FHNeighborhoodDetailStrategySM *)self.sectionModel;
    id cellModel = model.items[index];

    if([cellModel isKindOfClass:[NSDictionary class]]){
        FHNeighborhoodDetailStrategyArticleCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailStrategyArticleCell class] withReuseIdentifier:@"FHNeighborhoodDetailStrategyArticleCell" forSectionController:self atIndex:index];
        cell.lynxEndLoadBlock = ^(CGFloat cellHeight) {
            model.cellHeight = cellHeight;
        };
        cell.tracerDic = model.detailTracerDic;
        [cell refreshWithData:cellModel];
        return cell;
    }else if([cellModel isKindOfClass:[FHNeighborhoodDetailSpaceModel class]]){
        FHNeighborhoodDetailSpaceCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailSpaceCell class] withReuseIdentifier:@"FHNeighborhoodDetailSpaceCell" forSectionController:self atIndex:index];
        [cell refreshWithData:cellModel];
        return cell;
    }
    return [super defaultCellAtIndex:index];
}



- (void)didSelectItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailStrategySM *model = (FHNeighborhoodDetailStrategySM *)self.sectionModel;
    id cellModel = model.items[index];
    if([cellModel isKindOfClass:[FHDetailNeighborhoodDataStrategyArticleListModel class]]){
        FHDetailNeighborhoodDataStrategyArticleListModel *articleModel = (FHDetailNeighborhoodDataStrategyArticleListModel *)cellModel;
        if(articleModel.schema.length > 0){
            NSMutableDictionary *dict = @{}.mutableCopy;
            // 埋点
            NSMutableDictionary *traceParam = @{}.mutableCopy;
            
            traceParam[@"origin_from"] = model.detailTracerDic[@"origin_from"] ?: @"be_null";
            traceParam[@"enter_from"] = model.detailTracerDic[@"page_type"] ?: @"be_null";
            traceParam[@"element_type"] = @"neighborhood_test_evaluate";
            traceParam[@"rank"] = [NSString stringWithFormat:@"%ld",(long)index];
            traceParam[@"log_pb"] = articleModel.logPb;
            if(model.extraDic[@"houseId"]){
                traceParam[@"from_gid"] = model.extraDic[@"houseId"];
            }
            if(articleModel.logPb[@"group_id"]){
                traceParam[@"group_id"] = articleModel.logPb[@"group_id"];
            }
            if(articleModel.logPb[@"impr_id"]){
                traceParam[@"impr_id"] = articleModel.logPb[@"impr_id"];
            }
            if(articleModel.logPb[@"group_source"]){
                traceParam[@"group_source"] = articleModel.logPb[@"group_source"];
            }
            
            dict[@"tracer"] = traceParam;

            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            
            NSURL *url = [NSURL URLWithString:articleModel.schema];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
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
    
    id cellModel = model.items[index];
    if([cellModel isKindOfClass:[FHDetailNeighborhoodDataStrategyArticleListModel class]]){
        FHDetailNeighborhoodDataStrategyArticleListModel *articleModel = (FHDetailNeighborhoodDataStrategyArticleListModel *)cellModel;
        NSString *tempKey = [NSString stringWithFormat:@"%@_%ld", NSStringFromClass([self class]), index];
        if ([self.elementShowCaches valueForKey:tempKey]) {
            return;
        }
        [self.elementShowCaches setValue:@(YES) forKey:tempKey];

        NSMutableDictionary *tracerDic = @{}.mutableCopy;
        tracerDic[@"origin_from"] = model.detailTracerDic[@"origin_from"] ?: @"be_null";
        tracerDic[@"enter_from"] = model.detailTracerDic[@"enter_from"] ?: @"be_null";
        tracerDic[@"page_type"] = model.detailTracerDic[@"page_type"] ?: @"be_null";
        tracerDic[@"element_type"] = @"neighborhood_test_evaluate";
        tracerDic[@"rank"] = [NSString stringWithFormat:@"%ld",(long)index];
        tracerDic[@"log_pb"] = articleModel.logPb;
        if(articleModel.logPb[@"group_id"]){
            tracerDic[@"group_id"] = articleModel.logPb[@"group_id"];
        }
        if(articleModel.logPb[@"impr_id"]){
            tracerDic[@"impr_id"] = articleModel.logPb[@"impr_id"];
        }
        if(articleModel.logPb[@"group_source"]){
            tracerDic[@"group_source"] = articleModel.logPb[@"group_source"];
        }
        [FHUserTracker writeEvent:@"feed_client_show" params:tracerDic];
    }

    if (self.canElementShow) {
        self.canElementShow = NO;
        NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
        tracerDic[@"element_type"] = @"neighborhood_test_evaluate";
        [tracerDic removeObjectForKey:@"element_from"];
        [FHUserTracker writeEvent:@"element_show" params:tracerDic];
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
