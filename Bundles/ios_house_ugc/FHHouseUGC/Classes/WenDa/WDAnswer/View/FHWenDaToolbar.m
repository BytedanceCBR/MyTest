//
//  FHWenDaToolbar.m
//  Article
//
//
//

#import "FHWenDaToolbar.h"
#import "TTUGCEmojiInputView.h"
#import "TTUGCEmojiParser.h"
#import <KVOController.h>
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import <TTRoute/TTRoute.h>

#define kFHWenDaToolbarHeight 80
#define kFHWenDaToolbarButtonSize 44
#define kFHWenDaToolbarLongTextButtonWidth 52
#define kFHWenDaToolbarLongTextButtonHeight 21

#define kFH_WEN_DA_EMOJI_INPUT_VIEW_HEIGHT ([TTDeviceHelper isScreenWidthLarge320] ? 216.f : 193.f)

@interface FHWenDaToolbar ()

@property (nonatomic, strong) SSThemedView *containerView;
@property (nonatomic, strong) SSThemedView *toolbarView;
@property (nonatomic, strong) SSThemedButton *keyboardButton;
@property (nonatomic, strong) SSThemedButton *longTextButton;
@property (nonatomic, strong) SSThemedButton *atButton;
@property (nonatomic, strong) SSThemedButton *shoppingButton;
@property (nonatomic, strong) SSThemedButton *hashtagButton;
@property (nonatomic, strong) SSThemedButton *emojiButton;
@property (nonatomic, strong) SSThemedButton *picButton;
@property (nonatomic, strong) TTUGCEmojiInputView *emojiInputView;

@property (nonatomic, assign) CGPoint toolbarViewOrigin;

@end

@implementation FHWenDaToolbar

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size = CGSizeMake(frame.size.width, frame.size.height + kFH_WEN_DA_EMOJI_INPUT_VIEW_HEIGHT);

    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.containerView];

        [self.containerView addSubview:self.toolbarView];
        [self.toolbarView addSubview:self.keyboardButton];
        [self.toolbarView addSubview:self.longTextButton];
        [self.toolbarView addSubview:self.atButton];
        [self.toolbarView addSubview:self.hashtagButton];
        [self.toolbarView addSubview:self.emojiButton];
        [self.toolbarView addSubview:self.picButton];
        [self.toolbarView addSubview:self.shoppingButton];

        self.keyboardButton.width = kFHWenDaToolbarButtonSize;
        self.keyboardButton.height = kFHWenDaToolbarButtonSize;
        self.keyboardButton.bottom = self.toolbarView.height;
        
        self.longTextButton.width = kFHWenDaToolbarLongTextButtonWidth;
        self.longTextButton.height = kFHWenDaToolbarLongTextButtonHeight;
        self.longTextButton.bottom = self.toolbarView.height / 2 + kFHWenDaToolbarLongTextButtonHeight / 2;

        self.atButton.width = kFHWenDaToolbarButtonSize;
        self.atButton.height = kFHWenDaToolbarButtonSize;
        self.atButton.bottom = self.toolbarView.height;
        
        self.shoppingButton.width = kFHWenDaToolbarButtonSize;
        self.shoppingButton.height = kFHWenDaToolbarButtonSize;
        self.shoppingButton.bottom = self.toolbarView.height;

        self.hashtagButton.width = kFHWenDaToolbarButtonSize;
        self.hashtagButton.height = kFHWenDaToolbarButtonSize;
        self.hashtagButton.bottom = self.toolbarView.height;

        self.emojiButton.width = kFHWenDaToolbarButtonSize;
        self.emojiButton.height = kFHWenDaToolbarButtonSize;
        self.emojiButton.bottom = self.toolbarView.height;

        self.picButton.width = kFHWenDaToolbarButtonSize;
        self.picButton.height = kFHWenDaToolbarButtonSize;
        self.picButton.bottom = self.toolbarView.height;

        [self.containerView addSubview:self.emojiInputView];

        [self refreshButtonsUI];

        self.emojiInputView.top = self.toolbarView.bottom;

        self.toolbarViewOrigin = self.origin;
        
        self.banShoppingInput = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }

    return self;
}

- (void)layoutViewWithFrame:(CGRect)newFrame {
    self.frame = newFrame;
    self.toolbarView.width = self.width;
    self.toolbarViewOrigin = self.origin;
    [self refreshButtonsUI];
}

