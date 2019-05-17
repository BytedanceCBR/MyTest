//
//  ExploreArticleCardCell.m
//  Article
//
//  Created by Chen Hong on 14/11/21.
//
//

#import "ExploreArticleCardCell.h"
#import "ExploreArticleCardCellView.h"
#import "ExploreArticleCellViewConsts.h"

@implementation ExploreArticleCardCell

+ (Class)cellViewClass
{
    return [ExploreArticleCardCellView class];
}


- (void)willAppear {
    [self willDisplay];
}

- (void)willDisplay
{
    [(ExploreArticleCardCellView *)self.cellView willDisplay];
}

- (void)didEndDisplaying {
    [(ExploreArticleCardCellView *)self.cellView didEndDisplaying];
}


// override
- (CGFloat)paddingForCellView {
    return [super paddingForCellView];
}

@end
