//
//  FHHouseNeighborhoodCardViewModel.m
//  ABRInterface
//
//  Created by bytedance on 2020/11/9.
//

#import "FHHouseNeighborhoodCardViewModel.h"
#import "FHSearchHouseModel.h"
#import "NSObject+FHTracker.h"
#import "FHUserTracker.h"
#import "TTRoute.h"
#import "FHHouseTitleAndTagViewModel.h"
#import "FHCommonDefines.h"

@interface FHHouseNeighborhoodCardViewModel()
@property (nonatomic, strong) FHSearchHouseItemModel *model;
@property (nonatomic, assign) BOOL showed;
@end

@implementation FHHouseNeighborhoodCardViewModel

- (instancetype)initWithModel:(FHSearchHouseItemModel *)model {
    self = [super init];
    if (self) {
        _model = model;
        _titleAndTag = [[FHHouseTitleAndTagViewModel alloc] initWithModel:model];
        _titleAndTag.maxWidth = SCREEN_WIDTH - 30 * 2 - 84 - 8;
    }
    return self;
}

- (BOOL)isValid {
    return YES;
}

- (FHImageModel *)leftImageModel {
    return [self.model.images firstObject];
}

- (NSString *)subtitle; {
    return self.model.displaySubtitle;
}

- (NSString *)stateInfo; {
    return self.model.displayStatsInfo;
}

- (NSString *)price {
    return self.model.displayPrice;
}

- (void)showCardAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.showed) {
        self.showed = YES;
        
        NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
        tracerDict[@"rank"] = @(indexPath.row);
        tracerDict[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : @"be_null";
        tracerDict[UT_ORIGIN_SEARCH_ID] = self.fh_trackModel.originSearchId ? : @"be_null";
        tracerDict[UT_PAGE_TYPE] = self.fh_trackModel.pageType ? : @"be_null";
        tracerDict[UT_ELEMENT_TYPE] = @"be_null";
        tracerDict[UT_SEARCH_ID] = self.fh_trackModel.searchId ? : @"be_null";
        tracerDict[@"group_id"] = self.model.id ? : @"be_null";
        tracerDict[@"impr_id"] = self.model.imprId ? : @"be_null";
        tracerDict[UT_LOG_PB] = self.model.logPbWithTags ? : @"be_null";
        tracerDict[@"house_type"] = @"neighborhood";
        tracerDict[@"biz_trace"] = [self.model bizTrace] ? : @"be_null";
        tracerDict[@"card_type"] = @"left_pic";
        if (self.fh_trackModel.elementFrom && ![self.fh_trackModel.elementFrom isEqualToString:@"be_null"]) {
            tracerDict[UT_ELEMENT_FROM] = self.fh_trackModel.elementFrom;
        }
        
        [FHUserTracker writeEvent:@"house_show" params:tracerDict];
    }
}

- (void)clickCardAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[UT_ENTER_FROM] = self.fh_trackModel.pageType ? : @"be_null";
    traceParam[UT_ELEMENT_FROM] = @"be_null";
    traceParam[UT_LOG_PB] = self.model.logPbWithTags ? : @"be_null";;
    traceParam[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : @"be_null";
    traceParam[UT_ORIGIN_SEARCH_ID] = self.fh_trackModel.originSearchId ? : @"be_null";
    traceParam[@"rank"] = @(indexPath.row);
    traceParam[@"card_type"] = @"left_pic";
    
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@",self.model.id];;
    if (urlStr.length > 0) {
        NSURL *url = [NSURL URLWithString:urlStr];
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{
            @"house_type":@(self.model.houseType.integerValue) ,
            @"tracer": traceParam,
            @"biz_trace": [self.model bizTrace] ? : @"be_null"
        }];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

@end
