//
//  FHBaseMainListViewModel+Old.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import "FHBaseMainListViewModel+Old.h"
#import "FHBaseMainListViewModel+Internal.h"
#import <TTRoute/TTRoute.h>
#import "FHHouseListAPI.h"
#import <MJRefresh/MJRefresh.h>
#import <FHHouseBase/FHMapSearchOpenUrlDelegate.h>
#import <FHHouseBase/FHEnvContext.h>
#import <Masonry/Masonry.h>
#import <FHHouseHome/FHCityListViewModel.h>

@implementation FHBaseMainListViewModel (Old)

-(TTHttpTask *)loadData:(BOOL)isRefresh  query:(NSString *)query completion:(void (^)(id<FHBaseModelProtocol> model ,NSError *error))completion
{
    return [self loadData:isRefresh fromRecommend:self.fromRecommend query:nil completion:completion];
}

#pragma mark - 网络请求
-(TTHttpTask *)loadData:(BOOL)isRefresh fromRecommend:(BOOL)isFromRecommend query:(NSString *)query  completion:(void (^)(id<FHBaseModelProtocol> model ,NSError *error))completion
{
    NSInteger offset = 0;
    NSMutableDictionary *param = [NSMutableDictionary new];
    
    if (isRefresh) {
        if (!self.isFirstLoad && self.canChangeHouseSearchDic) {
            if (self.houseSearchDic.count <= 0) {
                // pageType 默认就是 [self pageTypeString]
                self.houseSearchDic = @{
                                        @"enter_query":@"be_null",
                                        @"search_query":@"be_null",
                                        @"page_type": [self pageTypeString],
                                        @"query_type":@"filter"
                                        };
            } else {
                NSMutableDictionary *dic = [self.houseSearchDic mutableCopy];
                dic[@"query_type"] = @"filter";
                self.houseSearchDic = dic;
            }
        }
        self.tableView.mj_footer.hidden = YES;
        [self.houseShowCache removeAllObjects];
        self.searchId = nil;
    } else {
        if (isFromRecommend) {
            offset = self.sugesstHouseList.count - 1;
        } else {
            offset = self.houseList.count;
        }
    }
    
    NSString *searchId = self.searchId;
    if (isFromRecommend) {
        return [self requestRecommendErshouHouseListData:isRefresh query:query offset:offset searchId:self.recommendSearchId completion:completion];
    } else {
        return [self requestErshouHouseListData:isRefresh query:query offset:offset searchId:searchId completion:completion];
    }
    
    return nil;
}

- (TTHttpTask *)requestErshouHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId completion:(void (^)(id<FHBaseModelProtocol> model ,NSError *error))completion
{
//    __weak typeof(self) wself = self;
    
    NSDictionary *param = @{@"house_type":@(self.houseType)};
    
    TTHttpTask *task = [FHHouseListAPI searchErshouHouseList:query params:param offset:offset searchId:searchId sugParam:nil class:[FHSearchHouseModel class] completion:^(FHSearchHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (completion) {
            completion(model , error);
        }
        
    }];
    
    return task;
}

- (TTHttpTask *)requestRecommendErshouHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId completion:(void (^)(id<FHBaseModelProtocol> model ,NSError *error))completion
{
    NSDictionary *param = @{@"house_type":@(self.houseType)};
    TTHttpTask *task = [FHHouseListAPI recommendErshouHouseList:query params:param offset:offset searchId:searchId sugParam:nil class:[FHRecommendSecondhandHouseModel class] completion:^(FHRecommendSecondhandHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (completion) {
            completion(model , error);
        }
    }];
    
    return task;
}



