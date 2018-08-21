//
//  NSDictionary+TTAdditions.m
//  Article
//
//  Created by Chen Hong on 15/4/30.
//
//

#import "NSDictionary+TTAdditions.h"
#import "NSStringAdditions.h"

@implementation NSDictionary (TTAdditions)

- (id)objectForKey:(NSString *)key defalutObj:(id)defaultObj {
    id obj = [self objectForKey:key];
    return obj ? obj : defaultObj;
}

- (id)objectForKey:(id)aKey ofClass:(Class)aClass defaultObj:(id)defaultObj {
    id obj = [self objectForKey:aKey];
    return (obj && [obj isKindOfClass:aClass]) ? obj : defaultObj;
}

- (int)intValueForKey:(NSString *)key defaultValue:(int)defaultValue {
    id value = [self objectForKey:key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return [(NSString *)value intValue];
    }
    return (value && [value isKindOfClass:[NSNumber class]]) ? [value intValue] : defaultValue;
}

- (NSInteger)integerValueForKey:(NSString *)key defaultValue:(NSInteger)defaultValue {
    id value = [self objectForKey:key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return [(NSString *)value integerValue];
    }
    return (value && [value isKindOfClass:[NSNumber class]]) ? [value integerValue] : defaultValue;
}

- (NSUInteger)unsignedIntegerValueForKey:(NSString *)key defaultValue:(NSUInteger)defaultValue {
    id value = [self objectForKey:key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return (NSUInteger)[(NSString *)value integerValue];
    }
    return (value && [value isKindOfClass:[NSNumber class]]) ? [value unsignedIntegerValue] : defaultValue;
}

- (double)doubleValueForKey:(NSString *)key defaultValue:(double)defaultValue
{
    id value = [self objectForKey:key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return [(NSString *)value doubleValue];
    }
    return (value && [value isKindOfClass:[NSNumber class]]) ? [value doubleValue] : defaultValue;
}

- (float)floatValueForKey:(NSString *)key defaultValue:(float)defaultValue {
    id value = [self objectForKey:key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return [(NSString *)value floatValue];
    }
    return (value && [value isKindOfClass:[NSNumber class]]) ? [value floatValue] : defaultValue;
}

- (long)longValueForKey:(NSString *)key defaultValue:(long)defaultValue {
    id value = [self objectForKey:key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return [(NSString *)value integerValue];
    }
    return (value && [value isKindOfClass:[NSNumber class]]) ? [value longValue] : defaultValue;
}

- (long long)longlongValueForKey:(NSString *)key defaultValue:(long long)defaultValue {
    id value = [self objectForKey:key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return [(NSString *)value longLongValue];
    }
    return (value && [value isKindOfClass:[NSNumber class]]) ? [[(NSNumber *)value stringValue] longLongValue] : defaultValue;
}

- (NSString *)stringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    id value = [self objectForKey:key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return value;
    }else if(value && [value isKindOfClass:[NSNumber class]]){
        return [value stringValue];
    }else{
        return defaultValue;
    }
}

- (NSArray *)arrayValueForKey:(NSString *)key defaultValue:(NSArray *)defaultValue {
    id value = [self objectForKey:key];
    return (value && [value isKindOfClass:[NSArray class]]) ? value : defaultValue;
}

- (NSDictionary *)dictionaryValueForKey:(NSString *)key defalutValue:(NSDictionary *)defaultValue {
    id value = [self objectForKey:key];
    return (value && [value isKindOfClass:[NSDictionary class]]) ? value : defaultValue;
}

- (id)tt_objectForKey:(NSString *)key {
    return [self objectForKey:key defalutObj:nil];
}

- (id)tt_objectForKey:(id)aKey ofClass:(Class)aClass {
    return [self objectForKey:aKey ofClass:aClass defaultObj:nil];
}

- (int)tt_intValueForKey:(NSString *)key {
    return [self intValueForKey:key defaultValue:0];
}

- (NSInteger)tt_integerValueForKey:(NSString *)key {
    return [self integerValueForKey:key defaultValue:0];
}

- (NSUInteger)tt_unsignedIntegerValueForKey:(NSString *)key {
    return [self unsignedIntegerValueForKey:key defaultValue:0];
}

- (float)tt_floatValueForKey:(NSString *)key {
    return [self floatValueForKey:key defaultValue:0.f];
}

- (double)tt_doubleValueForKey:(NSString *)key {
    return [self doubleValueForKey:key defaultValue:0.];
}

- (long)tt_longValueForKey:(NSString *)key {
    return [self longValueForKey:key defaultValue:0];
}

- (long long)tt_longlongValueForKey:(NSString *)key {
    return [self longlongValueForKey:key defaultValue:0];
}

- (BOOL)tt_boolValueForKey:(NSString *)key {
    return [self integerValueForKey:key defaultValue:0] != 0;
}

- (NSString *)tt_stringValueForKey:(NSString *)key {
    return [self stringValueForKey:key defaultValue:nil];
}

- (NSArray *)tt_arrayValueForKey:(NSString *)key {
    return [self arrayValueForKey:key defaultValue:nil];
}

- (NSDictionary *)tt_dictionaryValueForKey:(NSString *)key {
    return [self dictionaryValueForKey:key defalutValue:nil];
}


@end

@implementation NSDictionary (TTFingerprint)

- (NSString *)tt_base64StringWithFingerprintType:(TTFingerprintType)type {
    if (!self || ![self isKindOfClass:[NSDictionary class]] || ((NSDictionary *)self).count == 0) {
        return nil;
    }
    NSError *error = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (!error && JSONData.length > 0) {
        return [[JSONData tt_dataWithFingerprintType:type] ss_base64EncodedString];
    }
    return nil;
}

@end

@implementation NSDictionary (JSONValue)

- (NSString *)JSONRepresentation {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
