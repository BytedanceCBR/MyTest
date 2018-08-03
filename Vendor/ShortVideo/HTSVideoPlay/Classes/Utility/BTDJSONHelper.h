//
//  BTDJSONHelper.h
//  Essay
//
//  Created by Quan Quan on 15/11/6.
//  Copyright © 2015年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTDJSONHelper : NSObject


@end

@interface NSString(JSONValue)

- (id)JSONValue;

@end

@interface NSArray(JSONValue)

- (NSString *)JSONRepresentation;

@end

@interface NSDictionary(JSONValue)

- (NSString *)JSONRepresentation;

+ (id)dictionaryWithJSONData:(NSData *)inData error:(NSError **)outError;

+ (id)dictionaryWithJSONString:(NSString *)inJSON error:(NSError **)outError;

@end

