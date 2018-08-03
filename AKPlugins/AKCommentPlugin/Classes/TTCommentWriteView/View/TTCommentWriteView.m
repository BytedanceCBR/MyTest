//
//  TTCommentWriteView.m
//  Article
//
//  Created by ranny_90 on 2018/1/4.
//

#import "TTCommentWriteView.h"
#import <TTUGCFoundation/TTUGCTextView.h>
#import <TTUGCFoundation/TTUGCTextViewMediator.h>
#import <TTUGCFoundation/TTUGCEmojiInputView.h>
#import <TTPlatformBaseLib/TTProfileFillManager.h>
#import <TTUGCFoundation/TTRichSpanText.h>
#import <TTUGCFoundation/TTUGCEmojiParser.h>
#import <TTBaseLib/NSObject+MultiDelegates.h>
#import <TTUIWidget/TTNavigationController.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <TTBaseLib/UITextView+TTAdditions.h>
#import <TTThemed/TTThemeManager.h>
#import <TTAccountBusiness.h>
#import "TTCommentFunctionView.h"
#import "TTCommentTransparentView.h"
#import "TTCommentDetailReplyWriteManager.h"
#import "TTCommentDefines.h"

#define PUBLISHBUTTON_WIDTH [TTDeviceUIUtils tt_newPadding:35.f]
#define PUBLISHBUTTON_HEIGHT [TTDeviceUIUtils tt_newPadding:22.5f]
#define EMOJI_INPUT_VIEW_HEIGHT ([TTDeviceHelper isScreenWidthLarge320] ? 216.f : 193.f)

static struct timeval commentTimeval;


@interface TTCommentWriteView() <TTCommentFunctionDelegate,UIGestureRecognizerDelegate, TTUGCTextViewDelegate>

@property (nonatomic, strong) SSThemedView *containerViewBackgroundView;
@property (nonatomic, strong) SSThemedView *containerView;

@property (nonatomic, strong) SSThemedView *textInputView;

@property (nonatomic, strong) SSThemedButton *publishButton;

@property (nonatomic, strong) TTCommentFunctionView *commentFunctionView;
@property (nonatomic, strong) TTUGCTextViewMediator *textViewMediator;

@property (nonatomic, strong) TTUGCEmojiInputView *emojiInputView;
@property (nonatomic, strong) TTCommentTransparentView *backgroundView;

@property (nonatomic, assign) BOOL hasRemovedFromWindow;

@property (nonatomic, strong) NSString *draftContent;
@property (nonatomic, strong) NSString *draftContentRichSpan;
@property (nonatomic, assign) NSInteger defaultTextPosition;

@property (nonatomic, assign) BOOL didBeginToComment;

@property (nonatomic, strong) id<TTCommentManagerProtocol> commentManager;

@end

@implementation TTCommentWriteView

+ (CGRect)frameForCommentInputView {
    CGRect frame = [UIApplication sharedApplication].keyWindow.bounds;

    if ([TTDeviceHelper isPadDevice] &&
        [TTDeviceHelper OSVersionNumber] < 8.0 &&
        !UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        frame.size = CGSizeMake(frame.size.height, frame.size.width);
    }

    return frame;
}


#pragma mark -- life method

