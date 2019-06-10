//
//  ArticleModelUpdateHelper.h
//  Article
//
//  Created by Zhang Leonardo on 14-7-16.
//
//

#import <Foundation/Foundation.h>

@interface ArticleModelUpdateHelper : NSObject

/**
 *  删除文章数据库文件、订阅数据库文件、判断本次是否是用户升级的安装
 *  该方法需要在每个版本启动的时候调用， 且只能调用一次
 */
+ (void)deleteCoreDataFileIfNeed;

/**
 *  删除不需要的频道数据库文件， 需要在启动的时候调用，
 *  可以调用多次， 所有的版本(第一次安装或者升级后)仅会执行一次内部逻辑
 *  从4.3 版本开始。 4.3 版本之后暂定升级不再删除频道数据库。
 *
 *  @return YES:需要处理，并且删除了。 NO：不需要处理，没有做任何操作
 */

+ (BOOL)deleteCategoryCoreDataFilesIfNeed;

/**
 *  清除旧(4.3之前，不包括4.3)频道数据库存在userdefault中的信息。
 *  该信息仅用于旧版本数据库到新版本数据库的迁移使用， 迁移完成后，则清楚该信息。
 */
+ (void)clearOldCategoryModelUserDefaultInfo;

/**
 *  讲存储的用于迁移的频道数据库的categoryID排序后的返回
 *
 *  @return categoryID排序后的结果
 */
+ (NSArray *)categoryIDsForSavedOldCategoryModel;

//+ (BOOL)needDealCategoryModelMigration;
//
///**
//    查询指定的categoryID是以前被订阅的顺序， 如果没有被订阅，返回-1
// */
//+ (NSInteger)ordexIndexForCategoryIDInOldDB:(NSString *)categoryID;

/**
 *  删除废弃的广告过期plist文件
 */
+ (void)deleteADExpirePlist;

@end
