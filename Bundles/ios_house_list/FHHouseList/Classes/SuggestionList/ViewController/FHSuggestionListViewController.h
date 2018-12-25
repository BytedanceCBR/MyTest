//
//  FHSuggestionListViewController.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import "FHSuggestionItemCell.h"

/* 回跳到上一级页面，回传参数 */
typedef void(^FHSuggestionListReturnBlock)(TTRouteObject *routeObject);

NS_ASSUME_NONNULL_BEGIN

@interface FHSuggestionListViewController : FHBaseViewController

@property (nonatomic, strong)   FHSuggectionTableView       *historyTableView;
@property (nonatomic, strong)   FHSuggectionTableView       *suggestTableView;

- (void)requestDeleteHistory;

@end

NS_ASSUME_NONNULL_END
