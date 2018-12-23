//
//  FHUtils.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHUtils : NSObject

+ (void)setContent:(id)object forKey:(NSString *)keyStr;

+ (instancetype)contentForKey:(NSString *)keyStr;

@end

NS_ASSUME_NONNULL_END
