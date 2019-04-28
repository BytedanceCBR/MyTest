//
//  ExploreArticleSurveyListCell.m
//  Article
//
//  Created by chenren on 9/18/17.
//
//

#import "ExploreArticleSurveyListCell.h"
#import "ExploreArticleSurveyListCellView.h"
#import "TTFeedContainerViewModel.h"

@implementation ExploreArticleSurveyListCell

+ (Class)cellViewClass
{
    return [ExploreArticleSurveyListCellView class];
}

- (ExploreCellViewBase *)createCellView
{
    ExploreArticleSurveyListCellView * cellView = [[[[self class] cellViewClass] alloc] initWithFrame:self.contentView.bounds];
    return cellView;
}

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(TTFeedContainerViewModel *)viewModel
{
    [super didSelectAtIndexPath:indexPath viewModel:viewModel];
}

@end
