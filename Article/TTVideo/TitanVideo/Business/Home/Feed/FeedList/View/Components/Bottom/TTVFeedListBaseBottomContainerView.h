//
//  TTVFeedListBaseBottomContainerView.h
//  Article
//
//  Created by pei yun on 2017/3/31.
//
//

#import "TTAsyncCornerImageView.h"
#import "TTIconLabel.h"
#import "TTAlphaThemedButton.h"
#import <TTVideoService/VideoFeed.pbobjc.h>
#import "ArticleVideoActionButton.h"
#import "TTVFeedListItem.h"
#import "TTVFeedContainerBaseView.h"

typedef void(^TTVMoreActionType)(NSString *type);

@interface TTVFeedListBaseBottomContainerView : TTVFeedContainerBaseView

@property (nonatomic, strong) TTVFeedListItem   *cellEntity;
@property (nonatomic, strong) NSString      *categoryId;

@property (nonatomic, strong ,readonly) TTAsyncCornerImageView   *avatarView;//头像
@property (nonatomic, strong ,readonly) TTIconLabel              *avatarLabel;//名称
@property (nonatomic, strong ,readonly) TTAlphaThemedButton      *avatarLabelButton;
@property (nonatomic, strong ,readonly) UILabel                  *typeLabel;//推广标志
@property (nonatomic, strong ,readonly) ArticleVideoActionButton *moreButton;//更多按钮
@property (nonatomic, strong ,readonly) TTAlphaThemedButton      *avatarViewButton; //头像上移时才会使用

@property (nonatomic, copy) TTVMoreActionType moreActionType;

- (void)updateAvatarViewWithUrl:(NSString *)avatarUrl sourceText:(NSString *)sourceText;
- (void)updateAvatarLabelWithText:(NSString *)avatarText;
- (void)updateTypeLabelWithText:(NSString *)typeText;
- (void)updateAvatarVerifyWithAuthInfo:(NSString *)userAuthInfo userDecoration:(NSString *)userDecoration userId:(NSString *)userId;

- (void)forwardToWeitoutiao;
- (void)moreActionClicked;
- (void)shareActionClicked;//finish
- (void)shareActionOnMovieTopViewClicked;
- (void)moreActionOnMovieTopViewClicked;
- (void)directShareOnmovieFinishViewWithActivityType:(NSString *)activityType;
- (void)directShareOnMovieViewWithActivityType:(NSString *)activityType;
- (void)bottomViewShareAction;
//展开分享actions
//- (void)shareTitleButtonAction;
- (void)dealShareButtonOnBottomViewWithActivityType:(NSString *)activityType;
+ (CGFloat)avatarViewBorderWidth;
+ (CGFloat)avatarHeight;


@end
