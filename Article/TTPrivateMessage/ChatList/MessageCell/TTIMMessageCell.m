//
//  TTIMMessageCell.m
//  EyeU
//
//  Created by matrixzk on 10/20/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "TTIMMessageCell.h"

#import "TTIMCellHelper.h"
#import "SSThemed.h"
#import "UIImageView+WebCache.h"
#import "TTIMMessageMediaView.h"
#import "TTAlphaThemedButton.h"
#import "TTIMMessage.h"
#import "TTImageView+TrafficSave.h"
#import "NSString-Extension.h"

#import "UIMenuController+Extension.h"
#import "UILabel+Tapping.h"

// Utils
#import "UIView-Extension.h"

typedef void(^ResendAction)();
@interface TTIMMessageSendStateView : SSThemedView
@property (nonatomic, assign) TTIMMessageSendState messageSendState;
@property (nonatomic, assign) BOOL showOnIncomingCell;
@property (nonatomic, assign) BOOL hiddenLoadingView;
@property (nonatomic, copy) ResendAction resendAction;
@end

@implementation TTIMMessageSendStateView {
    TTAlphaThemedButton *_resendButton;
    SSThemedImageView *_loadingImgView;
    BOOL _isLoadingAnimating;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    frame = CGRectMake(0, 0, 44, 44); // 默认最小点击size
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground4;
        _resendButton = [[TTAlphaThemedButton alloc] initWithFrame:frame];
        _resendButton.imageName = @"retry"; // 22*22
        [_resendButton addTarget:self action:@selector(resendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_resendButton];
        
        _loadingImgView = [[SSThemedImageView alloc] initWithImage:[UIImage imageNamed:@"letter_loading"]]; // 18*18
        [self addSubview:_loadingImgView];
        self.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)setMessageSendState:(TTIMMessageSendState)messageSendState
{
    _messageSendState = messageSendState;
    
    switch (messageSendState) {
        case TTIMMessageSendStateNormal:
        case TTIMMessageSendStatePrepared:
        case TTIMMessageSendStateSuccess:
            if (_isLoadingAnimating) {
                [self stopLoadingAnimating];
            }
            self.hidden = YES;
            break;
            
        case TTIMMessageSendStateSending:
            _loadingImgView.hidden = _hiddenLoadingView;
            if (!_loadingImgView.hidden) {
                [self startLoadingAnimating];
            }
            _resendButton.hidden = YES;
            self.hidden = NO;
            break;
            
        case TTIMMessageSendStateFailed:
            if (_isLoadingAnimating) {
                [self stopLoadingAnimating];
            }
            wrapperTrackEventWithCustomKeys(@"private_letter", @"dialog", nil, nil, @{@"dialog" : @"sent_fail"});
            _loadingImgView.hidden = YES;
            _resendButton.hidden = NO;
            self.hidden = NO;
            break;
            
        default:
            break;
    }
}

- (void)setShowOnIncomingCell:(BOOL)showOnIncomingCell
{
    _resendButton.imageEdgeInsets = UIEdgeInsetsMake(11, showOnIncomingCell ? 0 : 22, 11, showOnIncomingCell ? 22 : 0);
    CGFloat offset = CGRectGetWidth(_loadingImgView.frame)/2;
    _loadingImgView.center = CGPointMake(showOnIncomingCell ? offset : (CGRectGetWidth(self.frame) - offset), CGRectGetHeight(self.frame)/2);
}

- (void)resendButtonPressed:(id)sender
{
    !self.resendAction ? : self.resendAction();
    wrapperTrackEventWithCustomKeys(@"private_letter", @"dialog", nil, nil, @{@"dialog" : @"resent_msg"});
}

- (void)startLoadingAnimating
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 1.0f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 10000.0f;
    [_loadingImgView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    _isLoadingAnimating = YES;
}

- (void)stopLoadingAnimating
{
    [_loadingImgView.layer removeAllAnimations];
    _loadingImgView.transform = CGAffineTransformIdentity;
    
    _isLoadingAnimating = NO;
}

- (void)handleApplicationWillEnterForegroundNotification:(NSNotification *)notification
{
    if (self.hidden || _loadingImgView.hidden) {
        return;
    }
    
    [self stopLoadingAnimating];
    [self startLoadingAnimating];
}

@end



@interface TTIMMessageCell () <TTIMMessageSendStateDelegate, TTLabelTappingDelegate>

@property (nonatomic, strong) TTImageView *avatarView;
@property (nonatomic, strong) SSThemedLabel *cellTopLabel;
@property (nonatomic, strong) SSThemedImageView *bubbleImgView;
@property (nonatomic, strong) TTIMMessageSendStateView *msgSendStateView;
@property (nonatomic, strong) TTIMMessageMediaView *mediaView;
@property (nonatomic, strong) TTUGCSimpleRichLabel *msgTextLabel;
@property (nonatomic, strong) TTIMMessage *message;
@property (nonatomic, strong) UITapGestureRecognizer *cellTapGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *cellLongPressGesture;

@end

#define kTTIMMessageCellBgColor [UIColor teu_colorOfBackground1]

@implementation TTIMMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        [self setupSubviews];
        
        self.cellTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        self.cellTapGesture.delegate = self;
        [self.contentView addGestureRecognizer:self.cellTapGesture];
        self.cellLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        self.cellLongPressGesture.delegate = self;
        [self.contentView addGestureRecognizer:self.cellLongPressGesture];
        
        [self tt_addThemeNotification];
    }
    return self;
}

