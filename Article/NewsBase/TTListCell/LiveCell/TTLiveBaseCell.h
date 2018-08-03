//
//  TTLiveBaseCell.h
//  Article
//
//  Created by 杨心雨 on 16/8/18.
//
//

#import "ExploreCellBase.h"
#import "TTTableViewBaseCellView.h"
#import "TTFeedDislikeView.h"
#import "TTLabel.h"
#import "SSThemed.h"
#import "TTImageView+TrafficSave.h"
#import "TTLiveFeedAvatarView.h"
#import "TTScoreView.h"
#import "TTLiveStatusView.h"
#import "TTArticleTagView.h"
#import "TTFollowThemeButton.h"

@interface TTLiveBaseCell : ExploreCellBase

@end

@interface TTLiveBaseCellView : TTTableViewBaseCellView

@property (nonatomic, strong) TTLabel *titleView;
@property (nonatomic, strong) SSThemedButton *dislikeView;
@property (nonatomic, strong) TTImageView *picView;
@property (nonatomic, strong) TTLiveFeedAvatarView *avatarView1;
@property (nonatomic, strong) TTLiveFeedAvatarView *avatarView2;
@property (nonatomic, strong) SSThemedLabel *introduceView;
@property (nonatomic, strong) SSThemedLabel *subtitleView;
@property (nonatomic, strong) TTScoreView *scoreView;
@property (nonatomic, strong) SSThemedImageView *playView;
@property (nonatomic, strong) SSThemedLabel *onlineView;
@property (nonatomic, strong) SSThemedLabel *onlineConstView;
@property (nonatomic, strong) TTLiveStatusView *statusView;
@property (nonatomic, strong) SSThemedView *topRect;
@property (nonatomic, strong) SSThemedView *bottomRect;
@property (nonatomic, strong) TTImageView *sourceView;
@property (nonatomic, strong) TTLabel *sourceLabel;
@property (nonatomic, strong) TTArticleTagView *tagView;
@property (nonatomic, strong) TTFollowThemeButton *followView;

- (void)liveEntityChanged:(NSNotification *)notification;

- (void)updateTitleView;
- (void)updatePicView;
- (void)updateAvatarView;
- (void)updateIntroduceView;
- (void)updateSubtitleView;
- (void)updateScoreView;
- (void)updatePlayView;
- (void)updateOnlineView;
- (void)updateStatusView;
- (void)updateInfoView;

@end
