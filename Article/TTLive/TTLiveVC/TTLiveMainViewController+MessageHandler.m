//
//  TTLiveMainViewController+MessageHandler.m
//  Article
//
//  Created by matrixzk on 8/1/16.
//
//

#import "TTLiveMainViewController+MessageHandler.h"

#import "TTLiveMessage.h"
#import "TTLiveCellHelper.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "amrFileCodec.h"

#import <TTAccountBusiness.h>
#import "ALAssetsLibrary+TTImagePicker.h"
#import "TTNavigationController.h"

#import "SSWebViewController.h"
#import "TTPhotoScrollViewController.h"

#import "TTLiveChatTableViewController.h"

#import "TTLiveAudioManager.h"
#import "TTLivePariseView.h"
#import "TTUGCImageCompressHelper.h"
#import "TTLiveTabCategoryItem.h"
#import "TTSwipePageViewController.h"
#import "UIScrollView+Refresh.h"
#import "TTRoute.h"



@implementation TTLiveMainViewController (MessageHandler)

- (TTLiveChatTableViewController *)currentChatViewController
{
    UIViewController *currentChannelVC = [self currentChannelVC];
    if ([currentChannelVC isKindOfClass:[TTLiveChatTableViewController class]]) {
        return (TTLiveChatTableViewController *)currentChannelVC;
    }
    return nil;
}

- (void)uploadMessage:(TTLiveMessage *)message
{
    //    if (message.sender == nil) {
    //        TTLiveMessageSender *sender = [[TTLiveMessageSender alloc] init];
    //        sender.chatroomInfo = self.overallModel;
    //        sender.message = message;
    //        message.sender = sender;
    //        if (!self.msgSenderArray) {
    //            self.msgSenderArray = [NSMutableArray new];
    //        }
    //        [self.msgSenderArray addObject:sender];
    //    }
    //    [message.sender uploadMediaSourceWidthMessage:message];
    
    TTLiveMessageSender *msgSender = [TTLiveMessageSender new];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:3];
    [params setValue:self.overallModel.liveId forKey:@"value"];
    [params setValue:self.overallModel.referFrom forKey:@"refer"];
    [params setValue:self.overallModel.liveStateNum forKey:@"stat"];
    msgSender.eventTrackParams = params;
    [msgSender sendMessage:message];
}

- (void)addMessage:(TTLiveMessage *)message toArray:(NSMutableArray *)imgArray
{
    if (message.imageModel) {
        [imgArray addObject:message.imageModel];
    } else if (message.localSelectedImageURL) {
        [imgArray addObject:message.localSelectedImageURL];
    } else {
        [imgArray addObject:message.thumbImage];
    }
}

#pragma mark - TTLiveMessageHandleDelegate Methods

- (void)tt_clickPariseByUserWithCommonImage:(NSString *)commonImage {
    if ([self.infiniteIconUrlList count] > 0) {
        NSUInteger index = arc4random() % [self.infiniteIconUrlList count];
        [self.pariseView userPariseWithUserImage:self.overallModel.userAvatarUrl commonImage:[self.infiniteIconUrlList objectAtIndex:index]];
        self.pariseCount = self.pariseCount + 1;
        self.userDigCount++;
        
        [self eventTrackWithEvent:@"live"
                            label:@"zan_click"
                        channelId:[(TTLiveTabCategoryItem *)self.overallModel.channelItems[self.topTabView.selectedIndex] categoryId]];
    }
}

