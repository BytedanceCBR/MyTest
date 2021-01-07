//
//  FHHouseNeighborhoodCardViewModel.m
//  ABRInterface
//
//  Created by bytedance on 2020/11/9.
//

#import "FHHouseNeighborhoodCardViewModel.h"
#import "NSObject+FHTracker.h"
#import "FHUserTracker.h"
#import "TTRoute.h"
#import "FHHouseTitleAndTagViewModel.h"
#import "FHCommonDefines.h"
#import "FHHouseCardStatusManager.h"
#import "FHHouseNeighborModel.h"
#import "FHEnvContext.h"

@interface FHHouseNeighborhoodCardViewModel()

@property (nonatomic, strong) FHImageModel *leftImageModel;

@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, copy) NSString *stateInfo;

@property (nonatomic, copy) NSString *price;

@property (nonatomic, assign) BOOL showed;

@property (nonatomic, copy) NSString *houseId;

@end

@implementation FHHouseNeighborhoodCardViewModel

- (instancetype)initWithModel:(id)data {
    self = [super init];
    if (self) {
        _model = data;
        _titleAndTag = [[FHHouseTitleAndTagViewModel alloc] initWithModel:data];
        _titleAndTag.maxWidth = SCREEN_WIDTH - 30 * 2 - 84 - 8;
        if ([data isKindOfClass:[FHSearchHouseItemModel class]]) {
            FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)data;
            self.leftImageModel = [model.images firstObject];
            self.subtitle = model.displaySubtitle;
            self.stateInfo = model.displayStatsInfo;
            self.price = model.displayPrice;
            self.houseId = model.id;
        } else if ([data isKindOfClass:[FHHouseNeighborDataItemsModel class]]) {
            FHHouseNeighborDataItemsModel *model = (FHHouseNeighborDataItemsModel *)data;
            self.leftImageModel = model.images.firstObject;
            self.subtitle = model.displaySubtitle;
            self.stateInfo = model.displayStatsInfo;
            self.price = model.displayPrice;
            self.houseId = model.id;
        }
    }
    return self;
}

- (BOOL)isValid {
    return YES;
}

- (CGFloat)opacity {
    CGFloat opacity = 1;
    if ([[FHHouseCardStatusManager sharedInstance] isReadHouseId:self.houseId withHouseType:FHHouseTypeNeighborhood]) {
        opacity = [FHEnvContext FHHouseCardReadOpacity];
        //FHHouseCardReadOpacity;
    }
    return opacity;
}

- (void)showCardAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.showed) {
        self.showed = YES;
        if ([self.model isKindOfClass:[FHSearchHouseItemModel class]]) {
            FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)self.model;
            NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
            tracerDict[@"rank"] = @(indexPath.row);
            tracerDict[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : @"be_null";
            tracerDict[UT_ENTER_FROM] = self.fh_trackModel.enterFrom ? : @"be_null";
            tracerDict[UT_ORIGIN_SEARCH_ID] = self.fh_trackModel.originSearchId ? : @"be_null";
            tracerDict[UT_PAGE_TYPE] = self.fh_trackModel.pageType ? : @"be_null";
            tracerDict[UT_ELEMENT_TYPE] = @"be_null";
            tracerDict[UT_SEARCH_ID] = self.fh_trackModel.searchId ? : @"be_null";
            tracerDict[@"group_id"] = model.id ? : @"be_null";
            tracerDict[@"impr_id"] = model.imprId ? : @"be_null";
            tracerDict[UT_LOG_PB] = model.logPbWithTags ? : @"be_null";
            tracerDict[@"house_type"] = @"neighborhood";
            tracerDict[@"biz_trace"] = [self.model bizTrace] ? : @"be_null";
            tracerDict[@"card_type"] = @"left_pic";
            if (self.fh_trackModel.elementFrom && ![self.fh_trackModel.elementFrom isEqualToString:@"be_null"]) {
                tracerDict[UT_ELEMENT_FROM] = self.fh_trackModel.elementFrom;
            }
            
            [FHUserTracker writeEvent:@"house_show" params:tracerDict];
        }
    }
}

- (void)clickCardAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.model isKindOfClass:[FHSearchHouseItemModel class]]) {
        [[FHHouseCardStatusManager sharedInstance] readHouseId:self.houseId withHouseType:FHHouseTypeNeighborhood];
        FHSearchHouseItemModel *model = (FHSearchHouseItemModel *)self.model;
        NSMutableDictionary *traceParam = @{}.mutableCopy;
        traceParam[UT_ENTER_FROM] = self.fh_trackModel.pageType ? : @"be_null";
        traceParam[UT_ELEMENT_FROM] = @"be_null";
        traceParam[UT_LOG_PB] = model.logPbWithTags ? : @"be_null";;
        traceParam[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : @"be_null";
        traceParam[UT_ORIGIN_SEARCH_ID] = self.fh_trackModel.originSearchId ? : @"be_null";
        traceParam[@"rank"] = @(indexPath.row);
        traceParam[@"card_type"] = @"left_pic";
        
        NSString *urlStr = [NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@",model.id];;
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{
                @"house_type":@(model.houseType.integerValue) ,
                @"tracer": traceParam,
                @"biz_trace": [model bizTrace] ? : @"be_null"
            }];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
        if (self.opacityDidChange) {
            self.opacityDidChange();
        }
    }
}

- (void)adjustIfNeedWithPreviousViewModel:(id<FHHouseCardCellViewModelProtocol>)viewModel {
    
}

@end