- (void)dealloc {
    [self tt_removeThemeNotification];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.message = nil;
}

- (void)setupSubviews
{
    _avatarView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, kSizeOfAvatarView().width, kSizeOfAvatarView().height)];
    _avatarView.contentMode = UIViewContentModeScaleAspectFill;
    _avatarView.layer.cornerRadius = _avatarView.width / 2;
    _avatarView.layer.masksToBounds = YES;
    _avatarView.backgroundColorThemeKey = kColorBackground1;
    _avatarView.borderColorThemeKey = kColorLine1;
    _avatarView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    [self.contentView addSubview:_avatarView];
    
    _cellTopLabel = [[SSThemedLabel alloc] init];
    _cellTopLabel.font = [UIFont systemFontOfSize:12];
    _cellTopLabel.textColorThemeKey = kColorText9;
    _cellTopLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_cellTopLabel];
    
    _msgSendStateView = [TTIMMessageSendStateView new];
    _msgSendStateView.backgroundColor = [UIColor clearColor];
    WeakSelf;
    _msgSendStateView.resendAction = ^{
        StrongSelf;
        if ([self.delegate respondsToSelector:@selector(ttimMessageCellHandleResendEvent:)]) {
            [self.delegate ttimMessageCellHandleResendEvent:self.message];
        }
    };
    [self.contentView addSubview:_msgSendStateView];
    
    //    _bubbleContainerView = [SSThemedView new];
    //    [self.contentView addSubview:_bubbleContainerView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat originY = 0;
    
    if (self.message.formattedSendDate.length > 0) {
        _cellTopLabel.text = self.message.formattedSendDate;
        _cellTopLabel.hidden = NO;
        _cellTopLabel.frame = CGRectMake(0, kTopPaddingOfCellTopLabel(), CGRectGetWidth(self.contentView.frame), kHeightOfCellTopLabel());
        originY = CGRectGetMaxY(_cellTopLabel.frame) + kBottomPaddingOfCellTopLabel();
    } else {
        _cellTopLabel.text = nil;
        _cellTopLabel.hidden = YES;
    }
    
    BOOL isIncomingMsg = ![self.message isSelf];
    
    CGFloat avatarOriginX = isIncomingMsg ? kAvatarViewOffset().horizontal : (CGRectGetWidth(self.contentView.frame) - kAvatarViewOffset().horizontal - kSizeOfAvatarView().width);
    _avatarView.frame = (CGRect){avatarOriginX, originY + kAvatarViewOffset().vertical, kSizeOfAvatarView()};
    
    UIView *bubbleView;
    CGSize bubbleSize;
    
    if (TTIMMessageTypeText == self.message.messageType) {
        _mediaView.hidden = YES;
        _bubbleImgView.hidden = NO;
        
        CGSize textSize = [TTIMCellHelper textSizeWithMessage:self.message];
        bubbleSize = [TTIMCellHelper sizeOfBubbleContainerViewWithMessage:self.message];
        
        CGFloat msgTextLabelOriginX = isIncomingMsg ? kMsgTextViewFrameInsets().left : (bubbleSize.width - kMsgTextViewFrameInsets().left - textSize.width);
        self.msgTextLabel.frame = (CGRect){msgTextLabelOriginX, kMsgTextViewFrameInsets().top, textSize};
        
        bubbleView = self.bubbleImgView;
        
    } else {
        
        _mediaView.hidden = NO;
        _bubbleImgView.hidden = YES;
        
        bubbleSize = [TTIMCellHelper sizeOfBubbleContainerViewWithMessage:self.message];
        bubbleView = self.mediaView;
    }
    
    CGFloat bubbleOriginX = isIncomingMsg ? kBubbleContainerViewOffset().horizontal : (CGRectGetWidth(self.contentView.frame) - kBubbleContainerViewOffset().horizontal - bubbleSize.width);
    bubbleView.frame = (CGRect){bubbleOriginX, CGRectGetMinY(_avatarView.frame), bubbleSize};
    
    if (TTIMMessageTypeText != self.message.messageType) {
        [TTIMCellHelper maskMediaView:bubbleView];
    }
    
    CGFloat stateViewCenterX = isIncomingMsg ? (CGRectGetMaxX(bubbleView.frame) + kMsgStateImgOffset().horizontal + CGRectGetWidth(_msgSendStateView.frame)/2) : (CGRectGetMinX(bubbleView.frame) - kMsgStateImgOffset().horizontal - CGRectGetWidth(_msgSendStateView.frame)/2);
    _msgSendStateView.center = CGPointMake(stateViewCenterX, CGRectGetMinY(bubbleView.frame) + bubbleSize.height/2 + kMsgStateImgOffset().vertical);
    
}

