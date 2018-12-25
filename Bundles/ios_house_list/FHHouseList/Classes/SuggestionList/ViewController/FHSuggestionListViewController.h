//
//  FHSuggestionListViewController.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import "FHSuggestionItemCell.h"
#import "FHHouseSuggestionDelegate.h"

typedef enum : NSUInteger {
    FHEnterSuggestionTypeHome       =   1,
    FHEnterSuggestionTypeFindTab       =   2,
    FHEnterSuggestionTypeList       =   3,
    FHEnterSuggestionTypeRenting       =   4,
} FHEnterSuggestionType;

NS_ASSUME_NONNULL_BEGIN

/*
 route跳转方式：不需要回传数据可以不带sug_delegate
 
 NSHashTable *sugDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
 [sugDelegateTable addObject:self];
 NSDictionary *dict = @{@"house_type":@(FHHouseTypeRentHouse) ,
 @"tracer": traceParam,
 @"from_home":@(4),
 @"sug_delegate":sugDelegateTable,
 @"homepage_roll_data":test,
 };
 TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
 
 NSURL *url = [NSURL URLWithString:@"sslocal://sug_list"];
 [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
 */
@interface FHSuggestionListViewController : FHBaseViewController

@property (nonatomic, strong)   FHSuggectionTableView       *historyTableView;
@property (nonatomic, strong)   FHSuggectionTableView       *suggestTableView;

- (void)requestDeleteHistory;

@end

NS_ASSUME_NONNULL_END
