//
//  NSDictionary+TTAdditions.h
//  Article
//
//  Created by Chen Hong on 15/4/30.
//
//

#import <Foundation/Foundation.h>
#import "NSDataAdditions.h"


@interface NSDictionary (TTAdditions)

- (id)objectForKey:(NSString *)key defalutObj:(id)defaultObj;
- (id)objectForKey:(id)aKey ofClass:(Class)aClass defaultObj:(id)defaultObj;
- (int)intValueForKey:(NSString *)key defaultValue:(int)defaultValue;
- (NSInteger)integerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;
- (NSUInteger)unsignedIntegerValueForKey:(NSString *)key defaultValue:(NSUInteger)defaultValue;
- (float)floatValueForKey:(NSString *)key defaultValue:(float)defaultValue;
- (double)doubleValueForKey:(NSString *)key defaultValue:(double)defaultValue;
- (long)longValueForKey:(NSString *)key defaultValue:(long)defaultValue;
- (long long)longlongValueForKey:(NSString *)key defaultValue:(long long)defaultValue;
- (NSString *)stringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue;
- (NSArray *)arrayValueForKey:(NSString *)key defaultValue:(NSArray *)defaultValue;
- (NSDictionary *)dictionaryValueForKey:(NSString *)key defalutValue:(NSDictionary *)defaultValue;

- (id)tt_objectForKey:(NSString *)key;
- (id)tt_objectForKey:(id)aKey ofClass:(Class)aClass;
- (int)tt_intValueForKey:(NSString *)key;
- (NSInteger)tt_integerValueForKey:(NSString *)key;
- (NSUInteger)tt_unsignedIntegerValueForKey:(NSString *)key;
- (float)tt_floatValueForKey:(NSString *)key;
- (double)tt_doubleValueForKey:(NSString *)key;
- (long)tt_longValueForKey:(NSString *)key;
- (long long)tt_longlongValueForKey:(NSString *)key;
- (BOOL)tt_boolValueForKey:(NSString *)key;
- (NSString *)tt_stringValueForKey:(NSString *)key;
- (NSArray *)tt_arrayValueForKey:(NSString *)key;
- (NSDictionary *)tt_dictionaryValueForKey:(NSString *)key;


@end

@interface NSDictionary (TTFingerprint)

/**
 *  将NSDictionary根据TTFingerprintType转换为base64格式字符串
 *
 *  @param type
 *
 *  @return 
 */
- (NSString *)tt_base64StringWithFingerprintType:(TTFingerprintType)type;

@end

@interface NSDictionary (JSONValue)

- (NSString *)JSONRepresentation;

@end
