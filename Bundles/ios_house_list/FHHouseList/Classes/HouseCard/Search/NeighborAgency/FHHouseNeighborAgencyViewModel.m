//
//  FHHouseNeighborAgencyViewModel.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseNeighborAgencyViewModel.h"
#import "FHSearchHouseModel.h"
#import "NSObject+FHTracker.h"
#import "FHUserTracker.h"
#import "NSDictionary+BTDAdditions.h"

@interface FHHouseNeighborAgencyViewModel()
@property (nonatomic, assign) BOOL showed;
@end

@implementation FHHouseNeighborAgencyViewModel


- (void)setContext:(NSDictionary *)context {
    [super setContext:context];
    
    FHHouseNeighborAgencyModel *model = (FHHouseNeighborAgencyModel *)self.model;
    NSInteger houseType = [self.context btd_integerValueForKey:@"house_type"];
    

    NSMutableDictionary *traceParam = [NSMutableDictionary new];
    traceParam[@"card_type"] = @"left_pic";
    traceParam[UT_ENTER_FROM] = self.fh_trackModel.enterFrom ? : UT_BE_NULL;
    traceParam[UT_ELEMENT_FROM] = self.fh_trackModel.elementFrom ? : UT_BE_NULL;
    traceParam[UT_PAGE_TYPE] = self.fh_trackModel.pageType ? : UT_BE_NULL;
    traceParam[UT_SEARCH_ID] = self.fh_trackModel.searchId ? : UT_BE_NULL;
    traceParam[UT_LOG_PB] = model.logPb;
    traceParam[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : UT_BE_NULL;
    traceParam[UT_ORIGIN_SEARCH_ID] = self.fh_trackModel.originSearchId ? : UT_BE_NULL;
    traceParam[@"rank"] = @(0);
    if (houseType == FHHouseTypeNeighborhood) {
        traceParam[@"realtor_position"] = @"neighborhood_expert_card";
    } else {
        traceParam[@"realtor_position"] = @"area_expert_card";
    }
    model.tracerDict = traceParam;
   
    if ([self.delegate respondsToSelector:@selector(belongsVC)]) {
        model.belongsVC = [(id<FHHouseNeighborAgencyViewModelDelegate>)self.delegate belongsVC];
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
    
    FHHouseNeighborAgencyModel *agencyCM = (FHHouseNeighborAgencyModel *)self.model;
    [self addLeadShowLog:agencyCM];
    tracerDict[UT_PAGE_TYPE] = self.fh_trackModel.pageType ? : UT_BE_NULL;
    tracerDict[@"card_type"] = @"left_pic";
    if(houseType == FHHouseTypeNeighborhood){
        tracerDict[@"element_type"] = @"neighborhood_expert_card";
        tracerDict[@"house_type"] = @"neighborhood";
    }else{
        tracerDict[@"element_type"] = @"area_expert_card";
        tracerDict[@"house_type"] = @"area";
    }

    tracerDict[UT_LOG_PB] = agencyCM.logPb ? : UT_BE_NULL;
    tracerDict[@"realtor_logpb"] = agencyCM.contactModel.realtorLogpb ? : UT_BE_NULL;
    
    if (self.fh_trackModel.elementFrom && ![self.fh_trackModel.elementFrom isEqualToString:UT_BE_NULL]) {
        tracerDict[UT_ELEMENT_FROM] = self.fh_trackModel.elementFrom;
    }
    
    [FHUserTracker writeEvent:@"house_show" params:tracerDict];
}

- (void)addLeadShowLog:(id)cm
{
    NSInteger houseType = [self.context btd_integerValueForKey:@"house_type"];
    BOOL isHasFilterCondition = [self.context btd_boolValueForKey:@"has_filter_condition"];
    
    FHHouseNeighborAgencyModel *cellModel = (FHHouseNeighborAgencyModel *)cm;
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[UT_PAGE_TYPE] = self.fh_trackModel.pageType ? : UT_BE_NULL;
    tracerDict[@"card_type"] = @"left_pic";
    tracerDict[UT_ENTER_FROM] = self.fh_trackModel.enterFrom ? : UT_BE_NULL;
    tracerDict[UT_ELEMENT_FROM] = self.fh_trackModel.elementFrom ? : UT_BE_NULL;
    tracerDict[@"rank"] = @(0);
    tracerDict[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : UT_BE_NULL;
    tracerDict[UT_ORIGIN_SEARCH_ID] = self.fh_trackModel.originSearchId ? : UT_BE_NULL;
    tracerDict[UT_LOG_PB] = cellModel.logPb ? : UT_BE_NULL;
    
    tracerDict[@"is_im"] = cellModel.contactModel.imOpenUrl.length > 0 ? @(1) : @(0);
    tracerDict[@"is_call"] = cellModel.contactModel.enablePhone ? @(1) : @(0);
    tracerDict[@"is_report"] = @(0);
    tracerDict[@"is_online"] = cellModel.contactModel.unregistered ? @(0) : @(1);
    tracerDict[@"realtor_id"] = cellModel.id;
    if(houseType == FHHouseTypeNeighborhood){
        tracerDict[@"element_type"] = @"neighborhood_expert_card";
        tracerDict[@"realtor_position"] = @"neighborhood_expert_card";
        tracerDict[@"house_type"] = @"neighborhood";
    }else{
        if (isHasFilterCondition) {
            tracerDict[@"element_type"] = @"area_expert_card";
            tracerDict[@"realtor_position"] = @"area_expert_card";
            tracerDict[@"house_type"] = @"area";
        }else{
            tracerDict[@"element_type"] = @"neighborhood_expert_card";
            tracerDict[@"realtor_position"] = @"neighborhood_expert_card";
            tracerDict[@"house_type"] = @"neighborhood";
        }
    }
    
    [FHUserTracker writeEvent:@"realtor_show" params:tracerDict];
}

@end
