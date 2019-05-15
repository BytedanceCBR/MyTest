//
//  TTLayOutUGCCellBaseModel.h
//  Article
//
//  Created by 王双华 on 16/10/17.
//
//

#import "TTLayOutCellBaseModel.h"
#import "TTArticleCellConst.h"
#import "TTLayOutCellDataHelper.h"
#import "TTArticleCellHelper.h"
#import "TTLabelTextHelper.h"

@interface TTLayOutUGCCellBaseModel : TTLayOutCellBaseModel

- (void)calculateTimeLabelWithY:(CGFloat)originY withContainWidth:(CGFloat)containWidth;

- (void)calculateOtherFramesWithContainWidth:(CGFloat)containWidth;

- (void)calculateInfoFrameWithY:(CGFloat)originY withContainWidth:(CGFloat)containWidth;
@end