- (void)refreshButtonsUI {
    self.emojiButton.hidden = YES;
    self.hashtagButton.hidden = YES;
    self.atButton.hidden = YES;
    self.shoppingButton.hidden = YES;
    
    self.emojiButton.right = 0;
    
    self.longTextButton.right = 0;
    self.picButton.left = 10;
    
    CGFloat right = self.toolbarView.width - 10;
    
    if (!self.keyboardButton.hidden) {
        self.keyboardButton.right = right;
        right -= kFHWenDaToolbarButtonSize + 5;
    } else {
        self.keyboardButton.right = 0;
    }
    // 隐藏
    self.hashtagButton.right = 0;
    self.atButton.right = 0;
    self.shoppingButton.right = 0;
    /*
     if (!self.hashtagButton.hidden) {
     self.hashtagButton.right = right;
     right -= kFHWenDaToolbarButtonSize + 5;
     } else {
     self.hashtagButton.right = 0;
     }
     
     if (!self.atButton.hidden) {
     self.atButton.right = right;
     right -= kFHWenDaToolbarButtonSize + 5;
     } else {
     self.atButton.right = right;
     }
     
     if (!self.shoppingButton.hidden) {
     self.shoppingButton.right = right;
     right -= kFHWenDaToolbarButtonSize + 5;
     } else {
     self.shoppingButton.right = right;
     }
     */
}

#pragma mark - actions

- (void)keyboardAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarDidClickKeyboardButton:)]) {
        BOOL switchToInput = [self.keyboardButton.imageName isEqualToString:@"fh_ugc_toolbar_keyboard_selected"]; // 这里折衷一下
        [self.delegate toolbarDidClickKeyboardButton:switchToInput];
        self.keyboardButton.imageName = switchToInput ? @"fh_ugc_toolbar_keyboard_normal" : @"fh_ugc_toolbar_keyboard_selected";
        self.keyboardButton.accessibilityLabel = switchToInput ? @"收起键盘" : @"弹出键盘";
        self.emojiButton.imageName = @"fh_ugc_toolbar_emoj_normal";
        self.emojiButton.accessibilityLabel = @"表情";
    }
}

- (void)longTextAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarDidClickLongText)]) {
        [self.delegate toolbarDidClickLongText];
    }
}

- (void)atAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarDidClickAtButton)]) {
        [self.delegate toolbarDidClickAtButton];
    }
}

- (void)shoppingAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarDidClickShoppingButton)]) {
        [self.delegate toolbarDidClickShoppingButton];
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
        self.keyboardButton.imageName = @"fh_ugc_toolbar_keyboard_selected";
        self.keyboardButton.accessibilityLabel = @"弹出键盘";
        self.emojiButton.imageName = @"fh_ugc_toolbar_emoj_normal";
        self.emojiButton.accessibilityLabel = @"表情";
        if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarDidClickEmojiButton:)]) {
            [self.delegate toolbarDidClickEmojiButton:NO];
        }
    } else {
        self.emojiInputViewVisible = YES;
        self.emojiInputView.hidden = NO;
        self.keyboardButton.imageName = @"fh_ugc_toolbar_keyboard_normal";
        self.keyboardButton.accessibilityLabel = @"收起键盘";
        self.emojiButton.imageName = @"fh_ugc_toolbar_keyboard_selected";
        self.emojiButton.accessibilityLabel = @"收起表情选择框";
        if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarDidClickEmojiButton:)]) {
            [self.delegate toolbarDidClickEmojiButton:YES];
            
            [UIView animateWithDuration:0.25 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.top = self.toolbarViewOrigin.y - kFH_WEN_DA_EMOJI_INPUT_VIEW_HEIGHT;
            } completion:nil];
        }
    }
}

- (void)picAction:(id)sender {
    if (self.picButtonClkBlk) {
        self.picButtonClkBlk();
    }
}

#pragma mark - UIKeyboardNotification

