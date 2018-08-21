//
//  TTVRelatedItem+TTVConvertToArticle.h
//  Article
//
//  Created by pei yun on 2017/6/13.
//
//

#import <TTVideoService/VideoInformation.pbobjc.h>
#import "Article.h"

@interface TTVRelatedItem (TTVConvertToArticle)

@property (nonatomic, strong) Article *savedConvertedArticle;

@end
