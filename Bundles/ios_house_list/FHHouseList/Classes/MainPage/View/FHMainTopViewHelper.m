//
//  FHMainTopViewHelper.m
//  FHHouseList
//
//  Created by 张静 on 2019/12/13.
//

#import "FHMainTopViewHelper.h"
#import "FHListEntrancesView.h"
#import "FHConfigModel.h"
#import <FHHouseBase/FHHouseBridgeManager.h>
#import <TTRoute.h>
#import "FHCommuteManager.h"

@implementation FHMainTopViewHelper

+ (void)fillFHListEntrancesView:(FHListEntrancesView *)entranceView withModel:(FHConfigDataOpDataModel *)model withTraceParams:(NSDictionary *)traceParams
{
    FHListEntrancesView *cellEntrance = entranceView;
    
    NSInteger countItems = model.items.count;
    //    if (countItems > [FHHomeCellHelper sharedInstance].kFHHomeIconRowCount * 2) {
    //        countItems = [FHHomeCellHelper sharedInstance].kFHHomeIconRowCount * 2;
    //    }
    
    [entranceView updateWithItems:model.items];
    
    cellEntrance.clickBlock = ^(NSInteger clickIndex , FHConfigDataOpDataItemsModel *itemModel){
        NSMutableDictionary *dictTrace = [NSMutableDictionary new];
        [dictTrace setValue:@"maintab" forKey:@"enter_from"];// todo zjing event
        
        if ([traceParams isKindOfClass:[NSDictionary class]]) {
            [dictTrace addEntriesFromDictionary:traceParams];
        }
        
        [dictTrace setValue:@"maintab_icon" forKey:@"element_from"];
        [dictTrace setValue:@"click" forKey:@"enter_type"];
        
        if ([itemModel.logPb isKindOfClass:[NSDictionary class]] && itemModel.logPb[@"element_from"] != nil) {
            [dictTrace setValue:itemModel.logPb[@"element_from"] forKey:@"element_from"];
        }
        
        NSString *stringOriginFrom = itemModel.logPb[@"origin_from"];
        if ([stringOriginFrom isKindOfClass:[NSString class]] && stringOriginFrom.length != 0) {
            [[[FHHouseBridgeManager sharedInstance] envContextBridge] setTraceValue:stringOriginFrom forKey:@"origin_from"];
            [dictTrace setValue:stringOriginFrom forKey:@"origin_from"];
        }else{
            [[[FHHouseBridgeManager sharedInstance] envContextBridge] setTraceValue:@"be_null" forKey:@"origin_from"];
            [dictTrace setValue:@"be_null" forKey:@"origin_from"];
        }
        
        NSDictionary *userInfoDict = @{@"tracer":dictTrace};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
        
        if ([itemModel.openUrl isKindOfClass:[NSString class]]) {
            NSURL *url = [NSURL URLWithString:itemModel.openUrl];
            if ([itemModel.openUrl containsString:@"://commute_list"]){
                //通勤找房
                [[FHCommuteManager sharedInstance] tryEnterCommutePage:itemModel.openUrl logParam:dictTrace];
            }else{
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
            }
        }
    };
    [cellEntrance setNeedsLayout];
}

// 首页轮播banner
//+ (void)fillFHHomeScrollBannerCell:(FHHomeScrollBannerCell *)cell withModel:(FHConfigDataMainPageBannerOpDataModel *)model {
//    // 更新cell数据
//    [cell updateWithModel:model];
//}


@end
