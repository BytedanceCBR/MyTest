//
//  FHHouseFindResultViewModel.h
//  FHHouseFind
//
//  Created by 张静 on 2019/3/25.
//

#import <Foundation/Foundation.h>
#import <TTRouteDefine.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseFindResultViewModel : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView routeParam:(TTRouteParamObj *)paramObj;

@end

NS_ASSUME_NONNULL_END
