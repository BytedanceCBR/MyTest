//
//  FHHouseReserveAdviserViewModel.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseReserveAdviserViewModel.h"
#import "FHSearchHouseModel.h"
#import "NSObject+FHTracker.h"
#import "FHUserTracker.h"
#import "NSDictionary+BTDAdditions.h"

@interface FHHouseReserveAdviserViewModel()
@property (nonatomic, assign) BOOL showed;
@end

@implementation FHHouseReserveAdviserViewModel

- (void)setContext:(NSDictionary *)context {
    [super setContext:context];
    
    FHHouseReserveAdviserModel *model = (FHHouseReserveAdviserModel *)self.model;
    NSInteger houseType = [self.context btd_integerValueForKey:@"house_type"];
    
    NSMutableDictionary *traceParam = [NSMutableDictionary new];
    traceParam[@"card_type"] = @"left_pic";
    traceParam[UT_ENTER_FROM] = self.fh_trackModel.enterFrom ? : UT_BE_NULL;
    traceParam[UT_ELEMENT_FROM] = self.fh_trackModel.elementFrom ? : UT_BE_NULL;
    traceParam[UT_PAGE_TYPE] = self.fh_trackModel.pageType ? : UT_BE_NULL;
    traceParam[UT_SEARCH_ID] = self.fh_trackModel.searchId ? : UT_BE_NULL;
    traceParam[UT_LOG_PB] = model.logPb ? : UT_BE_NULL;;
    traceParam[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : UT_BE_NULL;
    traceParam[UT_ORIGIN_SEARCH_ID] = self.fh_trackModel.originSearchId ? : UT_BE_NULL;
    traceParam[@"rank"] = @(0);
    if(houseType == FHHouseTypeNeighborhood){
        traceParam[UT_ELEMENT_TYPE] = @"neighborhood_expert_card";
    }else{
        traceParam[UT_ELEMENT_TYPE] = @"area_expert_card";
    }
    model.tracerDict = traceParam;
    
    if ([self.delegate respondsToSelector:@selector(belongSubscribeCache)]) {
        model.subscribeCache = [(id<FHHouseReserveAdviserViewModelDelegate>)self.delegate belongSubscribeCache];
    }
   
    if ([self.delegate respondsToSelector:@selector(belongsVC)]) {
        model.belongsVC = [(id<FHHouseReserveAdviserViewModelDelegate>)self.delegate belongsVC];
    }
    
    if ([self.delegate respondsToSelector:@selector(belongTableView)]) {
        model.tableView = [(id<FHHouseReserveAdviserViewModelDelegate>)self.delegate belongTableView];
    }
}

- (void)showCardAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showed) return;
    self.showed = YES;
    
    BOOL isFirstHavetip = [self.context btd_boolValueForKey:@"is_first_havetip"];
    NSInteger houseType = [self.context btd_integerValueForKey:@"house_type"];
    NSInteger rank = indexPath.row;
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"rank"] = @(!isFirstHavetip ? rank - 1 :rank);
    tracerDict[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : UT_BE_NULL;
    tracerDict[UT_ORIGIN_SEARCH_ID] = self.fh_trackModel.originSearchId ? : UT_BE_NULL;
    
    tracerDict[UT_PAGE_TYPE] = self.fh_trackModel.pageType ? : UT_BE_NULL;
    tracerDict[UT_ENTER_FROM] = self.fh_trackModel.enterFrom ? : UT_BE_NULL;
    tracerDict[UT_ELEMENT_FROM] = self.fh_trackModel.elementFrom ? : UT_BE_NULL;
    if (houseType == FHHouseTypeNeighborhood) {
        tracerDict[UT_ELEMENT_TYPE] = @"neighborhood_expert_card";
    } else {
        tracerDict[UT_ELEMENT_TYPE] = @"area_expert_card";
    }
    
    FHHouseReserveAdviserModel *cm = (FHHouseReserveAdviserModel *)self.model;
    tracerDict[UT_LOG_PB] = cm.logPb ? : UT_BE_NULL;

    [FHUserTracker writeEvent:@"inform_show" params:tracerDict];
}

@end
