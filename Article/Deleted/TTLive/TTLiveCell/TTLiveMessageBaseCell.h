//
//  TTLiveMessageBaseCell.h
//  Article
//
//  Created by matrixzk on 1/27/16.
//
//

#import <UIKit/UIKit.h>

#import "TTLiveCellHelper.h"
#import "TTLiveMessage.h"

@class SSThemedImageView;
@class SSThemedButton;
@class SSThemedView;
@class TTLiveMessage;
@class TTLiveMessageSendStateView;
@class TTLiveMessageSendProgressView;
@class TTLiveCellNormalContentView;


@class TTLiveMessageBaseCell;
@protocol TTLiveMessageHandleDelegate <NSObject>
@optional
- (void)ttLiveHandleMessageReplyedAction:(TTLiveMessage *)message;
- (void)ttLiveHandleMessageSharedAction:(TTLiveMessage *)message;
- (void)ttLiveHandleMessageImageTappedAction:(TTLiveMessage *)message convertedImageFrame:(CGRect)convertedFrame targetView:(UIView *)view;
- (void)ttLiveHandleMessageADLinkTappedAction:(TTLiveMessage *)message;

- (void)ttLiveHandleMessageResendAction:(TTLiveMessage *)message;
- (void)ttLiveHandleMessageAvatarTappedAction:(TTLiveMessage *)message;

- (void)ttLiveMessageActionBubbleDidDisplayed:(TTLiveMessage *)message;
- (void)ttLiveMessageSendingDidCanceled:(TTLiveMessage *)message;

@end


@interface TTLiveMessageBaseCell : UITableViewCell

@property (nonatomic, weak) id<TTLiveMessageHandleDelegate> delegate;
@property (nonatomic, strong, readonly) SSThemedView *containerView;
@property (nonatomic, strong, readonly) SSThemedImageView *bubbleImgView;
@property (nonatomic, strong, readonly) TTLiveCellNormalContentView *normalContentView;
@property (nonatomic, strong, readonly) TTLiveCellNormalContentView *replyedNormalContentView;
@property (nonatomic, strong, readonly) TTLiveMessageSendStateView *msgSendStateView;
@property (nonatomic, strong, readonly) TTLiveMessageSendProgressView *loadingProgressView;
@property (nonatomic, assign, readonly, getter=isIncomingMsg) BOOL incomingMsg;
@property (nonatomic, strong, readonly) TTLiveMessage *message;

/// NOTE: must call `super`.
- (void)setupCellWithMessage:(TTLiveMessage *)message;

@end
