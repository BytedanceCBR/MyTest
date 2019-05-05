//
//  TTMeiNvTitleLargePicHuoShanCell.m
//  Article
//
//  Created by  xuzichao on 16/6/15.
//
//

#import "TTMeiNvTitleLargePicHuoShanCell.h"
#import "TTMeiNvTitleLargePicHuoShanCellView.h"

@interface TTMeiNvTitleLargePicHuoShanCell()

@property(nonatomic, strong)TTMeiNvTitleLargePicHuoShanCellView * playVideoCellView;
@end

@implementation TTMeiNvTitleLargePicHuoShanCell


+ (Class)cellViewClass
{
    return [TTMeiNvTitleLargePicHuoShanCellView class];
}

- (ExploreCellViewBase *)createCellView
{
    if (!_playVideoCellView) {
        self.playVideoCellView = [[TTMeiNvTitleLargePicHuoShanCellView alloc] initWithFrame:self.bounds];
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