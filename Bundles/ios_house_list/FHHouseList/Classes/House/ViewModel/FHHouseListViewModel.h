//
//  FHHouseListViewModel.h
//  FHHouseList
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHBaseHouseListViewModel.h"
#import <FHHouseSuggestionDelegate.h>

@protocol FHMapSearchOpenUrlDelegate;

NS_ASSUME_NONNULL_BEGIN
/*
 * 二手房列表页 viewmodel
 */
@interface FHHouseListViewModel : FHBaseHouseListViewModel <FHHouseSuggestionDelegate>

@property (nonatomic, copy) NSString *houseListOpenUrl;
@property (nonatomic , assign) FHHouseType houseType;

@property(nonatomic , copy) void (^sugSelectBlock)(TTRouteParamObj *paramObj);
@property(nonatomic , copy) void (^houseListOpenUrlUpdateBlock)(TTRouteParamObj *paramObj, BOOL isFromMap);

#pragma mark - log相关
@property(nonatomic , assign) BOOL isEnterCategory; // 是否算enter_category

-(void)addStayCategoryLog:(NSTimeInterval)stayTime;
// findTab过来的houseSearch需要单独处理下埋点数据
-(void)updateHouseSearchDict:(NSDictionary *)houseSearchDic;

@end

NS_ASSUME_NONNULL_END
