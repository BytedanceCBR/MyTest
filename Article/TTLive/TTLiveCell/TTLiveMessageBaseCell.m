//
//  TTLiveMessageBaseCell.m
//  Article
//
//  Created by matrixzk on 1/27/16.
//
//


#import "TTLiveMessageBaseCell.h"

//#import "TTLiveManager.h"
#import "TTLiveAudioManager.h"

#import "SSThemed.h"
#import "UIImageView+WebCache.h"
#import "TTRoute.h"
#import "TTImageView.h"
#import "TTLiveChatTableViewController.h"
#import <TTAccountBusiness.h>
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"


@interface TTLiveAvatarView : UIView
- (void)setupAvatarViewWithMessage:(TTLiveMessage *)message;
@end

@implementation TTLiveAvatarView
{
    TTImageView *_avatarImgView;
//    SSThemedLabel *_roleLabel;
    TTLiveMessage *_message;
    UIView      *_coverView;//头像上盖一个%5的黑色遮罩
}

- (instancetype)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(0, 0, SideOfAvatarImage(), SideOfAvatarImage() + 20 + PaddingOfAvatarAndRoleLabel()); // 40 + 20 = 60
    self = [super initWithFrame:frame];
    if (self) {
        
        _avatarImgView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, SideOfAvatarImage(), SideOfAvatarImage())];
        _avatarImgView.backgroundColorThemeKey = kColorBackground2;
        _avatarImgView.layer.cornerRadius = SideOfAvatarImage()/2;
        _avatarImgView.layer.masksToBounds = YES;
        _coverView = [[UIView alloc] initWithFrame:_avatarImgView.frame];
        _coverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.05];
        _coverView.layer.cornerRadius = SideOfAvatarImage()/2;
        _coverView.layer.masksToBounds = YES;
        [self addSubview:_avatarImgView];
        [self addSubview:_coverView];
        
//        _roleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
//        _roleLabel.textAlignment = NSTextAlignmentCenter;
//        _roleLabel.textColorThemeKey = kColorText2;
//        _roleLabel.font = [UIFont systemFontOfSize:FontSizeOfRoleLabel()];
//        [self addSubview:_roleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

- (void)setupAvatarViewWithMessage:(TTLiveMessage *)message
{
    _message = message;
    
    // case 1:
//    NSURL *avatarURL = [NSURL URLWithString:message.userAvatarURLStr];
//    __weak typeof(self) wSelf = self;
//    [_avatarImgView sd_setImageWithURL:avatarURL
//                      placeholderImage:[self avatarPlaceholderImage]
//                               options:0
//                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                                 if (avatarURL == imageURL && image) {
//                                     typeof(self) self = wSelf;
//                                     self->_avatarImgView.image = [self circularImage:image];
//                                 }
//    }];
    
    // case 2:
    [_avatarImgView setImageWithURLString:message.userAvatarURLStr];
    
//    _roleLabel.text = message.userRoleName;
//    [_roleLabel sizeToFit];
//    _roleLabel.frame = (CGRect){0, 0, _roleLabel.frame.size};
//    _roleLabel.center = CGPointMake(CGRectGetWidth(_avatarImgView.frame)/2,
//                                    CGRectGetHeight(_avatarImgView.frame) + PaddingOfAvatarAndRoleLabel() + CGRectGetHeight(_roleLabel.frame)/2);
}

@end


#pragma mark - TTLiveMessageSendStateView

@interface TTLiveMessageSendStateView : UIView

@property (nonatomic, strong, readonly) SSThemedButton *resendButton;
@property (nonatomic, assign) TTLiveMessageNetworkState messageSendState;
@property (nonatomic, assign) BOOL isIncomingMsg;
@property (nonatomic, assign) BOOL hiddenActivityIndicatorView;

@end


@interface TTLiveMessageSendStateView ()
@property (nonatomic, strong) SSThemedButton *resendButton;
@end

@implementation TTLiveMessageSendStateView
{
    UIActivityIndicatorView *_indicatorView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(0, 0, 44, 44); // 图标的大小是24，为了点击方便，给edgeInsets扩充到了44.
    self = [super initWithFrame:frame];
    if (self) {
        _resendButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _resendButton.frame = frame;
        _resendButton.imageName = @"chatroom_resend";
        [self addSubview:_resendButton];
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2);
        [self addSubview:_indicatorView];
    }
    return self;
}

