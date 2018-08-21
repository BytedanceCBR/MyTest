//
//  TTLayOutUnifyADLargePicCellModel.m
//  Article
//
//  Created by 王双华 on 16/10/24.
//
//

#import "TTLayOutUnifyADLargePicCellModel.h"
#import "Article+TTADComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"

@implementation TTLayOutUnifyADLargePicCellModel

- (CGFloat)heightForLargePicRegionWithTop:(CGFloat)top
{
    id<TTAdFeedModel> adModel = self.orderedData.adModel;
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:nil adModel:adModel.imageModel picStyle:TTArticlePicViewStyleLarge width:self.cellWidth];
    CGRect picViewFrame = CGRectMake(0, top, picSize.width, picSize.height);
    self.picViewFrame = picViewFrame;
    self.picViewHidden = NO;
    self.picViewStyle = TTArticlePicViewStyleLarge;
    self.picViewHiddenMessage = YES;
    self.picViewUserInteractionEnabled = YES;
    
    if ([TTLayOutCellDataHelper shouldShowPlayButtonWithOrderedData:self.orderedData]) {
        self.playButtonFrame = CGRectMake(0, 0, picSize.width, picSize.height);
        self.playButtonHidden = NO;
        self.playButtonImageName = @"feed_play_icon";
        self.playButtonUserInteractionEnable = ![self.orderedData isPlayInDetailView];
    }
    
    return picSize.height;
}

- (CGFloat)heightForADActionRegionWithTop:(CGFloat)top
{
//    CGSize ADActionSize = [TTArticleCellHelper getADActionSize:self.containWidth];
//    self.adBackgroundViewFrame = CGRectMake(0, top, ADActionSize.width, ADActionSize.height);
    self.adBackgroundViewHidden = YES;
    
    CGFloat actionButtonWidth = 72;
    CGFloat actionButtonHeight = 28;
    if (self.orderedData) {
        id<TTAdFeedModel> adModel = self.orderedData.adModel;
        if ([adModel showActionButtonIcon]) {
            actionButtonWidth = 108.f;
        }
    }
    NSString *adSubtitleStr = [TTLayOutCellDataHelper getSubtitleStringWithOrderedData:self.orderedData];
    CGSize adSubtitleSize = [adSubtitleStr sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:15]}];
    adSubtitleSize = CGSizeMake(ceilf(adSubtitleSize.width), ceilf(adSubtitleSize.height));
    CGRect adSubtitleFrame = CGRectMake(self.originX, top + [TTDeviceUIUtils tt_newPadding:18.f], self.containWidth - 8 - 20 - actionButtonWidth, adSubtitleSize.height);
    self.adSubtitleLabelFrame = adSubtitleFrame;
    self.adSubtitleLabelHidden = NO;
    self.adSubtitleLabelFontSize = [TTDeviceUIUtils tt_newFontSize:15];
    self.adSubtitleLabelTextColorHex = @"999999";
    self.adSubtitleLabelStr = adSubtitleStr;
    self.adSubtitleLabelUserInteractionEnabled = [TTLayOutCellDataHelper isADSubtitleUserInteractive:self.orderedData];
    
    self.separatorViewHidden = YES;
    
    self.actionButtonFrame = CGRectMake(self.originX + self.containWidth - actionButtonWidth ,CGRectGetMidY(adSubtitleFrame) - actionButtonHeight / 2 , actionButtonWidth, actionButtonHeight);
    self.actionButtonHidden = NO;
    self.actionButtonFontSize = 14;
    self.actionButtonBorderWidth = 1.f;
    
    return CGRectGetMaxY(self.actionButtonFrame) - top;
}

- (void)calculateAllFrame
{
    self.originX = kPaddingLeft();
    self.containWidth = self.cellWidth - kPaddingLeft() - kPaddingRight();
    
    CGFloat height = 0;
    
    height += kPaddingTop();
    height += [self heightForTitleRegionWithTop:height];
    height += kPaddingPicTop();
    height += [self heightForLargePicRegionWithTop:height];
    height += [self heightForADActionRegionWithTop:height];
    height += kPaddingInfoTop();
    self.infoBarOriginY = height;
    self.infoBarContainWidth = self.containWidth;
    height += [self heightForInfoRegionWithTop:self.infoBarOriginY containWidth:self.infoBarContainWidth];
    height += kPaddingBottom();
    
    self.cellCacheHeight = ceilf(height);
    
    [self calculateBottomLineFrame];
}

@end
