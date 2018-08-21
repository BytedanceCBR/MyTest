//
//  ArticleCommentView.m
//  Article
//
//  Created by SunJiangting on 14-5-25.
//
//

#import "ArticleCommentView.h"
#import "SSCommentInputHeader.h"
#import "SSUserModel.h"
#import "NetworkUtilities.h"
#import "TTIndicatorView.h"
#import "SSCommonLogic.h"
#import "TTTrackerWrapper.h"
#import "SSCheckbox.h"
#import "TTThemedAlertController.h"
#import "TTNavigationController.h"
#import "TTGroupModel.h"
#import "SSCommentModel.h"
#import "SSCommentManager.h"
#import <TTAccountBusiness.h>

#import "ArticleMobileViewController.h"
#import <sys/time.h>
#import "TTCommentViewModel.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTBusinessManager+StringUtils.h"

#import "UITextView+TTAdditions.h"
#import "HPGrowingTextView.h"
//#import "FRForumServer.h"
#import "SSCommonLogic.h"
#import "TTPersistence.h"

#import "TTUGCEmojiParser.h"
#import "TTKitchenHeader.h"
#import "TTCommentDataManager.h"


unsigned int g_momentForumCommentMaxCharactersLimit = kMaxCommentLength;

NSString *const kArticleCommentViewInsertForwardCommentNotification = @"kArticleCommentViewInsertForwardCommentNotification";
NSString *const kArticleCommentViewDeleteForwardCommentNotification = @"kArticleCommentViewDeleteForwardCommentNotification";

#define PUBLISHBUTTON_WIDTH [TTDeviceUIUtils tt_newPadding:33.f]
#define PUBLISHBUTTON_HEIGHT [TTDeviceUIUtils tt_newPadding:36.f]

@interface ArticleCommentView () <HPGrowingTextViewDelegate, UIGestureRecognizerDelegate> {
    NSInteger   _defaultTextPosition;
}


@property (nonatomic, strong) SSThemedView  *inputBackgroundView;

@property (nonatomic, strong) SSThemedLabel     *tipLabel;
@property (nonatomic, strong) SSThemedButton    *publishButton;
@property (nonatomic, assign) BOOL              hasRemovedFromWindow;
@property (nonatomic, assign) BOOL              didBeginToComment;
@property (nonatomic, strong) SSThemedView      *separatorView;
@property (nonatomic, assign) BOOL isDismiss;

@end

static struct timeval commentTimeval;

@implementation ArticleCommentView

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.backgroundView = nil;
    self.inputBackgroundView = nil;
    self.commentView = nil;
    self.textView = nil;
    self.tipLabel = nil;
    self.publishButton = nil;
    self.delegate = nil;
    self.contextInfo = nil;
    self.separatorView = nil;
    [self.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeGestureRecognizer:obj];
    }];
}