- (void)setMessageSendState:(TTLiveMessageNetworkState)messageSendState
{
    _messageSendState = messageSendState;
    
    switch (messageSendState) {
        case TTLiveMessageNetworkStatePrepared:
        case TTLiveMessageNetworkStateSuccess:
            _indicatorView.hidden = YES;
            _resendButton.hidden = YES;
            break;
            
        case TTLiveMessageNetworkStateLoading:
            _indicatorView.hidden = _hiddenActivityIndicatorView;
            if (!_indicatorView.hidden) {
                [_indicatorView startAnimating];
            }
            _resendButton.hidden = YES;
            break;
            
        case TTLiveMessageNetworkStateFaild:
            if (!_indicatorView.hidden) {
                [_indicatorView stopAnimating];
                _indicatorView.hidden = YES;
            }
            _resendButton.hidden = NO;
            break;
            
        default:
            break;
    }
}

- (void)setIsIncomingMsg:(BOOL)isIncomingMsg
{
    self.resendButton.imageEdgeInsets = UIEdgeInsetsMake(10, isIncomingMsg ? 0 : 20, 10, isIncomingMsg ? 20 : 0);
    _indicatorView.center = CGPointMake(isIncomingMsg ? CGRectGetWidth(_indicatorView.frame)/2 : (CGRectGetWidth(self.frame) - CGRectGetWidth(_indicatorView.frame)/2), CGRectGetHeight(self.frame)/2);
}

@end


#pragma mark - TTLiveMessageSendProgressView

@interface TTLiveMessageSendProgressView : UIView
@property (nonatomic, strong, readonly) SSThemedButton *cancelButton;
@property (nonatomic, assign) CGFloat loadingProgress;
@end

@interface TTLiveMessageSendProgressView ()
@property (nonatomic, strong) SSThemedButton *cancelButton;
@end

@implementation TTLiveMessageSendProgressView
{
    SSThemedView *_progressBgView;
    SSThemedImageView *_progressImgView;
    
    CGFloat _deltaWidth;
    CGFloat _originYOfProgressImgView;
}

static CGFloat heightOfProgressView = 8;

- (instancetype)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(0, 0, 0, HeightOfLoadingProgressView());
    self = [super initWithFrame:frame];
    if (self) {
        
        _originYOfProgressImgView = TopPaddingOfLoadingProgressViewCancelButton() + (SideOfLoadingProgressViewCancelButton() - heightOfProgressView)/2;
        
        // progressBgView
        _progressBgView = [SSThemedView new];
        _progressBgView.backgroundColorThemeKey = kColorBackground16;
        _progressBgView.layer.masksToBounds = YES;
        _progressBgView.layer.cornerRadius = heightOfProgressView/2;
        [self addSubview:_progressBgView];
        
        // progressImgView
        _progressImgView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _progressImgView.image = [[UIImage themedImageNamed:@"chatroom_loading"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)
                                                                                                resizingMode:UIImageResizingModeStretch];
        [_progressBgView addSubview:_progressImgView];
        
        // cancelButton
        _cancelButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.imageName = @"chatroom_close";
        _cancelButton.frame = CGRectMake(0, 0, 44, CGRectGetHeight(frame));
        CGFloat horizontalImgEdgeInset = (44 - SideOfLoadingProgressViewCancelButton())/2;
        _cancelButton.imageEdgeInsets = UIEdgeInsetsMake(TopPaddingOfLoadingProgressViewCancelButton(),
                                                         horizontalImgEdgeInset,
                                                         BottomPaddingOfLoadingProgressViewCancelButton(),
                                                         horizontalImgEdgeInset);
        [self addSubview:_cancelButton];
        
        _deltaWidth = (-CGRectGetWidth(_cancelButton.frame) + horizontalImgEdgeInset - BottomPaddingOfLoadingProgressViewCancelButton());
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _cancelButton.center = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(_cancelButton.frame)/2, CGRectGetHeight(self.frame)/2);
    CGFloat withOfProgressBgView = (CGRectGetWidth(self.frame) + _deltaWidth);
    _progressBgView.frame = CGRectMake(0, _originYOfProgressImgView, withOfProgressBgView, heightOfProgressView);
    _progressImgView.frame = CGRectMake(0, 0, ceilf(MAX(withOfProgressBgView * _loadingProgress, 18)), heightOfProgressView);
}

