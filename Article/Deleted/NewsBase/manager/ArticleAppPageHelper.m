//
//  ArticleAppPageHelper.m
//  Article
//
//  Created by Kimimaro on 13-5-23.
//
//

#import "ArticleAppPageHelper.h"

#import "Article.h"
#import "ArticleFriend.h"
#import "TTRoute.h"
#import "ListDataHeader.h"
#import "TTRelationshipDefine.h"
#import <TTBaseLib/NSStringAdditions.h>

@implementation ArticleAppPageHelper

static ArticleAppPageHelper *_shareHelper;
+ (ArticleAppPageHelper *)sharedHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareHelper = [[self alloc] init];
    });
    return _shareHelper;
}

+ (id)alloc
{
    NSAssert(_shareHelper == nil, @"Attempt to alloc second instance for a singleton.");
    return [super alloc];
}

- (ArticleFriend *)newArticleFriendForRouteParamObj:(TTRouteParamObj *)paramObj index:(NSNumber **)index titles:(NSArray<NSString *> **)titles {
    NSString   *pageName = paramObj.host;
    NSDictionary *params = paramObj.allParams;
    
    ArticleFriend *tFriend = nil;
    NSUInteger appearedIndex = 1;
    NSArray<NSString *> *titleArray;
    
    if ([pageName isEqualToString:@"add_friend"]) {
        appearedIndex = 0;
        tFriend = [ArticleFriend accountUser];
    } else if ([pageName isEqualToString:@"relation"]) {
        if (!isEmptyString(paramObj.segment)) {
            NSString *segment = paramObj.segment;
            if ([segment isEqualToString:@"follower"]) {
                appearedIndex = 2;
            } else if ([segment isEqualToString:@"subscribe"]) {
                appearedIndex = 0;
            } else if ([segment isEqualToString:@"visitor"]) {
                appearedIndex = 3;
            }
        }
        
        if ([params.allKeys containsObject:@"uid"]) {
            tFriend = [[ArticleFriend alloc] initWithDictionary:@{@"user_id" : [params objectForKey:@"uid"]}];
        } else {
            tFriend = [ArticleFriend accountUser];
        }
        NSString *titlesString = [params valueForKey:@"titles"];
        if (!isEmptyString(titlesString)) {
            titleArray = [titlesString JSONValue];
            if (![titleArray isKindOfClass:[NSArray class]]) {
                titleArray = nil;
            }
        }
    }
    if (index) {
        *index = [NSNumber numberWithInteger:appearedIndex];
    }
    if (titles) {
        *titles = titleArray;
    }
    return tFriend;
}
@end