- (instancetype) initWithFrame:(CGRect) frame {
    frame = [UIApplication sharedApplication].keyWindow.bounds;
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        
        self.backgroundView = [[SSThemedView alloc] initWithFrame:self.bounds];
        self.backgroundView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        self.backgroundView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backgroundView];
        
        UIGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapActionFired:)];
        tapGesture.delegate = self;
        [self.backgroundView addGestureRecognizer:tapGesture];
        
        UIGestureRecognizer * fakePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(fakePan)];
        [self addGestureRecognizer:fakePanGesture];
        
        self.commentView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - [TTDeviceUIUtils tt_newPadding:53.f], frame.size.width, [TTDeviceUIUtils tt_newPadding:53.f])];
        self.commentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.commentView.backgroundColorThemeKey = kColorBackground4;
        self.commentView.separatorAtTOP = YES;
        self.commentView.borderColorThemeKey = kColorLine7;
        
        [self addSubview:self.commentView];
        
        self.inputBackgroundView = [[SSThemedView alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:14], [TTDeviceUIUtils tt_newPadding:10], self.commentView.width - [TTDeviceUIUtils tt_newPadding:34] - PUBLISHBUTTON_WIDTH, [TTDeviceUIUtils tt_newPadding:32.f])];
        self.inputBackgroundView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.inputBackgroundView.borderColorThemeKey = kColorLine1;
        self.inputBackgroundView.backgroundColorThemeKey = kColorBackground3;
        self.inputBackgroundView.layer.cornerRadius = self.inputBackgroundView.height / 2.f;
        self.inputBackgroundView.layer.masksToBounds = YES;
        [self.commentView addSubview:self.inputBackgroundView];
        
        CGRect textRect = CGRectMake(4, 0, CGRectGetWidth(self.inputBackgroundView.bounds) - 5, CGRectGetHeight(self.inputBackgroundView.bounds));
        
        self.textView = [[HPGrowingTextView alloc] initWithFrame:textRect];
        //        self.textView.contentInset = UIEdgeInsetsZero;
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.delegate = self;
        self.textView.placeholderColor = [UIColor tt_themedColorForKey:kColorText3];
        self.textView.placeholder = [SSCommonLogic commentInputViewPlaceHolder];
        CGFloat verticalMargin = (self.textView.internalTextView.height - [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16.f]].pointSize - 4.f) / 2.f;
        self.textView.internalTextView.textContainerInset = UIEdgeInsetsMake(verticalMargin, self.textView.internalTextView.textContainerInset.left, verticalMargin, self.textView.internalTextView.textContainerInset.right);
        self.textView.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16.f]];
        [self.inputBackgroundView addSubview:self.textView];
        
        
        self.tipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.textView.frame) - 80, CGRectGetMaxY(self.textView.frame) - 12, 70, 10)];
        self.tipLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:10.f]];
        self.tipLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        self.tipLabel.backgroundColor = [UIColor clearColor];
        self.tipLabel.textAlignment = NSTextAlignmentRight;
        self.tipLabel.textColorThemeKey = kColorText9;
        //        [self.inputBackgroundView addSubview:self.tipLabel];
        
        self.publishButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        self.publishButton.frame = CGRectMake(0, 0, PUBLISHBUTTON_WIDTH, PUBLISHBUTTON_HEIGHT);
        self.publishButton.left = self.inputBackgroundView.right + [TTDeviceUIUtils tt_newPadding:10];
        self.publishButton.bottom = self.inputBackgroundView.bottom;
        [self.publishButton setTitle:NSLocalizedString(@"发布", nil) forState:UIControlStateNormal];
        self.publishButton.titleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:14.f]];
        
        self.publishButton.titleColorThemeKey = kColorText6;
        self.publishButton.disabledTitleColorThemeKey = kColorText9;
        [self.publishButton addTarget:self action:@selector(publishActionFired:) forControlEvents:UIControlEventTouchUpInside];
        
        self.publishButton.enabled = NO;
        [self.commentView addSubview:self.publishButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postReplyCommentFinished:) name:kPostMessageFinishedNotification object:nil];
        
        
        [self growingTextViewDidChange:self.textView];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    self.inputBackgroundView.backgroundColor = SSGetThemedColorWithKey(kColorBackground3);
    self.inputBackgroundView.layer.borderColor = [SSGetThemedColorWithKey(kColorLine1) CGColor];
    self.commentView.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    self.textView.placeholderColor = SSGetThemedColorWithKey(kColorText9);
    self.textView.textColor = SSGetThemedColorWithKey(kColorText1);
    self.tipLabel.textColor = SSGetThemedColorWithKey(kColorText3);
}

- (void) setContextInfo:(NSDictionary *)contextInfo {
    ArticleMomentCommentModel * momentCommentModel = [contextInfo valueForKey:ArticleMomentCommentModelKey];
    NSString * placeholder = [SSCommonLogic commentInputViewPlaceHolder];
    if (momentCommentModel.user.name.length > 0) {
        placeholder = [NSString stringWithFormat:NSLocalizedString(@"回复 %@：", nil), momentCommentModel.user.name];
    }
    self.textView.placeholder = placeholder;
    // 从draft设置默认的textView.text
    {
        ArticleMomentModel * momentModel = [contextInfo valueForKey:ArticleMomentModelKey];
        NSString * momentId = momentModel.ID;
        NSString * commentID = momentCommentModel.ID;
        NSString *content = nil;
        if (!isEmptyString(commentID)) {
            // 回复评论的评论
            NSDictionary *draft = [SSCommonLogic draftForType:SSCommentTypeMomentComment];
            NSString *draftCommentID = [draft valueForKey:@"Identifier"];
            if ([draftCommentID isEqualToString:commentID]) {
                content = [draft valueForKey:draftCommentID];
                _defaultTextPosition = [[draft valueForKey:@"TextPosition"] intValue];
            }
        } else {
            NSDictionary *draft = [SSCommonLogic draftForType:SSCommentTypeMoment];
            NSString *draftMomentId = [draft valueForKey:@"Identifier"];
            if ([draftMomentId isEqualToString:momentId]) {
                content = [draft valueForKey:draftMomentId];
                _defaultTextPosition = [[draft valueForKey:@"TextPosition"] intValue];
            }
        }
        if (!isEmptyString(content)) {
            self.textView.text = content;
            [self growingTextViewDidChange:self.textView];
        }
    }
    _contextInfo = contextInfo;
}

