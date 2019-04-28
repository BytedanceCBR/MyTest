//
//  TTVVideoInformationResponse+TTAdDetailInnerArticleProtocolSupport.m
//  Article
//
//  Created by pei yun on 2017/7/25.
//
//

#import "TTVVideoInformationResponse+TTAdDetailInnerArticleProtocolSupport.h"
#import "TTVVideoInformationResponse+TTVComputedProperties.h"

@implementation TTVVideoInformationResponse (TTAdDetailInnerArticleProtocolSupport)

- (NSString *)mediaID
{
    NSString *result = self.article.userId;
    if (result.length == 0 && self.articleMiddleman) {
        result = [self.articleMiddleman mediaUserID];
    }
    return result;
}

@end
