//
//  FHHouseNewEntrancesViewModel.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewEntrancesViewModel.h"
#import "FHEnvContext.h"
#import "FHHouseOpenURLUtil.h"
#import "FHUserTracker.h"
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
    NSDictionary *logPbParams = [FHTracerModel getLogPbParams:item.logPb];
    NSString *icon_name = [logPbParams btd_stringValueForKey:@"icon_name"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[UT_ENTER_FROM] = self.fh_trackModel.pageType ? : @"be_null";
    dict[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : @"be_null";
    dict[UT_ELEMENT_FROM] = icon_name ? : @"be_null";
    dict[UT_LOG_PB] = item.logPb ? : @"be_null";

    [FHHouseOpenURLUtil openUrl:openUrl logParams:dict];
    
    {
        NSMutableDictionary *logParams = [NSMutableDictionary dictionary];
        logParams[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : @"be_null";
        logParams[UT_PAGE_TYPE] = self.fh_trackModel.pageType ? : @"be_null";
        logParams[@"icon_name"] = icon_name ? : @"be_null";
        [FHUserTracker writeEvent:@"click_icon" params:logParams];
    }
}
@end
