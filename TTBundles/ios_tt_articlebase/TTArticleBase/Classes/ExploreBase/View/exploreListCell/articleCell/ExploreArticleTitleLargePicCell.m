//
//  ExploreArticleTitleLargePicCell.m
//  Article
//
//  Created by Chen Hong on 14-9-14.
//
//

#import "ExploreArticleTitleLargePicCell.h"
#import "ExploreArticleTitleLargePicCellView.h"

@interface ExploreArticleTitleLargePicCell()
@property (nonatomic, strong) ExploreArticleTitleLargePicCellView *picCellView;
@end

@implementation ExploreArticleTitleLargePicCell

+ (Class)cellViewClass
{
    return [ExploreArticleTitleLargePicCellView class];
}

- (ExploreCellViewBase *)createCellView
{
    if (!_picCellView) {
        self.picCellView = [[ExploreArticleTitleLargePicCellView alloc] initWithFrame:self.bounds];
    }
    return _picCellView;
}

//- (UIView *)animationFromView
//{
//    return [self.picCellView animationFromView];
//}
//
//- (UIImage *)animationFromImage
//{
//    return [self.picCellView animationFromImage];
//}

@end

