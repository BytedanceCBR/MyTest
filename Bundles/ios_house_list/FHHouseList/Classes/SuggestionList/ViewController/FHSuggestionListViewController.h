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
#import "FHSuggestionListNavBar.h"

typedef enum : NSUInteger {
    FHEnterSuggestionTypeDefault       =   0,// H5
    FHEnterSuggestionTypeHome       =   1,// 首页
    FHEnterSuggestionTypeFindTab       =   2,// 找房Tab
    FHEnterSuggestionTypeList       =   3, // 列表页
    FHEnterSuggestionTypeRenting       =   4,// 租房大类页
    FHEnterSuggestionTypeOldMain       =   5,// 二手房大类页
} FHEnterSuggestionType;

// 特别说明：目前只有房源列表页和找房Tab列表页 需要pop back和回传数据need_back_vc

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
 @"need_back_vc":vc
 };
 TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
 
 NSURL *url = [NSURL URLWithString:@"sslocal://house_search"];
 [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
 */
@interface FHSuggestionListViewController : FHBaseViewController

@property (nonatomic, strong)   FHSuggectionTableView       *historyTableView;
@property (nonatomic, strong)   FHSuggectionTableView       *suggestTableView;

@property (nonatomic, strong)     FHSuggestionListNavBar     *naviBar;

- (void)requestDeleteHistory;

- (void)jumpToCategoryListVCByUrl:(NSString *)jumpUrl queryText:(NSString *)queryText placeholder:(NSString *)placeholder infoDict:(NSDictionary *)infos;

@end

NS_ASSUME_NONNULL_END
