//
//  TTLayOutPlainGroupPicCellModel.m
//  Article
//
//  Created by 王双华 on 16/10/17.
//
//

#import "TTLayOutPlainGroupPicCellModel.h"

@implementation TTLayOutPlainGroupPicCellModel

- (CGFloat)heightForGroupPicRegionWithTop:(CGFloat)top
{
    CGFloat height = 0;
    
    top += kCellGroupPicTopPadding;
    CGRect picFrame = CGRectZero;
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:self.orderedData adModel:nil picStyle:TTArticlePicViewStyleTriple width:self.cellWidth];
    picFrame = CGRectMake(0, top, picSize.width, picSize.height);
    self.picViewFrame = picFrame;
    self.picViewHidden = NO;
    self.picViewStyle = TTArticlePicViewStyleTriple;
    self.picViewHiddenMessage = NO;
    self.picViewUserInteractionEnabled = YES;
    
    height = kCellGroupPicTopPadding + picSize.height;
    
    return height;
}

@end

@implementation TTLayOutPlainGroupPicCellModelS0

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
    height += [self heightForGroupPicRegionWithTop:height];
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

@implementation TTLayOutPlainGroupPicCellModelS0AD

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
    height += [self heightForGroupPicRegionWithTop:height];
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

- (CGFloat)heightForArticleInfoRegionWithTop:(CGFloat)top containWidth:(CGFloat)containWidth
{
    CGFloat left = self.originX;
    CGFloat labelY = top + floor((kCellInfoBarHeight - kCellTypeLabelHeight) / 2);;
    NSString *typeString = [TTLayOutCellDataHelper getTypeStringWithOrderedData:self.orderedData];
    
    CGFloat sourceMaxWidth = containWidth - kCellUninterestedButtonWidth - 4;
    
    if (!isEmptyString(typeString)) {
        //优化，字符串相同时避免重复计算
        if (![self.typeLabelStr isEqualToString:typeString]) {
            CGSize typeSize = [typeString sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kCellTypeLabelFontSize]}];
            typeSize = CGSizeMake(ceilf(typeSize.width), ceilf(typeSize.height));
            CGRect typeLabelFrame = CGRectMake(left, labelY, typeSize.width + kCellTypeLabelInnerPadding * 2, kCellTypeLabelHeight);
            self.typeLabelFrame = typeLabelFrame;
            self.typeLabelStr = typeString;
        }
        left += self.typeLabelFrame.size.width + kCellTypelabelRightPaddingToInfoLabel;
        sourceMaxWidth -= (self.typeLabelFrame.size.width + kCellTypelabelRightPaddingToInfoLabel);
        self.typeLabelHidden = NO;
    }
    
    self.unInterestedButtonHidden = YES;
    return self.typeLabelFrame.size.height;
}

@end

@implementation TTLayOutPlainGroupPicCellModelS1

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForHeaderInfoRegionWithTop:height];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
    height += [self heightForGroupPicRegionWithTop:height];
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

@implementation TTLayOutPlainGroupPicCellModelS2

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForHeaderInfoRegionInTwoLinesWithTop:height needLayoutDislike:NO];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
    height += [self heightForGroupPicRegionWithTop:height];
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

