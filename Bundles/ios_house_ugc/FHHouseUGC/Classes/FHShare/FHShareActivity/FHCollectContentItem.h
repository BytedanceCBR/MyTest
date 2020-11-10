//
//  FHCollectContentItem.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/9.
//

#import "BDUGShareBaseContentItem.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const FHActivityContentItemTypeCollect = @"com.f100.ActivityContentItem.Collect";

@interface FHCollectContentItem : BDUGShareBaseContentItem

@property(nonatomic,copy) void (^collectBlcok)(void);

@end

@interface FHShareCollectDataModel : NSObject

@property(nonatomic,assign) BOOL collected;
@property(nonatomic,copy) void (^collectBlcok)(void);

@end

NS_ASSUME_NONNULL_END
