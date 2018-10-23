//
//  TTVideoTabHuoShanCellView.h
//  Article
//
//  Created by xuzichao on 16/6/12.
//
//

#import "ExploreArticleCellView.h"
#import "ExploreCellBase.h"
#import "TTVideoCellActionBar.h"

static BOOL huoShanShowConnectionAlertCount = YES;

@interface TTVideoTabHuoShanCellView : ExploreArticleCellView


@property(nonatomic, strong)TTAlphaThemedButton *playButton;
@property(nonatomic, strong)SSThemedLabel *videoRightBottomLabel; //默认显示时间
@property(nonatomic, strong)UIView *redDot; //红点
@property(nonatomic, strong)TTVideoCellActionBar *actionBar;

- (CGRect)logoViewFrame;
- (CGRect)movieViewFrameRect;
- (void)didEndDisplaying;
- (void)cellInListWillDisappear:(CellInListDisappearContextType)context;

@end
