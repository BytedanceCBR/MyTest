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
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:nil adModel:adModel.imageModel picStyle:TTArticlePicViewStyleTriple width:self.containWidth];
    CGRect picViewFrame = CGRectMake(self.originX, top, picSize.width, picSize.height);
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
    height += kPaddingBottom();
    
    self.cellCacheHeight = ceilf(height);
    
    [self calculateBottomLineFrame];
}

@end
