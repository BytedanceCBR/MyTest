//
//  TTDetailModel+videoArticleProtocol.m
//  Article
//
//  Created by pei yun on 2017/4/10.
//
//

#import "TTDetailModel+videoArticleProtocol.h"
#import "Article+TTVArticleProtocolSupport.h"
#import "TTVVideoInformationResponse+TTVArticleProtocolSupport.h"
#import <objc/runtime.h>

@implementation TTDetailModel (videoArticleProtocol)

@dynamic protocoledArticle;

- (id<TTVArticleProtocol>)protocoledArticle
{
    if (self.videoInfo) {
        return self.videoInfo;
    }
    return self.article;
}

- (TTVVideoInformationResponse *)videoInfo
{
   return objc_getAssociatedObject(self, @selector(videoInfo));
}

- (void)setVideoInfo:(TTVVideoInformationResponse *)videoInfo
{
   objc_setAssociatedObject(self, @selector(videoInfo), videoInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTVVideoArticle *)videoArticle
{
   return objc_getAssociatedObject(self, @selector(videoArticle));
}

- (void)setVideoArticle:(TTVVideoArticle *)videoArticle
{
   objc_setAssociatedObject(self, @selector(videoArticle), videoArticle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
