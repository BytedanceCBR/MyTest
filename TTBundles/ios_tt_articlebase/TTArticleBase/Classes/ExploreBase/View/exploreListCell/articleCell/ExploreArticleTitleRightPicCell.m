//
//  ExploreArticleTitleRightPicCell.m
//  Article
//
//  Created by Chen Hong on 14-9-14.
//
//

#import "ExploreArticleTitleRightPicCell.h"
#import "ExploreArticleTitleRightPicCellView.h"

@interface ExploreArticleTitleRightPicCell()
@property (nonatomic, strong) ExploreArticleTitleRightPicCellView *rightPicCellView;
@end

@implementation ExploreArticleTitleRightPicCell

+ (Class)cellViewClass
{
    return [ExploreArticleTitleRightPicCellView class];
}

- (ExploreCellViewBase *)createCellView
{
    if (!_rightPicCellView) {
        self.rightPicCellView = [[ExploreArticleTitleRightPicCellView alloc] initWithFrame:self.bounds];
    }
    return _rightPicCellView;
}

//- (UIView *)animationFromView
//{
//    return [self.rightPicCellView animationFromView];
//}
//
//- (UIImage *)animationFromImage
//{
//    return [self.rightPicCellView animationFromImage];
//}

@end
