//
//  TTABStorageManager.h
//  ABTest
//
//  Created by ZhangLeonardo on 16/1/24.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//
//  负责ABManager相关需要存储的操作

#import <Foundation/Foundation.h>

/**
 *  负责ABManager相关需要存储的操作
 */
@interface TTABStorageManager : NSObject

/**
 *  是否是脏数据
 */
@property(nonatomic, assign)BOOL dirtyData;

#pragma mark -- Feature Key

/**
 *  指定的feature key 对应的值
 *
 *  @param key 指定的feature key
 *
 *  @return feature key 对应的值
 */
- (NSString *)valueForFeatureKey:(NSString *)key;

/**
 *  存储key与对应的value
 *
 *  @param value feature key 对应的value
 *  @param key   feature key
 */
- (void)setValue:(NSString *)value forFeatureKey:(NSString *)key;

/**
 *  批量更新key value
 *
 *  @param keyValues key: feture key， value:feture value
 */
- (void)batchSetKeyValues:(NSDictionary *)keyValues;


#pragma mark -- ABGroups 

/**
 *  返回当前版本的ABGroups
 *
 *  @return ABGroups
 */
+ (NSString *)currentSavedABGroups;

/**
 *  查看当前版本的ABGroups是否被分配过
 *
 *  @return 当前版本的ABGroups是否被分配过
 */
+ (BOOL)isABGroupAllocationed;

/**
 *  存储当前版本计算的ABGroups
 *
 *  @param abGroups 当前版本的ABGroups
 */
+ (void)saveCurrentVersionABGroups:(NSString *)abGroups;

#pragma mark -- Random Number

/**
 *  查找随机数字典（层名字与随机数的对应关系表）
 *
 *  @return 查找随机数字典
 */
+ (NSDictionary *)randomNumber;

/**
 *  存储随机数字典
 *
 *  @param dict （层名字与随机数的对应关系表）
 */
+ (void)saveRandomNumberDicts:(NSDictionary *)dict;

#pragma mark -- ABVersion

/**
 *  存储ABVersion
 *
 *  @param ABVersion ABVersion
 */
+ (void)saveABVersion:(NSString *)ABVersion;

/**
 *  返回ABVersion
 *
 *  @return ABVersion
 */
+ (NSString *)ABVersion;

#pragma mark -- app version

/**
 *  第一次安装应用的版本号
 *
 *  @return 第一次安装应用的版本号
 */
+ (NSString *)firstInstallVersionStr;

#pragma mark -- executed experiment group names
/**
 *  存储执行过的实验的group name的集合
 *
 *  @param groupNames 执行过的实验的group name的集合
 */
+ (void)saveExecutedExperimentGroupNames:(NSDictionary *)groupNames;

/**
 *  执行过的实验的group name的集合
 *
 *  @return 执行过的实验的group name的集合
 */
+ (NSDictionary *)executedExperimentGroupNames;

@end
