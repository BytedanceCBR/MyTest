//
//  TTSettingMineTabManager.h
//  Article
//
//  Created by Dianwei on 14-9-26.
//
//

#import <Foundation/Foundation.h>
#import "TTSettingMineTabEntry.h"

#define kTTSettingMineTabManagerRefreshedNotification @"kTTSettingMineTabManagerRefreshedNotification"

@class TTSettingMineTabGroup;

@interface TTSettingMineTabManager : NSObject<Singleton>

@property (nonatomic, strong, readonly) NSArray<TTSettingMineTabGroup *> *visibleSections;
@property (nonatomic, assign, readonly) BOOL hadDisplayedADRegisterEntrance;

/**
 *  拉取服务端配置，时机：启动后，切换账号时，后台切前台
 */
- (void)startGetMineTabConfiguration;
/**
 *  持久化配置信息
 */
- (void)saveMineTabGroups;
/**
 *  关于UI展现的数据源是否发生变化，如果任意一条entry的数据源发生了变化，则需要刷新外部视图
 *
 *  @return 是否需要reload tableView
 */
- (BOOL)reloadSectionsIfNeeded;
/**
 *  额外的配置信息默认只在服务端下发后更新，如果需要手动更新，调用此方法
 */
- (void)buildExtraMineTabGroups;
/**
 *  获取某个type的cell对应的数据源，一般用于本地控制的cell
 *
 *  @param type     想要取到某条数据源的type
 *
 *  @return 某条枚举对应的数据源entry
 */
- (TTSettingMineTabEntry *)getEntryForType:(TTSettingMineTabEntyType)type;
/**
 *  将某个type和其对应的entry缓存在字典中，以便方便的查询
 *
 *  @param entry    某条数据源
 *  @param type     某条数据源的type
 *
 *  @return 某条枚举对应的数据源entry
 */
- (void)setEntry:(TTSettingMineTabEntry *)entry ForType:(TTSettingMineTabEntyType)type;

/**
 *  根据settings接口下发的开关刷新私信入口
 *
 */

- (void)refreshPrivateLetterEntry:(BOOL)enabled;


/**
 更新一下visibleSections
 */
- (void)rebuildshVisibleSections;

@end
