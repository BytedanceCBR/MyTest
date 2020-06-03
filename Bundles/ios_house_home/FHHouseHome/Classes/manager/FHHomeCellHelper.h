//
//  FHHomeCellHelper.h
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import <Foundation/Foundation.h>
#import "FHHomeBaseTableCell.h"
#import "FHHomeTableViewDelegate.h"
#import "FHHomeConfigManager.h"
#import "FHHomeScrollBannerCell.h"
#import "FHHouseType.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FHHomeCellViewType) {
    FHHomeCellViewTypeEntrances,                   //模块列表入口
    FHHomeCellViewTypeBanner,             //占位
    FHHomeCellViewTypeCityTrend,         //城市行情
};

//#define kFHHomeIconDefaultHeight 42.0 //icon高度

#define kFHHomeBannerDefaultHeight 60.0 //banner高度

#define kFHHomeHouseItemHeight 88.0 //banner高度

//#define kFHHomeIconRowCount 5 //每行icon个数

#define kFHHomeBannerRowCount 2 //每行banner个数
#define kFHHomeAgentCardType 6 //经纪人卡片类型

@class FHHomeEntrancesCell;

@interface FHHomeCellHelper : NSObject

@property(nonatomic , assign) FHHomeHeaderCellPositionType headerType;
@property (nonatomic, assign)   BOOL       isFirstLanuch;// 是否是第一次
@property (nonatomic, weak)   FHHomeScrollBannerCell       *fhLastHomeScrollBannerCell;
@property (nonatomic, assign) CGFloat kFHHomeIconDefaultHeight;
@property (nonatomic, assign) NSInteger kFHHomeIconRowCount;

 + (instancetype)sharedInstance;


+ (void)registerCells:(UITableView *)tableView;

/**
 * 根据配置代理
 */
+ (void)registerDelegate:(UITableView *)tableView andDelegate:(id)delegate;


/**
 * 根据配置数据计算头部高度
 */
- (CGFloat)heightForFHHomeHeaderCellViewType;


/**
 * 根据首页房源列表高度
 */
- (CGFloat)heightForFHHomeListHouseSectionHeight;

/**
 * 根据配置数据计算头部计算策略
 */
- (CGFloat)initFHHomeHeaderIconCountAndHeight;

/**
 * 根据配置数据计算头部高度
 */
+ (NSString *)configIdentifier:(JSONModel *)model;


/**
 * 根据类型返回Class
 */
+ (Class)cellClassFromCellViewType:(FHHomeCellViewType)cellType;

/**
 * 根据数据填充头部cell
 */
+ (void)configureCell:(FHHomeBaseTableCell *)cell withJsonModel:(JSONModel *)model;

/**
 * 根据数据填充首页列表cell
 */
+ (void)configureHomeListCell:(FHHomeBaseTableCell *)cell withJsonModel:(JSONModel *)model;

/**
 * cell点击route跳转
 */
- (void)openRouteUrl:(NSString *)url andParams:(NSDictionary *)param;


/**
 * 刷新数据
 */
- (void)refreshFHHomeTableUI:(UITableView *)tableView andType:(FHHomeHeaderCellPositionType)type;

/**
 * 处理cell展示的埋点
 */
+ (void)handleCellShowLogWithModel:(JSONModel *)model;

/**
 * 清空showcache
 */
- (void)clearShowCache;

/**
 * 上报新样式埋点
 */
+ (void)sendBannerTypeCellShowTrace:(FHHouseType)houseType;


//匹配房源名称
+ (NSArray <NSString *>*)matchHouseSegmentedTitleArray;


+ (void)fillFHHomeEntrancesCell:(FHHomeEntrancesCell *)cell withModel:(FHConfigDataOpDataModel *)model withTraceParams:(NSDictionary *)traceParams;

@end 

NS_ASSUME_NONNULL_END
