//
//  TTUGCToolbar.m
//  Article
//
//  Created by Jiyee Sheng on 31/08/2017.
//
//

#import "TTUGCToolbar.h"
#import "TTUGCEmojiInputView.h"
#import "TTUGCEmojiParser.h"
#import <KVOController.h>
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"

#define kTTUGCToolbarHeight 80
#define kTTUGCToolbarButtonSize 44
#define EMOJI_INPUT_VIEW_HEIGHT ([TTDeviceHelper isScreenWidthLarge320] ? 216.f : 193.f)

@interface TTUGCToolbar ()

@property (nonatomic, strong) SSThemedView *containerView;
@property (nonatomic, strong) SSThemedView *toolbarView;
@property (nonatomic, strong) SSThemedButton *keyboardButton;
@property (nonatomic, strong) SSThemedButton *atButton;
@property (nonatomic, strong) SSThemedButton *hashtagButton;
@property (nonatomic, strong) SSThemedButton *emojiButton;
@property (nonatomic, strong) TTUGCEmojiInputView *emojiInputView;

@property (nonatomic, assign) CGPoint toolbarViewOrigin;

@end

@implementation TTUGCToolbar

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size = CGSizeMake(frame.size.width, frame.size.height + EMOJI_INPUT_VIEW_HEIGHT);

    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.containerView];

        [self.containerView addSubview:self.toolbarView];
        [self.toolbarView addSubview:self.keyboardButton];
        [self.toolbarView addSubview:self.atButton];
        [self.toolbarView addSubview:self.hashtagButton];
        [self.toolbarView addSubview:self.emojiButton];

        self.keyboardButton.width = kTTUGCToolbarButtonSize;
        self.keyboardButton.height = kTTUGCToolbarButtonSize;
        self.keyboardButton.bottom = self.toolbarView.height;

        self.atButton.width = kTTUGCToolbarButtonSize;
        self.atButton.height = kTTUGCToolbarButtonSize;
        self.atButton.bottom = self.toolbarView.height;

        self.hashtagButton.width = kTTUGCToolbarButtonSize;
        self.hashtagButton.height = kTTUGCToolbarButtonSize;
        self.hashtagButton.bottom = self.toolbarView.height;

        self.emojiButton.width = kTTUGCToolbarButtonSize;
        self.emojiButton.height = kTTUGCToolbarButtonSize;
        self.emojiButton.bottom = self.toolbarView.height;

        [self.containerView addSubview:self.emojiInputView];

        [self refreshButtonsUI];

        self.emojiInputView.top = self.toolbarView.bottom;

        self.toolbarViewOrigin = self.origin;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }

    return self;
}

- (void)refreshButtonsUI {
    self.keyboardButton.left = 5;

    CGFloat right = self.toolbarView.width - 5;
    if (!self.emojiButton.hidden) {
        self.emojiButton.right = right;
    } else {
        self.emojiButton.right = 0;
    }

    if (!self.hashtagButton.hidden) {
        right -= kTTUGCToolbarButtonSize + 10;
        self.hashtagButton.right = right;
    } else {
        self.hashtagButton.right = 0;
    }

    if (!self.atButton.hidden) {
        right -= kTTUGCToolbarButtonSize + 10;
        self.atButton.right = right;
    } else {
        self.atButton.right = right;
    }
}

#pragma mark - actions

- (void)keyboardAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarDidClickKeyboardButton:)]) {
        BOOL switchToInput = [self.keyboardButton.imageName isEqualToString:@"toolbar_icon_keyboard_up"]; // 这里折衷一下
        [self.delegate toolbarDidClickKeyboardButton:switchToInput];
        self.keyboardButton.imageName = switchToInput ? @"toolbar_icon_keyboard_down" : @"toolbar_icon_keyboard_up";
        self.emojiButton.imageName = @"toolbar_icon_emoji";
    }
}

- (void)atAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarDidClickAtButton)]) {
        [self.delegate toolbarDidClickAtButton];
    }
}

- (void)hashtagAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarDidClickHashtagButton)]) {
        [self.delegate toolbarDidClickHashtagButton];
    }
}

- (void)emojiAction:(id)sender {
    if (self.emojiInputViewVisible) {
        self.emojiInputViewVisible = NO;
        self.keyboardButton.imageName = @"toolbar_icon_keyboard_up";
        self.emojiButton.imageName = @"toolbar_icon_emoji";
        if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarDidClickEmojiButton:)]) {
            [self.delegate toolbarDidClickEmojiButton:NO];
        }
    } else {
        self.emojiInputViewVisible = YES;
        self.emojiInputView.hidden = NO;
        self.keyboardButton.imageName = @"toolbar_icon_keyboard_down";
        self.emojiButton.imageName = @"toolbar_icon_keyboard";
        if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarDidClickEmojiButton:)]) {
            [self.delegate toolbarDidClickEmojiButton:YES];

            [UIView animateWithDuration:0.25 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.top = self.toolbarViewOrigin.y - EMOJI_INPUT_VIEW_HEIGHT;
            } completion:nil];
        }
    }
}

