//
//  TTArticleTitleLargePicHuoShanCell.m
//  Article
//
//  Created by xuzichao on 16/6/13.
//
//

#import "TTArticleTitleLargePicHuoShanCell.h"
#import "TTArticleTitleLargePicHuoShanCellView.h"

@interface TTArticleTitleLargePicHuoShanCell()

@property(nonatomic, strong)TTArticleTitleLargePicHuoShanCellView * playVideoCellView;
@end

@implementation TTArticleTitleLargePicHuoShanCell


+ (Class)cellViewClass
{
    return [TTArticleTitleLargePicHuoShanCellView class];
}

- (ExploreCellViewBase *)createCellView
{
    if (!_playVideoCellView) {
        self.playVideoCellView = [[TTArticleTitleLargePicHuoShanCellView alloc] initWithFrame:self.bounds];
    }
    return _playVideoCellView;
}

- (void)didEndDisplaying
{
    [_playVideoCellView didEndDisplaying];
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context
{
    [_playVideoCellView cellInListWillDisappear:context];
}


@end