//
//  TTABMigrationManager.h
//  Article
//
//  Created by ZhangLeonardo on 16/1/27.
//
//
//  在ABManager进行分组之前，可能需要迁移、合并一些历史的数据，这些工作由ABMigrationManger完成

#import <Foundation/Foundation.h>

/**
 *  负责迁移、合并一些历史的数据
 */
@interface TTABMigrationManager : NSObject

/**
 *  如果需要，开始执行迁移
 */
- (void)migrationIfNeed;

@end
