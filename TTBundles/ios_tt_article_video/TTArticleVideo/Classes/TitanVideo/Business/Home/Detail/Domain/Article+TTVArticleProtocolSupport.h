//
//  Article+TTVArticleProtocolSupport.h
//  Article
//
//  Created by pei yun on 2017/4/10.
//
//

#import "Article.h"
#import "TTVArticleProtocol.h"
#import "Article+TTADComputedProperties.h"

@interface Article (TTVArticleProtocolSupport) <TTVArticleProtocol>

- (NSString *)videoIDOfVideoDetailInfo;
- (NSString *)articleDetailContent;

- (Article *)ttv_convertedArticle;

@end

@interface Article (TTVDetailInfoUpdated)

@property (nonatomic, assign) BOOL detailInfoUpdated;

@end
