//
//  TTVPlayerLogEvent.h
//  Article
//
//  Created by panxiang on 2017/6/4.
//
//

#import <Foundation/Foundation.h>
@interface TTVPlayerLogEvent : NSObject

+ (instancetype)sharedInstance;

- (void)logPreloaderData:(NSArray<NSDictionary *> *)logData;

@end
