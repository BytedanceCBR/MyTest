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
#import "FHHouseNeighborAgencyViewModel.h"
#import "FHHouseReserveAdviserViewModel.h"
#import "FHHouseCardStatusManager.h"
#import "FHEnvContext.h"

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

@property (nonatomic, copy) NSString *houseId;

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
            self.houseId = item.id;
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
            self.hasVr = item.vrInfo.hasVr;
            self.hasVideo = !self.hasVr && item.videoInfo.hasVideo;
            self.houseId = item.houseid;
        }
    }
    return self;
}

- (CGFloat)opacity {
    CGFloat opacity = 1;
    if ([[FHHouseCardStatusManager sharedInstance] isReadHouseId:self.houseId withHouseType:FHHouseTypeNewHouse]) {
        opacity = [FHEnvContext FHHouseCardReadOpacity];
        //FHHouseCardReadOpacity;
    }
    return opacity;
}

- (void)clickCardAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.model isKindOfClass:[FHSearchHouseItemModel class]]) {
        [[FHHouseCardStatusManager sharedInstance] readHouseId:self.houseId withHouseType:FHHouseTypeNewHouse];
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)self.model;
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
        
        urlStr = [NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",model.id];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{
                @"house_type":@(model.houseType.integerValue) ,
                @"tracer": traceParam,
                @"biz_trace": [model bizTrace] ? : UT_BE_NULL
            }];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
        if (self.opacityDidChange) {
            self.opacityDidChange();
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
        tracerDict[@"house_type"] = @"new";
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
