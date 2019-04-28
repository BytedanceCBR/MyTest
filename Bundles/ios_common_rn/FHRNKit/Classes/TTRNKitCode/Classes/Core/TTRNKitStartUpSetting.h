//
//  TTRNKitStartUpSetting.h
//  AFgzipRequestSerializer
//
//  Created by renpeng on 2018/7/11.
//

#import <Foundation/Foundation.h>

@interface TTRNKitStartUpSetting : NSObject

//只存储在内存中，方便统一管理
+ (id)startUpParameterForKey:(NSString *)key;

+ (void)setStartUpParameters:(NSDictionary *)params;

+ (void)setStartUpParameter:(id)value forKey:(NSString *)key;

//会进行持久化处理
+ (void)setValue:(id)value forKey:(id)key;

+ (id)valueForKey:(id)key;

@end
