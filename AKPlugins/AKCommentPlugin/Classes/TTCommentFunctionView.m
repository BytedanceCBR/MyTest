//
//  TTCommentFunctionView.m
//  Article
//
//  Created by ranny_90 on 2017/11/13.
//

#import "TTCommentFunctionView.h"
#import <TTBaseLib/TTDeviceUIUtils.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTUIWidget/TTAlphaThemedButton.h>
#import <TTUGCAttributedLabel.h>
#import <TTKitchen/TTKitchenHeader.h>

#define kTTCommentToolbarButtonSize 24

@interface TTCommentFunctionView ()

@property (nonatomic, strong) SSThemedButton *commentRepostCheckButton;

@property (nonatomic, strong) SSThemedButton *atButton;

@property (nonatomic, strong) TTAlphaThemedButton *emojiButton;

@end


@implementation TTCommentFunctionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _repostTitle = [KitchenMgr getString:KKCCommentRepostFirstDetailText];

        [self addSubview:self.emojiButton];
        [self addSubview:self.atButton];
        [self addSubview:self.commentRepostCheckButton];
    }
    return self;
}

- (void)layoutSubviews {
    [self refreshFunctionView];
}

- (void)refreshFunctionView {

    CGFloat rightMargin = [TTDeviceUIUtils tt_newPadding:15.f];

    if (!self.emojiButton.hidden) {
        self.emojiButton.centerY = self.height / 2.f;
        self.emojiButton.right = self.width - rightMargin;
        self.emojiButton.width = kTTCommentToolbarButtonSize;
        self.emojiButton.height = kTTCommentToolbarButtonSize;

        rightMargin += kTTCommentToolbarButtonSize + 30;
    }

    if (!self.atButton.hidden) {
        self.atButton.width = kTTCommentToolbarButtonSize;
        self.atButton.height = kTTCommentToolbarButtonSize;
        self.atButton.centerY = self.height / 2.f;
        self.atButton.right = self.right - rightMargin;
        rightMargin += kTTCommentToolbarButtonSize + 10;
    }

    if (!self.commentRepostCheckButton.hidden) {
        CGFloat btnW = 12;
        CGFloat hintLabelLeft = 24.0;
        CGFloat hintLabelRight = self.right - rightMargin;
        UIFont *labelFont = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];

        CGRect rect = [_repostTitle boundingRectWithSize:CGSizeMake(hintLabelRight - hintLabelLeft, 16)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName : labelFont}
                                                 context:nil];
        self.commentRepostCheckButton.frame =
            CGRectMake([TTDeviceUIUtils tt_newPadding:14.f], ([TTDeviceUIUtils tt_newPadding:40] - [TTDeviceUIUtils tt_newPadding:19]) / 2,
                       [TTDeviceUIUtils tt_newPadding:btnW + 18 + rect.size.width], [TTDeviceUIUtils tt_newPadding:19]);
        self.commentRepostCheckButton.centerY = self.height / 2.f;
    }

    if (self.commentRepostCheckButton.hidden == YES && self.atButton.hidden == YES && self.emojiButton.hidden == YES) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarNeedHiddenStatusUpdate:)]) {
            [self.delegate toolbarNeedHiddenStatusUpdate:YES];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarNeedHiddenStatusUpdate:)]) {
            [self.delegate toolbarNeedHiddenStatusUpdate:NO];
        }
    }
}


//表情输入按钮
- (void)setEmojiButtonState:(TTCommentFunctionEmojiButtonState)emojiButtonState {
    _emojiButtonState = emojiButtonState;

    if (_emojiButtonState == TTCommentFunctionEmojiButtonStateEmoji) {
        self.emojiButton.imageName = @"toolbar_icon_emoji";
    } else {
        self.emojiButton.imageName = @"toolbar_icon_keyboard";
    }
}

- (TTAlphaThemedButton *)emojiButton {
    if (!_emojiButton) {
        _emojiButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _emojiButton.hitTestEdgeInsets = UIEdgeInsetsMake(-8, -6, -8, -6);
        _emojiButton.imageName = @"toolbar_icon_emoji";
        [_emojiButton sizeToFit];
        _emojiButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [_emojiButton addTarget:self action:@selector(emojiInputMethod:) forControlEvents:UIControlEventTouchUpInside];

        CGFloat insets = (44 - kTTCommentToolbarButtonSize) / 2.f;
        _emojiButton.hitTestEdgeInsets = UIEdgeInsetsMake(-insets, -insets, -insets, -insets);
    }
    return _emojiButton;
}

