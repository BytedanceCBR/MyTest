//
//  FHHomePageSettingViewModel.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/10/16.
//

#import <Foundation/Foundation.h>
#import "FHHomePageSettingController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHomePageSettingViewModel : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHHomePageSettingController *)viewController;

- (void)loadData;

@end

NS_ASSUME_NONNULL_END