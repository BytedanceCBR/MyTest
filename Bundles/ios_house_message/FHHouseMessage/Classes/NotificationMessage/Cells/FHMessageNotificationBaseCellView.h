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
#import "TTUGCAsyncAttributedLabel.h"

@class TTMessageNotificationModel;

// 默认配置
extern CGFloat FHMNAvatarImageViewSize();

extern CGFloat FHMNAvatarImageViewLeftPadding();

extern CGFloat FHMNAvatarImageViewTopPadding();

extern CGFloat FHMNRefTextLabelWidth();

extern CGFloat FHMNRefImageViewSize();

extern CGFloat FHMNRefImageViewCornerRadius();

extern CGFloat FHMNRefTopPadding();

extern CGFloat FHMNRefRightPadding();

extern CGFloat FHMNRefTextLabelFontSize();

extern CGFloat FHMNRefTextLabelLineHeight();

extern NSInteger FHMNRefTextLabelNumberOfLines();

extern CGFloat FHMNBodyTextLabelLeftPadding();

extern CGFloat FHMNBodyTextLabelRightPaddingWithRef();

extern CGFloat FHMNBodyTextLabelTopPadding();

extern CGFloat FHMNBodyTextLabelFontSize();

extern CGFloat FHMNBodyTextLabelLineHeight();

extern NSInteger FHMNBodyTextLabelNumberOfLines();

extern CGFloat FHMNTimeLabelLeftPadding();

extern CGFloat FHMNTimeLabelRightPaddingWithRef();

extern CGFloat FHMNTimeLabelTopPadding();

extern CGFloat FHMNTimeLabelFontSize();

extern CGFloat FHMNTimeLabelBottomPadding();

extern CGFloat FHMNTimeLabelHeight();

extern CGFloat FHMNMultiTextViewLeftPadding();

extern CGFloat FHMNMultiTextViewRightPaddingWithRef();

extern CGFloat FHMNMultiTextViewTopPadding();

extern CGFloat FHMNMultiTextViewHeight();

extern CGFloat FHMNRoleInfoViewLeftPadding();

extern CGFloat FHMNRoleInfoViewRightPaddingWithRef();

extern CGFloat FHMNRoleInfoViewTopPadding();

extern CGFloat FHMNRoleInfoViewHeight();

extern CGFloat FHMNRoleInfoViewFontSize();

//保护用，避免一个字都显示不全的情况
extern CGFloat FHMNUserNameLabelMinWidth();

@interface FHMessageNotificationBaseCellView : SSViewBase

@property(nonatomic, strong, nullable) UIImageView *avatarImageView; //头像
@property(nonatomic, strong, nullable) UILabel *roleInfoView;    //展示用户的名字以及认证信息，如v，版主，好友，已关注
//@property (nonatomic, strong, nullable) SSThemedLabel          *contactInfoLabel;//展示联系人关系
@property(nonatomic, strong, nullable) TTUGCAsyncAttributedLabel *refTextLabel;    //右侧展示的引用文本
@property(nonatomic, strong, nullable) UIImageView *refImageView;    //右侧展示的引用图
@property(nonatomic, strong, nullable) TTUGCAsyncAttributedLabel *bodyTextLabel;   //消息主体
@property(nonatomic, strong, nullable) UILabel *timeLabel;       //显示时间
@property(nonatomic, strong, nullable) UIView *multiTextView;   //展示聚合消息的view
@property(nonatomic, strong, nullable) UIImageView *multiTextArrow;  //展示聚合消息的箭头
@property(nonatomic, strong, nullable) UILabel *multiTextLabel;  //展示聚合消息的内容
@property(nonatomic, strong, nullable) UIView *bottomLineView;  //底部分割线
@property(nonatomic, strong, nullable) NSDictionary *tracerDict;

@property(nonatomic, strong, nullable) TTMessageNotificationModel *messageModel;       //cell对应的model

//@property (nonatomic, strong, nullable) SSThemedImageView      *refPlayIcon;     //右侧展示引用图时候的播放按钮

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

- (void)updateRoleInfoViewForMaxWidth:(CGFloat)maxWidth;

- (void)layoutAvatarImageView;

- (void)layoutRoleInfoView;

- (void)layoutBodyTextLabelWithOrigin:(CGPoint)origin maxWidth:(CGFloat)maxWidth;

- (void)layoutMultiTextViewWithOrigin:(CGPoint)origin maxWitdh:(CGFloat)maxWidth;

- (void)layoutTimeLabelWithOrigin:(CGPoint)origin maxWidth:(CGFloat)maxWidth;

- (void)layoutRefTextLabel;

- (void)layoutRefImageView;

- (void)layoutBottomLine;

@end
