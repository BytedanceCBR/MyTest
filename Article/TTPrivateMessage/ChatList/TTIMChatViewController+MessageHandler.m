//
//  TTIMChatViewController+MessageHandler.m
//  EyeU
//
//  Created by matrixzk on 10/31/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "TTIMChatViewController+MessageHandler.h"

#import "TTIMMessage.h"
#import "TTIMCellHelper.h"
#import "TTIMMessageSender.h"
#import "TTPhotoScrollViewController.h"
#import "NetworkUtilities.h"
#import "TTThemedAlertController.h"
#import "TTPLManager.h"
#import "TTRoute.h"
#import <TTInteractExitHelper.h>

@implementation TTIMChatViewController (MessageHandler)

- (void)sendMessages:(NSArray<TTIMMessage *> *)messages
{
    if (self.sessionId.length == 0) {
        PLLOGD(@">>> ttim : toUserId is NULL !");
        return;
    }
    
    [messages enumerateObjectsUsingBlock:^(TTIMMessage * _Nonnull msg, NSUInteger idx, BOOL * _Nonnull stop) {
        [TTIMMessageSender sendMessage:msg toUsers:@[self.sessionId]];
    }];
}

#pragma mark - TTIMMessageCellEventDelegate Methods

- (void)ttimMessageCellImageDidTapped:(TTIMMessage *)message convertedFrame:(CGRect)convertedFrame
{
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    __block NSUInteger startIndex = 0;
    
    [[self messages] enumerateObjectsUsingBlock:^(TTIMMessage * _Nonnull msg, NSUInteger idx, BOOL * _Nonnull stop) {
        if (msg.msgType == TTIMMessageTypeImage && msg.thumbImage) {
            
            if (msg.tempLocalSelectedImage) {
                [imageArray addObject:msg.tempLocalSelectedImage];
            } else if (msg.imageServerURL) {
                [imageArray addObject:msg.imageServerURL];
            } else {
                [imageArray addObject:msg.thumbImage];
            }
            
            if (msg == message) {
                startIndex = imageArray.count - 1;
            }
        }
    }];
    
    if (imageArray.count == 0) {
        return;
    }
    
    TTPhotoScrollViewController *showImageViewController = [TTPhotoScrollViewController new];
    showImageViewController.targetView = self.view;
    showImageViewController.finishBackView = [TTInteractExitHelper getSuitableFinishBackViewWithCurrentContext];
    showImageViewController.multipleTypeImages = imageArray;
    [showImageViewController setStartWithIndex:startIndex];
    
    NSMutableArray *picFrameArray = [[NSMutableArray alloc] initWithCapacity:startIndex + 1];
    for (NSUInteger i = 0; i < startIndex; i++) {
        [picFrameArray addObject:NSNull.null];
    }
    [picFrameArray addObject:[NSValue valueWithCGRect:convertedFrame]];
    showImageViewController.placeholderSourceViewFrames = picFrameArray;
    
    [showImageViewController presentPhotoScrollView];
}

- (void)ttimMessageCellHandleResendEvent:(TTIMMessage *)message
{
    if (self.sessionId.length == 0) {
        PLLOGD(@">>> ttim : toUserId is NULL !");
        return;
    }
    
    // 先删除旧消息
    [self deleteMessage:message];
    
    // copy msg, 重置一些状态
    TTIMMessage *newMessage = [message copy];
    newMessage.clientMsgId = 0;
    newMessage.isShow = IMMsgNotDelete;
    newMessage.formattedSendDate = nil;
    
    [TTIMMessageSender sendMessage:newMessage toUsers:@[self.sessionId]];
}

- (void)ttimMessageCellAvatarDidTapped:(TTIMMessage *)message
{
    NSString *url = [NSString stringWithFormat:@"sslocal://profile?uid=%lld", message.fromUser];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:url]];
    wrapperTrackEventWithCustomKeys(@"private_letter", @"dialog", nil, nil, @{@"dialog" : @"user_picture"});
}

- (void)ttimMessageCellTapped {
    [self dismissMessageInputView];
}

#pragma mark - TTIMMessageInputViewDelegate Methods

- (void)ttimMessageInputViewTextDidSend:(NSString *)text
{
    [[TTPLManager sharedManager] setNeedShowTip:YES];
    TTIMMessage *msg = [TTIMMessage new];
    msg.messageType = TTIMMessageTypeText;
    msg.msgText = text;
    
    [msg generateMessageContent];
    
    [self sendMessages:@[msg]];
}

//- (void)ttimMessageInputViewAlbumPhotosDidPicked:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isOriginPhoto
//{
//    NSMutableArray *msgArray = [NSMutableArray arrayWithCapacity:photos.count];
//    [photos enumerateObjectsUsingBlock:^(UIImage * _Nonnull image, NSUInteger idx, BOOL * _Nonnull stop) {
//        
//        /*
//        if (!isOriginPhoto) {
//            image = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.5)];
//        }
//         */
//        
//        image = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.5)];
//        TTIMMessage *msg = [TTIMMessage new];
//        msg.tempLocalSelectedImage = image;
//        msg.messageType = TTIMMessageTypeImage;
//        msg.imageOriginSize = CGSizeMake(image.size.width, image.size.height);
//        msg.thumbImage = [TTIMCellHelper thumbImageFromSourceImage:image];
//        msg.uploadOriginalPhoto = isOriginPhoto;
//        
//        msg.assert = (idx < assets.count) ? assets[idx] : nil;
//        
//        [msg generateMessageExtraInfo];
//        
//        // 在拿到图片serverURL时生成。
//        // [msg generateMessageContent];
//        
//        [msgArray addObject:msg];
//    }];
//    
//    [self sendMessages:msgArray];
//}

//- (void)ttimMessageInputViewCameraDidBackWithURL:(NSURL *)pathURL isVideo:(BOOL)isVideo previewImage:(UIImage *)previewImage
//{
//    if (!pathURL) { return; }
//    
//    TTIMMessage *msg = [TTIMMessage new];
//    if (isVideo) { // video
//        msg.messageType = TTIMMessageTypeVideo;
//        msg.localVideoPath = pathURL.absoluteString;
//    } else { // photo
//        msg.messageType = TTIMMessageTypeImage;
//        msg.localCameraImageURL = pathURL.absoluteString;
//        // if (!previewImage) { return; }
//    }
//    previewImage = [UIImage imageWithData:UIImageJPEGRepresentation(previewImage, 0.5)];
//    msg.tempLocalSelectedImage = previewImage;
//    msg.imageOriginSize = CGSizeMake(previewImage.size.width, previewImage.size.height);
//    msg.thumbImage = [TTIMCellHelper thumbImageFromSourceImage:previewImage];
//    
//    [msg generateMessageExtraInfo];
//    
//    [self sendMessages:@[msg]];
//}

/*
- (void)ttimMessageInputViewTextDidBeginEditing:(UITextView *)textView
{
}

- (void)ttimMessageInputViewTextDidChange:(UITextView *)textView
{
}
 */

@end
