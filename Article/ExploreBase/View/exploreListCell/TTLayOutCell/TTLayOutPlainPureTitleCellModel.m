//
//  TTLayOutPlainPureTitleCellModel.m
//  Article
//
//  Created by 王双华 on 16/10/17.
//
//

#import "TTLayOutPlainPureTitleCellModel.h"

@implementation TTLayOutPlainPureTitleCellModel

- (CGFloat)heightForInfoBarTopPadding
{
    return kCellTitleBottomPaddingToInfo;
}

- (CGFloat)heightForCellBottomPadding
{
    return kCellBottomPadding;
}

@end

@implementation TTLayOutPlainPureTitleCellModelS0

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
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

@implementation TTLayOutPlainPureTitleCellModelS0AD

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
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

@implementation TTLayOutPlainPureTitleCellModelS1

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForHeaderInfoRegionWithTop:height];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
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

@implementation TTLayOutPlainPureTitleCellModelS2

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForHeaderInfoRegionInTwoLinesWithTop:height needLayoutDislike:NO];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
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

- (void)calculateNeedUpdateFrame
{
    if (self.infoBarOriginY > 0 && self.infoBarContainWidth > 0) {
        [self calculateBottomLineFrame];
        [self heightForArticleInfoRegionWithTop:self.infoBarOriginY containWidth:self.infoBarContainWidth];
        [self heightForHeaderInfoRegionInTwoLinesWithTop:self.sourceImageViewFrame.origin.y needLayoutDislike:NO];
    }
}

@end
