//
//  ArticleCommentHeaderView.h
//  Article
//
//  Created by Zhang Leonardo on 13-8-6.
//
//  评论的section view

#import "ExploreCommentView.h"

@interface ArticleCommentHeaderView : SSViewBase

+ (CGFloat)heightForHeaderView;

- (void)refreshTitle:(NSString *)title;

@end
