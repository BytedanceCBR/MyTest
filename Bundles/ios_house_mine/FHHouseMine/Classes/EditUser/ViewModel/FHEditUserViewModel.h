//
//  FHEditUserViewModel.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/5/20.
//

#import <Foundation/Foundation.h>
#import "FHEditUserController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHEditUserViewModel : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHEditUserController *)viewController;

@end

NS_ASSUME_NONNULL_END
