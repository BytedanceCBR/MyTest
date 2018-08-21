//
//  TTArticleDetailMenuController.h
//  Article
//
//  Created by zhaoqin on 11/10/2016.
//
//

#import <Foundation/Foundation.h>

@class Article;

@interface TTArticleDetailMenuController : NSObject

- (void)performMenuAndInsertData:(NSDictionary *)data article:(Article *)article dismiss:(void (^)())dismissBlock;

- (void)dismissMenu;

@end
