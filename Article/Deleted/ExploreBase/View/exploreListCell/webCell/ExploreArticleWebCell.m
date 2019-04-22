//
//  ExploreArticleWebCell.m
//  Article
//
//  Created by Chen Hong on 15/1/8.
//
//

#import "ExploreArticleWebCell.h"
#import "ExploreArticleWebCellView.h"
#import "ExploreArticleCellViewConsts.h"

@implementation ExploreArticleWebCell

+ (Class)cellViewClass
{
    return [ExploreArticleWebCellView class];
}

- (void)didEndDisplaying {
    [(ExploreArticleWebCellView *)self.cellView didEndDisplaying];
}

// override
- (CGFloat)paddingForCellView {
    return [super paddingForCellView] + kCellLeftPadding;
}

@end
