//
//  FHHouseNewBillboardItemViewModel.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewBillboardItemViewModel.h"
#import "FHSearchHouseModel.h"
#import "NSObject+FHTracker.h"
#import "FHHouseOpenURLUtil.h"
#import "FHHouseNewBillboardTrackDefines.h"
#import "FHUserTracker.h"
#import "NSDictionary+BTDAdditions.h"

@interface FHHouseNewBillboardItemViewModel()
@property (nonatomic, strong) FHCourtBillboardPreviewItemModel *model;
@property (nonatomic, assign) BOOL showed;
@end

@implementation FHHouseNewBillboardItemViewModel

- (instancetype)initWithModel:(FHCourtBillboardPreviewItemModel *)model {
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

- (NSString *)title {
    return self.model.title;
}

- (NSString *)subtitle {
    return self.model.subtitle;
}

- (NSString *)detail {
    return self.model.pricingPerSqm;;
}

- (FHImageModel *)img {
    return self.model.img;
}

- (void)onShowView {
    if (!self.showed) {
        self.showed = YES;
        
        NSMutableDictionary *logParams = [NSMutableDictionary dictionary];
        logParams[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : @"be_null";
        logParams[UT_ENTER_FROM] = self.fh_trackModel.enterFrom ? : @"be_null";
        logParams[UT_PAGE_TYPE] = self.fh_trackModel.pageType ? : @"be_null";
        logParams[UT_ELEMENT_TYPE] = UT_ELEMENT_TYPE_BILLBOARD;
        logParams[UT_KEY_RANK] = @(self.itemIndex);
        
        NSDictionary *logPbParams = [FHTracerModel getLogPbParams:self.model.logPb];
        if (logPbParams) {
            [logParams addEntriesFromDictionary:logPbParams];
        }
        
        [FHUserTracker writeEvent:UT_EVENT_BILLBOARD_ITEM_SHOW params:logParams];
    }
}

- (void)onClickView {
    NSString *openUrl = self.model.openUrl;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[UT_ENTER_FROM] = self.fh_trackModel.pageType ? : @"be_null";
    dict[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : @"be_null";
    dict[UT_ELEMENT_FROM] = UT_ELEMENT_TYPE_BILLBOARD;
    [FHHouseOpenURLUtil openUrl:openUrl logParams:dict];
}

- (BOOL)isValid {
    return YES;
}

@end