#pragma mark - UIKeyboardNotification

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    if (!self.superview) {
        return;
    }

    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardScreenFrame = [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    keyboardScreenFrame = [self convertRect:keyboardScreenFrame fromView:nil];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions options = UIViewAnimationCurveEaseIn | UIViewAnimationCurveEaseOut | UIViewAnimationCurveLinear;
    switch (animationCurve) {
        case UIViewAnimationCurveEaseInOut:
            options = UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            options = UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options = UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options = UIViewAnimationOptionCurveLinear;
            break;
        default:
            options = animationCurve << 16;
            break;
    }

    CGFloat duration = [[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect frame = self.frame;
    CGFloat targetY = CGRectGetMinY(keyboardScreenFrame) - CGRectGetHeight(frame); // 键盘弹出状态位置
    BOOL isDismissing = CGRectGetMinY(keyboardScreenFrame) >= [[[UIApplication sharedApplication] delegate] window].bounds.size.height;

    // 为了保证从上往下收起动画效果的完整性
    if (isDismissing) { // 收起
        if (self.emojiInputViewVisible) { // 切换到表情输入，收起键盘
            targetY = CGRectGetMinY(keyboardScreenFrame) - CGRectGetHeight(frame);

            // 提前显示表情选择器
            self.emojiInputView.hidden = !self.emojiInputViewVisible;
            self.keyboardButton.imageName = @"toolbar_icon_keyboard_down";
            self.emojiButton.imageName = @"toolbar_icon_keyboard";
        } else { // 直接收起键盘
            [self endEditing:YES];
            return;
        }
    } else { // 弹出键盘
        targetY = CGRectGetMinY(keyboardScreenFrame) - kTTUGCToolbarHeight;

        // Emoji 选择器输入情况下，点击 TextView 自动弹出键盘
        if (self.emojiInputViewVisible) {
            self.emojiInputViewVisible = NO;
        }

        self.keyboardButton.imageName = @"toolbar_icon_keyboard_down";
        self.emojiButton.imageName = @"toolbar_icon_emoji";
    }

    frame.origin.y = targetY;

    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        if (self.emojiInputViewVisible) {
            self.emojiInputView.hidden = NO;
        } else {
            self.emojiInputView.hidden = YES;
        }
    }];
}

- (BOOL)endEditing:(BOOL)animated {
    
    void (^animations)(void) = ^{
        self.top = self.toolbarViewOrigin.y;
    };

    void (^completion)(BOOL) = ^(BOOL finished) {
        self.keyboardButton.imageName = @"toolbar_icon_keyboard_up";
        self.emojiButton.imageName = @"toolbar_icon_emoji";

        if (self.emojiInputViewVisible) {
            self.emojiInputViewVisible = NO;
        }

        self.emojiInputView.hidden = !self.emojiInputViewVisible;
    };

    if (animated) {
        
        [UIView animateWithDuration:0.25 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:animations completion:completion];
        
    } else {
        animations();
        completion(YES);
    }

    return YES;
}

- (void)setBanAtInput:(BOOL)banAtInput {
    _banAtInput = banAtInput;

    self.atButton.enabled = !banAtInput;
    self.atButton.hidden = banAtInput;

    [self refreshButtonsUI];
}

- (void)setBanHashtagInput:(BOOL)banHashtagInput {
    _banHashtagInput = banHashtagInput;

    self.hashtagButton.enabled = !banHashtagInput;
    self.hashtagButton.hidden = banHashtagInput;

    [self refreshButtonsUI];
}

- (void)setBanEmojiInput:(BOOL)banEmojiInput {
    _banEmojiInput = banEmojiInput;

    self.emojiButton.enabled = !banEmojiInput;
    self.emojiButton.hidden = banEmojiInput;

    [self refreshButtonsUI];
}

- (void)markKeyboardAsVisible {
    self.keyboardButton.imageName = @"toolbar_icon_keyboard_down";
    self.emojiButton.imageName = @"toolbar_icon_emoji";
}

#pragma mark - getter and setter

- (SSThemedView *)containerView {
    if (!_containerView) {
        _containerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, kTTUGCToolbarHeight - kTTUGCToolbarButtonSize, self.width, kTTUGCToolbarButtonSize + EMOJI_INPUT_VIEW_HEIGHT)];
        _containerView.backgroundColorThemeKey = kColorBackground3;
    }

    return _containerView;
}

- (SSThemedView *)toolbarView {
    if (!_toolbarView) {
        _toolbarView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, kTTUGCToolbarButtonSize)];
        _toolbarView.backgroundColorThemeKey = kColorBackground3;
    }

    return _toolbarView;
}

- (SSThemedButton *)keyboardButton {
    if (!_keyboardButton) {
        _keyboardButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _keyboardButton.imageName = @"toolbar_icon_keyboard_up";
        [_keyboardButton addTarget:self action:@selector(keyboardAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _keyboardButton;
}

- (SSThemedButton *)atButton {
    if (!_atButton) {
        _atButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _atButton.imageName = @"toolbar_icon_at";
        [_atButton addTarget:self action:@selector(atAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _atButton;
}

- (SSThemedButton *)hashtagButton {
    if (!_hashtagButton) {
        _hashtagButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _hashtagButton.imageName = @"toolbar_icon_hashtag";
        [_hashtagButton addTarget:self action:@selector(hashtagAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _hashtagButton;
}

- (SSThemedButton *)emojiButton {
    if (!_emojiButton) {
        _emojiButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _emojiButton.imageName = @"toolbar_icon_emoji";
        [_emojiButton addTarget:self action:@selector(emojiAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    return _emojiButton;
}

- (TTUGCEmojiInputView *)emojiInputView {
    if (!_emojiInputView) {
        _emojiInputView = [[TTUGCEmojiInputView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width, EMOJI_INPUT_VIEW_HEIGHT)];
        _emojiInputView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        _emojiInputView.textAttachments = [TTUGCEmojiParser emojiTextAttachments];
        _emojiInputView.hidden = YES;
    }

    return _emojiInputView;
}

@end
