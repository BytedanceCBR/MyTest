//
//  ArticleAppPageHelper.h
//  Article
//
//  Created by Kimimaro on 13-5-23.
//
//

#import <Foundation/Foundation.h>
#import "TTRoute.h"

@class ArticleFriend;

@interface ArticleAppPageHelper : NSObject

+ (ArticleAppPageHelper *)sharedHelper;

- (ArticleFriend *)newArticleFriendForRouteParamObj:(TTRouteParamObj *)paramObj index:(NSNumber **)index titles:(NSArray<NSString *> **)titles;

@end
