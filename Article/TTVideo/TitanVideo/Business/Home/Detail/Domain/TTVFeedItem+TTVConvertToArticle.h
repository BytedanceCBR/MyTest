//
//  TTVFeedItem+TTVConvertToArticle.h
//  Article
//
//  Created by pei yun on 2017/4/11.
//
//

#import <TTVideoService/VideoFeed.pbobjc.h>
#import <TTVideoService/Common.pbobjc.h>
#import "Article.h"

@interface TTVFeedItem (TTVConvertToArticle)

@property (nonatomic, strong) Article *savedConvertedArticle;

@end

@interface Article (TTVConvertFromFeedItem)

@property (nonatomic, assign) BOOL convertedFromFeedItem;

@end