- (void)setLoadingProgress:(CGFloat)loadingProgress
{
    _loadingProgress = MIN(1, MAX(loadingProgress, 0));
    [self setNeedsLayout];
}

@end


#pragma mark - TTLiveBaseCell

#import "TTLiveCellNormalContentView.h"
#import "TTDeviceHelper.h"

@interface TTLiveMessageBaseCell () <TTLiveMessageSendStateDelegate>

@property (nonatomic, strong) TTLiveAvatarView *avatarView;
@property (nonatomic, strong) SSThemedView *containerView;
@property (nonatomic, strong) SSThemedImageView *bubbleImgView;
@property (nonatomic, strong) TTLiveCellNormalContentView *normalContentView;
@property (nonatomic, strong) TTLiveCellNormalContentView *replyedNormalContentView;
@property (nonatomic, strong) TTLiveMessageSendStateView *msgSendStateView;
@property (nonatomic, strong) TTLiveMessageSendProgressView *loadingProgressView;
@property (nonatomic, strong) TTLiveMessage *message;
@property (nonatomic, assign, getter=isIncomingMsg) BOOL incomingMsg;
@property (nonatomic, copy)   NSString *layoutString;
@end

@implementation TTLiveMessageBaseCell
{
    BOOL _supportCellBottomLoadingProgressView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
        
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        [_containerView addGestureRecognizer:longPressGestureRecognizer];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [_containerView addGestureRecognizer:tapGestureRecognizer];
        [self.contentView addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.msgSendStateView.hidden = YES;
    self.loadingProgressView.hidden = YES;
    
    self.loadingProgressView.loadingProgress = 0;
}

- (void)setupSubviews
{
    self.backgroundColor = [UIColor clearColor];
    
    _avatarView = [[TTLiveAvatarView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_avatarView];
    
    _msgSendStateView = [TTLiveMessageSendStateView new];
    [_msgSendStateView.resendButton addTarget:self
                                       action:@selector(messageResendButtonPressed:)
                             forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_msgSendStateView];
    
    _containerView = [[SSThemedView alloc] initWithFrame:CGRectZero];
    _containerView.backgroundColor = TTLiveChatListBGColor;
    [self.contentView addSubview:_containerView];
    
    _bubbleImgView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
    _bubbleImgView.userInteractionEnabled = YES;
    [_containerView addSubview:_bubbleImgView];
    
    _loadingProgressView = [TTLiveMessageSendProgressView new];
    [_loadingProgressView.cancelButton addTarget:self
                                          action:@selector(messageUploadCancelButtonPressed:)
                                forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_loadingProgressView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 根据信息来源布局
    CGFloat avatarViewLeft = self.isIncomingMsg ? kLivePaddingCellAvatarViewSide() : (self.contentView.width - kLivePaddingCellAvatarViewSide() - _avatarView.width);
    _avatarView.origin = CGPointMake(avatarViewLeft, kLivePaddingCellContentTop());
    
    CGFloat containerViewOriginX = self.isIncomingMsg ? CGRectGetMaxX(self.avatarView.frame) + PaddingOfContainerAndAvatarView() : CGRectGetMinX(self.avatarView.frame) - PaddingOfContainerAndAvatarView() - CGRectGetWidth(self.containerView.frame) - OffsetOfBubbleImageArrow();
    self.containerView.frame = (CGRect){containerViewOriginX, CGRectGetMinY(self.avatarView.frame), self.containerView.frame.size};
    
    CGRect bubbleImageViewFrame = self.containerView.bounds;
    CGFloat topInfoViewHeight = kLivePaddingCellTopInfoViewHeight(_message.cellLayout);
    if (!_message.isReplyedMsg && !(_message.cellLayout & TTLiveCellLayoutBubbleCoverTop)) {
        bubbleImageViewFrame.origin.y += topInfoViewHeight;
        bubbleImageViewFrame.size.height -= topInfoViewHeight;
    }
    bubbleImageViewFrame.size.width += OffsetOfBubbleImageArrow();
    _bubbleImgView.frame = bubbleImageViewFrame;
    
    // layout loadingProgressView
    if ([TTLiveCellHelper shouldShowCellBottomLoadingProgressViewWithMessage:_message]) {
        self.loadingProgressView.frame = CGRectMake(self.isIncomingMsg ? containerViewOriginX + OffsetOfBubbleImageArrow() : containerViewOriginX, CGRectGetMaxY(self.containerView.frame), CGRectGetWidth(self.containerView.frame) - OffsetOfBubbleImageArrow() + _loadingProgressView.cancelButton.imageEdgeInsets.right, CGRectGetHeight(_loadingProgressView.frame));
        self.loadingProgressView.hidden = NO;
    } else {
        self.loadingProgressView.hidden = YES;
    }
    
    CGFloat resendViewSide = CGRectGetWidth(self.msgSendStateView.frame);
//    CGFloat topInfoViewOffset = HeightOfTopInfoView();
    if (TTLiveMessageTypeAudio == _message.msgType && isEmptyString(_message.msgText) && !_message.replyedMessage && !_message.isReplyedMsg) {
        topInfoViewHeight += (SidePaddingOfContentView() - BottomPaddingOfNicknameLabel());
    }
    self.msgSendStateView.center = CGPointMake(self.isIncomingMsg ? CGRectGetMaxX(self.containerView.frame) + SidePaddingOfResendView() + resendViewSide/2 : CGRectGetMinX(self.containerView.frame) - SidePaddingOfResendView() - resendViewSide/2, CGRectGetMinY(self.containerView.frame) + (CGRectGetHeight(self.containerView.frame) + topInfoViewHeight)/2);
}

- (TTLiveCellNormalContentView *)normalContentView
{
    if (!_normalContentView) {
        _normalContentView = [[TTLiveCellNormalContentView alloc] initWithFrame:CGRectZero];
        [self.containerView addSubview:_normalContentView];
    }
    return _normalContentView;
}

- (TTLiveCellNormalContentView *)replyedNormalContentView
{
    if (!_replyedNormalContentView) {
        _replyedNormalContentView = [[TTLiveCellNormalContentView alloc] initWithFrame:CGRectZero];
        [self.containerView addSubview:_replyedNormalContentView];
    }
    return _replyedNormalContentView;
}

- (void)setIncomingMsg:(BOOL)incoming
{
    _incomingMsg = incoming;
    
    if (!_bubbleImgView.image || !_bubbleImgView.highlightedImage) {
        UIEdgeInsets capInsets = UIEdgeInsetsMake(20, 20, 20, 20);
        NSString *imageName = incoming ? @"chatroom_bubble_background" : @"chatroom_oneself_bubble_background";
        _bubbleImgView.image = [[UIImage themedImageNamed:imageName] resizableImageWithCapInsets:capInsets
                                                                                    resizingMode:UIImageResizingModeStretch];
        self.msgSendStateView.isIncomingMsg = _incomingMsg;
    }
}


#pragma mark - Data

- (void)setupCellWithMessage:(TTLiveMessage *)message
{
    // reset delegate
    self.message.delegate = nil;
    self.message = message;
    self.message.delegate = self;
    
    self.incomingMsg = ![message.userId isEqualToString:[TTAccountManager userID]];
    
    // setup AvatarView
    [self.avatarView setupAvatarViewWithMessage:message];
    
    _supportCellBottomLoadingProgressView = [TTLiveCellHelper supportCellBottomLoadingProgressViewWithMessage:self.message];
    self.msgSendStateView.hiddenActivityIndicatorView = _supportCellBottomLoadingProgressView;
    
    // reset msgSendStateView
    [self refreshMsgSendStateViewWithState:self.message.networkState];
}


- (void)refreshMsgSendStateViewWithState:(TTLiveMessageNetworkState)msgSendState
{
    self.msgSendStateView.hidden = (TTLiveMessageNetworkStatePrepared == msgSendState ||
                                    TTLiveMessageNetworkStateSuccess == msgSendState);
    self.msgSendStateView.messageSendState = msgSendState;
}

- (void)updateTableViewIfNeeded
{
    UIResponder *targetResponder = [self ss_nextResponderWithClass:[UITableView class]];
    if ([targetResponder isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)targetResponder;
        [tableView beginUpdates];
        [tableView endUpdates];
    }
}


#pragma mark - Action

- (void)messageResendButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(ttLiveHandleMessageResendAction:)]) {
        [self.delegate ttLiveHandleMessageResendAction:self.message];
    }
    
    self.message.loadingProgress = @(0);
    [self updateTableViewIfNeeded];
}

