//
//  TTLayOutUnifyADRightPicCellModel.m
//  Article
//
//  Created by 王双华 on 16/10/24.
//
//

#import "TTLayOutUnifyADRightPicCellModel.h"

@implementation TTLayOutUnifyADRightPicCellModel

- (CGFloat)heightForTitleAndRightPicAndInfoRegionWithTop:(CGFloat)top
{
    CGFloat regionHeight = 0;

    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:nil adModel:nil picStyle:TTArticlePicViewStyleRight width:self.containWidth];
    CGFloat titleWidth = self.containWidth - picSize.width - kPaddingTitleToPic();
    CGFloat picX = self.originX + titleWidth + kPaddingTitleToPic();
    CGSize titleSize = CGSizeMake(titleWidth, 0);
    
    CGFloat leftHeight = 0;
    NSString *titleStr = [TTLayOutCellDataHelper getTitleStringWithOrderedData:self.orderedData];
    NSAttributedString *titleAttributedStr = [TTLabelTextHelper attributedStringWithString:titleStr fontSize:kTitleViewFontSize() lineHeight:kTitleViewLineHeight() lineBreakMode:NSLineBreakByTruncatingTail];
    self.titleAttributedStr = titleAttributedStr;
    titleSize.height = [TTLabelTextHelper heightOfText:titleStr fontSize:kTitleViewFontSize() forWidth:titleSize.width forLineHeight:kTitleViewLineHeight() constraintToMaxNumberOfLines:kTitleViewLineNumber()];
    CGFloat titlePadding = kTitleViewLineHeight() - kTitleViewFontSize();
    CGFloat titleRealHeight = titleSize.height - titlePadding;
    
    leftHeight += titleRealHeight + kPaddingInfoTop();
    
    CGSize infoSize = [TTArticleCellHelper getInfoSize:titleWidth];
    CGFloat infoHeight = kInfoViewHeight();
    
    leftHeight += infoHeight;
    CGFloat picY = 0;
    CGFloat titleY = 0;
    CGFloat infoY = 0;
    if (leftHeight >= picSize.height) {
        titleY = top - titlePadding / 2;
        picY = ceil(top + (leftHeight - picSize.height) / 2);
        infoY = top + titleRealHeight + kPaddingInfoTop();
        regionHeight = leftHeight;
    }
    else{
        titleY = ceil(top + (picSize.height - leftHeight) / 2 - titlePadding / 2);
        picY = top;
        infoY = ceil(titleY + titleSize.height - titlePadding / 2 + kPaddingInfoTop());
        regionHeight = picSize.height;
    }
    CGRect picFrame = CGRectMake(picX, picY, picSize.width, picSize.height);
    self.picViewFrame = picFrame;
    self.picViewHidden = NO;
    self.picViewStyle = TTArticlePicViewStyleRight;
    self.picViewHiddenMessage = YES;
    self.picViewUserInteractionEnabled = YES;
    
    CGRect titleFrame = CGRectMake(self.originX, titleY, titleSize.width, titleSize.height);
    self.titleLabelFrame = titleFrame;
    self.titleLabelHidden = NO;
    self.titleLabelNumberOfLines = kTitleViewSpecialLineNumber();
    
    self.infoBarOriginY = infoY;
    self.infoBarContainWidth = infoSize.width;
    [self heightForInfoRegionWithTop:self.infoBarOriginY containWidth:self.infoBarContainWidth];
    
    return regionHeight;
}


- (void)calculateAllFrame
{
    self.originX = kPaddingLeft();
    self.containWidth = self.cellWidth - kPaddingLeft() - kPaddingRight();
    
    CGFloat height = 0;
    
    height += kPaddingTop();
    height += [self heightForTitleAndRightPicAndInfoRegionWithTop:height];
    height += kPaddingActionADTop();
    height += [self heightForADActionRegionWithTop:height];
    height += kPaddingBottom();
    
    self.cellCacheHeight = ceilf(height);
    
    [self calculateBottomLineFrame];
}

@end
