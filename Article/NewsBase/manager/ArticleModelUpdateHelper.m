//
//  ArticleModelUpdateHelper.m
//  Article
//
//  Created by Zhang Leonardo on 14-7-16.
//
//

#import "ArticleModelUpdateHelper.h"
#import <sqlite3.h>

#import "TTArticleCategoryManager.h"
#import "TTProjectLogicManager.h"
#import "TTCategory.h"
#import "TTVideoCategory.h"
#import "ExploreEntry.h"
#import "ExploreOrderedData+TTBusiness.h"

//用于升级时候， 迁移频道数据库使用，存储老数据库中的频道订阅状态和Index。迁移完后，会清楚该key对应的值
#define kOldCategoryModelInfoUserDefaultKey @"kOldCategoryModelInfoUserDefaultKey"

@implementation ArticleModelUpdateHelper

#pragma mark -- public
+ (void)deleteCoreDataFileIfNeed
{
    BOOL isUpgradeUser = NO;
    
    //删除文章数据库, 尝试删除3.6版本的文章数据库
    NSString *fileName = @"news36.sqlite";//3.6版本遗留，不要删除这行
    isUpgradeUser = isUpgradeUser || [self deleteDataBaseForFileName:fileName fileInDocumentDirectory:NO];
    
    //删除文章数据库, 尝试删除（除3.6版本的）文章数据库
    fileName = @"news.sqlite";
    isUpgradeUser = isUpgradeUser || [self deleteDataBaseForFileName:fileName fileInDocumentDirectory:NO];
    
    //判断频道数据库是否存在，用来判断用户是升级还是直接安装的。
    //判断3.6版本的频道数据库是否存在
    fileName = @"other36.sqlite";
    isUpgradeUser = isUpgradeUser || [self dataBaseFileExistForFileName:fileName fileInDocumentDirectory:YES];
    
    //判断4.3 之前，（不包括3.6）版本的频道数据库。
    fileName = @"other.sqlite";
    isUpgradeUser = isUpgradeUser || [self dataBaseFileExistForFileName:fileName fileInDocumentDirectory:YES];

    //判断更早的版本， 频道数据库位于cache目录下的
    fileName = @"other.sqlite";
    isUpgradeUser = isUpgradeUser || [self dataBaseFileExistForFileName:fileName fileInDocumentDirectory:NO];
    
    //4.3开始，判断频道数据库是否存在
    fileName = @"news_category.sqlite";
    isUpgradeUser = isUpgradeUser || [self dataBaseFileExistForFileName:fileName fileInDocumentDirectory:YES];
    
    //5.7开始，频道数据库为两个
    fileName = @"video_category.sqlite";
    isUpgradeUser = isUpgradeUser || [self dataBaseFileExistForFileName:fileName fileInDocumentDirectory:YES];
    
    // 频道数据库从CoreData改为FMDB
    fileName = [NSString stringWithFormat:@"%@.db", [TTCategory dbName]];
    isUpgradeUser = isUpgradeUser || [self dataBaseFileExistForFileName:fileName fileInDocumentDirectory:YES];
    
    fileName = [NSString stringWithFormat:@"%@.db", [TTVideoCategory dbName]];
    isUpgradeUser = isUpgradeUser || [self dataBaseFileExistForFileName:fileName fileInDocumentDirectory:YES];
    
    fileName = [NSString stringWithFormat:@"%@.db", [ExploreEntry dbName]];
    isUpgradeUser = isUpgradeUser || [self dataBaseFileExistForFileName:fileName fileInDocumentDirectory:YES];
    
    //删除4.3开始新增的订阅数据库
    fileName = @"explore_entry.sqlite";
    BOOL exist = [self deleteDataBaseForFileName:fileName fileInDocumentDirectory:YES];
    isUpgradeUser = isUpgradeUser || exist;
    
    //保存是否是升级的用户状态
    [ExploreLogicSetting setIsUpgradeUser:isUpgradeUser];    
}

+ (void)deleteADExpirePlist {
    NSString *fileName = @"STPreferences/TTADExpire.plist";
    [self deleteDataBaseForFileName:fileName fileInDocumentDirectory:YES];
}

