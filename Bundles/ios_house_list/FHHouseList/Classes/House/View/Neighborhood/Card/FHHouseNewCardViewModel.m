//
//  FHHouseNewCardViewModel.m
//  FHHouseList
//
//  Created by xubinbin on 2020/11/27.
//

#import "FHHouseNewCardViewModel.h"
#import "FHCommonDefines.h"
#import "FHHouseRecommendViewModel.h"
#import "NSObject+FHOptimize.h"
#import "FHCommonDefines.h"
#import "NSObject+FHTracker.h"
#import "FHUserTracker.h"
#import "TTRoute.h"
#import "FHHouseType.h"
#import "FHRelevantDurationTracker.h"
#import "NSDictionary+BTDAdditions.h"
#import "FHHouseListViewModel.h"
#import "FHHouseEnvContextBridge.h"
#import "FHHouseBridgeManager.h"

@interface FHHouseNewCardViewModel()

@property (nonatomic, strong) FHImageModel *leftImageModel;

@property (nonatomic, strong) FHImageModel *tagImageModel;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *propertyText;

@property (nonatomic, copy) NSString *propertyBorderColor;

@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, copy) NSString *price;

@property (nonatomic, copy) NSString *pricePerSqm;

@property (nonatomic, strong) NSArray<FHHouseTagsModel *> *tagList;

@property (nonatomic, assign) BOOL hasVr;

@property (nonatomic, assign) BOOL hasVideo;

@end

@implementation FHHouseNewCardViewModel

- (instancetype)initWithModel:(id)model {
    self = [super init];
    if (self) {
        _model = model;
        if ([model isKindOfClass:[FHSearchHouseItemModel class]]) {
            FHSearchHouseItemModel *item = (FHSearchHouseItemModel *)model;
            _recommendViewModel = [[FHHouseRecommendViewModel alloc] initWithModel:item.advantageDescription];
            self.leftImageModel = [item.images firstObject];
            self.title = item.displayTitle;
            self.price = item.displayPricePerSqm;
            self.subtitle = item.displayDescription;
            self.tagList = item.tags;
            self.hasVr = item.vrInfo.hasVr;
            self.hasVideo = !self.hasVr && item.videoInfo.hasVideo;
            self.propertyText = item.propertyTag.content;
            self.propertyBorderColor = item.propertyTag.borderColor;
            self.tagImageModel = item.tagImage.firstObject;
        } else if ([model isKindOfClass:[FHHouseListBaseItemModel class]]) {
            FHHouseListBaseItemModel *item = (FHHouseListBaseItemModel *)model;
            _recommendViewModel = [[FHHouseRecommendViewModel alloc] initWithModel:item.advantageDescription];
            self.leftImageModel = [item.houseImage firstObject];
            self.title = item.title;
            self.price = item.displayPricePerSqm;
            self.subtitle = item.displaySubtitle;
            self.tagList = item.tags;
            self.propertyText = item.propertyTag.content;
            self.propertyBorderColor = item.propertyTag.borderColor;
        }
    }
    return self;
}

- (void)clickCardAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.model isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)self.model;
        NSString *urlStr = nil;
        NSNumber *isFirstHavetipNum = [self.context btd_numberValueForKey:@"is_first_havetip"];
        NSInteger row = indexPath.row;
        if (isFirstHavetipNum && isFirstHavetipNum.boolValue == NO) {
            row--;
        }
        id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
        [contextBridge setTraceValue:self.fh_trackModel.originFrom forKey:@"origin_from"];
        [contextBridge setTraceValue:self.fh_trackModel.originSearchId forKey:@"origin_search_id"];
        
        NSMutableDictionary *traceParam = @{}.mutableCopy;
        traceParam[UT_ENTER_FROM] = self.fh_trackModel.pageType ? : @"be_null";
        traceParam[UT_ELEMENT_FROM] = @"be_null";
        traceParam[UT_LOG_PB] = model.logPbWithTags ? : @"be_null";;
        traceParam[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : @"be_null";
        traceParam[UT_ORIGIN_SEARCH_ID] = self.fh_trackModel.originSearchId ? : @"be_null";
        traceParam[@"rank"] = @(row);
        traceParam[@"card_type"] = @"left_pic";
        if (model.isRecommendCell) {
            traceParam[UT_ELEMENT_FROM] = @"search_related";
        }
        urlStr = [NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",model.id];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{
                @"house_type":@(model.houseType.integerValue) ,
                @"tracer": traceParam,
                @"biz_trace": [model bizTrace] ? : @"be_null"
            }];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

- (void)showCardAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    [self executeOnce:^{
        [weakSelf addHouseShowWithIndexPath:indexPath];
    } token:FHExecuteOnceUniqueTokenForCurrentContext];
}

- (void)addHouseShowWithIndexPath:(NSIndexPath *)indexPath {
    if ([self.model isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)self.model;
        NSNumber *isFirstHavetipNum = [self.context btd_numberValueForKey:@"is_first_havetip"];
        NSInteger row = indexPath.row;
        if (isFirstHavetipNum && isFirstHavetipNum.boolValue == NO) {
            row--;
        }
        NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
        tracerDict[@"rank"] = @(row);
        tracerDict[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : @"be_null";
        tracerDict[UT_ORIGIN_SEARCH_ID] = self.fh_trackModel.originSearchId ? : @"be_null";
        tracerDict[UT_PAGE_TYPE] = self.fh_trackModel.pageType ? : @"be_null";
        tracerDict[UT_ELEMENT_TYPE] = self.fh_trackModel.elementType ? : @"be_null";
        tracerDict[UT_SEARCH_ID] = self.fh_trackModel.searchId ? : @"be_null";
        tracerDict[@"group_id"] = model.id ? : @"be_null";
        tracerDict[@"impr_id"] = model.imprId ? : @"be_null";
        tracerDict[UT_LOG_PB] = model.logPbWithTags ? : @"be_null";
        tracerDict[@"house_type"] = @"old";
        tracerDict[@"biz_trace"] = [self.model bizTrace] ? : @"be_null";
        tracerDict[@"card_type"] = @"left_pic";
        if (self.fh_trackModel.elementFrom && ![self.fh_trackModel.elementFrom isEqualToString:@"be_null"]) {
            tracerDict[UT_ELEMENT_FROM] = self.fh_trackModel.elementFrom;
        }
        [FHUserTracker writeEvent:@"house_show" params:tracerDict];
    }
}

@end
