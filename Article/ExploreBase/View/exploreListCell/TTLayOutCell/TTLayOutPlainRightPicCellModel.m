//
//  TTLayOutPlainRightPicCellModel.m
//  Article
//
//  Created by 王双华 on 16/10/17.
//
//

#import "TTLayOutPlainRightPicCellModel.h"

@implementation TTLayOutPlainRightPicCellModel

- (CGFloat)heightForCellTopPadding
{
    return kCellTopPaddingWithRightPic;
}

//标题与图片居中
- (CGFloat)heightForTitleAndRightPicAndInfoRegionInPlainCellWithTop:(CGFloat)top
{
    CGFloat regionHeight = 0;
    CGFloat originTop = top;
    
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:nil adModel:nil picStyle:TTArticlePicViewStyleRight width:self.containWidth];
    CGSize titleSize = CGSizeMake(self.containWidth - kCellTitleRightPaddingToPic - picSize.width, 0);
    
    NSString *titleStr = [TTLayOutCellDataHelper getTitleStringWithOrderedData:self.orderedData];
    NSAttributedString *titleAttributedStr = [TTLabelTextHelper attributedStringWithString:titleStr fontSize:kCellTitleLabelFontSize lineHeight:kCellTitleLineHeight lineBreakMode:NSLineBreakByTruncatingTail];
    self.titleAttributedStr = titleAttributedStr;
    titleSize.height = [TTLabelTextHelper heightOfText:titleStr fontSize:kCellTitleLabelFontSize forWidth:titleSize.width forLineHeight:kCellTitleLineHeight constraintToMaxNumberOfLines:kCellRightPicTitleLabelMaxLine];
    CGFloat titlePadding = kCellTitleLineHeight - kCellTitleLabelFontSize;
    CGFloat titleRealHeight = titleSize.height - titlePadding;
    CGFloat titleAndSourceHeight = titleRealHeight + kCellInfoBarHeight + kCellTitleBottomPaddingToInfo;
//    不显示info
//    titleAndSourceHeight = titleRealHeight;
    
    CGFloat titleY = 0;
    CGFloat picY = 0;
    CGFloat picX = self.cellWidth - kCellRightPadding - picSize.width;
    
    CGFloat infoBarWidth = self.containWidth;
    
    if (titleAndSourceHeight > picSize.height) {
        self.hideTimeForRightPic = NO;
        if (titleRealHeight > picSize.height) {
            // 标题与图片y方向居中对齐
            titleY = top - titlePadding / 2;
            picY = ceil((titleSize.height - picSize.height) / 2 + titleY);
        }
        else {
            picY = top;
            titleY = ceil((picSize.height - titleSize.height) / 2 + picY);
        }
        top = MAX(titleY + titleSize.height - titlePadding / 2, picY + picSize.height) + kCellInfoBarTopPadding;
        infoBarWidth = self.containWidth;
        regionHeight = top + kCellInfoBarHeight - originTop;
    }
    else {
        self.hideTimeForRightPic = YES;
        picY = top;
        titleY = ceil(top + (picSize.height - titleAndSourceHeight) / 2 - titlePadding / 2);
        top = titleY + titleSize.height - titlePadding / 2 + kCellInfoBarTopPadding;
        CGFloat padding = kCellUninterestedButtonRightPadding;
        infoBarWidth = picX - kCellLeftPadding - padding;
        self.originY = picY + picSize.height;
        regionHeight = picSize.height;
    }
    
    CGRect titleFrame = CGRectMake(kCellLeftPadding, titleY, titleSize.width, titleSize.height);
    self.titleLabelFrame = titleFrame;
    self.titleLabelHidden = NO;
    self.titleLabelNumberOfLines = kCellRightPicTitleLabelMaxLine;
    
    CGRect picFrame = CGRectMake(picX, picY, picSize.width, picSize.height);
    self.picViewFrame = picFrame;
    self.picViewHidden = NO;
    self.picViewStyle = TTArticlePicViewStyleRight;
    self.picViewHiddenMessage = NO;
    self.picViewUserInteractionEnabled = YES;
    
    self.infoBarOriginY = top;
    self.infoBarContainWidth = infoBarWidth;
    
    [self heightForArticleInfoRegionWithTop:self.infoBarOriginY containWidth:self.infoBarContainWidth];
    
    return regionHeight;
}

