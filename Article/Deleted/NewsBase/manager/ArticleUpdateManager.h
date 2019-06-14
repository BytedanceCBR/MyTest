//
//  ArticleUpdateManager.h
//  Article
//
//  Created by SunJiangting on 14-12-16.
//
//

#import <Foundation/Foundation.h>

extern NSString *const ArticleDidUpdateNotification;
@interface ArticleUpdateManager : NSObject

+ (instancetype) sharedManager;

- (void)addUpdateCommand:(NSString *)commandId groupModels:(NSDictionary *)groupModels;

@end