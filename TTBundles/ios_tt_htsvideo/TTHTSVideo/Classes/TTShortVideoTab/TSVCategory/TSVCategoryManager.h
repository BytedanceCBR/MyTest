//
//  TSVCategoryManager.h
//  Article
//
//  Created by 王双华 on 2017/10/29.
//

#import <Foundation/Foundation.h>
#import "TSVCategory.h"
#import "TTCategoryDefine.h"

typedef void(^TSVCategoryManagerRequestFinishBlock)(NSArray <TSVCategory *> *categories);

@interface TSVCategoryManager : NSObject

@property (nonatomic, strong) NSString *currentSelectedCategoryID;

+ (TSVCategoryManager*)sharedManager;

/**
 *  优先获取本地数据库中的存储的频道，若只有一个推荐频道，那么返回默认的频道列表
 */
- (NSArray <TSVCategory *> *)localCategories;

/**
 *  向服务器请求频道列表
 */
- (void)fetchCategoriesFromRemote:(TSVCategoryManagerRequestFinishBlock)finishBlock;

@end