//u11cell 右图标题与图片上对齐
- (CGFloat)heightForTitleAndRightPicAndInfoRegionInUFCellWithTop:(CGFloat)top
{
    CGFloat regionHeight = 0;
    CGFloat originTop = top;
    
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:nil adModel:nil picStyle:TTArticlePicViewStyleRight width:self.containWidth];
    CGSize titleSize = CGSizeMake(self.containWidth - kCellTitleRightPaddingToPic - picSize.width, 0);
    
    NSString *titleStr = [TTLayOutCellDataHelper getTitleStringWithOrderedData:self.orderedData];
    NSAttributedString *titleAttributedStr = [TTLabelTextHelper attributedStringWithString:titleStr fontSize:kCellTitleLabelFontSize lineHeight:kCellTitleLineHeight lineBreakMode:NSLineBreakByTruncatingTail];
    self.titleAttributedStr = titleAttributedStr;
    titleSize.height = [TTLabelTextHelper heightOfText:titleStr fontSize:kCellTitleLabelFontSize forWidth:titleSize.width forLineHeight:kCellTitleLineHeight constraintToMaxNumberOfLines:kCellRightPicTitleLabelMaxLine];
    CGFloat titlePadding = kCellTitleLineHeight - kCellTitleLabelFontSize;
    CGFloat titleRealHeight = titleSize.height - titlePadding;
    CGFloat titleAndSourceHeight = titleRealHeight + kCellInfoBarHeight + kCellTitleBottomPaddingToInfo;
    
    CGFloat picX = self.cellWidth - kCellRightPadding - picSize.width;
    CGFloat picY = top;
    
    CGFloat titleY = ceilf(top - titlePadding / 2);
    
    self.infoBarContainWidth = self.containWidth;
    if (titleAndSourceHeight > picSize.height) {
        self.hideTimeForRightPic = NO;
        self.infoBarOriginY = MAX(titleY + titleSize.height - titlePadding / 2, picY + picSize.height) + kCellInfoBarTopPadding;
        regionHeight = self.infoBarOriginY + kCellInfoBarHeight - originTop;
    }
    else{
        self.hideTimeForRightPic = YES;
        self.infoBarContainWidth = picX - self.originX - kCellUninterestedButtonRightPadding;
        self.infoBarOriginY = titleY + titleSize.height - titlePadding / 2 + kCellTitleBottomPaddingToInfo;
        regionHeight = picSize.height;
    }
    
    self.titleLabelFrame = CGRectMake(self.originX, titleY, titleSize.width, titleSize.height);
    self.titleLabelHidden = NO;
    self.titleLabelNumberOfLines = kCellRightPicTitleLabelMaxLine;
    
    self.picViewFrame = CGRectMake(picX, picY, picSize.width, picSize.height);
    self.picViewHidden = NO;
    self.picViewStyle = TTArticlePicViewStyleRight;
    self.picViewHiddenMessage = NO;
    self.picViewUserInteractionEnabled = YES;
    
    [self heightForArticleInfoRegionWithTop:self.infoBarOriginY containWidth:self.infoBarContainWidth];
    return regionHeight;
}

@end


@implementation TTLayOutPlainRightPicCellModelS0

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    //右图 info和title和picview在一个区域
    height += [self heightForTitleAndRightPicAndInfoRegionInPlainCellWithTop:height];
    height += [self heightForAbstractRegionWithTop:height];
    height += [self heightForCommentRegionWithTop:height];
    height += [self heightForEntityWordViewRegionWithTop:height];
    height += [self heightForCellBottomPadding];
    
    self.cellCacheHeight = ceilf(height);
    
    [self calculateBottomLineFrame];
}

@end

@implementation TTLayOutPlainRightPicCellModelS1

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForHeaderInfoRegionWithTop:height];
    //右图 info和title和picview在一个区域
    height += [self heightForTitleAndRightPicAndInfoRegionInUFCellWithTop:height];
    height += [self heightForAbstractRegionWithTop:height];
    height += [self heightForCommentRegionWithTop:height];
    height += [self heightForEntityWordViewRegionWithTop:height];
    height += [self heightForCellBottomPadding];
    
    self.cellCacheHeight = ceilf(height);
    
    [self calculateBottomLineFrame];
}

@end

@implementation TTLayOutPlainRightPicCellModelS2

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForHeaderInfoRegionInTwoLinesWithTop:height needLayoutDislike:NO];
    //右图 info和title和picview在一个区域
    height += [self heightForTitleAndRightPicAndInfoRegionInUFCellWithTop:height];
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
