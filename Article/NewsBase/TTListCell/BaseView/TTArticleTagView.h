//
//  TTArticleTagView.h
//  Article
//
//  Created by 杨心雨 on 16/8/22.
//
//

#import <SSThemed.h>
#import "ExploreOrderedData+TTBusiness.h"

@interface TTArticleTagView : SSThemedLabel

- (void)layoutTypeIcon;
- (void)updateTypeIcon:(ExploreOrderedData * _Nonnull)orderedData;

@end
