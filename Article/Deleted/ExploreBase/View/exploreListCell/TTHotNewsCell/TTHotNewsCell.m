//
//  TTHotNewsCell.m
//  Article
//
//  Created by Sunhaiyuan on 2018/1/22.
//

#import "TTHotNewsCell.h"
#import "TTHotNewsCellView.h"

@implementation TTHotNewsCell

+ (Class)cellViewClass {
    return [TTHotNewsCellView class];
}

- (ExploreCellViewBase *)createCellView {
    TTHotNewsCellView *cellView = [[[[self class] cellViewClass] alloc] initWithFrame:self.contentView.bounds];
    return cellView;
}

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(TTFeedContainerViewModel *)viewModel {
    [super didSelectAtIndexPath:indexPath viewModel:viewModel];
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    [super didSelectWithContext:context];
}

@end
