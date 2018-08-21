//
//  SSCommon+JSON.h
//  Article
//
//  Created by SunJiangting on 14-6-16.
//
//

#import <Foundation/Foundation.h>

@interface NSString (tt_JSONValue)

+ (id)tt_objectWithJSONData:(NSData *)inData error:(NSError **)outError;
+ (id)tt_objectWithJSONString:(NSString *)inJSON error:(NSError **)outError;
- (id)tt_JSONValue;

@end

@interface NSArray (tt_JSONValue)

- (NSString *)tt_JSONRepresentation;

@end


@interface NSDictionary (tt_JSONValue)

- (NSString *)tt_JSONRepresentation;

@end
