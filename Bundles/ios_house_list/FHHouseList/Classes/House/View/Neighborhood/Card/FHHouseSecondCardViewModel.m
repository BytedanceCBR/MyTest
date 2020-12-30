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
#import "FHHouseNeighborAgencyViewModel.h"
#import "FHHouseReserveAdviserViewModel.h"
#import "FHHouseCardStatusManager.h"
#import "NSString+BTDAdditions.h"

@interface FHHouseSecondCardViewModel()

@property (nonatomic, strong) FHImageModel *leftImageModel;

@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, copy) NSString *price;

@property (nonatomic, copy) NSString *pricePerSqm;

@property (nonatomic, strong) NSArray<FHHouseTagsModel *> *tagList;

@property (nonatomic, assign) BOOL hasVr;

@property (nonatomic, copy) NSString *houseId;

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
            self.houseId = item.id;
        } else if ([model isKindOfClass:[FHHouseListBaseItemModel class]]) {
            FHHouseListBaseItemModel *item = (FHHouseListBaseItemModel *)model;
            _recommendViewModel = [[FHHouseRecommendViewModel alloc] initWithModel:item.advantageDescription];
            self.leftImageModel = [item.houseImage firstObject];
            self.price = item.displayPrice;
            self.pricePerSqm = item.displayPricePerSqm;
            self.subtitle = item.displaySubtitle;
            self.tagList = item.tags;
            self.hasVr = item.vrInfo.hasVr;
            self.houseId = item.id;
        } else if ([model isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
            FHSearchHouseDataItemsModel *item = (FHSearchHouseDataItemsModel *)model;
            _recommendViewModel = [[FHHouseRecommendViewModel alloc] initWithModel:item.advantageDescription];
            self.leftImageModel = [item.houseImage firstObject];
            self.price = item.displayPrice;
            self.pricePerSqm = item.displayPricePerSqm;
            self.subtitle = item.displaySubtitle;
            self.tagList = item.tags;
            self.hasVr = item.vrInfo.hasVr;
            self.houseId = item.hid;
        }

    }
    return self;
}

- (void)cutTagListWithFont:(UIFont *)font {
    if ([self.tagList count] != 1) {
        return;
    }
    FHHouseTagsModel *element = [self.tagList[0] copy];
    CGFloat width = [element.content btd_widthWithFont:font height:14];
    NSString *resultString;
    if (width > self.tagListMaxWidth) {
        NSString *preString;
        NSArray *paramsArrary = [element.content componentsSeparatedByString:@" · "];
        for (int i = 0; i < paramsArrary.count; i ++) {
            NSString *tagStr = paramsArrary[i];
            if (preString.length > 0) {
                preString = [NSString stringWithFormat:@"%@ · %@",preString, tagStr];
            } else {
                preString = tagStr;
            }
            width =  [preString btd_widthWithFont:font height:14];
            if (width > self.tagListMaxWidth) {
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


- (CGFloat)opacity {
    CGFloat opacity = 1;
    if ([[FHHouseCardStatusManager sharedInstance] isReadHouseId:self.houseId withHouseType:FHHouseTypeSecondHandHouse]) {
        opacity = FHHouseCardReadOpacity;
    }
    return opacity;
}

- (void)clickCardAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.model isKindOfClass:[FHSearchHouseItemModel class]]) {
        [[FHHouseCardStatusManager sharedInstance] readHouseId:self.houseId withHouseType:FHHouseTypeSecondHandHouse];
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)self.model;
        NSNumber *houseTypeNum = [self.context btd_numberValueForKey:@"house_type"];
        NSString *urlStr = nil;
        NSInteger rankOffset = [self.context btd_integerValueForKey:@"rank_offset"];
        NSInteger rank = indexPath.row + rankOffset;
        id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
        [contextBridge setTraceValue:self.fh_trackModel.originFrom forKey:@"origin_from"];
        [contextBridge setTraceValue:self.fh_trackModel.originSearchId forKey:@"origin_search_id"];
        
        NSMutableDictionary *traceParam = @{}.mutableCopy;
        traceParam[UT_ENTER_FROM] = self.fh_trackModel.pageType ? : UT_BE_NULL;
        traceParam[UT_ELEMENT_FROM] = self.fh_trackModel.elementType ? : UT_BE_NULL;
        traceParam[UT_LOG_PB] = model.logPbWithTags ? : UT_BE_NULL;
        traceParam[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : UT_BE_NULL;
        traceParam[UT_ORIGIN_SEARCH_ID] = self.fh_trackModel.originSearchId ? : UT_BE_NULL;
        traceParam[@"rank"] = @(rank);
        traceParam[@"card_type"] = @"left_pic";
        
        
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
                @"biz_trace": [model bizTrace] ? : UT_BE_NULL
            }];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
        [[FHRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];
        if (self.opacityDidChange) {
            self.opacityDidChange();
        }
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
        NSInteger rankOffset = [self.context btd_integerValueForKey:@"rank_offset"];
        NSInteger rank = indexPath.row + rankOffset;
        NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
        tracerDict[@"rank"] = @(rank);
        tracerDict[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : UT_BE_NULL;
        tracerDict[UT_ORIGIN_SEARCH_ID] = self.fh_trackModel.originSearchId ? : UT_BE_NULL;
        tracerDict[UT_PAGE_TYPE] = self.fh_trackModel.pageType ? : UT_BE_NULL;
        tracerDict[UT_ELEMENT_TYPE] = self.fh_trackModel.elementType ? : UT_BE_NULL;
        tracerDict[UT_SEARCH_ID] = self.fh_trackModel.searchId ? : UT_BE_NULL;
        tracerDict[@"group_id"] = model.id ? : UT_BE_NULL;
        tracerDict[@"impr_id"] = model.imprId ? : UT_BE_NULL;
        tracerDict[UT_LOG_PB] = model.logPbWithTags ? : UT_BE_NULL;
        tracerDict[@"house_type"] = @"old";
        tracerDict[@"biz_trace"] = [self.model bizTrace] ? : UT_BE_NULL;
        tracerDict[@"card_type"] = @"left_pic";
        if (self.fh_trackModel.elementFrom && ![self.fh_trackModel.elementFrom isEqualToString:UT_BE_NULL]) {
            tracerDict[UT_ELEMENT_FROM] = self.fh_trackModel.elementFrom;
        }
        [FHUserTracker writeEvent:@"house_show" params:tracerDict];
    }
}

- (void)adjustIfNeedWithPreviousViewModel:(id<FHHouseCardCellViewModelProtocol>)viewModel {
    if ([self.model isKindOfClass:[FHSearchHouseItemModel class]]) {
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)self.model;
        if (viewModel == nil) {
            //如果在首位，topMargin=10
            model.topMargin = 10;
        } else {
            model.topMargin = 5;
        }
    }
}

@end
