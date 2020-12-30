//
//  FHHouseSearchRentHouseViewModel.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseSearchRentHouseViewModel.h"
#import "FHSearchBaseItemModel.h"
#import "FHSearchHouseModel.h"
#import "NSObject+FHTracker.h"
#import "FHUserTracker.h"
#import "NSDictionary+BTDAdditions.h"
#import "TTRoute.h"
#import "FHHouseNeighborAgencyViewModel.h"
#import "FHHouseReserveAdviserViewModel.h"


@implementation FHHouseSearchRentHouseViewModel

- (void)showCardAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger rankOffset = [self.context btd_integerValueForKey:@"rank_offset"];
    NSInteger rank = indexPath.row + rankOffset;
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"rank"] = @(rank);
    tracerDict[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : UT_BE_NULL;
    tracerDict[UT_ORIGIN_SEARCH_ID] = self.fh_trackModel.originSearchId ? : UT_BE_NULL;
    tracerDict[UT_PAGE_TYPE] = self.fh_trackModel.pageType ? : UT_BE_NULL;
    tracerDict[UT_SEARCH_ID] = self.fh_trackModel.searchId ? : UT_BE_NULL;
    tracerDict[UT_ENTER_FROM] = self.fh_trackModel.enterFrom ? : UT_BE_NULL;
    tracerDict[UT_ELEMENT_FROM] = self.fh_trackModel.elementFrom ? : UT_BE_NULL;
    tracerDict[UT_ELEMENT_TYPE] = self.fh_trackModel.elementType ? : UT_BE_NULL;
    
    FHSearchHouseItemModel *houseModel = (FHSearchHouseItemModel *)self.model;
    tracerDict[@"group_id"] = houseModel.id ? : @"be_null";
    tracerDict[@"impr_id"] = houseModel.imprId ? : @"be_null";
    tracerDict[UT_LOG_PB] = houseModel.logPbWithTags ? : @"be_null";
    tracerDict[@"house_type"] = @"rent";
    tracerDict[@"biz_trace"] = [houseModel bizTrace] ? : @"be_null";
    tracerDict[@"card_type"] = @"left_pic";
    
    if (self.fh_trackModel.elementFrom && ![self.fh_trackModel.elementFrom isEqualToString:UT_BE_NULL]) {
        tracerDict[UT_ELEMENT_FROM] = self.fh_trackModel.elementFrom;
    }
    
    [FHUserTracker writeEvent:@"house_show" params:tracerDict];
}

- (void)clickCardAtIndexPath:(NSIndexPath *)indexPath {
    NSString *elementFrom = self.fh_trackModel.elementType ? : UT_BE_NULL;
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    FHSearchHouseItemModel *theModel = (FHSearchHouseItemModel *)self.model;
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://rent_detail?house_id=%@",theModel.id];;
    if (theModel.isRecommendCell) {
        traceParam[UT_SEARCH_ID] = self.fh_trackModel.searchId ? : UT_BE_NULL;
        elementFrom = @"search_related";
    }

    traceParam[@"card_type"] = @"left_pic";
    traceParam[UT_ENTER_FROM] = self.fh_trackModel.pageType ? : UT_BE_NULL;
    traceParam[UT_ELEMENT_FROM] = elementFrom;

    traceParam[UT_LOG_PB] = theModel.logPbWithTags ? : UT_BE_NULL;
    traceParam[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : UT_BE_NULL;
    traceParam[UT_ORIGIN_SEARCH_ID] = self.fh_trackModel.originSearchId ? : UT_BE_NULL;
    
    NSInteger rankOffset = [self.context btd_integerValueForKey:@"rank_offset"];
    NSInteger rank = indexPath.row + rankOffset;
    traceParam[@"rank"] = @(rank);
    
    NSMutableDictionary *dict = @{
        @"house_type":@(theModel.houseType.integerValue) ,
        @"tracer": traceParam
    }.mutableCopy;
    
    NSURL *url = [NSURL URLWithString:urlStr];
    dict[@"biz_trace"] = theModel.bizTrace;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

@end
