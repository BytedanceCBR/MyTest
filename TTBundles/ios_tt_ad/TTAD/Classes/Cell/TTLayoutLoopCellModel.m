//
//  TTLayoutLoopCellModel.m
//  Article
//
//  Created by 曹清然 on 2017/6/20.
//
//

#import "TTLayoutLoopCellModel.h"

@implementation TTLayoutLoopCellModel

- (CGFloat)heightForLoopPicRegionWithTop:(CGFloat)top
{
    CGFloat height = 0;
    
    top += kCellGroupPicTopPadding;
    CGRect picFrame = CGRectZero;
    
    CGSize loopPicSize = [TTArticleCellHelper getLoopPicSizeWithOrderData:self.orderedData WithContainWidth:(self.cellWidth)  WithPicPadding:KCellLoopPicInnerPadding WithEdgePadding:kCellLeftPadding];
    
    picFrame = CGRectMake(0, top, self.cellWidth, loopPicSize.height);
    self.adInnerLoopPicViewFrame = picFrame;
    self.adInnerLoopPicViewHidden = NO;
    self.adInnerLoopPerPicSize = loopPicSize;

    height = kCellGroupPicTopPadding + loopPicSize.height;
    return height;
}

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
    height += [self heightForLoopPicRegionWithTop:height];
    height += [self heightForInfoBarTopPadding];
    self.infoBarOriginY = height;
    self.infoBarContainWidth = self.containWidth;
    height += [self heightForArticleInfoRegionWithTop:self.infoBarOriginY containWidth:self.infoBarContainWidth];
    height += [self heightForAbstractRegionWithTop:height];
    height += [self heightForCommentRegionWithTop:height];
    height += [self heightForEntityWordViewRegionWithTop:height];
    height += [self heightForCellBottomPadding];
    
    self.cellCacheHeight = ceilf(height);
    
    [self calculateBottomLineFrame];
}

@end
