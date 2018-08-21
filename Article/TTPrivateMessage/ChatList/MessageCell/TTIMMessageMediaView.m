//
//  TTIMMessageMediaView.m
//  EyeU
//
//  Created by matrixzk on 10/20/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "TTIMMessageMediaView.h"

#import "TTIMMessage.h"
#import "TTIMCellHelper.h"
#import "UIImageView+WebCache.h"
#import "TTIMUtils.h"
#import "TTIMMessageSender.h"
#import <BDWebImage/SDWebImageAdapter.h>

#pragma mark -
#pragma mark - TTIMMessageImageMediaView

@interface TTIMMessageImageMediaView : UIView
@end

@interface TTIMMessageImageMediaView ()
@property (nonatomic, strong) SSThemedImageView *imageView;
@property (nonatomic, strong) TTIMMessage *message;
@end

@implementation TTIMMessageImageMediaView

- (void)dealloc {
    PLLOGD(@"");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [SSThemedImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}

- (void)setupMediaViewWithMessage:(TTIMMessage *)message
{
    _message = message;
    _imageView.image = nil;
    
    UIView *superMediaView = (UIView *)[self ss_nextResponderWithClass:[TTIMMessageMediaView class]];
        superMediaView.backgroundColor = nil;
    
    /**
     *  取图优先级:
     *  优先使用已生成的缩略图，其次是网络取图，最后是本地图片(包括相册选取和相机现拍及现拍的视频封面图)。
     *  网络取图的性能体验优于从本地相册中取图，且网络取图也有cache。
     */
    
    if (message.thumbImage) {
        _imageView.image = message.thumbImage;
        return;
    }

    // placeholder color
    superMediaView.backgroundColor = [UIColor colorWithHexString:[_message isSelf] ? @"#FFE7E1" : @"#F2F1F7"];
    
    void(^handleImage)(UIImage *image) = ^(UIImage *image) {
        if (!image) { return; }
        
        UIImage *thumbImage = image.images ? image : [TTIMCellHelper thumbImageFromSourceImage:image]; // GIF 显示原图
        message.thumbImage = thumbImage;
        // message.imageOriginSize = image.size;
        
        self.imageView.image = thumbImage;
        self.imageView.alpha = 0;
        [UIView animateWithDuration:.5f animations:^{
            self.imageView.alpha = 1;
            
            // 清除占位底色
            superMediaView.backgroundColor = [UIColor clearColor];
        }];
        
        // 用于发送失败的图片类型消息重发
        if ([message isSelf] &&
            (TTIMMessageSendStateFailed == message.sendState || TTIMMessageSendStatePrepared == message.sendState) &&
            (TTIMMessageTypeImage == message.messageType)) {
            message.tempLocalSelectedImage = image;
        }
    };
    
    if (message.imageServerURL.length > 0 /* && TTNetworkConnected() */) {
        WeakSelf;
        [_imageView sda_setImageWithURL:[NSURL URLWithString:message.imageServerURL] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            StrongSelf;
            if (!self ||
                ![self.message.imageServerURL isEqualToString:imageURL.absoluteString]) {
                return;
            }
            
            handleImage(image);
        }];
        
    } else if ([message isSelf]) { // 自己发送的消息
        
        if (message.assertIdentifier.length > 0) { // 相册选取的图片
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [TTIMUtils fetchImageWithIdentifier:message.assertIdentifier resultHandler:^(UIImage *image, NSString *identifier) {
                    if ([self.message.assertIdentifier isEqualToString:identifier]) {
                        image = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.5)];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            handleImage(image);
                        });
                    }
                }];
            });
        } else  if (message.localCameraImageURL.length > 0) { // 相机拍摄返回的图片
#if DEBUG
            NSRange range = [message.localCameraImageURL rangeOfString:@"tmp/"];
            NSString *subPath = [message.localCameraImageURL substringFromIndex:range.location + range.length];
            NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:subPath];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            handleImage(image);
#else
            UIImage *image = [UIImage imageWithContentsOfFile:message.localCameraImageURL];
            image = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.5)];
            handleImage(image);
#endif
        }
    }
}

@end


#pragma mark -
#pragma mark - TTIMMessageVideoMediaView

@interface TTIMMessageVideoMediaView : UIView
@property (nonatomic, strong, readonly) SSThemedImageView *playIcon;
@end

@interface TTIMMessageVideoMediaView ()

@property (nonatomic, strong) TTIMMessageImageMediaView *videoCoverImgView;
@property (nonatomic, strong) SSThemedImageView *playIcon;
@end

@implementation TTIMMessageVideoMediaView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _videoCoverImgView = [TTIMMessageImageMediaView new];
        [self addSubview:_videoCoverImgView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _videoCoverImgView.frame = self.bounds;
    self.playIcon.center = _videoCoverImgView.center;
}

