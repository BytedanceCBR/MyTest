//
//  FHHouseListViewModel.h
//  FHHouseList
//
//  Created by 春晖 on 2018/12/6.
//

#import "FHBaseHouseListViewModel.h"
#import <FHHouseSuggestionDelegate.h>

typedef enum : NSUInteger {
    FHHouseListSearchTypeDefault = 0,
    FHHouseListSearchTypeNeighborhoodDeal, // 查成交
} FHHouseListSearchType;

@protocol FHMapSearchOpenUrlDelegate;

NS_ASSUME_NONNULL_BEGIN
/*
 * 列表页 viewmodel
 */

@class FHMainOldTopTagsView;
@class FHHouseListCommuteTipView;
@class FHFakeInputNavbar;
@interface FHHouseListViewModel : FHBaseHouseListViewModel <FHHouseSuggestionDelegate>

@property (nonatomic , copy) NSString *houseListOpenUrl;
@property (nonatomic , copy) NSString *searchPageOpenUrl;
@property (nonatomic , assign) FHHouseType houseType;
@property (nonatomic , assign) FHHouseListSearchType searchType;

@property (nonatomic , weak) UIViewController *listVC;

@property (nonatomic , copy) void (^sugSelectBlock)(TTRouteParamObj *paramObj);
@property (nonatomic , copy) void (^houseListOpenUrlUpdateBlock)(TTRouteParamObj *paramObj, BOOL isFromMap);

@property (nonatomic , copy) void (^commuteSugSelectBlock)(NSString *poi);

@property (nonatomic , assign) BOOL isEnterCategory; // 是否算enter_category
@property (nonatomic , assign) BOOL fromFindTab;

//通勤找房
@property (nonatomic , assign, getter=isCommute) BOOL commute; //是否是通勤找房
@property (nonatomic , copy) NSString *commutePoi;//用户进入sug选择后显示的内容
@property (nonatomic , strong) FHHouseListCommuteTipView *commuteTipView;

#pragma mark - log相关
-(void)addStayCategoryLog:(NSTimeInterval)stayTime;
// findTab过来的houseSearch需要单独处理下埋点数据
-(void)updateHouseSearchDict:(NSDictionary *)houseSearchDic;
-(NSDictionary *)categoryLogDict;
- (void)addClickHouseSearchLog;

//通勤找房 点击 修改、收起 埋点
-(void)addModifyCommuteLog:(BOOL)showOrHide;

-(void)commuteFilterUpdated;

- (void)addNotiWithNaviBar:(FHFakeInputNavbar *)naviBar;

- (void)refreshMessageDot;

+ (NSInteger)searchOffsetByhouseModel:(JSONModel *)houseModel;

- (void)setTopTagsView:(FHMainOldTopTagsView *)topTagsView;
- (void)addTagsViewClick:(NSString *)value_id;

@end

NS_ASSUME_NONNULL_END
