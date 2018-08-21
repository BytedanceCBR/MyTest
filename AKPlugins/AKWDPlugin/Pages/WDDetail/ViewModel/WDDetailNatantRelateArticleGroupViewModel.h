//
//  WDDetailNatantRelateArticleGroupViewModel.h
//  Article
//
//  Created by 延晋 张 on 16/4/26.
//
//

#import <Foundation/Foundation.h>

@class WDAnswerEntity;
@class WDDetailModel;
@class WDDetailNatantRelateArticleGroupView;

@interface WDDetailNatantRelateArticleGroupViewModel : NSObject

@property (nonatomic, strong, nullable) WDAnswerEntity *answerEntity;
@property (nonatomic, strong, nullable) NSArray * relatedItems;
@property (nonatomic, copy,   nullable) NSString * eventLabel;
@property (nonatomic, strong, nullable) WDDetailModel * detailModel;
// will modify later vm should not contain any view
@property (nonatomic, weak, nullable) WDDetailNatantRelateArticleGroupView * groupView;

- (void)checkVisableRelatedArticlesAtContentOffset:(CGFloat)offsetY referViewHeight:(CGFloat)referHeight;

- (void)resetAllRelatedItemsWhenNatantDisappear;

- (nullable NSArray *)mappingOriginToModel:(nullable NSArray *)originData;

@end




