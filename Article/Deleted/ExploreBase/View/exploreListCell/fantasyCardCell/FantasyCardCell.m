//
//  FantasyCardCell.h
//  Article
//
//  Created by chenren on 1/02/18.
//
//

#import "FantasyCardCell.h"
#import "FantasyCardCellView.h"
#import "TTFeedContainerViewModel.h"

@implementation FantasyCardCell

+ (Class)cellViewClass
{
    return [FantasyCardCellView class];
}

- (ExploreCellViewBase *)createCellView
{
    FantasyCardCellView * cellView = [[[[self class] cellViewClass] alloc] initWithFrame:self.contentView.bounds];
    return cellView;
}

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(TTFeedContainerViewModel *)viewModel
{
    [super didSelectAtIndexPath:indexPath viewModel:viewModel];
}

@end
