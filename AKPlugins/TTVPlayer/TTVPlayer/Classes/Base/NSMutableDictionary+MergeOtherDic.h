//
//  NSMutableDictionary+MergeOtherDic.h
//  ScreenRotate
//
//  Created by lisa on 2019/3/29.
//  Copyright © 2019 . All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (MergeOtherDic)
- (void)mergingWithDictionary:(NSDictionary *)dict;
- (void)mergingWithDictionary:(NSDictionary *)dict ignoredDictKey:(NSString *)ignoredKey;

@end

NS_ASSUME_NONNULL_END