- (void)showIndicatorMsg:(NSString *)msg imageName:(NSString *)imgName {
    UIImage *tipImage = nil;
    if (!isEmptyString(imgName)) {
        tipImage = [UIImage themedImageNamed:imgName];
    }
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:tipImage autoDismiss:YES dismissHandler:nil];
}

- (void)showWrongImgIndicatorWithMsg:(NSString *)msg {
    [self showIndicatorMsg:msg imageName:@"close_popup_textpage.png"];
}

- (void)publishActionFired:(UIButton *)button {
    NSString *trimStr = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (isEmptyString(trimStr)) {
        [self showIndicatorMsg:sInputContentTooShortTip imageName:@"close_popup_textpage.png"];
        return;
    }
    if(!TTNetworkConnected()) {
        [self showWrongImgIndicatorWithMsg:kNoNetworkTipMessage];
        return;
    }
    
    if (self.textView.text.length > g_momentForumCommentMaxCharactersLimit) {//非法内容， 不能发送
        [self showContentTooLongTip];
        return;
    }
    
    __weak typeof(self) wself = self;
    ArticleMobilePiplineCompletion sendLogic = ^(ArticleLoginState state){
        ////////////////// 友盟统计:
        wrapperTrackEventWithCustomKeys(@"xiangping", @"update_write_confirm", [_extraTrackDict objectForKey:@"value"], nil, _extraTrackDict);
        
        [wself publishCommentWithContextInfo:wself.contextInfo finishBlock:^(ArticleMomentCommentModel *model, NSError *error) {
            if (error) {
                /// TODO:error
            } else {
                if ([wself.delegate respondsToSelector:@selector(commentView:didFinishPublishComment:)]) {
                    [wself.delegate commentView:wself didFinishPublishComment:model];
                }
                if (_finishBlock) {
                    _finishBlock(model, error);
                }
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
                [dict setValue:wself.contextInfo forKey:@"contextInfo"];
                [dict setValue:[model toDict] forKey:@"commentDict"];
            }
        }];
    };
    
    if ([self.delegate respondsToSelector:@selector(commentView:publishWithText:)]){
        [self.delegate commentView:self publishWithText:self.textView.text];
    }
    
    if (![TTAccountManager isLogin]) {
        
        [self.textView resignFirstResponder];
        
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypePost source:@"post_comment" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                //登录成功 走发送逻辑
                if ([TTAccountManager isLogin]) {
                    sendLogic(ArticleLoginStatePlatformLogin);
                }
            } else if (type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromVC:self.viewController type:TTAccountLoginDialogTitleTypeDefault source:@"post_comment" completion:^(TTAccountLoginState state) {

                }];
            } else if (type == TTAccountAlertCompletionEventTypeCancel) {
                [wself.textView becomeFirstResponder];
            }
        }];
    }
    else {
        sendLogic(ArticleLoginStatePlatformLogin);
    }
}

- (void)publishToOriginalArticleCommentForMoment:(ArticleMomentModel *)momentModel withMyMomentCommentModel:(ArticleMomentCommentModel *)myModel toReplyModel:(ArticleMomentCommentModel *)replyModel contextInfo:(NSDictionary *)contextInfo
{
    /*
     *  momentModel:动态
     *  myModel:发表的回复
     *  replyModel:如果是对回复A的回复，这个表示回复A
     */
    
}

- (void) willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (!newWindow) {
        self.hasRemovedFromWindow = YES;
        _defaultTextPosition = self.textView.selectedRange.location;
    }
}

