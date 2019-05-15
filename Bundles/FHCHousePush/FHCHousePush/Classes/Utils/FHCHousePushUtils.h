//
//  FHCHousePushUtils.h
//  FHCHousePush
//
//  Created by 张静 on 2019/4/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCHousePushUtils : NSObject

+ (NSString *)fixStringTypeGroupID:(NSString *)gIDStr;
+ (NSNumber *)fixNumberTypeGroupID:(NSNumber *)gID;

@end

NS_ASSUME_NONNULL_END
