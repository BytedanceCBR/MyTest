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
