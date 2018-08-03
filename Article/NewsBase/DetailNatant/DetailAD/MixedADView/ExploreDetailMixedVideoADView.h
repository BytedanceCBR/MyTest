//
//  ExploreDetailMixedVideoADView.h
//  Article
//
//  Created by huic on 16/5/3.
//
//

#import "ExploreDetailBaseADView.h"
#import "ExploreMovieView.h"
#import "TTAdDetailViewDefine.h"
#import "TTVBasePlayVideo.h"

@class ExploreArticleMovieViewDelegate;

@protocol TTNatantVideoADView <NSObject>
@property(nonatomic, strong) TTImageView *logo;
@property(nonatomic, strong) TTVBasePlayVideo *movieView;
@end


//当详情页消失的时候，移除正在播放的广告视频
#define kDetailVideoADDisappearNotification @"DetailVideoADDisappearNotification"

extern CGFloat videoFitHeight(ArticleDetailADModel *adModel, CGFloat width);

@interface ExploreDetailMixedVideoADView : ExploreDetailBaseADView <TTAdDetailSubviewState>

@property(nonatomic, strong) SSThemedLabel *titleLabel;
@property(nonatomic, strong) UIImageView *topMaskView;
@property(nonatomic, strong) TTImageView *logo;
@property(nonatomic, strong) SSThemedButton *playButton;
@property(nonatomic, strong) TTVBasePlayVideo *movieView;
@property(nonatomic, strong) SSThemedLabel *videoDurationLabel;
@property(nonatomic, strong) SSThemedLabel *adLabel;

@property(nonatomic, strong) SSThemedLabel *sourceLabel;
@property(nonatomic, strong) SSThemedView *bottomLine;

@property(nonatomic, strong) SSThemedButton *moreInfoButton;
@property(nonatomic, strong) SSThemedButton *moreInfoLabel;

@property(nonatomic, strong) ExploreArticleMovieViewDelegate *movieViewDelegate;

- (void)layout;

- (void)tryAutoPlay;

@end
