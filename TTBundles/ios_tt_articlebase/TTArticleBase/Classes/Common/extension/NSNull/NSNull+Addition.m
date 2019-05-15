//
//  NSNull+Addition.m
//  Article
//
//  Created by Dianwei on 14-9-30.
//
//

#import "NSNull+Addition.h"

@implementation NSNull (Addition)

- (BOOL)boolValue
{
    return NO;
}


- (int)intValue
{
    return 0;
}

- (NSString*)stringValue
{
    return nil;
}

- (NSInteger)integerValue
{
    return 0;
}

- (BOOL)isEqualToString:(NSString*)str
{
    return NO;
}

- (long long)longLongValue
{
    return 0;
}

- (float)floatValue
{
    return .0f;
}

- (double)doubleValue
{
    return 0.f;
}

- (NSUInteger)length
{
    return 0;
}
- (NSUInteger)count {
    return 0;
}

- (NSUInteger)unsignedIntegerValue {
    return 0;
}
@end
