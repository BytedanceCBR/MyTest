//
//  FHMessageNotificationBaseCellView.h
//  Article
//
//  Created by zhulijun.2539 on 2019/6/17.
//
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"
#import "TTIconLabel.h"

// 默认配置
extern CGFloat FHMNAvatarImageViewSize();
extern CGFloat FHMNAvatarImageViewLeftPadding();
extern CGFloat FHMNAvatarImageViewTopPadding();

extern CGFloat FHMNRefTextLabelWidth();
extern CGFloat FHMNRefImageViewSize();
extern CGFloat FHMNRefTopPadding();
extern CGFloat FHMNRefRightPadding();
extern CGFloat FHMNRefTextLabelFontSize();
extern CGFloat FHMNRefTextLabelLineHeight();
extern NSInteger FHMNRefTextLabelNumberOfLines();

extern CGFloat FHMNBodyTextLabelLeftPadding();
extern CGFloat FHMNBodyTextLabelDefaultRightPadding();
extern CGFloat FHMNBodyTextLabelRightPaddingWithRef();
extern CGFloat FHMNBodyTextLabelTopPadding();
extern CGFloat FHMNBodyTextLabelFontSize();
extern CGFloat FHMNBodyTextLabelLineHeight();
extern NSInteger FHMNBodyTextLabelNumberOfLines();

extern CGFloat FHMNContactInfoLabelLeftPadding();
extern CGFloat FHMNContactInfoLabelDefaultRightPadding();
extern CGFloat FHMNContactInfoLabelRightPaddingWithRef();
extern CGFloat FHMNContactInfoLabelTopPadding();
extern CGFloat FHMNContactInfoLabelHeight();
extern CGFloat FHMNContactInfoLabelFontSize();

extern CGFloat FHMNTimeLabelLeftPadding();
extern CGFloat FHMNTimeLabelDefaultRightPadding();
extern CGFloat FHMNTimeLabelRightPaddingWithRef();
extern CGFloat FHMNTimeLabelTopPadding();
extern CGFloat FHMNTimeLabelFontSize();
extern CGFloat FHMNTimeLabelBottomPadding();
extern CGFloat FHMNTimeLabelHeight();

extern CGFloat FHMNMultiTextViewLeftPadding();
extern CGFloat FHMNMultiTextViewDefaultRightPadding();
extern CGFloat FHMNMultiTextViewRightPaddingWithRef();
extern CGFloat FHMNMultiTextViewTopPadding();
extern CGFloat FHMNMultiTextViewHeight();

extern CGFloat FHMNRoleInfoViewLeftPadding();
extern CGFloat FHMNRoleInfoViewDefaultRightPadding();
extern CGFloat FHMNRoleInfoViewRightPaddingWithRef();
extern CGFloat FHMNRoleInfoViewTopPadding();
extern CGFloat FHMNRoleInfoViewHeight();
extern CGFloat FHMNRoleInfoViewFontSize();

//保护用，避免一个字都显示不全的情况
extern CGFloat FHMNUserNameLabelMinWidth();

@class SSThemedLabel;
@class SSThemedView;
@class TTMessageNotificationModel;
@class TTAsyncCornerImageView;
@class TTImageView;

@interface FHMessageNotificationBaseCellView : SSViewBase

@property (nonatomic, strong, nullable) TTAsyncCornerImageView *avatarImageView; //头像
@property (nonatomic, strong, nullable) TTIconLabel            *roleInfoView;    //展示用户的名字以及认证信息，如v，版主，好友，已关注
@property (nonatomic, strong, nullable) SSThemedLabel          *contactInfoLabel;//展示联系人关系
@property (nonatomic, strong, nullable) SSThemedLabel          *refTextLabel;    //右侧展示的引用文本
@property (nonatomic, strong, nullable) TTImageView            *refImageView;    //右侧展示的引用图
@property (nonatomic, strong, nullable) SSThemedLabel          *bodyTextLabel;   //消息主体
@property (nonatomic, strong, nullable) SSThemedLabel          *timeLabel;       //显示时间
@property (nonatomic, strong, nullable) SSThemedButton         *multiTextView;   //展示聚合消息的view
@property (nonatomic, strong, nullable) SSThemedView           *bottomLineView;  //底部分割线

@property (nonatomic, strong, nullable) TTMessageNotificationModel *messageModel;       //cellview对应的model

@property (nonatomic, strong, nullable) SSThemedImageView      *refPalyIcon;     //右侧展示引用图时候的播放按钮

+ (CGFloat)heightForData:(nullable TTMessageNotificationModel *)data cellWidth:(CGFloat)width;
+ (CGFloat)heightForBodyTextLabelWithData:(nullable TTMessageNotificationModel *)data maxWidth:(CGFloat)maxWidth;
+ (CGFloat)heightForRefTextLabelWithData:(nullable TTMessageNotificationModel *)data maxWidth:(CGFloat)maxWidth;

- (void)refreshUI;
- (void)refreshWithData:(nullable TTMessageNotificationModel *)data;
- (nullable TTMessageNotificationModel *)cellData;
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

- (void)updateAvatarImageView;
- (void)updateRefTextLabel;
- (void)updateRefImageView;
- (void)updateBodyTextLabel;
- (void)updateTimeLabel;
- (void)updateMultiTextView;
- (void)updateContactInfoLabel;
- (void)updateRoleInfoViewForMaxWidth:(CGFloat)maxWidth;

- (void)layoutAvatarImageView;
- (void)layoutRoleInfoView;
- (void)layoutContactInfoLabelWithOrigin:(CGPoint)origin maxWitdh:(CGFloat)maxWidh;
- (void)layoutBodyTextLabelWithOrigin:(CGPoint)origin maxWidth:(CGFloat)maxWidth;
- (void)layoutMultiTextViewWithOrigin:(CGPoint)origin maxWitdh:(CGFloat)maxWidth;
- (void)layoutTimeLabelWithOrigin:(CGPoint)origin maxWidth:(CGFloat)maxWidth;
- (void)layoutRefTextLabel;
- (void)layoutRefImageView;
- (void)layoutBottomLine;

@end
