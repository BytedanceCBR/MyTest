//
//  FHUGCCategoryManager.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/4/20.
//

#import <Foundation/Foundation.h>
#import "FHUGCCategoryModel.h"
#import "FHHouseUGCHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCCategoryManager : NSObject

@property(nonatomic, strong) NSMutableArray *allCategories;

/**
 *  请求频道回调
 */
@property(nonatomic, copy) void (^completionRequest)(BOOL isSuccess);

+ (FHUGCCategoryManager *)sharedManager;

+ (FHCommunityCollectionCellType)convertCategoryToType:(NSString *)category;

- (void)startGetCategory;
- (void)startGetCategory:(BOOL)userChanged;
- (void)startGetCategoryWithCompleticon:(void(^)(BOOL isSuccess))completion;

@end

NS_ASSUME_NONNULL_END
