//
//  ExploreArticleEssayCell.m
//  Article
//
//  Created by chenren on 9/05/17.
//
//

#import "ExploreArticleEssayADTypeCell.h"
#import "ExploreArticleEssayADTypeCellView.h"
#import "TTFeedContainerViewModel.h"

@implementation ExploreArticleEssayADTypeCell

+ (Class)cellViewClass
{
    return [ExploreArticleEssayADTypeCellView class];
}

- (ExploreCellViewBase *)createCellView
{
    ExploreArticleEssayADTypeCellView * cellView = [[[[self class] cellViewClass] alloc] initWithFrame:self.contentView.bounds];
    return cellView;
}

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(TTFeedContainerViewModel *)viewModel
{
    [super didSelectAtIndexPath:indexPath viewModel:viewModel];
}

@end