- (void)setupMediaViewWithMessage:(TTIMMessage *)message
{
    [_videoCoverImgView setupMediaViewWithMessage:message];
}

- (SSThemedImageView *)playIcon
{
    if (!_playIcon) {
        _playIcon = [[SSThemedImageView alloc] initWithImage:[UIImage imageNamed:@"chat_video"]];
        [_videoCoverImgView addSubview:_playIcon];
    }
    return _playIcon;
}

@end

#pragma mark - 
#pragma mark - TTIMMessageMediaView

@interface TTIMMessageMediaView ()

@property (nonatomic, strong) TTIMMessageImageMediaView *imageMediaView;
@property (nonatomic, strong) TTIMMessageVideoMediaView *videoMediaView;
@property (nonatomic, strong) TTIMMessage *message;

//@property (nonatomic, strong) TTIMProgressView *progressView;

@property (nonatomic, strong) UIImageView *magicExpressionReplayIcon;
@end

@implementation TTIMMessageMediaView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMediaMessageUploadProgressChangedNotification:) name:kTTIMMediaMessageUploadProgressChangedNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    switch (_message.messageType) {
        case TTIMMessageTypeImage:
        {
            self.imageMediaView.frame = self.bounds;
        }
            break;
        default:
            break;
    }
    
//    if ([self shouldShowSendProgressViewWithMessage:self.message]) {
//        self.progressView.frame = self.bounds;
//        self.progressView.hidden = NO;
//    } else {
//        _progressView.hidden = YES;
//    }
}

- (void)setupMediaViewWithMessage:(TTIMMessage *)message
{
    _message = message;
    
//    _progressView.hidden = YES;
    
    switch (message.messageType) {
        case TTIMMessageTypeImage:
            _videoMediaView.hidden = YES;
            _imageMediaView.hidden = NO;
            _magicExpressionReplayIcon.hidden = YES;
            [self.imageMediaView setupMediaViewWithMessage:message];
            break;
        default:
            break;
    }
    
    
    if ([self shouldShowSendProgressViewWithMessage:message]) {
        _videoMediaView.playIcon.hidden = YES;
        [self refreshSendProgressViewWithProgress:message.sendProgress];
    }
    
    [self setNeedsLayout];
}

- (void)handleMediaMessageUploadProgressChangedNotification:(NSNotification *)notification
{
    TTIMMessage *message = notification.object;
    if (![message isKindOfClass:[TTIMMessage class]]) {
        return;
    }
    
    if (message.clientMsgId == _message.clientMsgId && message != _message) {
        _message.sendProgress = message.sendProgress;
    }
}

- (void)refreshSendProgressViewWithProgress:(CGFloat)newProgress
{
    if (newProgress >= 1.0 /*|| _message.sendState == TTIMMessageSendStateFailed*/) {
//        _progressView.hidden = YES;
        _videoMediaView.playIcon.hidden = NO;
        return;
    }
//    else {
//        self.progressView.hidden = NO;
//        _videoMediaView.playIcon.hidden = YES;
//    }
    
    // NSLog(@">>>>> progress mediaView : %@", @(newProgress));
//    self.progressView.progress = newProgress;
}

- (BOOL)shouldShowSendProgressViewWithMessage:(TTIMMessage *)message
{
    BOOL show = NO;
    switch (message.messageType) {
        case TTIMMessageTypeImage:
            show = YES;
            break;
        default:
            show = NO;
            break;
    }
    return show && [message isSelf] &&
           // 上传速度快于cell UI渲染时需要这个条件，比如重发时列表滑动很长才能滑动到底部的情况
           (message.sendProgress < 1) &&
           (message.sendState == TTIMMessageSendStatePrepared);
}

#pragma mark - getter

- (TTIMMessageImageMediaView *)imageMediaView
{
    if (!_imageMediaView) {
        _imageMediaView = [TTIMMessageImageMediaView new];
        [self addSubview:_imageMediaView];
//        [self bringSubviewToFront:_progressView];
    }
    return _imageMediaView;
}

- (TTIMMessageVideoMediaView *)videoMediaView
{
    if (!_videoMediaView) {
        _videoMediaView = [TTIMMessageVideoMediaView new];
        [self addSubview:_videoMediaView];
//        [self bringSubviewToFront:_progressView];
    }
    return _videoMediaView;
}

//- (TTIMProgressView *)progressView
//{
//    if (!_progressView) {
//        _progressView = [[TTIMProgressView alloc] initWithFrame:CGRectZero circleRadius:25];
//        [self addSubview:_progressView];
//        [self bringSubviewToFront:_progressView];
//    }
//    return _progressView;
//}

@end
