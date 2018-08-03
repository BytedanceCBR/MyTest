//
//  TTVideoCellActionBar.h
//  Article
//
//  Created by 王双华 on 16/9/8.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "ArticleVideoActionButton.h"
#import "TTFollowThemeButton.h"
#import "TTAsyncCornerImageView+VerifyIcon.h"
#import "TTIconLabel.h"
#import "TTVideoAdCellShareController.h"
#import "TTAlphaThemedButton.h"
@class ExploreArticleCellView;
@class ExploreAvatarView;
@class ExploreActionButton;
@class TTImageView;

typedef NS_ENUM(NSInteger, TTVideoCellActionBarLayoutScheme)
{
    TTVideoCellActionBarLayoutSchemeDefault,    //默认样式 头条号头像、名称、标签、播放次数（老版）、评论、分享
    TTVideoCellActionBarLayoutSchemeAD,         //广告样式 广告头像、广告来源、标签、广告按钮
    TTVideoCellActionBarLayoutSchemeLive        //直播样式 头条号头像、名称，在线人数、分享
};

@interface TTVideoCellActionBar : SSThemedView

@property (nonatomic, strong) TTAsyncCornerImageView   *avatarView;//头像
@property (nonatomic, strong) TTIconLabel              *avatarLabel;//名称
@property (nonatomic, strong) TTAlphaThemedButton      *avatarLabelButton;
@property (nonatomic, strong) TTAlphaThemedButton      *avatarButton;//头像按钮 add:626
@property (nonatomic, strong) UILabel                  *typeLabel;//推广标志
@property (nonatomic, strong) SSThemedLabel            *liveCountLabel;//直播状态在线人数
@property (nonatomic, strong) ExploreActionButton      *adActionButton;//广告"查看详情"等按钮
@property (nonatomic, strong) SSThemedLabel            *countLabel;//播放次数
@property (nonatomic, strong) TTAlphaThemedButton *followButton; // 关注按钮
@property (nonatomic, strong) TTFollowThemeButton *redPacketFollowButton; // 关注按钮
@property (nonatomic, strong) ArticleVideoActionButton *commentButton;//评论按钮
@property (nonatomic, strong) ArticleVideoActionButton *shareButton;//分享按钮
@property (nonatomic, strong) ArticleVideoActionButton *moreButton;//更多按钮
@property (nonatomic, strong) TTVideoAdCellShareController *shareController;
@property (nonatomic        ) TTVideoCellActionBarLayoutScheme schemeType;//布局方式，未设置时是默认样式

- (void)refreshWithData:(id)data;
- (void)layoutSubviewsIfNeeded;

- (void)startFollowButtonIndicatorAnimating:(BOOL)hasFollowed;
- (void)stopFollowButtonIndicatorAnimating;

@end
