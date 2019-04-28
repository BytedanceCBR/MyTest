//
//  ExploreSubscribePGCCell.m
//  Article
//
//  Created by Huaqing Luo on 24/11/14.
//
//

#import "ExploreSubscribePGCCell.h"
#import "ExploreSubscribePGCCellView.h"
// #import "ExploreEntryManager.h"

@implementation ExploreSubscribePGCCell

+ (Class)cellViewClass
{
    return [ExploreSubscribePGCCellView class];
}

- (void)hideBottomLine
{
    [(ExploreSubscribePGCCellView *)(self.cellView) doHideBottomLine];
}

- (void)hideBadge
{
    [(ExploreSubscribePGCCellView *)(self.cellView) hideBadge];
}

@end