- (void)setupCellWithMessage:(TTIMMessage *)message
{
    self.message.delegate = nil;
    self.message = message;
    self.message.delegate = self;
    
    [_avatarView setImageWithURLString:message.avatarImageURL placeholderImage:[UIImage imageNamed:@"friend_contact_icon"]];
    BOOL isIncomingMsg = ![message isSelf];
    
    // config sendStateView
    self.msgSendStateView.showOnIncomingCell = isIncomingMsg;
    self.msgSendStateView.messageSendState = TTIMMessageSendStateNormal;
    
    switch (message.messageType) {
        case TTIMMessageTypeText:
        {
            self.msgTextLabel.textColorThemeKey = kColorText1;
            if (!self.bubbleImgView.image) {
                UIEdgeInsets capInsets = UIEdgeInsetsMake(25, 16, 5, 16);
                NSString *imageName = isIncomingMsg ? @"chat" : @"chat_me";
                self.bubbleImgView.image = [[UIImage themedImageNamed:imageName] resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
            }
            
            if (TTIMMessageSubtypeUnsupportedMsgPrompt == message.messageSubtype) {
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[message.msgText tt_attributedStringWithFont:[UIFont systemFontOfSize:kFontSizeOfMsgCellText()] lineHeight:ceil(self.msgTextLabel.font.pointSize * 4 / 3)]];
                NSRange range = [message.msgText rangeOfString:kTTIMUnsupportedMsgPromptHighlightedText];
                if (range.location != NSNotFound) {
                    [attributedString addAttribute:NSForegroundColorAttributeName
                                             value:[UIColor colorWithHexString:@"#2489FF"]
                                             range:range];
                }
                self.msgTextLabel.text = attributedString;
            } else {
                [self.msgTextLabel setText:message.msgText textRichSpans:message.msgTextContentRichSpans];
            }
        }
            break;
            
        case TTIMMessageTypeImage:
//        case TTIMMessageTypeVideo:
//        case TTIMMessageTypeMagicExpression:
        {
            [self.mediaView setupMediaViewWithMessage:message];
        }
            break;
        
        default:
            break;
    }
    
    
    [self refreshSendStateViewWithState:message.sendState];
    
    // 注掉有隐患，观察确认下。
//    [self setNeedsLayout];
}