- (void)messageUploadCancelButtonPressed:(id)sender
{
    self.message.networkState = TTLiveMessageNetworkStateFaild;
    if (TTLiveMessageTypeVideo == self.message.msgType) {
        [self.message.msgSender cancelVideoUpload];
    }
    
    if ([self.delegate respondsToSelector:@selector(ttLiveMessageSendingDidCanceled:)]) {
        [self.delegate ttLiveMessageSendingDidCanceled:self.message];
    }
}

// 处理图片tap手势
- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognize
{
    [TTLiveCellHelper dismissCellMenuIfNeeded];
    
    // 头像区域
    if (CGRectContainsPoint(self.avatarView.bounds, [gestureRecognize locationInView:self.avatarView])) {
        if ([self.delegate respondsToSelector:@selector(ttLiveHandleMessageAvatarTappedAction:)]) {
            [self.delegate ttLiveHandleMessageAvatarTappedAction:self.message];
        }
        return;
    }
    
    if (!isEmptyString(self.message.link) &&
        CGRectContainsPoint(self.normalContentView.bounds,
                            [gestureRecognize locationInView:self.normalContentView])) {
        // 命中广告类型 message
        if ([self.delegate respondsToSelector:@selector(ttLiveHandleMessageADLinkTappedAction:)]) {
            [self.delegate ttLiveHandleMessageADLinkTappedAction:self.message];
        }
            
    } else if (!isEmptyString(self.message.replyedMessage.link) &&
               CGRectContainsPoint(_replyedNormalContentView.bounds,
                                   [gestureRecognize locationInView:_replyedNormalContentView])) {
        // 命中被回复广告类型 replyedMessage
        if ([self.delegate respondsToSelector:@selector(ttLiveHandleMessageADLinkTappedAction:)]) {
            [self.delegate ttLiveHandleMessageADLinkTappedAction:self.message.replyedMessage];
        }
                   
    } else if (TTLiveMessageTypeImage == self.message.msgType &&
               CGRectContainsPoint([(UIView *)self.normalContentView.metaImgView frame],
                                   [gestureRecognize locationInView:self.normalContentView])) {
        // 命中 message 图片
        if (!self.message.thumbImage) {
            return;
        }
        CGRect convertedFrame = [self.normalContentView convertRect:[(UIView *)self.normalContentView.metaImgView frame] toView:nil];
        if ([self.delegate respondsToSelector:@selector(ttLiveHandleMessageImageTappedAction:convertedImageFrame:targetView:)]) {
            [self.delegate ttLiveHandleMessageImageTappedAction:self.message convertedImageFrame:convertedFrame targetView:self];
        }
                   
    } else if (TTLiveMessageTypeImage == self.message.replyedMessage.msgType &&
               CGRectContainsPoint([(UIView *)_replyedNormalContentView.metaImgView frame],
                                   [gestureRecognize locationInView:_replyedNormalContentView])) {
        // 命中 replyedMessage 图片
        if (!self.message.replyedMessage.thumbImage) {
            return;
        }
        CGRect convertedFrame = [_replyedNormalContentView convertRect:[(UIView *)_replyedNormalContentView.metaImgView frame] toView:nil];
        if ([self.delegate respondsToSelector:@selector(ttLiveHandleMessageImageTappedAction:convertedImageFrame:targetView:)]) {
            [self.delegate ttLiveHandleMessageImageTappedAction:self.message.replyedMessage convertedImageFrame:convertedFrame targetView:self];
        }
    }
}

