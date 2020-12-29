//
//  FHHouseRedirectTipViewModel.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseRedirectTipViewModel.h"
#import "FHHouseListModel.h"
#import "FHUserTracker.h"
#import "FHEnvContext.h"
#import "FHHouseBridgeManager.h"

@interface FHHouseRedirectTipViewModel()
@property (nonatomic, assign) BOOL showed;
@end

@implementation FHHouseRedirectTipViewModel

- (instancetype)initWithModel:(id)model {
    self = [super initWithModel:model];
    if (self) {
        if ([model isKindOfClass:FHSearchHouseDataRedirectTipsModel.class]) {
            FHSearchHouseDataRedirectTipsModel *tipsModel = (FHSearchHouseDataRedirectTipsModel *)model;
            tipsModel.clickRightBlock = ^(NSString * _Nonnull openUrl) {
                if (openUrl.length > 0) {
                    [FHEnvContext sharedInstance].refreshConfigRequestType = @"switch_house";
                    [FHEnvContext openSwitchCityURL:openUrl completion:^(BOOL isSuccess) {
                        // 进历史
                        if (isSuccess) {
                            [[[FHHouseBridgeManager sharedInstance] cityListModelBridge] switchCityByOpenUrlSuccess];
                        }
                    }];
                    NSDictionary *params = @{
                        @"click_type":@"switch",
                        @"enter_from":@"search"
                    };
                    [FHUserTracker writeEvent:@"city_click" params:params];
                }
            };
        }
    }
    return self;
}

- (void)showCardAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showed) return;
    self.showed = YES;
    
    NSDictionary *params = @{
        @"page_type":@"city_switch",
        @"enter_from":@"search"
    };
    [FHUserTracker writeEvent:@"city_switch_show" params:params];
}

@end
