//
//  TTLayOutUnifyADGroupPicCellModel.m
//  Article
//
//  Created by 王双华 on 16/10/25.
//
//

#import "TTLayOutUnifyADGroupPicCellModel.h"
#import "Article+TTADComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"

@implementation TTLayOutUnifyADGroupPicCellModel

- (CGFloat)heightForGroupPicRegionWithTop:(CGFloat)top
{
    id<TTAdFeedModel> adModel = self.orderedData.adModel;
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:nil adModel:adModel.imageModel picStyle:TTArticlePicViewStyleTriple width:self.cellWidth];
    CGRect picViewFrame = CGRectMake(0, top, picSize.width, picSize.height);
    self.picViewFrame = picViewFrame;
    self.picViewHidden = NO;
    self.picViewStyle = TTArticlePicViewStyleTriple;
    self.picViewHiddenMessage = YES;
    self.picViewUserInteractionEnabled = YES;
    
    return picSize.height;
}

- (void)calculateAllFrame
{
    self.originX = kPaddingLeft();
    self.containWidth = self.cellWidth - kPaddingLeft() - kPaddingRight();
    
    CGFloat height = 0;
    
    height += kPaddingTop();
    height += [self heightForTitleRegionWithTop:height];
    height += kPaddingPicTop();
    height += [self heightForGroupPicRegionWithTop:height];
    height += kPaddingInfoTop();
    self.infoBarOriginY = height;
    self.infoBarContainWidth = self.containWidth;
    height += [self heightForInfoRegionWithTop:self.infoBarOriginY containWidth:self.infoBarContainWidth];
    height += kPaddingActionADTop();
    height += [self heightForADActionRegionWithTop:height];
    height += 10; //底部间距
    
    self.cellCacheHeight = ceilf(height);
    
    [self calculateBottomLineFrame];
}

- (CGFloat)heightForADActionRegionWithTop:(CGFloat)top
{
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
    CGRect adSubtitleFrame = CGRectMake(self.originX, top, self.containWidth - 8 - 20 - actionButtonWidth, adSubtitleSize.height);
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
    
    return CGRectGetMaxY(self.actionButtonFrame) - top;
}

@end