- (void)dealloc {
    _inputTextView.delegate = nil;
    [_inputTextView tt_removeDelegate:_textViewMediator];
    _commentFunctionView.delegate = nil;
    _emojiInputView.delegate = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCommentManager:(id<TTCommentManagerProtocol>)commentManager {

    CGRect frame = [TTCommentWriteView frameForCommentInputView];
    self = [super initWithFrame:frame];
    if (self) {

        self.commentManager = commentManager;
        if ([TTDeviceHelper isPadDevice]) {
            self.banEmojiInput = YES;
        }
        self.isDismiss = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.isNeedTips = YES;
        [self setupViews];
        [self addObservers];
        self.commentManager.commentWriteView = self;
        self.banCommentRepost = YES;
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat bottomSafeInset = self.tt_safeAreaInsets.bottom;
    CGFloat minHeight = [TTDeviceUIUtils tt_newPadding:32 + 10 + 10] + EMOJI_INPUT_VIEW_HEIGHT;
    if ([TTAccountManager isLogin]){
        minHeight += [TTDeviceUIUtils tt_newPadding:33];
    }
    if (self.containerView.height <= minHeight){
        self.containerView.height = minHeight + bottomSafeInset;
        self.emojiInputView.top = self.textInputView.bottom;
    }
    if (@available(iOS 11.0, *)) {
        self.textInputView.width = self.width - self.tt_safeAreaInsets.left - self.tt_safeAreaInsets.right;
        self.textInputView.left = self.tt_safeAreaInsets.left;
    }
}

- (void)willAppear {
    [super willAppear];
}

- (void)didAppear {
    [super didAppear];
}

- (void)willDisappear {
    [super willDisappear];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];

    UIViewController * viewController = (UIViewController *)[TTUIResponderHelper topViewControllerFor: self];
    TTNavigationController * navigationController = (TTNavigationController *)viewController;
    if (!newWindow) {
        _defaultTextPosition = self.inputTextView.selectedRange.location;
        self.hasRemovedFromWindow = YES;
        if ([navigationController isKindOfClass:[TTNavigationController class]]) {
            navigationController.topViewController.ttDisableDragBack = NO;
        }
    }
    if (newWindow && self.hasRemovedFromWindow) {
        if (!self.inputTextView.isFirstResponder) {
            //            [self.inputTextView becomeFirstResponder];
        }
        if ([navigationController isKindOfClass:[TTNavigationController class]]) {
            navigationController.topViewController.ttDisableDragBack = YES;
        }
    }
}

#pragma mark - public method

- (void)setTextViewPlaceholder:(NSString *)placeholder {
    self.inputTextView.internalGrowingTextView.placeholder = placeholder;

    [self layoutIfNeeded];
}

- (void)setRepostButtonTitle:(NSString *)repostButtonTitle {
    _repostButtonTitle = repostButtonTitle;
    self.commentFunctionView.repostTitle = self.repostButtonTitle;

    [self layoutIfNeeded];
}

- (BOOL)isCommentRepostedChecked {
    return self.commentFunctionView.isCommentRepostChecked;
}

- (struct timeval)commentTimeval {
    return commentTimeval;
}

- (void)configureDraftContent:(NSString *)draftContent withDraftContentRichSpan:(NSString *)draftContentRichSpan withDefaultTextPosition:(NSInteger)defaultTextPosition {
    self.draftContent = draftContent;
    self.draftContentRichSpan = draftContentRichSpan;
    self.defaultTextPosition = defaultTextPosition;

    TTRichSpans *contentRichSpan = [TTRichSpans richSpansForJSONString:self.draftContentRichSpan];
    if (!isEmptyString(draftContent)) {
        self.inputTextView.richSpanText = [[TTRichSpanText alloc] initWithText:draftContent richSpans:contentRichSpan];
    } else {
        self.inputTextView.richSpanText = [[TTRichSpanText alloc] initWithText:@"" richSpans:contentRichSpan];
    }
    self.publishButton.enabled = !isEmptyString(self.inputTextView.text);

    [self layoutIfNeeded];
}

- (void)configurePublishButtonEnable:(BOOL)enable {
    self.publishButton.enabled = enable;
    [self layoutIfNeeded];
}


- (void)setBanEmojiInput:(BOOL)banEmojiInput {

    _banEmojiInput = banEmojiInput;
    self.commentFunctionView.banEmojiInput = _banEmojiInput;
    [self layoutIfNeeded];
}

- (void)setBanCommentRepost:(BOOL)banCommentRepost {

    _banCommentRepost = banCommentRepost;
    self.commentFunctionView.banCommentRepost = banCommentRepost;
    if (self.commentFunctionView.banCommentRepost) {
        self.inputTextView.isBanHashtag = YES;
        self.inputTextView.isBanAt = YES;
    }
    [self layoutIfNeeded];
}

- (void)showInView:(UIView *)view animated:(BOOL)animated {
    UIViewController *viewController = [self shouldShowedInViewControllerForView:view];
    if ([viewController isKindOfClass:[TTNavigationController class]]) {
        TTNavigationController *navigationController = (TTNavigationController *)viewController;
        navigationController.topViewController.ttDisableDragBack = YES;
    }

    // 图片评论二级页采用了 present 方式，不包含 statusBar
    if (!CGRectEqualToRect(viewController.view.frame, self.frame)) {
        self.height = viewController.view.height;
    }

    [viewController.view addSubview:self];
    [self layoutIfNeeded];

    void (^completion)(BOOL) = ^(BOOL finished) {
        self.containerView.bottom = CGRectGetHeight(self.bounds);
    };

    self.backgroundView.alpha = 0.0;
    void (^animations)(void) = ^{
        self.backgroundView.alpha = 0.5;
        completion(YES);
    };

    if (animated) {
        [UIView animateWithDuration:0.25 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:animations completion:nil];
    } else {
        animations();
    }

    if (self.emojiInputViewVisible) {
        self.emojiInputView.hidden = NO;
        self.commentFunctionView.emojiButtonState = TTCommentFunctionEmojiButtonStateKeyboard;
    } else {
        self.emojiInputView.hidden = YES;
        self.commentFunctionView.emojiButtonState = TTCommentFunctionEmojiButtonStateEmoji;
        [self.inputTextView becomeFirstResponder];
    }

    //此处注意埋点问题，统计 写评论时「同时转发到微头条」选项展示，以及回复时的埋点

    if (self.commentManager) {
        [self.commentManager commentViewShow];
    }
}

- (UIViewController *)shouldShowedInViewControllerForView:(UIView *)view {
    if (!view) {
        view = SSGetMainWindow();
    }

    UIViewController * viewController = (UIViewController *)[TTUIResponderHelper topViewControllerFor: view];
    if ([viewController isKindOfClass:[TTNavigationController class]]) {
        viewController = (TTNavigationController *)viewController;
    }
    else if ([viewController isKindOfClass:NSClassFromString(@"TTArticleTabBarController")]) {
        viewController = viewController;
    }
    else {
        viewController = (TTNavigationController *)viewController.navigationController;
    }

    if (viewController.presentedViewController != nil) {
        UIViewController *presentedNav = [viewController presentedViewController];
        if ([presentedNav isKindOfClass:[TTNavigationController class]]) {
            viewController = [[((TTNavigationController *)presentedNav) viewControllers] lastObject];
        }
        else {
            viewController = [TTUIResponderHelper topViewControllerFor: viewController];
        }
    }
    return viewController;
}

- (void)dismissAnimated:(BOOL) animated {
    if (self.textViewMediator.isSelectViewControllerVisible) {
        return;
    }

    self.isDismiss = YES;

    if (self.commentManager) {
        [self.commentManager commentViewDismiss];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [self.inputTextView resignFirstResponder];
    self.backgroundView.alpha = 0.5;
    void (^animations)(void) = ^{
        self.backgroundView.alpha = 0.f;
        self.containerView.top = self.bottom;
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
        UIViewController * viewController = (UIViewController *)[TTUIResponderHelper topViewControllerFor: self.superview];
        if ([viewController isKindOfClass:[TTNavigationController class]]) {
            TTNavigationController * navigationController = (TTNavigationController *)viewController;
            navigationController.topViewController.ttDisableDragBack = NO;
        }
        [self removeFromSuperview];
    };
    if (animated) {
        [UIView animateWithDuration:0.25 animations:animations completion:completion];
    } else {
        animations();
        completion(YES);
    }

}


- (void)showContentTooLongTip:(NSString *)tips {
    if (!isEmptyString(tips)) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:tips message:nil preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:kCommentOK actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
        CGFloat frameTop = 0;
        if ([self.inputTextView isFirstResponder]) {
                frameTop = CGRectGetMaxY(self.containerView.frame);
            }
            [alert showFrom:self.viewController animated:YES keyboardPresentingWithFrameTop:frameTop];
    }
}

#pragma mark -- kvo method

- (void)themeChanged:(NSNotification*)notification {
    [super themeChanged:notification];

    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
        self.inputTextView.keyboardAppearance = UIKeyboardAppearanceLight;
    } else {
        self.inputTextView.keyboardAppearance = UIKeyboardAppearanceDark;
    }

    self.inputTextView.internalGrowingTextView.placeholderColor = SSGetThemedColorWithKey(kColorText9);
    self.inputTextView.internalGrowingTextView.textColor = SSGetThemedColorWithKey(kColorText1);
}

