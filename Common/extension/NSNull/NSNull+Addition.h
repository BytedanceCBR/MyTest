//
//  NSNull+Addition.h
//  Article
//
//  Created by Dianwei on 14-9-30.
//
//

#import <Foundation/Foundation.h>

@interface NSNull (Addition)
- (BOOL)boolValue;
- (int)intValue;
- (NSString*)stringValue;
- (NSInteger)integerValue;
- (BOOL)isEqualToString:(NSString*)str;
- (long long)longLongValue;
- (float)floatValue;
- (double)doubleValue;
- (NSUInteger)length;
- (NSUInteger)count;
- (NSUInteger)unsignedIntegerValue;
@end
