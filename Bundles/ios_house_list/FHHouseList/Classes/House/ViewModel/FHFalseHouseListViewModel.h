//
//  FHFalseHouseListViewModel.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/5/30.
//

#import <Foundation/Foundation.h>
#import "TTRouteDefine.h"
#import "FHHouseFindRecommendModel.h"

@class FHFalseHouseListViewController;

NS_ASSUME_NONNULL_BEGIN

@interface FHFalseHouseListViewModel : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView viewController:(FHFalseHouseListViewController *)viewController routeParam:(TTRouteParamObj *)paramObj;

-(void)addStayCategoryLog:(NSTimeInterval)stayTime;

@end

NS_ASSUME_NONNULL_END
