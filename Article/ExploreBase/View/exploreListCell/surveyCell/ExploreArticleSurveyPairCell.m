//
//  ExploreArticleSurveyPairCell.m
//  Article
//
//  Created by chenren on 9/05/17.
//
//

#import "ExploreArticleSurveyPairCell.h"
#import "ExploreArticleSurveyPairCellView.h"
#import "TTFeedContainerViewModel.h"

@implementation ExploreArticleSurveyPairCell

+ (Class)cellViewClass
{
    return [ExploreArticleSurveyPairCellView class];
}

- (ExploreCellViewBase *)createCellView
{
    ExploreArticleSurveyPairCellView * cellView = [[[[self class] cellViewClass] alloc] initWithFrame:self.contentView.bounds];
    return cellView;
}

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(TTFeedContainerViewModel *)viewModel
{
    [super didSelectAtIndexPath:indexPath viewModel:viewModel];
}

@end