#pragma mark 地图找房
-(void)showOldMapSearch
{
    /*
     1. event_type：house_app2c_v2
     2. click_type: 点击类型,{'地图找房': 'map', '房源列表': 'list'}
     3. category_name：category名,{'二手房列表页': 'old_list'}
     4. enter_from：category入口,{'首页': 'maintab', '找房tab': 'findtab'}
     5. enter_type：进入category方式,{'点击': 'click'}
     6. element_from：组件入口,{'首页搜索': 'maintab_search', '首页icon': 'maintab_icon', '找房tab开始找房': 'findtab_find', '找房tab搜索': 'findtab_search'}
     7. search_id
     8. origin_from
     9. origin_search_id
     */
    
    if (self.mapFindHouseOpenUrl.length > 0) {
        
        NSMutableString *openUrl = self.mapFindHouseOpenUrl;
        NSMutableDictionary *param = [self categoryLogDict].mutableCopy;
        param[@"click_type"] = @"map";
        param[@"enter_type"] = @"click";
        TRACK_EVENT(@"click_switch_mapfind", param);
        
        NSMutableString *query = @"".mutableCopy;
        if (![self.mapFindHouseOpenUrl containsString:@"enter_category"]) {
            [query appendString:[NSString stringWithFormat:@"enter_category=%@",[self categoryName]]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:@"origin_from"]) {
            [query appendString:[NSString stringWithFormat:@"&origin_from=%@",self.tracerModel.originFrom ? : @"be_null"]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:@"origin_search_id"]) {
            [query appendString:[NSString stringWithFormat:@"&origin_search_id=%@",self.originSearchId ? : @"be_null"]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:@"enter_from"]) {
            [query appendString:[NSString stringWithFormat:@"&enter_from=%@",[self pageTypeString]]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:@"element_from"]) {
            [query appendString:[NSString stringWithFormat:@"&element_from=%@",self.tracerModel.elementFrom ? : @"be_null"]];
            
        }
        if (![self.mapFindHouseOpenUrl containsString:@"search_id"]) {
            [query appendString:[NSString stringWithFormat:@"&search_id=%@",self.searchId ? : @"be_null"]];
            
        }
        if (query.length > 0) {
            
            openUrl = [NSString stringWithFormat:@"%@&%@",openUrl,query];
        }
        
        //需要重置非过滤器条件，以及热词placeholder
        [self.houseFilterBridge closeConditionFilterPanel];
        
        NSURL *url = [NSURL URLWithString:openUrl];
        NSMutableDictionary *dict = @{}.mutableCopy;
        
        NSHashTable *hashMap = [[NSHashTable alloc]initWithOptions:NSPointerFunctionsWeakMemory capacity:1];
        [hashMap addObject:self];
        dict[OPENURL_CALLBAK] = hashMap;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
    
}


-(NSDictionary *)categoryLogDict {
    
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"category_name"] = [self categoryName] ? : @"be_null";
    tracerDict[@"enter_from"] = self.tracerModel.enterFrom ? : @"be_null";
    tracerDict[@"enter_type"] = self.tracerModel.enterType ? : @"be_null";
    tracerDict[@"element_from"] = self.tracerModel.elementFrom ? : @"be_null";
    tracerDict[@"search_id"] = self.searchId ? : @"be_null";
    tracerDict[@"origin_from"] = self.tracerModel.originFrom ? : @"be_null";
    tracerDict[@"origin_search_id"] = self.originSearchId ? : @"be_null";
    
    return tracerDict;
}

-(NSString *)stayPageEvent {
    
    return @"enter_category";
}

- (void)updateRedirectTipInfo
{
    if (self.showRedirectTip && self.redirectTips) {
        
        self.redirectTipView.hidden = NO;
        self.redirectTipView.text = self.redirectTips.text;
        self.redirectTipView.text1 = self.redirectTips.text2;
        [self.redirectTipView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(36);
        }];
        
        NSDictionary *params = @{@"page_type":@"city_switch",
                                 @"enter_from":@"search"};
        [FHUserTracker writeEvent:@"city_switch_show" params:params];
        
    }else {
        self.redirectTipView.hidden = YES;
        [self.redirectTipView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}

- (void)closeRedirectTip
{
    self.showRedirectTip = NO;
    self.redirectTipView.hidden = YES;
    [self.redirectTipView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    NSDictionary *params = @{@"click_type":@"cancel",
                             @"enter_from":@"search"};
    [FHUserTracker writeEvent:@"city_click" params:params];
}

- (void)clickRedirectTip
{
    if (self.redirectTips.openUrl.length > 0) {
        
        [FHEnvContext openSwitchCityURL:self.redirectTips.openUrl completion:^(BOOL isSuccess) {
            // 进历史
            if (isSuccess) {
                FHCityListViewModel *cityListViewModel = [[FHCityListViewModel alloc] initWithController:nil tableView:nil];
                [cityListViewModel switchCityByOpenUrlSuccess];
            }
        }];
        NSDictionary *params = @{@"click_type":@"switch",
                                 @"enter_from":@"search"};
        [FHUserTracker writeEvent:@"city_click" params:params];
    }
}

@end
