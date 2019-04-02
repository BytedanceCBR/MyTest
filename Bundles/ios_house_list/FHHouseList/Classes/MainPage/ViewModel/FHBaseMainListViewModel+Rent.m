//
//  FHBaseMainListViewModel+Rent.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import "FHBaseMainListViewModel+Rent.h"
#import "FHBaseMainListViewModel+Internal.h"
#import <FHHouseBase/FHMainApi.h>
#import <FHHouseBase/FHHouseRentModel.h>
#import <TTRoute/TTRoute.h>
#import <FHHouseBase/FHBaseViewController.h>
#import <FHHouseBase/FHEnvContext.h>
#import <FHHouseBase/FHUserTrackerDefine.h>

@implementation FHBaseMainListViewModel (Rent)

-(TTHttpTask *)requestRentData:(BOOL)isHead query:(NSString *_Nullable)query completion:(void(^_Nullable)(FHHouseRentModel *_Nullable model , NSError *_Nullable error))completion
{
    NSInteger offset = 0;
    if (!isHead) {
        offset = self.houseList.count;
    }
    
    return   [FHMainApi searchRent:query params:nil offset:offset searchId:self.searchId sugParam:nil completion:^(FHHouseRentModel * _Nonnull model, NSError * _Nonnull error) {
        if (completion) {
            completion(model,error);
        }
    }];
}

-(NSString *)originFromWithFilterType:(FHHouseRentFilterType)filterType
{
    switch (filterType) {
            case FHHouseRentFilterTypeWhole:
            return  @"renting_fully";
            case FHHouseRentFilterTypeApart:
            return  @"renting_apartment";
            case FHHouseRentFilterTypeShare:
            return  @"renting_joint";
            case FHHouseRentFilterTypeMap:
            return @"renting_mapfind";
        default:
            return nil;
    }
    return nil;
}

-(FHHouseRentFilterType)rentFilterType:(NSString *)openUrl
{
    NSURL *url = [NSURL URLWithString:openUrl];
    if (!url) {
        return FHHouseRentFilterTypeNone;
    }
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    if ([components.host isEqualToString:@"mapfind_rent"]) {
        return FHHouseRentFilterTypeMap;
    }
    
    if ([components.host isEqualToString:@"house_list"]) {
        for (NSURLQueryItem *queryItem in components.queryItems) {
            if ([queryItem.name isEqualToString:@"rental_type[]"]) {
                if ([queryItem.value isEqualToString:@"1"]) {
                    //整租
                    return FHHouseRentFilterTypeWhole;
                }else if ([queryItem.value isEqualToString:@"2"]){
                    //合租
                    return FHHouseRentFilterTypeShare;
                }
            }else if ([queryItem.name isEqualToString:@"rental_contract_type[]"]){
                if ([queryItem.value isEqualToString:@"2"]) {
                    //公寓
                    return FHHouseRentFilterTypeApart;
                }
                
            }
        }
    }
    return FHHouseRentFilterTypeNone;
}

-(void)showCommuteConfigPage
{    
    id delegate = WRAP_WEAK(self);
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[COMMUTE_CONFIG_DELEGATE] = delegate;
    
    NSMutableDictionary *tracer = [NSMutableDictionary new];
    tracer[UT_ENTER_FROM] = @"renting";
    tracer[UT_ELEMENT_FROM] = @"commuter_info";
    tracer[UT_ORIGIN_FROM] = UT_OF_COMMUTE;
    tracer[UT_ORIGIN_SEARCH_ID] = self.originSearchId;
    
    param[TRACER_KEY] = tracer;
        
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:param];
    
    NSURL *url = [NSURL URLWithString:@"sslocal://commute_config"];
    [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
    
}

-(void)commuteWithDest:(NSString *)location type:(FHCommuteType)type duration:(NSString *)duration inController:(UIViewController *)controller
{
    [self gotoCommuteList:controller];
}


-(void)tryAddCommuteShowLog
{
    if (self.houseType != FHHouseTypeRentHouse) {
        return;
    }
    
    FHConfigDataModel *dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    FHConfigDataRentOpDataModel *rentModel = dataModel.rentOpData;
    CGFloat bannerHeight = [FHMainRentTopView bannerHeight:dataModel.rentBanner];
    if (bannerHeight < 1) {
        return;
    }
    /*
     "1. event_type ：house_app2c_v2
     2. page_type（页面类型）：rent_list
     3. element_type（组件类型）：commuter_info（通勤找房）
     4. origin_from:renting_list
     6. origin_search_id
     7.log_pb"
     */
    FHConfigDataRentOpDataItemsModel *item = [rentModel.items firstObject];
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_PAGE_TYPE] = @"rent_list";
    param[UT_ELEMENT_TYPE] = @"commuter_info";
    param[UT_ORIGIN_FROM] = self.originFrom;
    param[UT_LOG_PB] = self.tracerModel.logPb;
    param[UT_ORIGIN_SEARCH_ID] = self.originSearchId?:UT_BE_NULL;
    param[UT_LOG_PB] = item.logPb?:UT_BE_NULL;
        
    TRACK_EVENT(UT_OF_ELEMENT_SHOW, param);
    
}

@end
