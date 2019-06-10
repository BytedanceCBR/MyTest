//
//  TTDBCenter.h
//  Article
//
//  Created by Chen Hong on 2017/2/28.
//
//

#import <Foundation/Foundation.h>

@interface TTDBCenter : NSObject

+ (instancetype)sharedInstance;

- (void)deleteDBIfNeeded;

+ (void)deleteAllDBFiles;

+ (void)deleteDBFile:(NSString *)dbName;

@end
