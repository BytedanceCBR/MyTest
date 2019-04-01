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
 * 列表页 viewmodel
 */

@class FHHouseListRedirectTipView;
@class FHHouseListCommuteTipView;
@interface FHHouseListViewModel : FHBaseHouseListViewModel <FHHouseSuggestionDelegate>

@property (nonatomic , copy) NSString *houseListOpenUrl;
@property (nonatomic , assign) FHHouseType houseType;

@property (nonatomic , weak) UIViewController *listVC;

@property (nonatomic , copy) void (^sugSelectBlock)(TTRouteParamObj *paramObj);
@property (nonatomic , copy) void (^houseListOpenUrlUpdateBlock)(TTRouteParamObj *paramObj, BOOL isFromMap);

@property (nonatomic , copy) void (^commuteSugSelectBlock)(NSString *poi);

@property (nonatomic , assign) BOOL isEnterCategory; // 是否算enter_category
@property (nonatomic , assign) BOOL showRedirectTip;
@property (nonatomic , assign) BOOL fromFindTab;

//通勤找房
@property (nonatomic , assign, getter=isCommute) BOOL commute; //是否是通勤找房
@property (nonatomic , strong) FHHouseListCommuteTipView *commuteTipView;

-(void)setRedirectTipView:(FHHouseListRedirectTipView *)redirectTipView;

#pragma mark - log相关
-(void)addStayCategoryLog:(NSTimeInterval)stayTime;
// findTab过来的houseSearch需要单独处理下埋点数据
-(void)updateHouseSearchDict:(NSDictionary *)houseSearchDic;
-(NSDictionary *)categoryLogDict;
- (void)addClickHouseSearchLog;

@end

NS_ASSUME_NONNULL_END