#pragma mark - TTLiveMessageSendStateDelegate Methods

- (void)ttLiveMessageSendStateChanged:(TTLiveMessageNetworkState)newState
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshMsgSendStateViewWithState:newState];
        if (_supportCellBottomLoadingProgressView && TTLiveMessageNetworkStateFaild == newState) {
            [self updateTableViewIfNeeded];
        }
    });
}

- (void)ttLiveMessageSendProgressChanged:(NSNumber *)newProgressNum
{
    if (!_supportCellBottomLoadingProgressView) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.loadingProgressView.hidden) {
            // NSLog(@"---loadingProgress : %@", newProgressNum);
            self.loadingProgressView.loadingProgress = newProgressNum.floatValue;
            if (newProgressNum.floatValue == 1) {
                [self updateTableViewIfNeeded];
            }
        }
    });
}

#pragma mark - Menu Action

- (void)handleLongPressGesture:(UIGestureRecognizer *)recognizer
{
    if (TTLiveMessageNetworkStateFaild == self.message.networkState ||
        TTLiveMessageNetworkStateLoading == self.message.networkState) {
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *audioMenuItem = [[UIMenuItem alloc] initWithTitle:[TTLiveAudioManager audioPlayModeSwitchable]
                                                               action:@selector(audioPlayModeSwitchAction:)];
        UIMenuItem *replyMenuItem = [[UIMenuItem alloc] initWithTitle:@"回复" action:@selector(replyAction:)];
        UIMenuItem *shareMenuItem = [[UIMenuItem alloc] initWithTitle:@"分享" action:@selector(shareAction:)];
        
        if ((TTLiveMessageTypeAudio == self.message.msgType || TTLiveMessageTypeAudio == self.message.replyedMessage.msgType) && ![TTDeviceHelper isPadDevice]) {
            if(self.message.disableComment){
                menuController.menuItems = @[audioMenuItem, shareMenuItem];
            }else{
                menuController.menuItems = @[audioMenuItem, replyMenuItem, shareMenuItem];
            }
        } else if (self.message.disableComment){
            menuController.menuItems = @[shareMenuItem];
        }else{
            menuController.menuItems = @[replyMenuItem,shareMenuItem];
        }
        
        [menuController setTargetRect:recognizer.view.frame inView:recognizer.view.superview];
        [menuController setMenuVisible:YES animated:YES];
        
        [self changeBubbleImageStateSelected:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuControllerWillHideMenuNotification:) name:UIMenuControllerWillHideMenuNotification object:nil];
        
        if ([self.delegate respondsToSelector:@selector(ttLiveMessageActionBubbleDidDisplayed:)]) {
            [self.delegate ttLiveMessageActionBubbleDidDisplayed:self.message];
        }
    }
}

