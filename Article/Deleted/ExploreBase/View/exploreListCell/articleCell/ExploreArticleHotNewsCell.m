//
//  ExploreArticleHotNewsCell.m
//  Article
//
//  Created by Sunhaiyuan on 2018/1/29.
//

#import "ExploreArticleHotNewsCell.h"
#import "ExploreArticleHotNewsCellView.h"

@implementation ExploreArticleHotNewsCell

+ (Class)cellViewClass {
    return [ExploreArticleHotNewsCellView class];
}

- (ExploreCellViewBase *)createCellView {
    ExploreArticleHotNewsCellView *cellView = [[[[self class] cellViewClass] alloc] initWithFrame:self.contentView.bounds];
    return cellView;
}

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(TTFeedContainerViewModel *)viewModel {
    [super didSelectAtIndexPath:indexPath viewModel:viewModel];
}

@end
