//
//  FHBaseSugListViewModel+priceValuation.m
//  FHHouseList
//
//  Created by 张静 on 2019/5/6.
//

#import "FHBaseSugListViewModel+priceValuation.h"
#import "FHBaseSugListViewModel+Internal.h"

@implementation FHBaseSugListViewModel (priceValuation)

- (void)requestSuggestion:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query
{
    if (self.sugHttpTask) {
        [self.sugHttpTask cancel];
    }
    self.highlightedText = query;
    __weak typeof(self) wself = self;
    
    self.sugHttpTask = [FHHouseListAPI requestSuggestionOnlyNeiborhoodCityId:cityId houseType:houseType query:query class:[FHSuggestionResponseModel class] completion:^(FHSuggestionResponseModel *  _Nonnull model, NSError * _Nonnull error) {
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