- (void)ttLiveHandleMessageImageTappedAction:(TTLiveMessage *)message convertedImageFrame:(CGRect)convertedFrame targetView:(UIView *)targetView;
{
    TTLiveChatTableViewController *currentChatVC = [self currentChatViewController];
    if (!currentChatVC) {
        return;
    }
    
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    __block NSUInteger startIndex = 0;
    [currentChatVC.messageArray enumerateObjectsUsingBlock:^(TTLiveMessage * _Nonnull msg, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (msg.msgType == TTLiveMessageTypeImage && msg.thumbImage && isEmptyString(msg.link)) {
            [self addMessage:msg toArray:imageArray];
            if (msg == message) {
                startIndex = imageArray.count - 1;
            }
        }
        
        if (msg.replyedMessage.msgType == TTLiveMessageTypeImage && msg.replyedMessage.thumbImage && isEmptyString(msg.replyedMessage.link)) {
            [self addMessage:msg.replyedMessage toArray:imageArray];
            if (msg.replyedMessage == message) {
                startIndex = imageArray.count - 1;
            }
        }
    }];
    
    //统计
    NSString *tabName = [self channelItemWithChannelId:currentChatVC.channelItem.categoryId.integerValue].title;
    NSMutableDictionary *trackerDic = [[NSMutableDictionary alloc] init];
    [trackerDic setValue:self.overallModel.liveId forKey:@"value"];
    [trackerDic setValue:self.overallModel.liveStateNum forKey:@"stat"];
    [trackerDic setValue:self.overallModel.referFrom forKey:@"refer"];
    [trackerDic setValue:tabName forKey:@"tab"];
    
    TTPhotoScrollViewController *showImageViewController = [[TTPhotoScrollViewController alloc] initWithTrackDictionary:trackerDic];
    showImageViewController.targetView = self.currentChannelVC.view;
    showImageViewController.finishBackView = self.currentChannelVC.view;
    showImageViewController.umengEventName = @"livecell";
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

- (void)ttLiveHandleMessageADLinkTappedAction:(TTLiveMessage *)message
{
    NSURL *openURL = [NSURL URLWithString:message.link];
    if ([message.link hasPrefix:@"http"]) {
        [SSWebViewController openWebViewForNSURL:openURL title:@"网页浏览" navigationController:self.navigationController supportRotate:NO];
    } else {
        [[TTRoute sharedRoute] openURLByPushViewController:openURL];
    }
    
    // event track
    [self eventTrackWithEvent:@"livecell" label:@"link_click"];
}

- (void)ttLiveHandleMessageReplyedAction:(TTLiveMessage *)message
{
    // 回复逻辑
    // 0. 只有leader角色回复时能发送所有类型信息，用户回复只有文字；1. 自己的消息只能用文字回复；2. 多媒体类型消息(图片、视频和语音)，只能用文字回复
    
    TTLiveMessageBoxType msgBoxType = TTLiveMessageBoxTypeSupportTextOnly;
    
    if ([self roleOfCurrentUserIsLeader] && // leader角色
        ![message.userId isEqualToString:[TTAccountManager userID]] && // 非回复自己
        (TTLiveMessageTypeImage != message.msgType && TTLiveMessageTypeVideo != message.msgType && TTLiveMessageTypeAudio != message.msgType) // 非回复多媒体类型消息
        ) {
        msgBoxType = TTLiveMessageBoxTypeSupportAll;
    }
    
    if (message.isTop) {
         NSString *topTagText = @"\U0000E613\n\n";
        message.msgText = [message.msgText stringByReplacingOccurrencesOfString:topTagText withString:@""];
    }
    
    [self.messageBoxView activedWithType:msgBoxType replyedMessage:message];
    
    // event track
    TTLiveChatTableViewController *currentChatVC = [self currentChatViewController];
    if (currentChatVC) {
        [self eventTrackWithEvent:@"livecell" label:@"long_click_reply" channelId:currentChatVC.channelItem.categoryId];
        //        [[TTLiveManager sharedManager] trackerliveCell:currentChatVC.channelItem.categoryId label:@"long_click_reply"];
    }
}

- (void)ttLiveHandleMessageSharedAction:(TTLiveMessage *)message
{
    //    [[TTLiveManager sharedManager] makeShare];
    [self makeShare];
    
    // event track
    TTLiveChatTableViewController *currentChatVC = [self currentChatViewController];
    if (currentChatVC) {
        [self eventTrackWithEvent:@"livecell" label:@"long_click_share" channelId:currentChatVC.channelItem.categoryId];
        //        [[TTLiveManager sharedManager] trackerliveCell:currentChatVC.channelItem.categoryId label:@"long_click_share"];
    }
}

- (void)ttLiveMessageActionBubbleDidDisplayed:(TTLiveMessage *)message
{
    TTLiveChatTableViewController *currentChatVC = [self currentChatViewController];
    if (currentChatVC) {
        [self eventTrackWithEvent:@"livecell" label:@"long_click" channelId:currentChatVC.channelItem.categoryId];
        //        [[TTLiveManager sharedManager] trackerliveCell:currentChatVC.channelItem.categoryId label:@"long_click"];
    }
}

- (void)ttLiveMessageSendingDidCanceled:(TTLiveMessage *)message
{
    // event track
    if ([TTLiveCellHelper supportCellBottomLoadingProgressViewWithMessage:message]) {
        NSString *label = @"";
        switch (message.msgType) {
            case TTLiveMessageTypeImage:
                label = @"photo_sent_cancel";
                break;
                
            case TTLiveMessageTypeVideo:
                label = @"video_sent_cancel";
                break;
                
            default:
                break;
        }
        [self eventTrackWithEvent:@"liveshot" label:label];
        //        [[TTLiveManager sharedManager] trackerEvent:@"liveshot" label:label tab:nil extValue:nil];
    }
}

- (void)ttLiveHandleMessageResendAction:(TTLiveMessage *)message
{
    [self uploadMessage:message];
    
    // event track
    NSString *event;
    NSString *label = @"";
    switch (message.msgType) {
        case TTLiveMessageTypeText:
            event = @"livetext";
            label = @"write_again";
            break;
            
        case TTLiveMessageTypeVideo:
            event = @"liveshot";
            label = @"video_sent_again";
            break;
            
        case TTLiveMessageTypeImage:
            event = @"liveshot";
            label = @"photo_sent_again";
            break;
            
        case TTLiveMessageTypeAudio:
            event = @"liveaudio";
            label = @"audio_sent_again";
            break;
            
        default:
            break;
    }
    
    [self eventTrackWithEvent:event label:label];
    //    [[TTLiveManager sharedManager] trackerEvent:event label:label tab:nil extValue:nil];
}

- (void)ttLiveHandleMessageAvatarTappedAction:(TTLiveMessage *)message
{
    NSURL *openURL = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://profile?uid=%@", message.userId]];
    [[TTRoute sharedRoute] openURLByPushViewController:openURL];
    
    // event track
    [self eventTrackWithEvent:@"live" label:@"cell_head"];
    //    [[TTLiveManager sharedManager] trackerEvent:@"live" label:@"cell_head" tab:nil extValue:nil];
}

#pragma mark - TTLiveMessageBoxDelegate Methods


- (void)ttLiveMediaMessageEditPrepared:(TTLiveMessageBox *)messageBox
{
    //录制的时候播放停止
    [TTLiveAudioManager stopCurrentPlayingAudioIfNeeded];
    //    [self stopLiveVideoIfNeeded];
    [self pauseLiveVideoIfNeeded];
}

- (void)ttLiveMediaMessageEditDidFinished:(TTLiveMessageBox *)messageBox
{
    // 尝试续播视频
    [self startLiveVideoIfNeeded];
}

- (void)ttMessageAlbumPhotoLibraryBack:(NSMutableArray *)assetsArray
{
    if (assetsArray.count <= 0) {
        return;
    }
    
    //无论照片视频，单次只发一个，数组循环即可
    NSMutableArray *messageArray = [NSMutableArray arrayWithCapacity:assetsArray.count];
    
    [assetsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TTLiveMessage *message = [[TTLiveMessage alloc] init];
        message.networkState = TTLiveMessageNetworkStatePrepared;
        
        if ([obj isKindOfClass:[NSURL class]]) {
            
            message.msgType = TTLiveMessageTypeVideo;
            message.localSelectedVideoURL = obj;
            
            UIImage *coverImageOfVideo = [UIImage imageWithData:UIImageJPEGRepresentation([self getImageFromVideoUrl:obj], 0.5)];
            message.thumbImage = [TTLiveCellHelper thumbImageWithSourceImage:coverImageOfVideo cellLayout:0];
            message.sizeOfOriginImage = coverImageOfVideo.size;
            [self formatSizeAndDurationOfVideo:nil fileUrl:obj message:message];
            
        } else if ([obj isKindOfClass:[ALAsset class]]) {
            
            message.msgType = TTLiveMessageTypeImage;
            
            ALAsset *asset = (ALAsset *)obj;
            UIImage *image = [TTUGCImageCompressHelper compressImage:[ALAssetsLibrary tt_fullResolutionImageFromAsset:asset] size:5*1024*1024 limitWidth:0 limitHeight:0];
            message.thumbImage = [TTLiveCellHelper thumbImageWithSourceImage:image cellLayout:0];
            message.tempLocalSelectedImage = image;
            message.sizeOfOriginImage = image.size;
            message.localSelectedImageURL = asset.defaultRepresentation.url;
        }else if ([obj isKindOfClass:[PHAsset class]]){
            
            message.msgType = TTLiveMessageTypeImage;
            PHAsset *asset = (PHAsset *)obj;
            UIImage *image = [self getImageFromPHAsset:asset];
            message.thumbImage = [TTLiveCellHelper thumbImageWithSourceImage:image cellLayout:0];
            message.tempLocalSelectedImage = image;
            message.sizeOfOriginImage = image.size;
        }
        
        // 回复时选多张图片时，只第一张图片显示成回复cell的样式，其余算单独发送。
        if (idx == 0) {
            message.replyedMessage = self.messageBoxView.replyedMsg;
        }
        [self addUserInfoToMessage:message];
        [messageArray addObject:message];
        
        //发起资源上传的网络请求
        [self uploadMessage:message];
        
    }];
    
    [self showMessageOnSuitableChannel:messageArray];
}

