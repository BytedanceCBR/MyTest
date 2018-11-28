//
//  FHFeedHouseCellHelper.h
//  Article
//
//  Created by 张静 on 2018/11/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFeedHouseCellHelper : NSObject

@property(nonatomic, strong,readonly)NSArray *cacheArray;

+(instancetype)sharedInstance;

- (void)addHouseCache:(NSString *)houseId;
- (void)removeHouseCacheArray;

@end

NS_ASSUME_NONNULL_END
