//
//  WDBottomToolView.h
//  Article
//
//  Created by 延晋 张 on 2016/12/2.
//
//

#import "SSThemed.h"
#import "WDDefines.h"
#import "TTAlphaThemedButton.h"

NS_ASSUME_NONNULL_BEGIN

@class WDBottomToolView;
@class WDDetailModel;

@protocol WDBottomToolViewDelegate <NSObject>

- (void)bottomView:(WDBottomToolView *)bottomView writeButtonClicked:(SSThemedButton *)wirteButton;
- (void)bottomView:(WDBottomToolView *)bottomView emojiButtonClicked:(SSThemedButton *)wirteButton;
- (void)bottomView:(WDBottomToolView *)bottomView commentButtonClicked:(SSThemedButton *)commentButton;
- (void)bottomView:(WDBottomToolView *)bottomView diggButtonClicked:(SSThemedButton *)diggButton;
- (void)bottomView:(WDBottomToolView *)bottomView nextButtonClicked:(SSThemedButton *)nextButton;

@end

@interface WDBottomToolView : SSThemedView

@property (nonatomic, strong, readonly) TTAlphaThemedButton *writeButton;
@property (nonatomic, strong, readonly) TTAlphaThemedButton *emojiButton;
@property (nonatomic, strong, readonly) TTAlphaThemedButton *commentButton;
@property (nonatomic, strong, readonly) TTAlphaThemedButton *digButton;
@property (nonatomic, strong, readonly) SSThemedButton *nextButton;

@property (nonatomic, strong, readonly) SSThemedView   *separatorView;

@property (nonatomic, strong) WDDetailModel *detailModel;

@property(nonatomic, strong) SSThemedLabel *badgeLabel;

@property(nullable, nonatomic, copy) NSString *commentBadgeValue;

@property (nonatomic, assign) BOOL banEmojiInput; // 是否支持表情输入

@property (nonatomic, weak) id<WDBottomToolViewDelegate> delegate;

- (void)relayoutItems;

- (void)showSupportsEmojiInputBubbleViewIfNeeded;

- (void)hideSupportsEmojiInputBubbleViewIfNeeded;

@end

extern CGFloat WDDetailGetToolbarHeight(void);

NS_ASSUME_NONNULL_END


