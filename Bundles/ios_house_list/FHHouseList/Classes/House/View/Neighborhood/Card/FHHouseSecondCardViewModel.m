//
//  FHHouseSecondCardViewModel.m
//  FHHouseList
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHHouseSecondCardViewModel.h"
#import "FHHouseTitleAndTagViewModel.h"
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

@interface FHHouseSecondCardViewModel()

@property (nonatomic, strong) FHImageModel *leftImageModel;

@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, copy) NSString *price;

@property (nonatomic, copy) NSString *pricePerSqm;

@property (nonatomic, strong) NSArray<FHHouseTagsModel *> *tagList;

@property (nonatomic, assign) BOOL hasVr;

@end

@implementation FHHouseSecondCardViewModel

- (instancetype)initWithModel:(id)model {
    self = [super init];
    if (self) {
        _model = model;
        _titleAndTag = [[FHHouseTitleAndTagViewModel alloc] initWithModel:model];
        _titleAndTag.maxWidth = SCREEN_WIDTH - 30 * 2 - 84 - 8;
        
        if ([model isKindOfClass:[FHSearchHouseItemModel class]]) {
            FHSearchHouseItemModel *item = (FHSearchHouseItemModel *)model;
            _recommendViewModel = [[FHHouseRecommendViewModel alloc] initWithModel:item.advantageDescription];
            self.leftImageModel = [item.houseImage firstObject];
            self.price = item.displayPrice;
            self.pricePerSqm = item.displayPricePerSqm;
            self.subtitle = item.displaySubtitle;
            self.tagList = item.tags;
            self.hasVr = item.vrInfo.hasVr;
        } else if ([model isKindOfClass:[FHHouseListBaseItemModel class]]) {
            FHHouseListBaseItemModel *item = (FHHouseListBaseItemModel *)model;
            _recommendViewModel = [[FHHouseRecommendViewModel alloc] initWithModel:item.advantageDescription];
            self.leftImageModel = [item.houseImage firstObject];
            self.price = item.displayPrice;
            self.pricePerSqm = item.displayPricePerSqm;
            self.subtitle = item.displaySubtitle;
            self.tagList = item.tags;
            self.hasVr = item.vrInfo.hasVr;
        } else if ([model isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
            FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)model;
            _recommendViewModel = [[FHHouseRecommendViewModel alloc] initWithModel:item.advantageDescription];
            self.leftImageModel = [item.houseImage firstObject];
            self.price = item.displayPrice;
            self.pricePerSqm = item.displayPricePerSqm;
            self.subtitle = item.displaySubtitle;
            self.tagList = item.tags;
            self.hasVr = item.vrInfo.hasVr;
        }

    }
    return self;
}

- (void)cutTagListWithFont:(UIFont *)font {
    if ([self.tagList count] != 1) {
        return;
    }
    FHHouseTagsModel *element = [self.tagList[0] copy];
    CGSize textSize =  [element.content sizeWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, 14) lineBreakMode:NSLineBreakByWordWrapping];
    NSString *resultString;
    if (textSize.width > self.tagListMaxWidth) {
        NSString *preString;
        NSArray *paramsArrary = [element.content componentsSeparatedByString:@" · "];
        for (int i = 0; i < paramsArrary.count; i ++) {
            NSString *tagStr = paramsArrary[i];
            if (preString.length > 0) {
                preString = [NSString stringWithFormat:@"%@ · %@",preString, tagStr];
            } else {
                preString = tagStr;
            }
            CGSize tagSize =  [preString sizeWithFont: font constrainedToSize:CGSizeMake(CGFLOAT_MAX, 14) lineBreakMode:NSLineBreakByWordWrapping];
            if (tagSize.width > self.tagListMaxWidth) {
                break;
            }
            resultString = preString;
        }
    } else {
        resultString = element.content;
    }
    element.content = resultString;
    self.tagList = @[element];
}

- (void)clickCardAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.model isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)self.model;
        NSNumber *houseTypeNum = [self.context btd_numberValueForKey:@"house_type"];
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
        if (model.externalInfo.externalUrl && model.externalInfo.isExternalSite.boolValue) {
            NSMutableDictionary * dictRealWeb = [NSMutableDictionary new];
            [dictRealWeb setValue:houseTypeNum forKey:@"house_type"];
            traceParam[@"group_id"] = model.id;
            traceParam[@"impr_id"] = model.imprId;
            
            [dictRealWeb setValue:traceParam forKey:@"tracer"];
            [dictRealWeb setValue:model.externalInfo.externalUrl forKey:@"url"];
            [dictRealWeb setValue:model.externalInfo.backUrl forKey:@"backUrl"];
            
            TTRouteUserInfo *userInfoReal = [[TTRouteUserInfo alloc] initWithInfo:dictRealWeb];
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://house_real_web"] userInfo:userInfoReal];
            return;
        }
        urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",model.id];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{
                @"house_type":@(model.houseType.integerValue) ,
                @"tracer": traceParam,
                @"biz_trace": [model bizTrace] ? : @"be_null"
            }];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
        [[FHRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];
    }
}

- (void)setTitleMaxWidth:(CGFloat)maxWidth{
    if (_titleAndTag) {
        _titleAndTag.maxWidth = maxWidth;
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
