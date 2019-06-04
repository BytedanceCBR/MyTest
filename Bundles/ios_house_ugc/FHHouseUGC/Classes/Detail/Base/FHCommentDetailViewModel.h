//
//  FHCommentDetailViewModel.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/3.
//

#import <Foundation/Foundation.h>
#import "FHUGCBaseViewModel.h"
#import "FHCommentDetailViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommentDetailViewModel : FHUGCBaseViewModel

-(instancetype)initWithController:(FHCommentDetailViewController *)viewController tableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
