//
//  TTArticleStoryToolView.h
//  Article
//
//  Created by 冯靖君 on 16/7/12.
//
//

#import "SSThemed.h"
#import "Article.h"

@interface TTArticleStoryToolView : SSThemedView

- (instancetype)initWithWidth:(CGFloat)width article:(Article *)article;

- (void)showInView:(UIView *)parentView animated:(BOOL)animated;

- (void)hideWithAnimated:(BOOL)animated;

@end
