//
//  TTArticleTitleLargePicHuoShanCellView.h
//  Article
//
//  Created by xuzichao on 16/6/13.
//
//

#import "ExploreArticleCellView.h"
#import "ExploreArticleTitleLargePicCellView.h"

@interface TTArticleTitleLargePicHuoShanCellView : ExploreArticleCellView

@property(nonatomic,strong)TTImageView* pic;
@property(nonatomic, strong)UIView * timeInfoBgView;
@property(nonatomic, strong)SSThemedButton * playButton;

- (void)didEndDisplaying;
- (void)cellInListWillDisappear:(CellInListDisappearContextType)context;

@end
