//
//  ExploreDetailnatantActionButton.h
//  Article
//
//  Created by Zhang Leonardo on 14-10-23.
//
//  详情页浮层动作按钮

#import "Article.h"

@interface ExploreDetailnatantActionButton : UIButton

- (void)refresh;
- (void)refreshWithArticle:(ExploreOriginalData *)article adID:(NSNumber *)adID;
- (id)initIsDigButton:(BOOL)digButton;

@end
