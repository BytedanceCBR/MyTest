//
//  ExploreLastReadCell.m
//  Article
//
//  Created by 冯靖君 on 15/5/24.
//
//

#import "ExploreLastReadCell.h"
#import "SSThemed.h"
#import "ExploreLastReadCellView.h"
#import "TTFeedContainerViewModel.h"
#import "UIScrollView+Refresh.h"

@implementation ExploreLastReadCell

+ (Class)cellViewClass
{
    return [ExploreLastReadCellView class];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
   
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.cellView.backgroundColor = SSGetThemedColorWithKey(kColorBackground3Highlighted);
    }
    else
        self.cellView.backgroundColor = SSGetThemedColorWithKey(kColorBackground3);

}

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(TTFeedContainerViewModel *)viewModel {
    [super didSelectAtIndexPath:indexPath viewModel:viewModel];
    
    if (viewModel.hasNew) {
        [self.tableView triggerPullDown];
    }

}

@end
