//
//  ExploreDetailToolbarView.h
//  Article
//
//  Created by SunJiangting on 15/7/27.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTAlphaThemedButton.h"
#import "TTArticleDetailDefine.h"

typedef NS_ENUM(NSInteger, ExploreDetailToolbarType) {
    ExploreDetailToolbarTypeNormal,
    ExploreDetailToolbarTypeOnlyWriteButton,
    ExploreDetailToolbarTypeExcludeCommentButtons,
    ExploreDetailToolbarTypeExcludeCollectButton,
    ExploreDetailToolbarTypeArticleComment,
    ExploreDetailToolbarTypePhotoComment,
    ExploreDetailToolbarTypePhotoOnlyWriteButton,
    ExploreDetailToolbarTypeCommentDetail
};

typedef NS_ENUM(NSUInteger, ExploreDetailToolbarFromView) {
    ExploreDetailToolbarFromViewUnknown,
    ExploreDetailToolbarFromViewVideoDetail
};

NS_ASSUME_NONNULL_BEGIN
@interface ExploreDetailToolbarView : SSThemedView

@property (nonatomic, strong, readonly) TTAlphaThemedButton *writeButton;   // 写评论输入框
@property (nonatomic, strong, readonly) TTAlphaThemedButton *emojiButton;   // 表情按钮
@property (nonatomic, strong, readonly) TTAlphaThemedButton *commentButton; // 评论按钮, 点击显示出评论列表
@property (nonatomic, strong, readonly) TTAlphaThemedButton *digButton;     // 点赞按钮
@property (nonatomic, strong, readonly) SSThemedButton *topButton;          // 点击回到相关视频的顶部
@property (nonatomic, strong, readonly) TTAlphaThemedButton *collectButton; // 收藏按钮
@property (nonatomic, strong, readonly) TTAlphaThemedButton *shareButton;   // 分享按钮
@property (nonatomic, strong, readonly) SSThemedView *separatorView;
@property (nonatomic, strong) SSThemedLabel *badgeLabel;

@property (nonatomic) TTDetailViewStyle viewStyle;

@property (nonatomic) ExploreDetailToolbarType toolbarType;

@property (nonatomic) ExploreDetailToolbarFromView fromView;

@property (nullable, nonatomic, copy) NSString *commentBadgeValue;

@property (nonatomic, assign) BOOL banEmojiInput; // 是否支持表情输入

- (void)relayoutItems;

@end

extern CGFloat ExploreDetailGetToolbarHeight(void);

NS_ASSUME_NONNULL_END
