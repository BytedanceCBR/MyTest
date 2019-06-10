//
//  TTLayOutU11CellBaseModel.h
//  Article
//
//  Created by 王双华 on 16/11/3.
//
//

#import "TTLayOutCellBaseModel.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTLayOutCellDataHelper.h"
#import "TTLabelTextHelper.h"
#import "TTArticleCellHelper.h"
#import "ExploreCellHelper.h"
#import "TTArticleCellHelper.h"
#import "TTArticleCellConst.h"

@interface TTLayOutUFCellBaseModel : TTLayOutCellBaseModel
@property (nonatomic, assign) CGRect recommendCardsFrame;
- (CGFloat)heightForTopSeparateViewWithTop:(CGFloat)top;
- (CGFloat)heightForBottomSeparateViewWithTop:(CGFloat)top;

- (CGFloat)heightForCellContentWithTop:(CGFloat)top;
- (CGFloat)heightForFunctionRegionWithTop:(CGFloat)top;

- (CGFloat)heightForActionLabelRegionWithTop:(CGFloat)top;
- (CGFloat)heightForActionButtonRegionWithTop:(CGFloat)top;
@end
