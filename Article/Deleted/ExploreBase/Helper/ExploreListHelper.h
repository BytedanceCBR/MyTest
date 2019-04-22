//
//  ExploreListHelper.h
//  Article
//
//  Created by Zhang Leonardo on 14-9-4.
//
//

#import <Foundation/Foundation.h>
#import "ExploreOrderedData+TTBusiness.h"
#import <TTUserSettings/TTUserSettingsHeader.h>
#import "ListDataHeader.h"

#define kPadWidth   704

@interface ExploreListHelper : NSObject

+ (BOOL)supportForCellType:(ExploreOrderedDataCellType)cellType;

/**
 *  排序
 *
 *  @param array     需要排序的列表
 *  @param Ascending YES：升序 ; NO：降序
 *
 *  @return 排完序的列表
 */
+ (NSArray *)sortByIndexForArray:(NSArray *)array orderedAscending:(BOOL)ascending;

/**
 *  排序
 *
 *  @param array    需要排序的列表
 *  @param listType 根据列表类型，选择升序还是降序
 *
 *  @return 排完序的列表
 */
+ (NSArray *)sortByIndexForArray:(NSArray *)array listType:(ExploreOrderedDataListType)listType;


/**
 *  过滤非收藏的列表, 多虑只对ordered data 生效
 *
 *  @param array 原列表
 *
 *  @return 返回均是收藏状态的列表
 */
+ (NSArray *)filterFavoriteItems:(NSArray *)orderedDatas;


#pragma mark -- 预加载条数
+ (NSUInteger)countForPreloadCell;
+ (void)setPreloadCount:(NSUInteger)count userSettingStatus:(TTNetworkTrafficSetting)setting;


+ (void)trackEventForLabel:(NSString *)label listType:(ExploreOrderedDataListType)listType categoryID:(NSString *)categoryID concernID:(NSString *)concernID refer:(NSUInteger)refer;

+ (NSString *)refreshTypeStrForReloadFromType:(ListDataOperationReloadFromType)refreshFromType;

@end
