//
//  BTDJSONHelper.m
//  Essay
//
//  Created by Quan Quan on 15/11/6.
//  Copyright © 2015年 Bytedance. All rights reserved.
//

#import "BTDJSONHelper.h"

@implementation BTDJSONHelper


@end

@implementation NSString(JSONValue)

- (id)JSONValue
{
    return [NSDictionary dictionaryWithJSONString:self error:nil];
}

@end

@implementation NSArray(JSONValue)

- (NSString *) JSONRepresentation
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end


@implementation NSDictionary(JSONValue)

- (NSString *)JSONRepresentation
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:(NSDictionary *)self options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (id)dictionaryWithJSONData:(NSData *)inData error:(NSError **)outError
{
    if (inData) {
        
        return [NSJSONSerialization JSONObjectWithData:inData options:NSJSONReadingAllowFragments error:outError];
    } else {
        
        return nil;
    }
}

+ (id)dictionaryWithJSONString:(NSString *)inJSON error:(NSError **)outError;
{
    NSData *theData = [inJSON dataUsingEncoding:NSUTF8StringEncoding];
    
    return([self dictionaryWithJSONData:theData error:outError]);
}

@end
