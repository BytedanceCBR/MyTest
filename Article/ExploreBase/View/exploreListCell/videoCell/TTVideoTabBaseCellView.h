//
//  TTVideoTabBaseCellView.h
//  Article
//
//  Created by 王双华 on 15/10/10.
//
//

#import "ExploreArticleCellView.h"
#import "ExploreCellBase.h"
#import "ExploreMovieView.h"
#import "TTVideoCellActionBar.h"
#import "TTVFullscreenProtocol.h"

@interface TTVideoTabBaseCellView : ExploreArticleCellView <ExploreMovieViewCellProtocol,TTVFullscreenCellProtocol>


@property(nonatomic, strong)TTAlphaThemedButton *playButton;
@property(nonatomic, strong)SSThemedLabel *videoRightBottomLabel; //默认显示时间
@property(nonatomic, strong)SSThemedView *redDot; //红点
@property(nonatomic, strong ,readonly)UIView *movieView;
@property(nonatomic, strong)TTVideoCellActionBar *actionBar;

- (void)didEndDisplaying;
- (void)cellInListWillDisappear:(CellInListDisappearContextType)context;

@end
