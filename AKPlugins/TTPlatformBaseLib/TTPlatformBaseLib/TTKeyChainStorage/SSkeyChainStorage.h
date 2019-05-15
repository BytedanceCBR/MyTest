//
//  SSkeyChainStorage.h
//  Article
//
//  Created by Dianwei on 13-5-9.
//
//

#import <Foundation/Foundation.h>

@interface SSkeyChainStorage : NSObject
+ (id)objectForKey:(NSString*)key;
// value must be JSON representable
+ (BOOL)setObject:(id)value key:(NSString*)key;
+ (BOOL)removeValueForKey:(NSString*)key;
@end
