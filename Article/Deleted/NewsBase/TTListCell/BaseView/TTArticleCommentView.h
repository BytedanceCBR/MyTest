//
//  TTArticleCommentView.h
//  Article
//
//  Created by 杨心雨 on 16/8/23.
//
//

#import "SSThemed.h"
#import "ExploreOrderedData+TTBusiness.h"

@interface TTArticleCommentView : SSThemedView

@property (nonatomic, strong) SSThemedLabel * _Nonnull commentView;
@property (nonatomic, strong) UIFont * _Nonnull font;
@property (nonatomic) CGFloat lineHeight;

- (void)layoutComment;
- (void)updateComment:(ExploreOrderedData * _Nonnull)orderedData;
- (void)updateCommentState:(BOOL)hasRead;

@end