- (void)keyboardWillHide:(NSNotification *)notification {
    CGFloat targetY;
    CGRect keyboardScreenFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect frame = self.frame;
    
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
    
    if (self.emojiInputViewVisible) { // 切换到表情输入，收起键盘
        targetY = CGRectGetMinY(keyboardScreenFrame) - CGRectGetHeight(frame);
        
        // 提前显示表情选择器
        self.emojiInputView.hidden = !self.emojiInputViewVisible;
        self.keyboardButton.imageName = @"fh_ugc_toolbar_keyboard_normal";
        self.keyboardButton.accessibilityLabel = @"收起键盘";
        self.emojiButton.imageName = @"fh_ugc_toolbar_keyboard_selected";
        self.emojiButton.accessibilityLabel = @"收起表情选择框";
    } else { // 直接收起键盘
        [self endEditing:YES];
        return;
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

- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat targetY;
    CGRect keyboardScreenFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect frame = self.frame;
    
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
    
    targetY = CGRectGetMinY(keyboardScreenFrame) - kFHWenDaToolbarHeight;
    
    // Emoji 选择器输入情况下，点击 TextView 自动弹出键盘
    if (self.emojiInputViewVisible) {
        self.emojiInputViewVisible = NO;
    }
    
    self.keyboardButton.imageName = @"fh_ugc_toolbar_keyboard_normal";
    self.keyboardButton.accessibilityLabel = @"收起键盘";
    self.emojiButton.imageName = @"fh_ugc_toolbar_emoj_normal";
    self.emojiButton.accessibilityLabel = @"表情";
    
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
        self.keyboardButton.imageName = @"fh_ugc_toolbar_keyboard_selected";
        self.keyboardButton.accessibilityLabel = @"弹出键盘";
        self.emojiButton.imageName = @"fh_ugc_toolbar_emoj_normal";
        self.emojiButton.accessibilityLabel = @"表情";
        
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

- (void)setBanLongText:(BOOL)banLongText {
    _banLongText = banLongText;
    self.longTextButton.hidden = banLongText;
    [self refreshButtonsUI];
}

- (void)setBanAtInput:(BOOL)banAtInput {
    _banAtInput = banAtInput;
    
    self.atButton.enabled = !banAtInput;
    self.atButton.hidden = banAtInput;
    
    [self refreshButtonsUI];
}

- (void)setBanShoppingInput:(BOOL)banShoppingInput {
    _banShoppingInput = banShoppingInput;
    
    self.shoppingButton.enabled = !banShoppingInput;
    self.shoppingButton.hidden = banShoppingInput;
    
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
    self.keyboardButton.imageName = @"fh_ugc_toolbar_keyboard_normal";
    self.keyboardButton.accessibilityLabel = @"收起键盘";
    self.emojiButton.imageName = @"fh_ugc_toolbar_emoj_normal";
    self.emojiButton.accessibilityLabel = @"表情";
}

#pragma mark - getter and setter

- (SSThemedView *)containerView {
    if (!_containerView) {
        _containerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, kFHWenDaToolbarHeight - kFHWenDaToolbarButtonSize, self.width, kFHWenDaToolbarButtonSize + kFH_WEN_DA_EMOJI_INPUT_VIEW_HEIGHT)];
        _containerView.backgroundColorThemeKey = kColorBackground3;
    }
    
    return _containerView;
}

- (SSThemedView *)toolbarView {
    if (!_toolbarView) {
        _toolbarView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, kFHWenDaToolbarButtonSize)];
        _toolbarView.backgroundColorThemeKey = kColorBackground3;
    }
    
    return _toolbarView;
}

- (SSThemedButton *)keyboardButton {
    if (!_keyboardButton) {
        _keyboardButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _keyboardButton.imageName = @"fh_ugc_toolbar_keyboard_selected";
        _keyboardButton.accessibilityLabel = @"弹出键盘";
        [_keyboardButton addTarget:self action:@selector(keyboardAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _keyboardButton;
}

- (SSThemedButton *)longTextButton {
    if (!_longTextButton) {
        _longTextButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [_longTextButton setTitle:@"发长文" forState:UIControlStateNormal];
        _longTextButton.titleColorThemeKey = kColorText1;
        _longTextButton.borderColorThemeKey = kColorText1;
        _longTextButton.layer.borderWidth = 1;
        _longTextButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _longTextButton.layer.cornerRadius = kFHWenDaToolbarLongTextButtonHeight / 2;
        [_longTextButton addTarget:self action:@selector(longTextAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _longTextButton;
}

- (SSThemedButton *)atButton {
    if (!_atButton) {
        _atButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _atButton.imageName = @"toolbar_icon_at";
        _atButton.accessibilityLabel = @"@";
        [_atButton addTarget:self action:@selector(atAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _atButton;
}

- (SSThemedButton *)shoppingButton {
    if (!_shoppingButton) {
        _shoppingButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _shoppingButton.imageName = @"toolbar_icon_shopping";
        [_shoppingButton addTarget:self action:@selector(shoppingAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shoppingButton;
}

- (SSThemedButton *)hashtagButton {
    if (!_hashtagButton) {
        _hashtagButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _hashtagButton.imageName = @"toolbar_icon_hashtag";
        _hashtagButton.accessibilityLabel = @"话题";
        [_hashtagButton addTarget:self action:@selector(hashtagAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _hashtagButton;
}

- (SSThemedButton *)emojiButton {
    if (!_emojiButton) {
        _emojiButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _emojiButton.imageName = @"fh_ugc_toolbar_emoj_normal";
        _emojiButton.accessibilityLabel = @"表情";
        [_emojiButton addTarget:self action:@selector(emojiAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _emojiButton;
}

- (SSThemedButton *)picButton {
    if (!_picButton) {
        _picButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _picButton.imageName = @"fh_ugc_toolbar_pic_normal";
        _picButton.accessibilityLabel = @"图片";
        [_picButton addTarget:self action:@selector(picAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _picButton;
}

- (TTUGCEmojiInputView *)emojiInputView {
    if (!_emojiInputView) {
        _emojiInputView = [[TTUGCEmojiInputView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width, kFH_WEN_DA_EMOJI_INPUT_VIEW_HEIGHT)];
        _emojiInputView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        _emojiInputView.textAttachments = [TTUGCEmojiParser emojiTextAttachments];
        _emojiInputView.hidden = YES;
    }
    
    return _emojiInputView;
}

@end