- (void) showInView:(UIView *) view animated:(BOOL) animated {
    if (!view) {
        view = SSGetMainWindow();
    }
    
    [view.navigationController.view addSubview:self];
    
    if ([TTDeviceHelper OSVersionNumber] < 8.0 && [TTDeviceHelper isPadDevice]) {
        self.frame = self.superview.bounds;
        [self layoutSubviews];
    }
    
    self.commentView.top = CGRectGetHeight(self.bounds);
    self.backgroundView.alpha = 0.0;
    void (^animations)(void) = ^{
        self.backgroundView.alpha = 0.5;
        [self.textView becomeFirstResponder];
        CGRect textRect = CGRectMake(4, 0, CGRectGetWidth(self.inputBackgroundView.bounds) - 4, CGRectGetHeight(self.inputBackgroundView.bounds));
        textRect.size.width -= 1;
        self.textView.frame = textRect;
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
    };
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:animations completion:completion];
    } else {
        animations();
        completion(YES);
    }
}

- (void) dismissAnimated:(BOOL) animated {
    [self _dismissAnimated:animated completion:NULL];
}

#pragma mark - Gesture
- (void) backgroundTapActionFired:(id) sender {
    BOOL shouldDismiss = YES;
    if ([self.delegate respondsToSelector:@selector(commentViewShouldDismiss:)]) {
        shouldDismiss = [self.delegate commentViewShouldDismiss:self];
    }
    if (shouldDismiss) {
        [self _dismissAnimated:YES completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(commentViewDidDismiss:)]) {
                [self.delegate commentViewDidDismiss:self];
                return;
            }
            if (_dismissBlock) {
                _dismissBlock(self);
            }
        }];
    }
}

- (void)fakePan
{
    NSLog(@"just capture pan gesture on TTNavigationController.view to avoid poping");
}

- (void)showContentTooLongTip {
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:[NSString stringWithFormat:sInputContentTooLongTip, g_momentForumCommentMaxCharactersLimit] message:nil preferredType:TTThemedAlertControllerTypeAlert];
    [alert addActionWithTitle:sOK actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
    CGFloat frameTop = 0;
    if ([self.textView isFirstResponder]) {
        frameTop = CGRectGetMaxY(self.commentView.frame);
    }
    [alert showFrom:self.viewController animated:YES keyboardPresentingWithFrameTop:frameTop];
}

- (BOOL)needDisablePublishButton
{
    return (self.textView.text.length == 0);
}

#pragma mark - HPGrowingTextViewDelegate
- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView {
    if (_defaultTextPosition < 0 || _defaultTextPosition > growingTextView.text.length) {
        _defaultTextPosition = 0;
    }
    growingTextView.selectedRange = NSMakeRange(_defaultTextPosition, 0);
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView {
    _didBeginToComment = NO;
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    CGFloat diff = height - self.textView.height;
    self.commentView.height += diff;
    self.inputBackgroundView.height += diff;
    self.textView.height += diff;
    self.commentView.top -= diff;
    self.publishButton.bottom = self.inputBackgroundView.bottom;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    if (!_didBeginToComment) {
        _didBeginToComment = YES;
        gettimeofday(&commentTimeval, NULL);
    }
    
    self.publishButton.enabled = ![self needDisablePublishButton];
    
    NSInteger contentLength = self.textView.text.length;
    NSInteger count = g_momentForumCommentMaxCharactersLimit - contentLength;
    if (count < 0) {
        self.tipLabel.hidden = NO;
        self.tipLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d", nil), count];
    } else {
        self.tipLabel.hidden = YES;
    }
}

#pragma mark - UIKeyboardNotification

- (void) keyboardWillChangeFrame:(NSNotification *) notification {
    NSDictionary * userInfo = notification.userInfo;
    /// keyboard相对于屏幕的坐标
    CGRect keyboardScreenFrame = [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if ([TTDeviceHelper isPadDevice] && [TTDeviceHelper OSVersionNumber] < 8.0) {
        keyboardScreenFrame = [self convertRect:keyboardScreenFrame fromView:nil];
    }
    
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
    
    CGRect frame = self.commentView.frame;
    BOOL keyboardHidden = NO;
    if (keyboardScreenFrame.origin.y == self.frame.size.height) {
        frame.origin.y = self.bottom;
    }
    else{
        frame.origin.y = CGRectGetMinY(keyboardScreenFrame) - CGRectGetHeight(frame);
    }
    
    if ([self.delegate respondsToSelector:@selector(commentView:willChangeFrame:keyboardHidden:contextInfo:)]) {
        [self.delegate commentView:self willChangeFrame:frame keyboardHidden:keyboardHidden contextInfo:self.contextInfo];
    }
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.commentView.frame = frame;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(commentView:didChangeFrame:keyboardHidden:contextInfo:)]) {
            [self.delegate commentView:self didChangeFrame:frame keyboardHidden:keyboardHidden  contextInfo:self.contextInfo];
        }
    }];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    [self dismissAnimated:YES];
}
- (void)postReplyCommentFinished:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    if(![userInfo objectForKey:@"error"]) {
        NSDictionary *commentData = [NSMutableDictionary dictionaryWithDictionary:[[notification userInfo] objectForKey:@"data"]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kArticleCommentViewInsertForwardCommentNotification object:commentData];
    }
}

