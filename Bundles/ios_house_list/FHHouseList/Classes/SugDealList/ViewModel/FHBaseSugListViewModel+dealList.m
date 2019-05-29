//
//  FHBaseSugListViewModel+dealList.m
//  FHHouseList
//
//  Created by 张静 on 2019/4/18.
//

#import "FHBaseSugListViewModel+dealList.h"
#import "FHBaseSugListViewModel+Internal.h"

@implementation FHBaseSugListViewModel (dealList)

- (void)requestNeighborDealSuggestion:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query searchType:(NSString *)searchType
{
    if (self.sugHttpTask) {
        [self.sugHttpTask cancel];
    }
    self.highlightedText = query;
    __weak typeof(self) wself = self;
    
    self.sugHttpTask = [FHHouseListAPI requestDealSuggestionCityId:cityId houseType:houseType query:query searchType:searchType class:[FHSuggestionResponseModel class] completion:^(FHSuggestionResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        if (error.code == NSURLErrorCancelled) {
            return ;
        }
        // 正常返回
        wself.sugListData = nil;
        if (model != NULL && error == NULL) {
            // 构建数据源
            wself.sugListData = model.data;
            wself.listController.hasValidateData = YES;
            [wself reloadSugTableView];
        } else {
            wself.listController.hasValidateData = NO;
            [wself reloadSugTableView];
        }
    }];
}

@end
