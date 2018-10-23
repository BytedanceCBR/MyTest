//
//  TTLayOutPlainCellBaseModel.h
//  Article
//
//  Created by 王双华 on 16/10/17.
//
//

#import "TTLayOutCellBaseModel.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTLayOutCellDataHelper.h"
#import "TTLabelTextHelper.h"
#import "TTArticleCellHelper.h"
#import "ExploreCellHelper.h"

@interface TTLayOutPlainCellBaseModel : TTLayOutCellBaseModel

- (void)calculateBottomLineFrame;

//cell 顶部间距
- (CGFloat)heightForCellTopPadding;
//cell 底部间距
- (CGFloat)heightForCellBottomPadding;
//infoBar 上边距
- (CGFloat)heightForInfoBarTopPadding;
//标题区域、纯标题，组图，大图用
- (CGFloat)heightForTitleRegionForPlainCellWithTop:(CGFloat)top;
//infoBar区域
- (CGFloat)heightForArticleInfoRegionWithTop:(CGFloat)top containWidth:(CGFloat)containWidth;
//摘要
- (CGFloat)heightForAbstractRegionWithTop:(CGFloat)top;
//评论
- (CGFloat)heightForCommentRegionWithTop:(CGFloat)top;
//实体词
- (CGFloat)heightForEntityWordViewRegionWithTop:(CGFloat)top;

@end
