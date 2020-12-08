//
//  FHHouseGuessYouWantViewModel.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseGuessYouWantViewModel.h"
#import "TTRoute.h"
#import "FHSearchHouseModel.h"
#import "FHUserTracker.h"
#import "NSObject+FHTracker.h"
#import "NSDictionary+BTDAdditions.h"

@implementation FHHouseGuessYouWantTipViewModel

- (void)handleChannelSwitch {
    FHSearchGuessYouWantTipsModel *model = (FHSearchGuessYouWantTipsModel *)self.model;
    NSString *url = model.realSearchOpenUrl;
    
    NSInteger preHouseType = [self.context btd_integerValueForKey:@"pre_house_type"];
    
    NSMutableDictionary *tracer = [NSMutableDictionary new];
    tracer[UT_ELEMENT_FROM] = [self channelSwitchElementFromNameByhouseType:preHouseType];
    tracer[UT_ENTER_FROM] = self.fh_trackModel.categoryName ? : UT_BE_NULL;
    tracer[UT_ENTER_TYPE] = @"click";
    tracer[UT_ORIGIN_FROM] = self.fh_trackModel.originFrom ? : UT_BE_NULL;
    
    NSMutableDictionary *infos = [NSMutableDictionary new];
    infos[@"tracer"] = tracer;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infos];
    if (url.length > 0) {
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:url] userInfo:userInfo];
    }
}

//仅仅适用于sug页面跳转不一致时的频道切换“点击查看xx房结果”
- (NSString *)channelSwitchElementFromNameByhouseType:(NSInteger)houseType {
    if(houseType == FHHouseTypeNewHouse){
        return @"channel_switch_new_result";
    }else if(houseType == FHHouseTypeSecondHandHouse){
        return @"channel_switch_old_result";
    }else if(houseType == FHHouseTypeRentHouse){
        return  @"channel_switch_renting_result";
    }else if(houseType == FHHouseTypeNeighborhood){
        return  @"channel_switch_neighborhood_result";
    }
    return UT_BE_NULL;
}

@end


@implementation FHHouseGuessYouWantContentViewModel

@end
