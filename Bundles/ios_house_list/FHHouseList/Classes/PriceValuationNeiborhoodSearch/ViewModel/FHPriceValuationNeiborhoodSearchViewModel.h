//
//  FHPriceValuationNeiborhoodSearchViewModel.h
//  FHHouseList
//
//  Created by 张元科 on 2019/3/27.
//

#import <Foundation/Foundation.h>
#import "FHHouseListAPI.h"
#import "FHSuggestionListModel.h"
#import "FHPriceValuationNeiborhoodSearchController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPriceValuationNeiborhoodSearchViewModel : NSObject

-(instancetype)initWithController:(FHPriceValuationNeiborhoodSearchController *)viewController;

- (void)clearSugTableView;
- (void)requestSuggestion:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query;

@end

NS_ASSUME_NONNULL_END
