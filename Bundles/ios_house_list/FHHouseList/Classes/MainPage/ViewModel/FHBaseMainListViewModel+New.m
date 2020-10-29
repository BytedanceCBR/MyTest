//
//  FHBaseMainListViewModel+New.m
//  FHHouseList
//
//  Created by wangxinyu on 2020/10/29.
//

#import "FHBaseMainListViewModel+New.h"
#import <MJRefresh/MJRefresh.h>
#import "FHBaseMainListViewModel+Internal.h"
#import "FHSearchHouseModel.h"
#import "FHHouseListAPI.h"
#import "FHSearchChannelTypes.h"

@implementation FHBaseMainListViewModel (New)

- (TTHttpTask *)requestNewData:(BOOL)isRefresh query:(NSString *)query completion:(void (^)(id<FHBaseModelProtocol> model ,NSError *error))completion {
    NSInteger offset = 0;
    
    if (isRefresh) {
        //TODO: 确认一下这个字典的作用canChangeHouseSearchDic？
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
        if ([self.houseDataModel isKindOfClass:[FHListSearchHouseDataModel class]]) {
            FHListSearchHouseDataModel *model = (FHListSearchHouseDataModel *)self.houseDataModel;
            offset = model.offset;
        }
    }
    
    NSString *searchId = self.searchId;
    return [self requestNewHouseListData:isRefresh query:query offset:offset searchId:searchId completion:completion];
}

- (TTHttpTask *)requestNewHouseListData:(BOOL)isRefresh query: (NSString *)query offset: (NSInteger)offset searchId: (NSString *)searchId completion:(void (^)(id<FHBaseModelProtocol> model ,NSError *error))completion {
    NSDictionary *param = @{
        @"house_type": @(self.houseType),
        @"channel_id": CHANNEL_ID_SEARCH_COURT_WITH_BANNER,
    };
    
    if (isRefresh) {
        if (query) {
            self.subScribeQuery = [NSString stringWithString:query];
        }
        self.subScribeOffset = offset;
        if (searchId) {
            self.subScribeSearchId = [NSString stringWithString:searchId];
        }
    }

    TTHttpTask *task = [FHHouseListAPI searchNewHouseList:query params:param offset:offset searchId:searchId sugParam:nil class:[FHListSearchHouseModel class] completion:(FHMainApiCompletion)^(FHListSearchHouseModel *  _Nullable model, NSError * _Nullable error) {
        
        if (completion) {
            completion(model , error);
        }
        
    }];
    
    return task;
}

@end
