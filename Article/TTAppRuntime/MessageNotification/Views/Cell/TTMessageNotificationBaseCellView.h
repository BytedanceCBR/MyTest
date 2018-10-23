//
//  TTMessageNotificationBaseCellView.h
//  Article
//
//  Created by 邱鑫玥 on 2017/4/7.
//
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"
#import "TTIconLabel.h"

// 默认配置
extern CGFloat TTMNAvatarImageViewSize();
extern CGFloat TTMNAvatarImageViewLeftPadding();
extern CGFloat TTMNAvatarImageViewTopPadding();

extern CGFloat TTMNRefTextLabelWidth();
extern CGFloat TTMNRefImageViewSize();
extern CGFloat TTMNRefTopPadding();
extern CGFloat TTMNRefRightPadding();
extern CGFloat TTMNRefTextLabelFontSize();
extern CGFloat TTMNRefTextLabelLineHeight();
extern NSInteger TTMNRefTextLabelNumberOfLines();

extern CGFloat TTMNBodyTextLabelLeftPadding();
extern CGFloat TTMNBodyTextLabelDefaultRightPadding();
extern CGFloat TTMNBodyTextLabelRightPaddingWithRef();
extern CGFloat TTMNBodyTextLabelTopPadding();
extern CGFloat TTMNBodyTextLabelFontSize();
extern CGFloat TTMNBodyTextLabelLineHeight();
extern NSInteger TTMNBodyTextLabelNumberOfLines();

extern CGFloat TTMNContactInfoLabelLeftPadding();
extern CGFloat TTMNContactInfoLabelDefaultRightPadding();
extern CGFloat TTMNContactInfoLabelRightPaddingWithRef();
extern CGFloat TTMNContactInfoLabelTopPadding();
extern CGFloat TTMNContactInfoLabelHeight();
extern CGFloat TTMNContactInfoLabelFontSize();

extern CGFloat TTMNTimeLabelLeftPadding();
extern CGFloat TTMNTimeLabelDefaultRightPadding();
extern CGFloat TTMNTimeLabelRightPaddingWithRef();
extern CGFloat TTMNTimeLabelTopPadding();
extern CGFloat TTMNTimeLabelFontSize();
extern CGFloat TTMNTimeLabelBottomPadding();
extern CGFloat TTMNTimeLabelHeight();

extern CGFloat TTMNMultiTextViewLeftPadding();
extern CGFloat TTMNMultiTextViewDefaultRightPadding();
extern CGFloat TTMNMultiTextViewRightPaddingWithRef();
extern CGFloat TTMNMultiTextViewTopPadding();
extern CGFloat TTMNMultiTextViewHeight();

extern CGFloat TTMNRoleInfoViewLeftPadding();
extern CGFloat TTMNRoleInfoViewDefaultRightPadding();
extern CGFloat TTMNRoleInfoViewRightPaddingWithRef();
extern CGFloat TTMNRoleInfoViewTopPadding();
extern CGFloat TTMNRoleInfoViewHeight();
extern CGFloat TTMNRoleInfoViewFontSize();

//保护用，避免一个字都显示不全的情况
extern CGFloat TTMNUserNameLabelMinWidth();

@class TTAsyncCornerImageView;
@class SSThemedLabel;
@class SSThemedView;
@class TTImageView;
@class TTMessageNotificationModel;
@class TTUserInfoView;

@interface TTMessageNotificationBaseCellView : SSViewBase

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
