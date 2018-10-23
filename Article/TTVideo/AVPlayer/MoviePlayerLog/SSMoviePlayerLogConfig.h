//
//  SSMoviePlayerLogConfig.h
//  Article
//
//  Created by Chen Hong on 15/8/26.
//
//

#import <Foundation/Foundation.h>

@interface SSMoviePlayerLogConfig : NSObject

+ (BOOL)fetchDNSInfo;
+ (void)setFetchDNSInfo:(BOOL)fetch;

+ (BOOL)fetchServerIPFromHead;
+ (void)setFetchServerIPFromHead:(BOOL)fetch;

@end
