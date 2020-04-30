//
//  TTABLayer.h
//  ABTest
//
//  Created by ZhangLeonardo on 16/1/20.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTABDefine.h"

extern const NSInteger kTTABTestMaxRegion;

extern const NSString * kTTABDefaultGroupName;

#pragma mark -- TTABLayerExperiment


/**
 *  层中的实验
 */
@interface TTABLayerExperiment : NSObject

/**
 *  如果命中该实验，对应的group的名字
 */
@property(nonatomic, strong, readonly)NSString * groupName;

/**
 *  该实验取值区间的左区间（包含）
 */
@property(nonatomic, assign, readonly)NSInteger minRegion;

/**
 *  该实验取值区间的右区间（包含）
 */
@property(nonatomic, assign, readonly)NSInteger maxRegion;

/**
 *  命中该实验后，需要去修改的“功能”的集合
 */
@property(nonatomic, strong, readonly)NSDictionary * results;

/**
 *  初始化一个实验
 *
 *  @param dict 初始化实验需要的字典信息
 *
 *  @return 实验的实例
 */
- (id)initWithDict:(NSDictionary *)dict;

@end

#pragma mark -- TTABLayer

/**
 *  客户端AB测试框架，“层”的类。
 *  “层”有两个作用：
 *  1.使正交的实验相互隔离
 *  2.同一层内相互影响的实验不会同时进入测试组。
 *
 *  同一个“层”中会与多个“实验”，每个“实验”都是多个小“功能”的组合，ABManager最终确保的是组合的比例分配符合预期。
 *  处于简化的目的，只在“层”的级别提供“过滤器”的概念，不在“实验”级别提供“过滤器”，如果该“层”未通过过滤器，则该层的实验全都不进行。
 */
@interface TTABLayer : NSObject
/**
 *  层的名字
 */
@property(nonatomic, strong, readonly)NSString * layerName;
/**
 *  层的条件， key,value 目前都是string
 */
@property(nonatomic, strong, readonly)NSDictionary * filters;

/**
 *  该层的所有实验
 */
@property(nonatomic, strong, readonly)NSArray<TTABLayerExperiment *> * experiments;

/**
 *  初始化层对象
 *
 *  @param dict 初始化层对象需要的字典内容
 *
 *  @return 实例化的层对象
 */
- (id)initWithDict:(NSDictionary *)dict;

/**
 *  给定随机数，返回随机数对应的实验
 *
 *  @param randomValue 随机数
 *
 *  @return 随机数对应的实验
 */
- (TTABLayerExperiment *)experimentForRandomValue:(NSInteger)randomValue;

@end
