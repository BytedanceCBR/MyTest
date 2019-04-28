//
//  TTArticleCardCellViewFooterView.h
//  Article
//
//  Created by 王双华 on 16/4/21.
//
//

#import "SSViewBase.h"

@class ExploreOrderedData;

@interface TTArticleCardCellViewFooterView : SSViewBase

- (void)setTarget:(id)target selector:(SEL)selector;

- (void)refreshUIWithModel:(ExploreOrderedData *)orderedData;

@end