- (void)refreshSendStateViewWithState:(TTIMMessageSendState)newState
{
    self.msgSendStateView.messageSendState = newState;
    
    // 无网等文件上传进度无法更新的情况导致的消息发送失败，隐掉进度条
    if (TTIMMessageSendStateFailed == newState) {
        [self.mediaView refreshSendProgressViewWithProgress:1];
    }
}

#pragma mark - TTIMMessageSendStateDelegate Methods

- (void)ttimMessageSendStateChanged:(TTIMMessageSendState)newState
{
    [self refreshSendStateViewWithState:newState];
    if (self.message.sendState == TTIMMessageSendStateFailed) {
        NSString *promptMessageText = [TTIMMessage promptTextOfFailedMessageWithErrorCode:self.message.errorCode];
        [TTIMMessage sendPromptMessageWithText:promptMessageText toUser:self.message.toUser];
    }
}

- (void)ttimMessageSendProgressChanged:(CGFloat)newProgress
{
    // NSLog(@">>>>> progress cell : %@", @(newProgress));
    [self.mediaView refreshSendProgressViewWithProgress:newProgress];
}

#pragma mark - TTLabelTappingDelegate
- (void)label:(UILabel *)label didSelectLinkWithURL:(NSURL *)URL
{
    [self.delegate ttimMessageCellHandleLinkEvent:self.message URL:URL];
}

#pragma mark - Gesture

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [UIMenuController dismissWithAnimated:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:self.contentView];
    
//    TTIMChatViewController *chatVC = (TTIMChatViewController *)[self ss_nextResponderWithClass:[TTIMChatViewController class]];
//    if ([chatVC isKindOfClass:[TTIMChatViewController class]]) {
//        [chatVC dismissMessageInputView];
//    }
    
    if (CGRectContainsPoint(self.avatarView.frame, tapPoint)) {
        if ([self.delegate respondsToSelector:@selector(ttimMessageCellAvatarDidTapped:)]) {
            [self.delegate ttimMessageCellAvatarDidTapped:self.message];
        }
    } else if (CGRectContainsPoint(self.bubbleImgView.frame, tapPoint)) {
        if (TTIMMessageSubtypeUnsupportedMsgPrompt == self.message.messageSubtype) {
//            [UIView showToastMessage:@"跳 AppStore 更新..." duration:1];
        }
    } else if (CGRectContainsPoint(self.mediaView.frame, tapPoint)) {
        
        CGRect convertedFrame = [self.contentView convertRect:self.mediaView.frame toView:nil];
        
        switch (self.message.messageType) {
            case TTIMMessageTypeImage:
                if (self.message.thumbImage && [self.delegate respondsToSelector:@selector(ttimMessageCellImageDidTapped:convertedFrame:)]) {
                    [self.delegate ttimMessageCellImageDidTapped:self.message convertedFrame:convertedFrame];
                }
                break;
            default:
                break;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(ttimMessageCellTapped)]) {
        [self.delegate ttimMessageCellTapped];
    }
}

