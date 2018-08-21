//
//  Article+TTAdDetailInnerArticleProtocolSupport.m
//  Article
//
//  Created by pei yun on 2017/7/24.
//
//

#import "Article+TTAdDetailInnerArticleProtocolSupport.h"

@implementation Article (TTAdDetailInnerArticleProtocolSupport)

- (NSString *)mediaID
{
    return [self.mediaInfo[@"media_id"] stringValue];
}

@end