- (void)changeBubbleImageStateSelected:(BOOL)isSelected
{
    UIEdgeInsets capInsets = UIEdgeInsetsMake(35, 20, 5, 20);
    
    NSString *imageName;
    NSString *selectedImageName;
    if (_incomingMsg) {
        imageName = @"chatroom_bubble_background";
        selectedImageName = @"chatroom_bubble_background_press";
    } else {
        imageName = @"chatroom_oneself_bubble_background";
        selectedImageName = @"chatroom_oneself_bubble_background_press";
    }
    
    _bubbleImgView.image = [[UIImage themedImageNamed:isSelected ? selectedImageName : imageName] resizableImageWithCapInsets:capInsets
                                                                                                                 resizingMode:UIImageResizingModeStretch];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (@selector(audioPlayModeSwitchAction:) == action || @selector(replyAction:) == action || @selector(shareAction:) == action) {
        return YES;
    } else {
        [self changeBubbleImageStateSelected:NO];
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)audioPlayModeSwitchAction:(id)sender
{
    [TTLiveAudioManager switchAudioPlayMode];
}

- (void)replyAction:(id)sender
{
    if ([_delegate respondsToSelector:@selector(ttLiveHandleMessageReplyedAction:)]) {
        [_delegate ttLiveHandleMessageReplyedAction:_message.isTop ? [_message copy] : _message];
    }
}

- (void)shareAction:(id)sender
{
    if ([_delegate respondsToSelector:@selector(ttLiveHandleMessageSharedAction:)]) {
        [_delegate ttLiveHandleMessageSharedAction:_message];
    }
}

- (void)handleMenuControllerWillHideMenuNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    
    [self changeBubbleImageStateSelected:NO];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController.isMenuVisible) {
        [menuController setMenuVisible:NO animated:YES];
    }
    [super touchesBegan:touches withEvent:event];
}

@end