- (void)ttMessageCameraPhotoBackAssetUrl:(NSURL *)url image:(UIImage *)photoImage
{
    if (!photoImage) {
        return;
    }
    
    TTLiveMessage *message = [[TTLiveMessage alloc] init];
    message.msgType = TTLiveMessageTypeImage;
    message.networkState = TTLiveMessageNetworkStatePrepared;
    
    UIImage *image = [UIImage imageWithData:UIImageJPEGRepresentation(photoImage, 0.5)];
    message.thumbImage = [TTLiveCellHelper thumbImageWithSourceImage:image cellLayout:0];
    message.tempLocalSelectedImage = image;
    message.sizeOfOriginImage = image.size;
    message.localSelectedImageURL = url;
    
    [self sendMessage:message];
}

- (void)ttMessageCameraVideoBack:(NSURL *)videoUrl previewImage:(UIImage *)previewImage
{
    if (!videoUrl) {
        return;
    }
    
    TTLiveMessage *message = [TTLiveMessage new];
    message.msgType = TTLiveMessageTypeVideo;
    message.networkState = TTLiveMessageNetworkStatePrepared;
    message.localSelectedVideoURL = videoUrl;
    UIImage *image = previewImage ? [UIImage imageWithData:UIImageJPEGRepresentation(previewImage, 0.5)]
    : [UIImage imageWithData:UIImageJPEGRepresentation([self getImageFromVideoUrl:videoUrl], 0.5)];
    message.thumbImage = [TTLiveCellHelper thumbImageWithSourceImage:image cellLayout:0];
    message.sizeOfOriginImage = image.size;
    [self formatSizeAndDurationOfVideo:nil fileUrl:videoUrl message:message];
    
    [self sendMessage:message];
}

