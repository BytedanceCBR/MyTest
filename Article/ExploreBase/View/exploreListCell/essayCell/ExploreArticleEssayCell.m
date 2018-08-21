//
//  ExploreArticleEssayCell.m
//  Article
//
//  Created by Chen Hong on 14-9-16.
//
//

#import "ExploreArticleEssayCell.h"
#import "ExploreArticleEssayCellView.h"
#import "EssayDetailViewController.h"
#import "TTFeedContainerViewModel.h"


@implementation ExploreArticleEssayCell

+ (Class)cellViewClass
{
    return [ExploreArticleEssayCellView class];
}

- (ExploreCellViewBase *)createCellView
{
    ExploreArticleEssayCellView * cellView = [[[[self class] cellViewClass] alloc] initWithFrame:self.contentView.bounds];
    cellView.from = EssayCellStyleList;
    return cellView;
}

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(TTFeedContainerViewModel *)viewModel {
    [super didSelectAtIndexPath:indexPath viewModel:viewModel];
    EssayData * essayData = (EssayData *)(((ExploreOrderedData *)self.cellData).originalData);
    EssayDetailViewController * controller = [[EssayDetailViewController alloc] initWithEssayData:essayData scrollToComment:NO trackEvent:@"essay_tab" trackLabel:viewModel.categoryID];
    [[TTUIResponderHelper topNavigationControllerFor:self] pushViewController:controller animated:YES];
}

@end