#pragma mark - PrivateMethod
- (void) _dismissAnimated:(BOOL) animated completion:(void(^)(BOOL finished)) _completion {
    _isDismiss = YES;
    // 取消的时候保存draft， 产品需求如下
    //    如果此次评论对象与上次记忆对象相同，则更新为最新评论内容。
    //    如果此次评论对象与上次记忆对象不同：
    //    评论框内容非空，则记忆本次内容。
    //    评论框内容为空，则不记忆本次内容，保留上次草稿。
    ArticleMomentModel * momentModel = [self.contextInfo valueForKey:ArticleMomentModelKey];
    NSString * momentId = momentModel.ID;
    ArticleMomentCommentModel * momentCommentModel = [self.contextInfo valueForKey:ArticleMomentCommentModelKey];
    NSString * commentID = momentCommentModel.ID;
    NSString * content = self.textView.text;
    if (!isEmptyString(commentID)) {
        NSDictionary *originalDraft = [SSCommonLogic draftForType:SSCommentTypeMomentComment];
        if ([[originalDraft valueForKey:@"Identifier"] isEqual:commentID] || !isEmptyString(content)) {
            NSMutableDictionary *draft = [NSMutableDictionary dictionaryWithCapacity:2];
            [draft setValue:commentID forKey:@"Identifier"];
            [draft setValue:content forKey:commentID];
            [draft setValue:@(self.textView.selectedRange.location) forKey:@"TextPosition"];
            [SSCommonLogic setDraft:draft forType:SSCommentTypeMomentComment];
        }
    } else if (!isEmptyString(momentId)) {
        NSDictionary *originalDraft = [SSCommonLogic draftForType:SSCommentTypeMoment];
        if ([[originalDraft valueForKey:@"Identifier"] isEqual:momentId] || !isEmptyString(content)) {
            NSMutableDictionary *draft = [NSMutableDictionary dictionaryWithCapacity:2];
            [draft setValue:momentId forKey:@"Identifier"];
            [draft setValue:content forKey:momentId];
            [draft setValue:@(self.textView.selectedRange.location) forKey:@"TextPosition"];
            [SSCommonLogic setDraft:draft forType:SSCommentTypeMoment];
        }
    }
    [self.textView resignFirstResponder];
    self.backgroundView.alpha = 0.3;
    void (^animations)(void) = ^{
        self.backgroundView.alpha = 0.f;
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
        if (_completion) {
            _completion(finished);
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

- (UIResponder *)_needResponder
{
    if (_delegate && [_delegate respondsToSelector:@selector(nextResponder)]) {
        UIResponder *responder = [self.delegate performSelector:@selector(nextResponder) withObject:nil];
        while (responder) {
            if ([responder isKindOfClass:NSClassFromString(@"ArticleMomentDetailViewController")]) {
                return responder;
            }
            responder = [responder nextResponder];
        }
    }
    return nil;
}

- (NSString *)_replyTextForMoment:(ArticleMomentModel *)momentModel withReplyComment:(ArticleMomentCommentModel *)replyModel
{
    NSString *text = _textView.text;
    if (nil == replyModel) {
        return [NSString stringWithFormat:@"%@//@%@: %@", text, momentModel.user.name, momentModel.content];
    }
    else {
        if (isEmptyString(replyModel.replyUser.ID)) {
            return [NSString stringWithFormat:@"%@//@%@: %@//@%@: %@", text, replyModel.user.name, replyModel.content, momentModel.user.name, momentModel.content];
        }
        else {
            return [NSString stringWithFormat:@"%@//@%@: %@", text, replyModel.user.name, replyModel.content];
        }
    }
}

- (BOOL)needSelectedForwardCheckButton {
    return [KitchenMgr getBOOL:KKCCommentRepostSelected];
}

- (void)setForwardheckButtonSelected:(BOOL)selected {
    [KitchenMgr setBOOL:selected forKey:KKCCommentRepostSelected];
}

@end

@implementation ArticleCommentView (PublishAction)


- (void)showRightImgIndicatorWithMsg:(NSString *)msg {
    [self showIndicatorMsg:msg imageName:@"doneicon_popup_textpage.png"];
}

- (void)publishCommentWithContextInfo:(NSDictionary *) contextInfo
                          finishBlock:(void(^)(ArticleMomentCommentModel *model, NSError *error))finishBlock {
    if(!TTNetworkConnected()) {
        [self showWrongImgIndicatorWithMsg:kNoNetworkTipMessage];
        return;
    }
    
    ArticleMomentModel * momentModel = [contextInfo valueForKey:ArticleMomentModelKey];
    NSString * momentId = momentModel.ID;
    ArticleMomentCommentModel * replyMomentCommentModel = [contextInfo valueForKey:ArticleMomentCommentModelKey];
    
    //从评论区进入时 带进来的commentModel
    id<TTCommentModelProtocol> origCommentModel = contextInfo[ArticleCommentModelKey];
    
    NSString * userId = replyMomentCommentModel.user.ID;
    NSString * commentID = replyMomentCommentModel.ID;
    NSString * content = [TTUGCEmojiParser stringify:self.textView.attributedText];
    /// 发表评论
    __weak typeof(self) weakSelf = self;
    [self showIndicatorMsg:sSending imageName:nil];
    self.publishButton.enabled = NO;
    
    NSString *ID = nil;
    if (_source == ArticleMomentSourceTypeArticleDetail) {
        ID = origCommentModel.commentID.stringValue;
    } else {
        ID = momentId;
    }
    [ArticleMomentCommentManager startPostCommentForComment:ID CommentID:commentID commentUserID:userId content:content source:_source isForward:NO withFinishBlock:^(ArticleMomentCommentModel *model, NSError *error) {
        if (error) {
            /// error
            self.publishButton.enabled = YES;
            NSString *msg = nil;
            if([error.domain isEqualToString:kCommonErrorDomain]) {
                msg = [[error userInfo] objectForKey:kErrorDisplayMessageKey];
            }
            if(isEmptyString(msg)) msg = kNetworkConnectionErrorTipMessage;
            [weakSelf showWrongImgIndicatorWithMsg:msg];
            
            if (finishBlock) {
                finishBlock(model, error);
            }
        } else {
            /*
             * 如果勾选了“同时转发到微头条”，则额外发表一条对当前动态的文章评论
             */
            [self publishToOriginalArticleCommentForMoment:momentModel
                                  withMyMomentCommentModel:model
                                              toReplyModel:replyMomentCommentModel
                                               contextInfo:contextInfo];
            [momentModel insertComment:model];
            [weakSelf showRightImgIndicatorWithMsg:sSendDone];
            // 发送成功之后就清空draft
            if (!isEmptyString(commentID)) {
                [SSCommonLogic setDraft:nil forType:SSCommentTypeMomentComment];
            } else {
                [SSCommonLogic setDraft:nil forType:SSCommentTypeMoment];
            }
            weakSelf.textView.text = nil;
            if (finishBlock) {
                finishBlock(model, error);
            }
        }
    }];
}

@end

NSString * const ArticleMomentCommentModelKey = @"MomentCommentModel";
NSString * const ArticleMomentModelKey = @"MomentModel";
NSString * const ArticleKeyboardHiddenKey = @"KeyboardHidden";
NSString * const ArticleCommentModelKey = @"CommentModel";