+ (BOOL)deleteCategoryCoreDataFilesIfNeed
{
    //4.3版本为目前最后一次频道迁移的版本
    NSString * key = @"kDeleteCategoryCoreDataFilesIfNeedKey430";
    BOOL hasDealed = [[[NSUserDefaults standardUserDefaults] objectForKey:key] boolValue];
    if (hasDealed) {
        return NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //处理频道数据库迁移
    [self saveCategorySubscribedsAndRemoveOldCategoryDB];
    return YES;
}

//+ (BOOL)needDealCategoryModelMigration
//{
//    NSDictionary * dict = [[NSUserDefaults standardUserDefaults] objectForKey:kOldCategoryModelInfoUserDefaultKey];
//    return [dict count] > 0;
//}
//
//+ (NSInteger)ordexIndexForCategoryIDInOldDB:(NSString *)categoryID
//{
//    NSDictionary * dict = [[NSUserDefaults standardUserDefaults] objectForKey:kOldCategoryModelInfoUserDefaultKey];
//    NSNumber * index = [dict objectForKey:categoryID];
//    if (index == nil) {
//        return -1;
//    }
//    return [index intValue];
//}

/**
 *  将存储的用于迁移的频道数据库的categoryID排序后的返回
 *
 *  @return categoryID排序后的结果
 */
+ (NSArray *)categoryIDsForSavedOldCategoryModel
{
    NSDictionary * dict = [[NSUserDefaults standardUserDefaults] objectForKey:kOldCategoryModelInfoUserDefaultKey];
    NSMutableArray * categoryDicts = [NSMutableArray arrayWithCapacity:10];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSNumber * index, BOOL *stop) {
        if (key && index) {
            NSDictionary * categoryDict = @{key : index};
            [categoryDicts addObject:categoryDict];
        }
    }];
    
    NSArray * sortedCategoryDicts = [categoryDicts sortedArrayUsingComparator:^NSComparisonResult(NSDictionary * obj1, NSDictionary * obj2) {
        
        int obj1Index = [[[obj1 allValues] firstObject] intValue];
        int obj2Index = [[[obj2 allValues] firstObject] intValue];
        if (obj1Index < obj2Index) {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedDescending;
        }
    }];
    NSMutableArray * categoryIds = [NSMutableArray arrayWithCapacity:10];
    [sortedCategoryDicts enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL *stop) {
        if ([[obj allKeys] firstObject]) {
            [categoryIds addObject:[[obj allKeys] firstObject]];
        }
    }];
    return categoryIds;
}

+ (void)clearOldCategoryModelUserDefaultInfo
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kOldCategoryModelInfoUserDefaultKey]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kOldCategoryModelInfoUserDefaultKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


#pragma mark -- private

/**
 *  存储老(4.3版本之前的,不包括4.3)频道数据库中的订阅频道的name 和index。
 *
 *  @param dict dict的key为categoryID,value为index
 */
