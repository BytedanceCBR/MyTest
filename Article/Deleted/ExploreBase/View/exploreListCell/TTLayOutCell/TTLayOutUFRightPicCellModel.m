//
//  TTLayOutUFRightPicCellModel.m
//  Article
//
//  Created by 王双华 on 17/1/11.
//
//

#import "TTLayOutUFRightPicCellModel.h"

@implementation TTLayOutUFRightPicCellModel

//u11cell 右图标题与图片上对齐
- (CGFloat)heightForTitleAndRightPicWithTop:(CGFloat)top
{
    CGFloat regionHeight = 0;
    
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:nil adModel:nil picStyle:TTArticlePicViewStyleRight width:self.containWidth];
    CGSize titleSize = CGSizeMake(self.containWidth - kCellTitleRightPaddingToPic - picSize.width, 0);
    
    NSString *titleStr = [TTLayOutCellDataHelper getTitleStringWithOrderedData:self.orderedData];
    NSAttributedString *titleAttributedStr = [TTLabelTextHelper attributedStringWithString:titleStr fontSize:kCellTitleLabelFontSize lineHeight:kCellTitleLineHeight lineBreakMode:NSLineBreakByTruncatingTail isBoldFontStyle:YES];
    self.titleAttributedStr = titleAttributedStr;
    titleSize.height = [TTLabelTextHelper heightOfText:titleStr fontSize:kCellTitleLabelFontSize forWidth:titleSize.width forLineHeight:kCellTitleLineHeight constraintToMaxNumberOfLines:kCellRightPicTitleLabelMaxLine
                                                isBold:YES];
    CGFloat titlePadding = kCellTitleLineHeight - kCellTitleLabelFontSize;
    CGFloat titleRealHeight = titleSize.height - titlePadding;
    
    CGFloat picX = self.cellWidth - kCellRightPadding - picSize.width;
    CGFloat picY = top;
    
    CGFloat titleY = ceilf(top - titlePadding / 2);
    
    if (titleRealHeight > picSize.height) {
        regionHeight = titleRealHeight;
    }
    else{
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
    
    return regionHeight;
}

@end

@implementation TTLayOutUFRightPicCellModelS2

- (CGFloat)heightForCellContentWithTop:(CGFloat)top
{
    CGFloat height = 0;
    height += [self heightForHeaderInfoRegionInTwoLinesWithTop:top needLayoutDislike:YES];
    height += [self heightForTitleAndRightPicWithTop:top + height];
    self.actionLabelY = top + height;
    height += [self heightForActionLabelRegionWithTop:top + height];
    height += [self heightForActionButtonRegionWithTop:top + height];
    return height;
}

- (void)calculateNeedUpdateFrame
{
    [self heightForHeaderInfoRegionInTwoLinesWithTop:self.sourceImageViewFrame.origin.y needLayoutDislike:YES];
    [self heightForActionLabelRegionWithTop:self.actionLabelY];
}
@end
