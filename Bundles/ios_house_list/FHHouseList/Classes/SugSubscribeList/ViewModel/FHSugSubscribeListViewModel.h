//
//  FHSugSubscribeListViewModel.h
//  FHHouseList
//
//  Created by 张元科 on 2019/3/19.
//

#import <Foundation/Foundation.h>
#import "FHSugSubscribeListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHSugSubscribeListViewModel : NSObject

-(instancetype)initWithController:(FHSugSubscribeListViewController *)viewController tableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
