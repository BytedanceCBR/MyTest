//
//  SSCommon+JSON.m
//  Article
//
//  Created by SunJiangting on 14-6-16.
//
//

#import "JSONAdditions.h"

@implementation NSString (tt_JSONValue)

+ (id)tt_objectWithJSONData:(NSData *)inData error:(NSError **)outError {
    if (!inData) {
        return nil;
    }
    id object = [NSJSONSerialization JSONObjectWithData:inData options:NSJSONReadingAllowFragments error:outError];
    return object;
}

+ (id)tt_objectWithJSONString:(NSString *)inJSON error:(NSError **)outError {
    NSData *data = [inJSON dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:outError];
    return object;
}

- (id)tt_JSONValue {
    return [NSString tt_objectWithJSONString:self error:nil];
}

@end


@implementation NSArray (tt_JSONValue)

- (NSString *)tt_JSONRepresentation {
    NSData * data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end


@implementation NSDictionary (tt_JSONValue)

- (NSString *)tt_JSONRepresentation {
    NSData * data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