- (void)orientationDidChangeNotification:(NSNotification *)notification{
    //统一处理视图发生旋转
    self.frame = [TTCommentWriteView frameForCommentInputView];
    [self dismissAnimated:YES];
}


#pragma mark - UIKeyboardNotification

- (void)keyboardWillChangeFrame:(NSNotification *) notification {
    if (!self.superview) {
        return;
    }

    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardScreenFrame = [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardScreenFrame = [self convertRect:keyboardScreenFrame fromView:nil];
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
    CGRect frame = self.containerView.frame;
    CGFloat targetY = CGRectGetMinY(keyboardScreenFrame) - CGRectGetHeight(frame); // 键盘弹出状态位置

    // 为了保证从上往下收起动画效果的完整性
    if (CGRectGetMinY(keyboardScreenFrame) >= self.height) { // 收起，这里采用 self.height 而不是 window.height，因为 present 方式弹出时高度不一致
        if (self.emojiInputViewVisible) { // 切换到表情输入，收起键盘
            targetY = CGRectGetHeight(self.frame) - CGRectGetHeight(self.containerView.frame);

            // 提前显示表情选择器
            self.emojiInputView.hidden = !self.emojiInputViewVisible;
        } else { // 直接收起键盘
            targetY = [[[UIApplication sharedApplication] delegate] window].bounds.size.height;
        }
    } else { // 弹出键盘
        targetY = CGRectGetMinY(keyboardScreenFrame) - CGRectGetHeight(self.textInputView.frame);

        // Emoji 选择器输入情况下，点击 TextView 自动弹出键盘
        if (self.emojiInputViewVisible) {
            self.commentFunctionView.emojiButtonState = TTCommentFunctionEmojiButtonStateEmoji;
            [self toolbarDidClickEmojiButton:NO];
        }
    }

    frame.origin.y = targetY;

    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.containerView.frame = frame;
    } completion:^(BOOL finished) {
        self.emojiInputView.hidden = !self.emojiInputViewVisible;
    }];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    if (self.emojiInputViewVisible) {
        return;
    }

    [self.commentManager commentViewCancelPublish];
    [self dismissAnimated:YES];
}


