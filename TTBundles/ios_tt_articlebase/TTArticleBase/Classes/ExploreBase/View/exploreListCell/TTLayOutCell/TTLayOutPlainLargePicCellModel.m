//
//  TTLayOutPlainLargePicCellModel.m
//  Article
//
//  Created by 王双华 on 16/10/17.
//
//

#import "TTLayOutPlainLargePicCellModel.h"
#import "ExploreOrderedData+TTAd.h"

@implementation TTLayOutPlainLargePicCellModel

- (CGFloat)heightForLargePicRegionWithTop:(CGFloat)top
{
    CGFloat regionHeight = 0;
    top += kCellGroupPicTopPadding;
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:self.orderedData adModel:nil picStyle:TTArticlePicViewStyleLarge width:self.containWidth];
    self.picViewFrame = CGRectMake(self.originX, top, picSize.width, picSize.height);
    self.picViewHidden = NO;
    self.picViewStyle = TTArticlePicViewStyleLarge;
    self.picViewHiddenMessage = NO;
    self.picViewUserInteractionEnabled = YES;
    
    top += picSize.height;
    regionHeight += kCellGroupPicTopPadding + picSize.height;
    if ([[self.orderedData.article hasVideo] boolValue]){
        if ([TTLayOutCellDataHelper shouldShowPlayButtonWithOrderedData:self.orderedData]) {
            self.playButtonFrame = CGRectMake(0, 0, picSize.width, picSize.height);
            self.playButtonHidden = NO;
            self.playButtonImageName = [TTDeviceHelper isPadDevice] ? @"FullPlay" : @"Play";
            self.playButtonUserInteractionEnable = ![self.orderedData isPlayInDetailView];
        }
        
        if ([self.orderedData isAdButtonUnderPic]) {//视频广告按钮在下的样式
            CGSize ADActionSize = [TTArticleCellHelper getADActionSize:self.containWidth];
            self.adBackgroundViewFrame = CGRectMake(self.originX, top, ADActionSize.width, ADActionSize.height);
            self.adBackgroundViewHidden = NO;
            
            NSString *adSubtitleStr = [TTLayOutCellDataHelper getSubtitleStringWithOrderedData:self.orderedData];
            CGSize adSubtitleSize = [adSubtitleStr sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:14]}];
            adSubtitleSize = CGSizeMake(ceilf(adSubtitleSize.width), ceilf(adSubtitleSize.height));
            CGRect adSourceFrame = CGRectMake(self.originX + 9, top + floor((ADActionSize.height - adSubtitleSize.height) / 2) - 4, ADActionSize.width - 115, adSubtitleSize.height);

            self.adSubtitleLabelFrame = adSourceFrame;
            self.adSubtitleLabelHidden = NO;
            self.adSubtitleLabelFontSize = 14;
            self.adSubtitleLabelTextColorThemeKey = kColorText2;
            self.adSubtitleLabelStr = adSubtitleStr;
            self.adSubtitleLabelUserInteractionEnabled = [TTLayOutCellDataHelper isADSubtitleUserInteractive:self.orderedData];
            
            self.separatorViewHidden = YES;
            
            self.actionButtonFrame = CGRectMake(self.originX + ADActionSize.width - 72 - 8, top + floor((ADActionSize.height - 28) / 2), 72, 28);
            self.actionButtonHidden = NO;
            self.actionButtonFontSize = 14;
            self.actionButtonBorderWidth = 1.f;
            
            
            top += ADActionSize.height;
            regionHeight += ADActionSize.height;
        }
    }
    
    return regionHeight;
}

@end

@implementation TTLayOutPlainLargePicCellModelS0

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
    height += [self heightForLargePicRegionWithTop:height];
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

@implementation TTLayOutPlainLargePicCellModelS1

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForHeaderInfoRegionWithTop:height];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
    height += [self heightForLargePicRegionWithTop:height];
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

@implementation TTLayOutPlainLargePicCellModelS2

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForHeaderInfoRegionInTwoLinesWithTop:height needLayoutDislike:NO];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
    height += [self heightForLargePicRegionWithTop:height];
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

@implementation TTLayOutPlainPanoramaCellModel

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
    height += [self heightForLargePicRegionWithTop:height];
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

- (CGFloat)heightForLargePicRegionWithTop:(CGFloat)top
{
    CGFloat height = [super heightForLargePicRegionWithTop:top];
    
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:self.orderedData adModel:nil picStyle:TTArticlePicViewStyleLarge width:self.containWidth];
    // 全景广告
    top += kCellGroupPicTopPadding;
    self.motionViewFrame = CGRectMake(self.originX, top, picSize.width, picSize.height);
    self.motionViewHidden = NO;
    self.picViewHidden = YES;

    return height;
}

@end

