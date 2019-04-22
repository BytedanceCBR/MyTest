//
//  ArticleForwardManager.h
//  Article
//
//  Created by SunJiangting on 15-1-23.
//
//

#import <Foundation/Foundation.h>
#import "ArticleMomentModel.h"

@interface ArticleForwardManager : NSObject

+ (instancetype)sharedManager;
/// 转发到我的动态
- (void)forwardMoment:(ArticleMomentModel *)momentModel
             withText:(NSString *)text
    completionHandler:(void(^)(NSError *error))completionHandler;

- (void)cancel;
@end