- (void)emojiInputMethod:(id)sender {
    BOOL switchToEmojiInput = self.emojiButtonState == TTCommentFunctionEmojiButtonStateEmoji;
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarDidClickEmojiButton:)]) {
        [self.delegate toolbarDidClickEmojiButton:switchToEmojiInput];
    }

    if (self.emojiButtonState == TTCommentFunctionEmojiButtonStateKeyboard) {

        self.emojiButtonState = TTCommentFunctionEmojiButtonStateEmoji;
        self.emojiButton.imageName = @"toolbar_icon_emoji";
    } else {

        self.emojiButtonState = TTCommentFunctionEmojiButtonStateKeyboard;
        self.emojiButton.imageName = @"toolbar_icon_keyboard";
    }
}

- (SSThemedButton *)atButton {
    if (!_atButton) {
        _atButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _atButton.imageName = @"toolbar_icon_at";
        [_atButton addTarget:self action:@selector(atAction:) forControlEvents:UIControlEventTouchUpInside];
        _atButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        CGFloat edge = (44 - kTTCommentToolbarButtonSize) / 2.f;
        _atButton.hitTestEdgeInsets = UIEdgeInsetsMake(-edge, -edge, -edge, -edge);
    }
    return _atButton;
}

- (void)atAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarDidClickAtButton)]) {
        [self.delegate toolbarDidClickAtButton];
    }
}

- (void)setRepostTitle:(NSString *)repostTitle {
    if (isEmptyString(repostTitle)) {
        return;
    }

    _repostTitle = repostTitle;
    [self.commentRepostCheckButton setTitle:_repostTitle forState:UIControlStateNormal];

    [self refreshFunctionView];
}

//评论并转发输入按钮
- (void)setBanCommentRepost:(BOOL)banCommentRepost {
    if ([TTDeviceHelper isPadDevice]) {
        banCommentRepost = YES;
    }

    _banCommentRepost = banCommentRepost;
    self.commentRepostCheckButton.hidden = _banCommentRepost;
    self.emojiButton.hidden = _banCommentRepost || _banEmojiInput;
    self.atButton.hidden = _banCommentRepost;

    [self refreshFunctionView];
}

- (void)setBanEmojiInput:(BOOL)banEmojiInput {
    if ([TTDeviceHelper isPadDevice]) {
        banEmojiInput = YES;
    }

    _banEmojiInput = banEmojiInput;
    self.emojiButton.hidden = _banEmojiInput || _banCommentRepost;

    [self refreshFunctionView];
}

- (BOOL)isCommentRepostChecked {
    return self.commentRepostCheckButton && !self.commentRepostCheckButton.hidden && self.commentRepostCheckButton.selected;
}

- (SSThemedButton *)commentRepostCheckButton {
    if (!_commentRepostCheckButton) {
        _commentRepostCheckButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _commentRepostCheckButton.imageName = @"details_choose_icon";
        _commentRepostCheckButton.selectedImageName = @"details_choose_ok_icon";
        _commentRepostCheckButton.highlightedImageName = nil;
        _commentRepostCheckButton.selected = [self shouldSetCheckedCommentRepostCheckButton];
        _commentRepostCheckButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_commentRepostCheckButton addTarget:self action:@selector(commentRepostCheckButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat insets = (44 - 12) / 2.f;
        _commentRepostCheckButton.hitTestEdgeInsets = UIEdgeInsetsMake(-insets, -insets, -insets, -insets);

        [_commentRepostCheckButton setTitle:_repostTitle forState:UIControlStateNormal];
        _commentRepostCheckButton.titleColorThemeKey = _commentRepostCheckButton.selected ? kColorText1 : kColorText3;

        UIFont *labelFont = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
        _commentRepostCheckButton.titleLabel.font = labelFont;
        _commentRepostCheckButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _commentRepostCheckButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 9);
        _commentRepostCheckButton.titleEdgeInsets = UIEdgeInsetsMake(0, 9, 0, -9);
    }
    return _commentRepostCheckButton;
}

- (void)commentRepostCheckButtonClicked:(id)sender {
    self.commentRepostCheckButton.selected = !self.commentRepostCheckButton.selected;
    self.commentRepostCheckButton.titleColorThemeKey = self.commentRepostCheckButton.selected ? kColorText1 : kColorText3;
    [self setCommentRepostCheckButtonChecked:self.commentRepostCheckButton.selected];

    if (self.delegate && [self.delegate respondsToSelector:@selector(toolBarDidClickRepostButton)]) {
        [self.delegate toolBarDidClickRepostButton];
    }
}

- (BOOL)shouldSetCheckedCommentRepostCheckButton {
    return [KitchenMgr getBOOL:KKCCommentRepostSelected];
}

- (void)setCommentRepostCheckButtonChecked:(BOOL)checked {
    [KitchenMgr setBOOL:checked forKey:KKCCommentRepostSelected];
}

@end
