//
//  FHSugSubscribeListViewController.h
//  FHHouseList
//
//  Created by 张元科 on 2019/3/19.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import "FHSuggestionListNavBar.h"
#import "UIViewController+Track.h"
#import "FHHouseType.h"
#import "FHSugSubscribeListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHSugSubscribeListViewController : FHBaseViewController

@property (nonatomic, assign) FHHouseType houseType;

- (void)cellSubscribeItemClick:(FHSugSubscribeDataDataItemsModel *)model;

@end

NS_ASSUME_NONNULL_END
