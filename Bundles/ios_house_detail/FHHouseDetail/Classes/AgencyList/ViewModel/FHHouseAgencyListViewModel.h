//
//  FHHouseAgencyListViewModel.h
//  FHHouseDetail
//
//  Created by 张静 on 2019/5/5.
//

#import <Foundation/Foundation.h>
#import "TTRoute.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseAgencyListViewModel : NSObject

@property(nonatomic, weak) UIViewController *viewController;
- (instancetype)initWithTableView:(UITableView *)tableView paramObj:(TTRouteParamObj *)paramObj;
- (void)confirmAction;

@end

NS_ASSUME_NONNULL_END
