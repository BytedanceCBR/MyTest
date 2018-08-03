//
//  TTDetailNatantRelateArticleGroupViewModel.h
//  Article
//
//  Created by Ray on 16/4/11.
//
//

#import <Foundation/Foundation.h>
#import "Article.h"

@class ArticleInfoManager;
@class TTDetailNatantRelateArticleGroupView;
@interface TTDetailNatantRelateArticleGroupViewModel : NSObject

@property (nonatomic, strong, nullable) NSArray * relatedItems;
@property (nonatomic, copy,   nullable) NSString * eventLabel;
@property (nonatomic, strong,   nullable) ArticleInfoManager * articleInfoManager;
@property (nonatomic, weak, nullable) TTDetailNatantRelateArticleGroupView * groupView;

- (void)checkVisableRelatedArticlesAtContentOffset:(CGFloat)offsetY referViewHeight:(CGFloat)referHeight;

- (void)resetAllRelatedItemsWhenNatantDisappear;

- (nullable NSArray *)mappingOriginToModel:(nullable NSArray *)originData;

@end
