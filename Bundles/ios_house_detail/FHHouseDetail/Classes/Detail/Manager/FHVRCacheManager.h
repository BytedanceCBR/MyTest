//
//  FHVRCacheManager.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHVRCacheManager : NSObject
@property(nonatomic,assign)NSInteger currentVRPreloadCount;

+(instancetype)sharedInstance;

- (BOOL)isCanCacheVRPreload;

- (void)addVRPreloadCache:(NSInteger)hashCode;

- (void)removeVRPreloadCache:(NSInteger)hashCode;
@end

NS_ASSUME_NONNULL_END
