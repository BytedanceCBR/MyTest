//
//  ExploreArticleEssayGIFCell.m
//  Article
//
//  Created by Chen Hong on 14-9-16.
//
//

#import "ExploreArticleEssayGIFCell.h"
#import "ExploreArticleEssayGIFCellView.h"
#import "EssayDetailViewController.h"
#import "TTFeedContainerViewModel.h"


@implementation ExploreArticleEssayGIFCell

+ (Class)cellViewClass
{
    return [ExploreArticleEssayGIFCellView class];
}

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(TTFeedContainerViewModel *)viewModel {
    [super didSelectAtIndexPath:indexPath viewModel:viewModel];
    EssayData * essayData = (EssayData *)(((ExploreOrderedData *)self.cellData).originalData);
    EssayDetailViewController * controller = [[EssayDetailViewController alloc] initWithEssayData:essayData scrollToComment:NO trackEvent:@"essay_tab" trackLabel:viewModel.categoryID];
    [[TTUIResponderHelper topNavigationControllerFor:self] pushViewController:controller animated:YES];
}

@end
