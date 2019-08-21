//
//  FHRNJumpManager.h
//  AKShareServicePlugin
//
//  Created by 谢飞 on 2019/7/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHRNJumpManager : NSObject

+ (void)jumpToClueDetail:(NSDictionary *)params;

+ (NSDictionary *)processDictionaryToJsonStr:(NSDictionary *)originDict;

+ (BOOL)isClueDetailCanUseRN;


@end

NS_ASSUME_NONNULL_END