#pragma mark -- delegate method

#pragma mark - TTCommentFunctionDelegate

- (void)toolBarDidClickRepostButton {

    if (self.commentManager && [self.commentManager respondsToSelector:@selector(commentViewClickRepostButton)]) {
        [self.commentManager commentViewClickRepostButton];
    }
}

- (void)toolbarDidClickEmojiButton:(BOOL)switchToEmojiInput {
    self.emojiInputViewVisible = switchToEmojiInput;

    _defaultTextPosition = self.inputTextView.selectedRange.location;
}

- (void)toolbarNeedHiddenStatusUpdate:(BOOL)isNeedToHidden {
    if (isNeedToHidden && self.commentFunctionView.height > 0 && self.commentFunctionView.hidden == NO) {
        self.commentFunctionView.height = 0;
        self.commentFunctionView.hidden = YES;
        self.containerView.top += [TTDeviceUIUtils tt_newPadding:33];
        self.containerView.height -= [TTDeviceUIUtils tt_newPadding:33];
        self.textInputView.height -= [TTDeviceUIUtils tt_newPadding:33];
    } else if (!isNeedToHidden && self.commentFunctionView.height <= 0 && self.commentFunctionView.hidden == YES) {
        self.commentFunctionView.height = [TTDeviceUIUtils tt_newPadding:43];
        self.commentFunctionView.hidden = NO;
        self.containerView.top -= [TTDeviceUIUtils tt_newPadding:33];
        self.containerView.height += [TTDeviceUIUtils tt_newPadding:33];
        self.textInputView.height += [TTDeviceUIUtils tt_newPadding:33];
    }

    self.publishButton.centerY = self.inputTextView.bottom - [TTDeviceUIUtils tt_newPadding:32.f]/2.f;
}

#pragma mark - TTUGCTextViewDelegate

