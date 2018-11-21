//
//  FHHomeCellHelper.h
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import <Foundation/Foundation.h>
#import "FHHomeBaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FHHomeCellViewType) {
    FHHomeCellViewTypeEntrances,                   //模块列表入口
    FHHomeCellViewTypeBanner,             //占位
    FHHomeCellViewTypeCityTrend,         //城市行情
};

@interface FHHomeCellHelper : NSObject

 + (instancetype)sharedInstance;


+ (void)registerCells:(UITableView *)tableView;

/**
 * 根据配置数据计算头部高度
 */
+ (CGFloat)heightForFHHomeHeaderCellViewType;

/**
 * 根据配置数据计算头部高度
 */
+ (NSString *)configIdentifier:(JSONModel *)model;

/**
 * 根据类型返回Class
 */
+ (Class)cellClassFromCellViewType:(FHHomeCellViewType)cellType;

/**
 * 根据数据填充cell
 */
+ (void)configureCell:(FHHomeBaseTableCell *)cell withJsonModel:(JSONModel *)model;

@end 

NS_ASSUME_NONNULL_END
