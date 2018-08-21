//
//  NSObject+TTFastCoding.h
//  homework
//
//  Created by panxiang on 14-7-17.
//  Copyright (c) 2014年 panxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TTFastCoding)
// Implement the method below to return an array of NSStrings representing the names of
// properties you wish to skip during encoding and decoding.
// The default implementation returns an empty array.

+ (NSArray *)propertiesToSkipDuringFastCoding;
- (void)encodePropertiesWithCoder:(NSCoder *)coder;
- (void)decodePropertiesWithCoder:(NSCoder *)coder;
@end
