//
//  TTVArticleConvertor.m
//  Article
//
//  Created by panxiang on 2017/12/1.
//

#import "TTVArticleConvertor.h"
#import "VideoInformation.pbobjc.h"
#import "Article.h"
#import "TTVFeedItem+TTVConvertToArticle.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTVFeedItem+Extension.h"
#import "TTVVideoArticle+Extension.h"
#import "TTVVideoInformationResponse+TTVArticleProtocolSupport.h"
#import "VideoFeed.pbobjc.h"

@implementation TTVArticleConvertor
+ (void)updateArticle:(id)aArticle withNewArticle:(TTVVideoInformationResponse *)info
{
    if ([aArticle isKindOfClass:[Article class]] && [info isKindOfClass:[TTVVideoInformationResponse class]]) {
        Article *article = aArticle;
        article.videoDetailInfo = info.videoDetailInfo;
    }else if ([aArticle isKindOfClass:[TTVFeedItem class]] && [info isKindOfClass:[TTVVideoInformationResponse class]]) {
//        TTVFeedItem *article = aArticle;
//        article.article = info.article;
    }
}
@end
