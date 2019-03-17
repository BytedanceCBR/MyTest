//
//  SSLogDataManager.h
//  Article
//
//  Created by Zhang Leonardo on 15-3-22.
//
//

#import <Foundation/Foundation.h>

@interface SSLogDataManager : NSObject

+ (SSLogDataManager *)shareManager;

- (void)appendLogData:(NSDictionary *)dict;

- (NSArray *)needSendLogDatas;

@end