- (void)ttMessageAudioRecordFinishedWithURL:(NSURL *)audioUrl duration:(CGFloat)duration
{
    if (isEmptyString(audioUrl.absoluteString)) {
        return;
    }
    //生成arm文件
    NSString *amrFilePath = [[audioUrl.path stringByDeletingPathExtension] stringByAppendingPathExtension:@"amr"];
    NSData *amrData = EncodeWAVEToAMR([NSData dataWithContentsOfURL:audioUrl], 1, 16);
    [amrData writeToFile:amrFilePath atomically:YES];
    
    //生成消息
    TTLiveMessage *message = [[TTLiveMessage alloc] init];
    message.msgType = TTLiveMessageTypeAudio;
    message.networkState = TTLiveMessageNetworkStatePrepared;
    // test
    // message.mediaFileDuration = [NSString stringWithFormat:@"%@", @(ceil([[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil].duration))];
    
    message.mediaFileDuration = [NSString stringWithFormat:@"%@", @(duration)];
    
    message.localWavAudioURL = audioUrl;
    message.localAmrAudioURL = [NSURL fileURLWithPath:amrFilePath];
    
    [self sendMessage:message];
}

- (void)ttMessageBox:(TTLiveMessageBox *)messageBox textBack:(NSString *)text
{
    if (isEmptyString(text)) {
        return;
    }
    
    WeakSelf;
    if (![TTAccountManager isLogin]) {
        
        [self.messageBoxView becomeToShortestAtBottom:NO];
        
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypePost source:@"live_message" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
            StrongSelf;
            if (type == TTAccountAlertCompletionEventTypeDone) {
                if ([TTAccountManager isLogin]) {
                    [self loginWithStatus:YES text:text];
                }
            } else if (type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromVC:self type:TTAccountLoginDialogTitleTypeDefault source:@"live_message" completion:^(TTAccountLoginState state) {

                }];
            } else if (type == TTAccountAlertCompletionEventTypeCancel) {
                [self loginWithStatus:NO text:text];
            }
        }];
        
        return;
    }
    
    TTLiveMessage *message = [[TTLiveMessage alloc] init];
    message.msgType = TTLiveMessageTypeText;
    message.msgText = text;
    message.networkState = TTLiveMessageNetworkStatePrepared;
    
    [self sendMessage:message];
    [self.messageBoxView clearDataBySendSuccess];
}