- (void)textViewDidChange:(TTUGCTextView *)textView {

    if (!self.didBeginToComment) {
        self.didBeginToComment = YES;
        gettimeofday(&commentTimeval, NULL);
    }

    self.publishButton.enabled = !isEmptyString(self.inputTextView.text);
}

- (void)textView:(TTUGCTextView *)textView willChangeHeight:(float)height withDiffHeight:(CGFloat)diffHeight{
    self.containerView.height += diffHeight;
    self.containerView.top -= diffHeight;
    self.commentFunctionView.top += diffHeight;
    self.textInputView.height += diffHeight;
}

#pragma mark - NSLayoutDelegate

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    return [TTDeviceUIUtils tt_newPadding:7]; // For really wide spacing; pick your own value
}


#pragma mark -- private method

- (void)setupViews {

    self.publishButton.frame = CGRectMake((self.width - self.inputTextView.right - PUBLISHBUTTON_WIDTH) / 2 + self.inputTextView.right, 0, PUBLISHBUTTON_WIDTH, PUBLISHBUTTON_HEIGHT);

    self.commentFunctionView.top = self.inputTextView.bottom;
    self.commentFunctionView.left = 0;
    self.commentFunctionView.width = self.width;
    self.commentFunctionView.height = [TTDeviceUIUtils tt_newPadding:43];

    self.textInputView.height += [TTDeviceUIUtils tt_newPadding:33];
    self.containerView.height += [TTDeviceUIUtils tt_newPadding:33];
    self.publishButton.centerY = self.inputTextView.bottom - [TTDeviceUIUtils tt_newPadding:32.f]/2.f;

    self.emojiInputView.top = self.textInputView.bottom;

    // TextView and Toolbar Mediator
    self.textViewMediator = [[TTUGCTextViewMediator alloc] init];
    self.textViewMediator.textView = self.inputTextView;
    self.inputTextView.delegate = self.textViewMediator;
    [self.inputTextView tt_addDelegate:self asMainDelegate:NO];
    self.commentFunctionView.delegate = self;
    [self.commentFunctionView tt_addDelegate:self.textViewMediator asMainDelegate:NO];

    [self addSubview:self.backgroundView];
    [self addSubview:self.containerViewBackgroundView];
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.textInputView];
    [self.textInputView addSubview:self.inputTextView];
    [self.textInputView addSubview:self.commentFunctionView];
    [self.textInputView addSubview:self.publishButton];
    [self.containerView addSubview:self.emojiInputView];

    //个人信息补全逻辑
    [[TTProfileFillManager manager] isShowProfileFill:nil log_action:YES disable:NO];

    [self reloadThemeUI];
}

- (void)addObservers {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChangeNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

    //postMessageFinished通知
}

#pragma mark -- action method

- (void)publish:(id)sender {

    if (self.commentManager) {
        [self.commentManager commentViewClickPublishButton];
    }
}


#pragma mark -- getter & setter method

- (SSThemedView *)containerViewBackgroundView {
    if (!_containerViewBackgroundView){
        _containerViewBackgroundView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, self.bottom, self.width, [TTDeviceUIUtils tt_newPadding:32 + 10 + 10] + EMOJI_INPUT_VIEW_HEIGHT)];
        _containerViewBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _containerViewBackgroundView.backgroundColorThemeKey = kColorBackground4;
        _containerViewBackgroundView.borderColorThemeKey = kColorLine7;
        _containerViewBackgroundView.separatorAtTOP = YES;
    }

    return _containerViewBackgroundView;
}

- (SSThemedView *)containerView {
    if (!_containerView) {
        _containerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, self.bottom, self.width, [TTDeviceUIUtils tt_newPadding:32 + 10 + 10] + EMOJI_INPUT_VIEW_HEIGHT)];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _containerView.backgroundColorThemeKey = kColorBackground4;
        _containerView.borderColorThemeKey = kColorLine7;
        _containerView.separatorAtTOP = YES;
    }

    return _containerView;
}

- (SSThemedView *)textInputView {
    if (!_textInputView) {
        _textInputView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, [TTDeviceUIUtils tt_newPadding:32 + 10 + 10])];
        _textInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    }

    return _textInputView;
}