- (void)handleLongPressGesture:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint tapPoint = [gestureRecognizer locationInView:self.contentView];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (CGRectContainsPoint(self.bubbleImgView.frame, tapPoint)) {
            [self becomeFirstResponder];
            UIMenuController *menu = [UIMenuController sharedMenuController];
            NSMutableArray *menuItems = [NSMutableArray array];
            UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyNormal:)];
            [menuItems addObject:copyItem];
            if (![self.message isSelf]) {
                UIMenuItem *reportItem = [[UIMenuItem alloc] initWithTitle:@"举报" action:@selector(reportMessage:)];
                UIMenuItem *blockItem = [[UIMenuItem alloc] initWithTitle:@"拉黑" action:@selector(blockMessage:)];
                [menuItems addObject:reportItem];
                [menuItems addObject:blockItem];
            }
            menu.menuItems = [menuItems copy];
            [menu setTargetRect:_msgTextLabel.frame inView:_msgTextLabel.superview];
            [menu setMenuVisible:YES animated:YES];
            wrapperTrackEventWithCustomKeys(@"private_letter", @"dialog", nil, nil, @{@"dialog" : @"press_msg"});
        }
    }
}

#pragma mark - Getter

- (SSThemedImageView *)bubbleImgView
{
    if (!_bubbleImgView) {
        _bubbleImgView = [SSThemedImageView new];
        _bubbleImgView.userInteractionEnabled = YES;
        [self.contentView insertSubview:_bubbleImgView belowSubview:_avatarView];
    }
    return _bubbleImgView;
}

- (TTIMMessageMediaView *)mediaView
{
    if (!_mediaView) {
        _mediaView = [TTIMMessageMediaView new];
        [self.contentView insertSubview:_mediaView belowSubview:_avatarView];
    }
    return _mediaView;
}

- (TTUGCSimpleRichLabel *)msgTextLabel
{
    if (!_msgTextLabel) {
        _msgTextLabel = [[TTUGCSimpleRichLabel alloc] initWithFrame:CGRectZero];
        _msgTextLabel.font = [UIFont systemFontOfSize:kFontSizeOfMsgCellText()];
        _msgTextLabel.textColorThemeKey = kColorText1;
        _msgTextLabel.numberOfLines = 0;
        _msgTextLabel.autoDetectLinks = YES;
        [self.bubbleImgView addSubview:_msgTextLabel];
    }
    return _msgTextLabel;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    BOOL canPerform = (action == @selector(copyNormal:))
    || (action == @selector(reportMessage:))
    || (action == @selector(blockMessage:));
    return canPerform;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)copyNormal:(id)sender {
    UIPasteboard *paste = [UIPasteboard generalPasteboard];
    paste.string = _message.msgText;
}

- (void)reportMessage:(id)sender {
    [self.delegate ttimMessageCellHandleReportEvent:_message];
}

- (void)blockMessage:(id)sender {
    [self.delegate ttimMessageCellHandleBlockEvent:_message];
}

#pragma mark Theme
- (void)tt_selfThemeChanged:(NSNotification *)notification {
    self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    if (_message.messageType == TTIMMessageTypeText) {
        BOOL isIncomingMsg = ![self.message isSelf];
        UIEdgeInsets capInsets = UIEdgeInsetsMake(25, 16, 5, 16);
        NSString *imageName = isIncomingMsg ? @"chat" : @"chat_me";
        self.bubbleImgView.image = [[UIImage themedImageNamed:imageName] resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
    }
}

#pragma mark - Cell Reuse Identifier

+ (NSString *)TTIMIncomingTextCellReuseIdentifier
{
    return [NSString stringWithFormat:@"%@_TTIMIncomingText", NSStringFromClass([self class])];
}

+ (NSString *)TTIMOutgoingTextCellReuseIdentifier
{
    return [NSString stringWithFormat:@"%@_TTIMOutgoingText", NSStringFromClass([self class])];
}

+ (NSString *)TTIMIncomingMediaCellReuseIdentifier
{
    return [NSString stringWithFormat:@"%@_TTIMIncomingMedia", NSStringFromClass([self class])];
}

+ (NSString *)TTIMOutgoingMediaCellReuseIdentifier
{
    return [NSString stringWithFormat:@"%@_TTIMOutgoingMedia", NSStringFromClass([self class])];
}

@end