+ (void)saveOldCategoryModelInfo:(NSDictionary *)dict
{
    if ([dict count] == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kOldCategoryModelInfoUserDefaultKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setValue:dict forKey:kOldCategoryModelInfoUserDefaultKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  保存之前版本订阅的频道，并且删除以前的数据库
 */
+ (void)saveCategorySubscribedsAndRemoveOldCategoryDB
{
    NSMutableDictionary * originalSubscribedCategory = [NSMutableDictionary dictionaryWithCapacity:10];
    
    //位于document中的频道数据
    NSString * pathString = [self pathForDataBaseFileName:@"other.sqlite" fileInDocumentDirectory:YES];

    if (isEmptyString(pathString)) {
        //3.6版本频道数据库的位置
        pathString = [self pathForDataBaseFileName:@"other36.sqlite" fileInDocumentDirectory:YES];
    }
    
    if (isEmptyString(pathString)) {
        //位于cache中的频道数据
        pathString = [self pathForDataBaseFileName:@"other.sqlite" fileInDocumentDirectory:NO];
    }
    
    sqlite3 * originalDB = nil;
    
    if (!isEmptyString(pathString)) {
        @try {
            int result = sqlite3_open([pathString fileSystemRepresentation], &originalDB);
            if (result == SQLITE_OK) {
                NSString *query = @"SELECT ZORDERINDEX, ZCATEGORYID FROM ZCATEGORY WHERE ZSUBSCRIBED = 1 AND ZDELETED != 1 ORDER BY ZORDERINDEX";
                sqlite3_stmt *statement;
                int result = sqlite3_prepare(originalDB, [query UTF8String], -1, &statement, 0);
                if (result == SQLITE_OK) {
                    while (sqlite3_step(statement) == SQLITE_ROW) {
                        int orderIndex = sqlite3_column_int(statement, 0);
                        char * categoryIDChar = (char *)sqlite3_column_text(statement, 1);
                        NSString *categoryIDStr = [[NSString alloc] initWithUTF8String:categoryIDChar];
                        
                        [originalSubscribedCategory setValue:@(orderIndex) forKey:categoryIDStr];
                        
                    }
                    sqlite3_finalize(statement);
                }
                sqlite3_close(originalDB);
            }
        }
        @catch (NSException *exception) {
            NSLog(@"category data migration file");
        }
        @finally {
            
        }
    }
    
    [self saveOldCategoryModelInfo:originalSubscribedCategory];
    
    
    //删除document中数据库
    [self deleteDataBaseForFileName:@"other.sqlite" fileInDocumentDirectory:YES];
    //删除cache中数据库
    [self deleteDataBaseForFileName:@"other.sqlite" fileInDocumentDirectory:NO];
    //删除3.6遗留的数据库
    [self deleteDataBaseForFileName:@"other36.sqlite" fileInDocumentDirectory:YES];
}

#pragma mark -- util

/**
 *  删除指定的数据库文件
 *
 *  @param fileName         数据库名
 *  @param fileInDocument   YES表示文件在NSDocumentDirectory目录，NO表示文件在NSCachesDirectory目录
 *
 *  @return 返回YES，表示数据库文件存在，并且删除了。 NO表示文件不存在.
 */
+ (BOOL)deleteDataBaseForFileName:(NSString *)fileName fileInDocumentDirectory:(BOOL)fileInDocument
{
    BOOL exist = NO;
    NSSearchPathDirectory dictionary = fileInDocument ? NSDocumentDirectory : NSCachesDirectory;
    NSString *pathString = [[NSSearchPathForDirectoriesInDomains(dictionary, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathString]) {
        exist = YES;
        [[NSFileManager defaultManager] removeItemAtPath:pathString error:nil];
    }
    return exist;
}

/**
 *  判断指定文件名的数据库是否存在
 *
 *  @param fileName       数据库的名字
 *  @param fileInDocument YES表示文件在NSDocumentDirectory目录，NO表示文件在NSCachesDirectory目录
 *
 *  @return YES:数据库存在，NO:数据库不存在
 */
+ (BOOL)dataBaseFileExistForFileName:(NSString *)fileName fileInDocumentDirectory:(BOOL)fileInDocument
{
    BOOL exist = NO;
    NSSearchPathDirectory dictionary = fileInDocument ? NSDocumentDirectory : NSCachesDirectory;
    NSString *pathString = [[NSSearchPathForDirectoriesInDomains(dictionary, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathString]) {
        exist = YES;
    }
    return exist;
}

/**
 *  获取指定名字数据库对应的文件的路径
 *
 *  @param fileName       数据库的名字
 *  @param fileInDocument YES表示文件在NSDocumentDirectory目录，NO表示文件在NSCachesDirectory目录
 *
 *  @return 返回nil，表示指定的文件不存在。否则表示指定的文件存在。
 */
+ (NSString *)pathForDataBaseFileName:(NSString *)fileName fileInDocumentDirectory:(BOOL)fileInDocument
{
    NSSearchPathDirectory dictionary = fileInDocument ? NSDocumentDirectory : NSCachesDirectory;
    NSString *pathString = [[NSSearchPathForDirectoriesInDomains(dictionary, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:pathString];
    return exist ? pathString : nil;
}

@end
