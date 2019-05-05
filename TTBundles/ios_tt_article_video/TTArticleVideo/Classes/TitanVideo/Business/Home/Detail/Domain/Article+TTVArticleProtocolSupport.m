//
//  Article+TTVArticleProtocolSupport.m
//  Article
//
//  Created by pei yun on 2017/4/10.
//
//

#import "Article+TTVArticleProtocolSupport.h"
#import "Article+TTADComputedProperties.h"
#import <objc/runtime.h>

@implementation Article (TTVArticleProtocolSupport)

- (NSString *)videoIDOfVideoDetailInfo
{
    return self.videoDetailInfo[VideoInfoIDKey];
}

- (NSString *)articleDetailContent
{
    return self.detail.content;
}

- (Article *)ttv_convertedArticle
{
    return self;
}

- (NSDictionary *)rawAdData
{
    return nil;
}

@end

@implementation Article (TTVDetailInfoUpdated)

- (void)setDetailInfoUpdated:(BOOL)detailInfoUpdated
{
   objc_setAssociatedObject(self, @selector(detailInfoUpdated), @(detailInfoUpdated), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)detailInfoUpdated
{
   return [objc_getAssociatedObject(self, @selector(detailInfoUpdated)) boolValue];
}

@end