- (TTUGCTextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[TTUGCTextView alloc] initWithFrame:CGRectMake(14.f, [TTDeviceUIUtils tt_newPadding:10.f], self.width - 14.f - 60.f, [TTDeviceUIUtils tt_newPadding:32.f])];
        _inputTextView.isBanHashtag = YES;
        if ([TTDeviceHelper isPadDevice]) {
            _inputTextView.isBanHashtag = YES;
            _inputTextView.isBanAt = YES;
        }
        _inputTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _inputTextView.backgroundColorThemeKey = kColorBackground3;
        _inputTextView.borderColorThemeKey = kColorLine1;

        _inputTextView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _inputTextView.layer.masksToBounds = YES;
        _inputTextView.textViewFontSize = [TTDeviceUIUtils tt_newFontSize:16.f];
        _inputTextView.typingAttributes = @{
                                            NSFontAttributeName: [UIFont systemFontOfSize:_inputTextView.textViewFontSize],
                                            NSForegroundColorAttributeName : SSGetThemedColorWithKey(kColorText1),
                                            };

        HPGrowingTextView *internalTextView = _inputTextView.internalGrowingTextView;
        internalTextView.minHeight = [TTDeviceUIUtils tt_newPadding:32.f];
        internalTextView.contentInset = UIEdgeInsetsMake(0.f, 7.f, 0.f, 4.f);
        CGFloat verticalMargin = floorf(([TTDeviceUIUtils tt_newPadding:32.f] - [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]].lineHeight) / 2.f); // 文字垂直居中
        internalTextView.internalTextView.textContainerInset = UIEdgeInsetsMake(verticalMargin, internalTextView.internalTextView.textContainerInset.left, verticalMargin, internalTextView.internalTextView.textContainerInset.right);
        internalTextView.placeholder = kCommentInputPlaceHolder;
        internalTextView.backgroundColor = [UIColor clearColor];
        internalTextView.textColor = SSGetThemedColorWithKey(kColorText1);
        internalTextView.placeholderColor = SSGetThemedColorWithKey(kColorText9);
        internalTextView.internalTextView.placeHolderFont = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]];
        _inputTextView.layer.cornerRadius = _inputTextView.height / 2;
        _inputTextView.richSpanText = [[TTRichSpanText alloc] initWithText:@"" richSpans:nil];
    }

    return _inputTextView;
}

- (TTCommentFunctionView *)commentFunctionView {
    if (!_commentFunctionView) {
        _commentFunctionView = [[TTCommentFunctionView alloc] init];
        _commentFunctionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        _commentFunctionView.delegate = self;
        if (!isEmptyString(self.repostButtonTitle)) {
            _commentFunctionView.repostTitle = self.repostButtonTitle;
        }

    }

    return _commentFunctionView;
}

- (SSThemedButton *)publishButton {
    if (!_publishButton) {
        _publishButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _publishButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -6, -8, -6);
        [_publishButton setTitle:@"发布" forState:UIControlStateNormal];
        _publishButton.titleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]];
        [_publishButton sizeToFit];
        _publishButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        _publishButton.titleColorThemeKey = kColorText6;
        _publishButton.disabledTitleColorThemeKey = kColorText9;
        [_publishButton addTarget:self action:@selector(publish:) forControlEvents:UIControlEventTouchUpInside];
        _publishButton.enabled = NO;
    }

    return _publishButton;
}

- (TTUGCEmojiInputView *)emojiInputView {
    if (!_emojiInputView) {
        _emojiInputView = [[TTUGCEmojiInputView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width, EMOJI_INPUT_VIEW_HEIGHT)];
        _emojiInputView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        _emojiInputView.delegate = self.inputTextView;
        _emojiInputView.textAttachments = [TTUGCEmojiParser emojiTextAttachments];
        _emojiInputView.source = @"comment";
        _emojiInputView.hidden = YES;
    }

    return _emojiInputView;
}

- (TTCommentTransparentView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[TTCommentTransparentView alloc] initWithFrame:self.bounds];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        WeakSelf;
        _backgroundView.touchComplete = ^{
            StrongSelf;
            [self.commentManager commentViewCancelPublish];
            [self dismissAnimated:YES];
        };
    }

    return _backgroundView;
}

@end