- (void)loginWithStatus:(BOOL)status text:(NSString *)text {
    if (status) {
        TTLiveMessage *replyedMsg = self.messageBoxView.replyedMsg;
        TTLiveMessage *message = [[TTLiveMessage alloc] init];
        message.msgType = TTLiveMessageTypeText;
        message.msgText = text;
        message.networkState = TTLiveMessageNetworkStatePrepared;
        message.replyedMessage = replyedMsg;
        [self sendMessage:message];
        
        //输入框根据身份变身
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self roleOfCurrentUserIsLeader]) {
                
                // [self resetEdgeInsetsOfContentScrollView];
                [self.fakeNavigationBar refreshRightButton];
                [self.droppedNavigationBar refreshRightButton];
                [self.messageBoxView setMessageViewType:TTLiveMessageBoxTypeSupportAll];
                for (UIResponder *page in self.swipePageVC.pages) {
                    if ([page isKindOfClass:[TTLiveChatTableViewController class]]) {
                        UITableView *tableView = ((TTLiveChatTableViewController *)page).tableView;
                        tableView.originContentInset = tableView.contentInset = [self edgeInsetsOfContentScrollView];
                    }
                }
                [self.view bringSubviewToFront:self.messageBoxView];
            }
            [self.messageBoxView clearDataBySendSuccess];
        });
    } else {
        [self.messageBoxView textFieldButtonClick:nil];
    }
}

//- (void)ttMessageBox:(TTLiveMessageBox *)messageBox textBeginEditing:(UITextView *)textView
//{
//}
//- (void)ttMessageBox:(TTLiveMessageBox *)messageBox textEditDidChange:(UITextView *)textView
//{
//}
//- (void)ttMessageBox:(TTLiveMessageBox *)messageBox textEndEditing:(UITextView *)textView
//{
//    if ([textView.text isEqualToString:@""]) {
//        [messageBox setInputBarSpeakerAvatar:[UIImage imageNamed:@"chatroom_write_black"]];
//    }
//}

#pragma mark - Helper

- (void)sendMessage:(TTLiveMessage *)message
{
    if (self.messageBoxView.replyedMsg) {
        message.replyedMessage = self.messageBoxView.replyedMsg;
    }
    
    [self addUserInfoToMessage:message];
    [self showMessageOnSuitableChannel:@[message]];
    
    [self uploadMessage:message];
}

- (void)addUserInfoToMessage:(TTLiveMessage *)message
{
    message.userDisplayName = [TTAccountManager userName];
    message.userAvatarURLStr = [TTAccountManager avatarURLString];
    message.userId = [TTAccountManager userID];
    message.sendTime = [self.dataSourceManager formattedTimeWithDate:[NSDate date]];
    message.userRoleName = message.userRoleName ? : [self leaderRoleNameWithUserID:message.userId];
    message.userVip = @([TTAccountManager isVerifiedOfUserVerifyInfo:[TTAccountManager userAuthInfo]]);
}


// helper
- (void)formatSizeAndDurationOfVideo:(id)videoAssetObj fileUrl:(NSURL *)videoUrl message:(TTLiveMessage *)message
{
    //相册资源
    if ([videoAssetObj isKindOfClass:[ALAsset class]]) {
        ALAsset *video = (ALAsset *)videoAssetObj;
        message.mediaFileSize = [TTLiveCellHelper formattedSizeWithVideoFileSize:[video defaultRepresentation].size];
        message.mediaFileDuration = [[video valueForProperty:ALAssetPropertyDuration] stringValue];
    }
    
    //文件资源
    else if (videoAssetObj == nil){
        if (videoUrl) {
            AVAsset *video = [AVAsset assetWithURL:videoUrl];
            message.mediaFileDuration = [NSString stringWithFormat:@"%d",(int)ceilf(CMTimeGetSeconds(video.duration))];
            CGFloat videoOriginSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:videoUrl.path error:nil] fileSize];
            message.mediaFileSize = [TTLiveCellHelper formattedSizeWithVideoFileSize:videoOriginSize];
        }
    }
}

//视频文件预览图
- (UIImage *)getImageFromVideoUrl:(NSURL *)url
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(0, 10000) actualTime:NULL error:&error];
    UIImage *image = [UIImage imageWithCGImage:img];
    return image;
    
}

- (UIImage *)getImageFromPHAsset:(PHAsset *)asset
{
    __block UIImage *tImage;
    if (asset.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                          options:options
                                                    resultHandler:
         ^(NSData *imageData,
           NSString *dataUTI,
           UIImageOrientation orientation,
           NSDictionary *info) {
             tImage = [UIImage imageWithData:imageData];
         }];
    }
    
    CGFloat longEdge = [TTUIResponderHelper screenSize].height;
    CGFloat ratio = longEdge / MAX(tImage.size.height, tImage.size.width);
    CGSize newSize = CGSizeMake(tImage.size.width * ratio * [UIScreen mainScreen].scale, tImage.size.height * ratio * [UIScreen mainScreen].scale);
    UIImage *image = [tImage resizedImage:newSize interpolationQuality:kCGInterpolationDefault];
    
    return image;
}

@end
