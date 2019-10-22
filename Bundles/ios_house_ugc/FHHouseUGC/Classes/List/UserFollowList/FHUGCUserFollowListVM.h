//
//  FHUGCUserFollowListVM.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/10/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FHUGCUserFollowListController;
// 用户列表的VM
@interface FHUGCUserFollowListVM : NSObject

- (instancetype)initWithController:(FHUGCUserFollowListController *)viewController tableView:(UITableView *)tableView;
@property (nonatomic, copy)     NSString       *socialGroupId;
- (void)requestUserList;

@end

NS_ASSUME_NONNULL_END
