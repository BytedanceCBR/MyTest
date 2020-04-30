//
//  TTABHelper.h
//  Article
//
//  Created by ZhangLeonardo on 16/1/27.
//
//

#import <Foundation/Foundation.h>
#import "NSObject+TTAdditions.h"

/**
 *  AB Helper是ABManager和业务之间的辅助类。
 *  ABManager有两个作用:
 *  1.透传ABManager的特殊值，如ABGroup, ABFeature, ABVersion。
 *  2.将ABManager中管理的feature key 翻译成业务层可以理解的值。
 *
 */
@interface TTABHelper : NSObject<Singleton>

/**
 *  如果需要，开始执行迁移
 */
- (void)migrationIfNeed;

/**
 *  开始分配
 */
- (void)distributionIfNeed;

/**
 *  ab group
 *
 *  @return ab group
 */
- (NSString *)ABGroup;
/**
 *  ab feature
 *
 *  @return ab feature
 */
- (NSString *)ABFeature;
/**
 *  ab version
 *
 *  @return ab version
 */
- (NSString *)ABVersion;

/**
 *  设置ab version
 *
 *  @param abVersion abVersion
 */
- (void)saveABVersion:(NSString *)abVersion;

/**
 *  保存服务器下发的修改
 *
 *  @param dict 服务器下发的又该的集合
 */
- (void)saveServerSettings:(NSDictionary *)dict;


#pragma mark -- feature key

/**
 *  返回feature key对应的值
 *
 *  @param featureKey 指定的feature key
 *
 *  @return feature key对应的值
 */
- (NSString *)valueForFeatureKey:(NSString *)featureKey;

#pragma mark -- 业务

/**
 *  清除缓存的文案类型(此type用于测试ABManager的正确性)
 */
typedef NS_ENUM(NSUInteger, TTClearCacheLiteraryType) {
    /**
     *  显示清除
     */
    TTClearCacheLiteraryTypeClear,
    /**
     *  显示清理
     */
    TTClearCacheLiteraryTypeClean,
};

/**
 *  返回“清除缓存”的文案类型
 *
 *  @return “清除缓存”的文案类型
 */
+ (TTClearCacheLiteraryType)clearCacheLiteraryType;

@end
