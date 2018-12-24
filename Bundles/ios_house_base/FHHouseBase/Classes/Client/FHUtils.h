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

//json 字符串转dic
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
