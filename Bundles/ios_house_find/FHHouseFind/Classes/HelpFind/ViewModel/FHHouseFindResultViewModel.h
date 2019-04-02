//
//  FHHouseFindResultViewModel.h
//  FHHouseFind
//
//  Created by 张静 on 2019/3/25.
//

#import <Foundation/Foundation.h>
#import <TTRouteDefine.h>
#import "FHHouseFindRecommendModel.h"

@class FHHouseFindResultViewController;

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFindResultViewModel : NSObject

@property (nonatomic , strong) FHHouseFindRecommendDataModel *recommendModel;
- (instancetype)initWithTableView:(UITableView *)tableView viewController:(FHHouseFindResultViewController *)viewController routeParam:(TTRouteParamObj *)paramObj;

@end

NS_ASSUME_NONNULL_END
