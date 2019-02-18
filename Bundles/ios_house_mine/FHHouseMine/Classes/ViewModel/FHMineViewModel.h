//
//  FHMineViewModel.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import <Foundation/Foundation.h>
#import "FHMineViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMineViewModel : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHMineViewController *)viewController;

- (void)requestData;

- (void)showInfo;

- (void)updateHeaderView;
//-(void)addEnterUserProfileLog;

@end

NS_ASSUME_NONNULL_END
