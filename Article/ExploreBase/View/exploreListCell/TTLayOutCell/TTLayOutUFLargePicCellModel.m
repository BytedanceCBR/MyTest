//
//  TTLayOutU11LargePicCellModel.m
//  Article
//
//  Created by 王双华 on 16/11/3.
//
//

#import "TTLayOutUFLargePicCellModel.h"

@implementation TTLayOutUFLargePicCellModel

- (CGFloat)heightForTitleRegionWithTop:(CGFloat)top
{
    CGFloat height = 0;
    CGFloat left = self.originX;
    NSString *titleStr = [TTLayOutCellDataHelper getTitleStringWithOrderedData:self.orderedData];
    CGSize titleSize = CGSizeMake(self.containWidth, 0);
    NSAttributedString *titleAttributedStr = [TTLabelTextHelper attributedStringWithString:titleStr fontSize:kTitleViewFontSize() lineHeight:kTitleViewLineHeight() lineBreakMode:NSLineBreakByTruncatingTail isBoldFontStyle:YES];
    self.titleAttributedStr = titleAttributedStr;
    titleSize.height = [TTLabelTextHelper heightOfText:titleStr fontSize:kTitleViewFontSize() forWidth:self.containWidth forLineHeight:kTitleViewLineHeight() constraintToMaxNumberOfLines:kTitleViewLineNumber()
                                                isBold:YES];
    CGFloat titlePadding = kTitleViewLineHeight() - kTitleViewFontSize();
    CGFloat titleY = top - titlePadding / 2;
    height = titleSize.height - titlePadding;
    CGRect titleLabelFrame = CGRectMake(left, titleY, titleSize.width, titleSize.height);
    self.titleLabelFrame = titleLabelFrame;
    self.titleLabelHidden = NO;
    self.titleLabelNumberOfLines = kCellTitleLabelMaxLine;
    return height;
}

- (CGFloat)heightForPicViewRegionWithTop:(CGFloat)top
{
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:self.orderedData picStyle:TTArticlePicViewStyleLarge width:self.containWidth];
    CGRect picViewFrame = CGRectMake(self.originX, top, picSize.width, picSize.height);
    self.picViewFrame = picViewFrame;
    self.picViewHidden = NO;
    self.picViewStyle = TTArticlePicViewStyleLarge;
    self.picViewHiddenMessage = NO;
    self.picViewUserInteractionEnabled = YES;
    
    if ([[self.orderedData.article hasVideo] boolValue]){
        if ([TTLayOutCellDataHelper shouldShowPlayButtonWithOrderedData:self.orderedData]) {
            self.playButtonFrame = CGRectMake(0, 0, picSize.width, picSize.height);
            self.playButtonHidden = NO;
            self.playButtonImageName = [TTDeviceHelper isPadDevice] ? @"FullPlay" : @"Play";
            self.playButtonUserInteractionEnable = ![self.orderedData isPlayInDetailView];
        }
    }
    
    return picSize.height;
}

@end

@implementation TTLayOutUFLargePicCellModelS2

- (CGFloat)heightForCellContentWithTop:(CGFloat)top
{
    CGFloat height = 0;
    CGFloat padding = 0;
    if (self.orderedData.cellLayOut.isExpand) {
        padding = 5;
    }
    height += [self heightForHeaderInfoRegionInTwoLinesWithTop:top needLayoutDislike:YES];
    height += [self heightForTitleRegionWithTop:top + height + padding];
    height += kPaddingPicTop();
    height += [self heightForPicViewRegionWithTop:top + height];
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
