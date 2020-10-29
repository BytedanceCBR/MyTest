//
//  FHHouseNewEntrancesViewModel.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewEntrancesViewModel.h"
#import "FHEnvContext.h"
#import "TTRoute.h"
#import "FHUserTracker.h"
#import "FHCommuteManager.h"
#import "NSObject+FHTracker.h"
#import "NSDictionary+BTDAdditions.h"

@interface FHHouseNewEntrancesViewModel()
@property (nonatomic, strong, readwrite) NSArray *items;
@end

@implementation FHHouseNewEntrancesViewModel

- (NSArray *)items {
    if (!_items) {
        FHConfigDataModel *configModel = [[FHEnvContext sharedInstance] getConfigFromCache];
        NSArray *items = configModel.courtOpData.items;
        if (items.count > 5) {
            items = [items subarrayWithRange:NSMakeRange(0, 5 )];
        }
    
        _items = items;
    }
    
    return _items;
}

- (BOOL)isValid {
    return self.items.count > 0;
}

- (void)onClickItem:(FHConfigDataOpDataItemsModel *)item {
    NSString *openUrl = item.openUrl;
    if (!openUrl || !openUrl.length || ![openUrl isKindOfClass:[NSString class]]) return;

    NSDictionary *logPbParams = [FHTracerModel getLogPbParams:item.logPb];
    NSString *originFrom = [logPbParams btd_stringValueForKey:UT_ORIGIN_FROM];
    if (!originFrom) {
        originFrom = self.fh_trackModel.originFrom;
    }
    NSString *elementFrom = [logPbParams btd_stringValueForKey:@"icon_name"];
    if (!elementFrom) {
        elementFrom = self.fh_trackModel.elementFrom;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[UT_ENTER_FROM] = self.fh_trackModel.pageType ? : @"be_null";
    dict[UT_ORIGIN_FROM] = originFrom ? : @"be_null";
    dict[UT_ELEMENT_FROM] = elementFrom ? : @"be_null";
    dict[UT_LOG_PB] = logPbParams ? : @"be_null";

    NSURL *url = [NSURL URLWithString:openUrl];
    if ([openUrl containsString:@"://commute_list"]){
        //通勤找房
        [[FHCommuteManager sharedInstance] tryEnterCommutePage:openUrl logParam:dict];
    } else {
        NSDictionary *userInfoDict = @{@"tracer":dict};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
    
    [self trackerClickIcon:logPbParams];
}

- (void)trackerClickIcon:(NSDictionary *)logPbParams {
    NSMutableDictionary *logParams = [NSMutableDictionary dictionary];
    if (logPbParams) {
        [logParams addEntriesFromDictionary:logPbParams];
    }
    
    logParams[UT_PAGE_TYPE] = self.fh_trackModel.pageType ? : @"be_null";
    [FHUserTracker writeEvent:@"click_icon" params:logParams];
}
@end
