//
//  TTLayOutUnifyADCellBaseModel.h
//  Article
//
//  Created by 王双华 on 16/10/24.
//
//

#import "TTLayOutCellBaseModel.h"
#import "TTLabelTextHelper.h"
#import "TTArticleCellHelper.h"
#import "TTArticleCellConst.h"
#import "TTLayOutCellDataHelper.h"
#import "ExploreArticleCellViewConsts.h"

@interface TTLayOutUnifyADCellBaseModel : TTLayOutCellBaseModel

- (void)calculateBottomLineFrame;
//- (void)calculateFrameWithContainWidth:(CGFloat)containWidth;
//- (void)calculateTitleFrameWithContainWidth:(CGFloat)containWidth;
//- (void)calculateInfoFrameWithY:(CGFloat)originY withContainWidth:(CGFloat)containWidth;

- (CGFloat)heightForTitleRegionWithTop:(CGFloat)top;

- (CGFloat)heightForInfoRegionWithTop:(CGFloat)top containWidth:(CGFloat)containWidth;

- (CGFloat)heightForADActionRegionWithTop:(CGFloat)top;
@end
