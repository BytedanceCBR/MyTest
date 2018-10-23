//
//  ArticleWebListView.h
//  Article
//
//  Created by Zhang Leonardo on 13-6-7.
//
//

#import "ArticleBaseListView.h"

@interface ArticleWebListView : ArticleBaseListView

@property(nonatomic, assign)BOOL isVisible;

- (id)initWithFrame:(CGRect)frame topInset:(CGFloat)topInset bottomInset:(CGFloat)bottomInset;

@end
