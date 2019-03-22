//
//  FHSugSubscribeListViewModel.h
//  FHHouseList
//
//  Created by 张元科 on 2019/3/19.
//

#import <Foundation/Foundation.h>
#import "FHHouseListAPI.h"
#import "FHSuggestionListModel.h"
#import "FHSugSubscribeModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHSugSubscribeListViewController;

@protocol FHSugSubscribeListDelegate <NSObject>

@optional
- (void)cellSubscribeItemClick:(FHSugSubscribeDataDataItemsModel *)model;

@end

@interface FHSugSubscribeListViewModel : NSObject

-(instancetype)initWithController:(FHSugSubscribeListViewController *)viewController tableView:(UITableView *)tableView;
- (void)requestSugSubscribe:(NSInteger)cityId houseType:(NSInteger)houseType;

@end

NS_ASSUME_NONNULL_END
