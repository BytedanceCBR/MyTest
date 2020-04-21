//
//  FHAccountBindingViewModel.h
//  FHHouseMine
//
//  Created by luowentao on 2020/4/21.
//

#import <Foundation/Foundation.h>
#import "FHAccountBindingViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHAccountBindingViewModel : NSObject
- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHAccountBindingViewController *)viewController;


- (void)initData;

@end

NS_ASSUME_NONNULL_END
