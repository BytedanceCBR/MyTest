//
//  NSDictionary+TTGeneratedContent.h
//  Article
//
//  Created by songxiangwu on 2016/10/24.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TTGeneratedContentType)
{
    TTGeneratedContentTypePGC = 0,
    TTGeneratedContentTypeUGC,
};

@interface NSDictionary (TTGeneratedContent)

- (TTGeneratedContentType)ttgc_contentType;
- (NSString *)ttgc_contentID;
- (NSString *)ttgc_mediaID;
- (NSString *)ttgc_contentName;
- (long long )ttgc_fansCount;
- (NSString *)ttgc_contentAvatarURL;
- (NSString *)ttgc_contentDescription;
- (NSString *)ttgc_userAuthInfo;
- (BOOL)ttgc_isSubCribed;

@end
