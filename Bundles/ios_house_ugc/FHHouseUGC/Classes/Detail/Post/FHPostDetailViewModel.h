//
//  FHPostDetailViewModel.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/3.
//

#import <Foundation/Foundation.h>
#import "FHUGCBaseViewModel.h"
#import "FHPostDetailViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPostDetailViewModel : FHUGCBaseViewModel

-(instancetype)initWithController:(FHPostDetailViewController *)viewController tableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
