//
//  VideoCategoryManager.h
//  Article
//
//  Created by xuzichao on 16-7-25.
//
//

#import <Foundation/Foundation.h>
#import "TTVideoCategory.h"
#import "TTCategoryDefine.h"


@interface TTVideoCategoryManager : NSObject

/**
 *  频道管理的单例
 *
 *  @return 频道管理的单例
 */
+ (TTVideoCategoryManager*)sharedManager;

/**
 *  推荐频道
 *
 *  @return 推荐频道
 */

+ (TTVideoCategory *)categoryModelByCategoryID:(NSString *)categoryID;
+ (TTVideoCategory *)insertCategoryWithDictionary:(NSDictionary *)dict;
+ (NSString*)currentSelectedCategoryID;
+ (void)setCurrentSelectedCategoryID:(NSString*)categoryID;

/**
 *  通过jsonDict构建video频道TTVideoCategory
 *
 *  @param dataDicts jsonDict of video category model
 *
 *  @return Array of TTVideoCategory
 */

- (NSArray *)videoCategoriesWithDataDicts:(NSArray *)dataDicts;

@end


@interface TTVideoCategoryManager(InsertDefaultCategory)
/**
 *  插入默认数据
 *  所有版本仅能调用一次, 由外部保证仅调用一次
 */
+ (void)insertDefaultData;

@end
