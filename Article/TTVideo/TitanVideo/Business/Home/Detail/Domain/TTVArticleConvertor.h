//
//  TTVArticleConvertor.h
//  Article
//
//  Created by panxiang on 2017/12/1.
//

#import <Foundation/Foundation.h>
@class Article;
@class TTVVideoInformationResponse;
@interface TTVArticleConvertor : NSObject
+ (void)updateArticle:(id)aArticle withNewArticle:(TTVVideoInformationResponse *)info;
@end
