//
//  AKShareManager.m
//  Article
//
//  Created by 冯靖君 on 2018/3/7.
//

#import "AKShareManager.h"
#import <TTIndicatorView.h>
#import <SDWebImageManager.h>
#import "AKHelper.h"

@interface AKQRShareView : UIView

@property (nonatomic, strong)UIImageView *qrImageView;
@property (nonatomic, strong)UIImageView *backgroundImageview;

+ (UIImage *)shareImageWithOriImage:(UIImage *)oriImage
                            qrImage:(UIImage *)qrImage
                              qrURL:(NSString *)qrURL;

@end

@implementation AKQRShareView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.backgroundImageview];
        [self.backgroundImageview addSubview:self.qrImageView];
    }
    return self;
}

- (instancetype)initWithOriImage:(UIImage *)oriImage
                         qrImage:(UIImage *)qrImage
                           qrURL:(NSString *)qrURL
{
    self = [self init];
    if (self) {
        self.backgroundImageview.image = oriImage;
        self.qrImageView.image = qrImage ?: [self.class _QRImageWithURL:qrURL];
        self.qrImageView.hidden = NO;
        [self refreshUI];
    }
    return self;
}

- (void)refreshUI
{
    if (self.backgroundImageview.image) {
        CGSize qrImageViewSize = CGSizeMake(220, 220);
        CGPoint qrImageViewCenter = CGPointMake(375, 1040);

        self.backgroundImageview.hidden = NO;
        self.backgroundImageview.frame = CGRectMake(0, 0, 750, 1334);
        self.qrImageView.frame = CGRectMake(0, 0, qrImageViewSize.width, qrImageViewSize.height);
        self.qrImageView.center = qrImageViewCenter;
    } else {
        self.backgroundImageview.hidden = YES;
    }
}

#pragma mark - private

+ (UIImage *)_QRImageWithURL:(NSString *)url
{
    if (isEmptyString(url)) {
        return nil;
    }
    
    // 实例化二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 恢复滤镜的默认属性
    [filter setDefaults];
    // 将字符串转换成NSData
    NSData *data = [url dataUsingEncoding:NSUTF8StringEncoding];
    // 通过KVO设置滤镜, 传入data, 将来滤镜就知道要通过传入的数据生成二维码
    [filter setValue:data forKey:@"inputMessage"];
    // 设置二维码 filter 容错等级
    [filter setValue:@"Q" forKey:@"inputCorrectionLevel"];
    // 生成二维码
    CIImage *outputImage = [filter outputImage];
    UIImage *image = [self _createNonInterpolatedUIImageFormCIImage:outputImage withSize:220.f];
    return image;
}

+ (UIImage *)_createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

+ (UIImage *)shareImageWithOriImage:(UIImage *)oriImage
                            qrImage:(UIImage *)qrImage
                              qrURL:(NSString *)qrURL
{
    AKQRShareView *view = [[AKQRShareView alloc] initWithOriImage:oriImage
                                                          qrImage:qrImage
                                                            qrURL:qrURL];
    UIImageView *shareView = view.backgroundImageview;
    UIGraphicsBeginImageContextWithOptions(shareView.frame.size, NO, 1);
    
    [shareView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRef imageRef = newImage.CGImage;
    CGRect rect = CGRectMake(0, 0, shareView.bounds.size.width , shareView.bounds.size.height);
    CGImageRef imageRefRect = CGImageCreateWithImageInRect(imageRef, rect);
    newImage = [[UIImage alloc] initWithCGImage:imageRefRect];
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImageView *)backgroundImageview
{
    if (_backgroundImageview == nil) {
        _backgroundImageview = [[UIImageView alloc] init];
        _backgroundImageview.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _backgroundImageview;
}

- (UIImageView *)qrImageView
{
    if (_qrImageView == nil) {
        _qrImageView = [[UIImageView alloc] init];
        _qrImageView.contentMode = UIViewContentModeScaleAspectFit;
        _qrImageView.hidden = YES;
    }
    return _qrImageView;
}

@end

@implementation AKQRShareHelper

+ (void)genQRImageWithOriImage:(UIImage *)oriImage
                   oriImageURL:(NSString *)oriImageURL
                       qrImage:(UIImage *)qrImage
              qrImageShortLink:(NSString *)qrImageShortLinkURL
               completionBlock:(AKQRShareImageCompletionBlock)completion
{
    void (^genImage)(UIImage *, UIImage *) = ^(UIImage * _Nonnull oriImage, UIImage * _Nullable qrImage) {
        if (nil == qrImage) {
            if (completion) {
                completion(oriImage);
            }
        } else {
            UIImage *genImage = [AKQRShareView shareImageWithOriImage:oriImage qrImage:qrImage qrURL:nil];
            if (genImage && completion) {
                completion(genImage);
            }
        }
    };
    
    void (^genQRImage)(UIImage *, NSString *) = ^( UIImage * _Nonnull oriImage, NSString * _Nonnull url) {
        UIImage *genImage = [AKQRShareView shareImageWithOriImage:oriImage qrImage:nil qrURL:url];
        if (genImage && completion) {
            completion(genImage);
        }
    };
    
    if (oriImage) {
        if (qrImage) {
            genImage(oriImage, qrImage);
        } else if (!isEmptyString(qrImageShortLinkURL)) {
            // 生成二维码图片
            genQRImage(oriImage, qrImageShortLinkURL);
        }
    } else {
        // 下载原分享图
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:oriImageURL] options:SDWebImageHighPriority | SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image && !error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (qrImage) {
                        genImage(image, qrImage);
                    } else if (!isEmptyString(qrImageShortLinkURL)) {
                        genQRImage(image, qrImageShortLinkURL);
                    } else {
                        // 异常情况，直接返回原图
                        genImage(image, nil);
                    }
                });
            } else {
                // do nothing
            }
        }];
    }
}

@end

@interface AKShareManager () <MFMessageComposeViewControllerDelegate>

@property (nonatomic, assign) AKSharePlatform sharePlatform;
@property (nonatomic, strong) NSDictionary *extra;
@property (nonatomic, copy) AKShareCompletionBlock completion;
@property (nonatomic, copy) AKSendSMSCompletion smsCompletion;

@end

@implementation AKShareManager

static AKShareManager *_instance = nil;

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[AKShareManager alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

#pragma mark - public

- (void)shareToPlatform:(AKSharePlatform)platform
            contentType:(AKShareContentType)contentType
                   text:(NSString *)text
                  title:(NSString *)title
            description:(NSString *)description
             webPageURL:(NSString *)webPageURLString
             thumbImage:(UIImage *)thumbImage
          thumbImageURL:(NSString *)thumbImageURL
                  image:(UIImage *)image
               videoURL:(NSString *)videoURLString
                  extra:(NSDictionary *)extra
        completionBlock:(AKShareCompletionBlock)completion
{
    self.sharePlatform = platform;
    self.completion = completion;
    
    TTWeChatShare *wxShare = [TTWeChatShare sharedWeChatShare];
    wxShare.delegate = self;
    wxShare.requestDelegate = self;
    TTQQShare *qqShare = [TTQQShare sharedQQShare];
    qqShare.delegate = self;
    qqShare.requestDelegate = self;
    
    switch (contentType) {
        case AKShareContentTypeText: {
            if (platform == AKSharePlatformWeChat || platform == AKSharePlatformWeChatTimeLine) {
                [wxShare sendTextToScene:[self wxsceneWithPlatform:platform] withText:text customCallbackUserInfo:extra];
            } else if (platform == AKSharePlatformQQ) {
                [qqShare sendText:text withCustomCallbackUserInfo:extra];
            } else if (platform == AKSharePlatformQZone) {
                // 不支持分享文字到qzone
            }
        }
            break;
        case AKShareContentTypeWebPage: {
            if (platform == AKSharePlatformWeChat || platform == AKSharePlatformWeChatTimeLine) {
                [wxShare sendWebpageToScene:[self wxsceneWithPlatform:platform] withWebpageURL:webPageURLString thumbnailImage:thumbImage title:title description:description customCallbackUserInfo:extra];
            } else if (platform == AKSharePlatformQQ) {
                [qqShare sendNewsWithURL:webPageURLString thumbnailImage:thumbImage thumbnailImageURL:thumbImageURL title:title description:description customCallbackUserInfo:extra];
            } else if (platform == AKSharePlatformQZone) {
                [qqShare sendNewsToQZoneWithURL:webPageURLString thumbnailImage:thumbImage thumbnailImageURL:thumbImageURL title:title description:description customCallbackUserInfo:extra];
            }
        }
            break;
        case AKShareContentTypeImage: {
            NSString *imageDescription = !isEmptyString(text) ? text : title;
            if (platform == AKSharePlatformWeChat || platform == AKSharePlatformWeChatTimeLine) {
                [wxShare sendImageToScene:[self wxsceneWithPlatform:platform] withImage:image customCallbackUserInfo:extra];
            } else if (platform == AKSharePlatformQQ) {
                // QQ图片分享支持带文字
                [qqShare sendImage:image withTitle:imageDescription description:description customCallbackUserInfo:extra];
            } else {
                [qqShare sendImageToQZoneWithImage:image title:imageDescription customCallbackUserInfo:extra];
            }
        }
            break;
        case AKShareContentTypeVideo: {
            if (platform == AKSharePlatformWeChat || platform == AKSharePlatformWeChatTimeLine) {
                [wxShare sendVideoToScene:[self wxsceneWithPlatform:platform] withVideoURL:videoURLString thumbnailImage:thumbImage title:title description:description customCallbackUserInfo:extra];
            } else {
                // qq不支持视频分享
            }
        }
            break;
        default:
            break;
    }
}

- (void)startFetchShareInfoWithTaskID:(NSInteger)taskID
                      completionBlock:(AKShareInfoBlock)shareInfoBlock
{
    [AKNetworkManager requestForJSONWithPath:@"task/get_share_info/" params:({
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@(taskID) forKey:@"task_id"];
        [params copy];
    }) method:@"GET" callback:^(NSInteger err_no, NSString *err_tips, NSDictionary *dataDict) {
        if (err_no == 0 && [dataDict isKindOfClass:[NSDictionary class]] && shareInfoBlock) {
            shareInfoBlock([dataDict copy]);
        }
    }];
}

- (void)sendSMSMessageWithBody:(NSString *)messageBody
                    recipients:(NSArray<NSString *> *)recipients
      presentingViewController:(UIViewController *)viewController
                sendCompletion:(AKSendSMSCompletion)completion
{
    if (![MFMessageComposeViewController canSendText]) {
        return;
    }
    MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
    messageViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    messageViewController.messageComposeDelegate = self;
    [messageViewController setBody:messageBody];
    [messageViewController setRecipients:[recipients copy]];
    
    if (viewController) {
        [viewController presentViewController:messageViewController animated:YES completion:nil];
    } else {
        [ak_top_vc() presentViewController:messageViewController animated:YES completion:nil];
    }
}

#pragma mark - private

- (enum WXScene)wxsceneWithPlatform:(AKSharePlatform)platform
{
    if (platform == AKSharePlatformWeChat) {
        return WXSceneSession;
    } else if (platform == AKSharePlatformWeChatTimeLine) {
        return WXSceneTimeline;
    } else {
        return -1;
    }
}

- (void)commonHandleWithError:(NSError *)error
{
    // 弹分享结果toast
    NSString *shareResultTip = [self shareResultTipWithError:error];
    if (!isEmptyString(shareResultTip)) {
        TTIndicatorView *indicateView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:shareResultTip indicatorImage:[self shareResultImageWithError:error] dismissHandler:nil];
        indicateView.autoDismiss = YES;
        [indicateView showFromParentView:[UIApplication sharedApplication].delegate.window];
    }
}

- (NSString *)shareResultTipWithError:(NSError *)error
{
    NSString *shareResultTip = nil;
    if (self.sharePlatform == AKSharePlatformQQ || self.sharePlatform == AKSharePlatformQZone) {
        if (error) {
            switch (error.code) {
                case kTTQQShareErrorTypeNotInstalled:
                    shareResultTip = NSLocalizedString(@"您未安装QQ", nil);
                    break;
                case kTTQQShareErrorTypeNotSupportAPI:
                    shareResultTip = NSLocalizedString(@"您的QQ版本过低，无法支持分享", nil);
                    break;
                default:
                    shareResultTip = nil;
                    break;
            }
        } else {
            shareResultTip = NSLocalizedString(@"QQ分享成功", nil);
        }
    } else {
        if(error) {
            switch (error.code) {
                case kTTWeChatShareErrorTypeNotInstalled:
                    shareResultTip = NSLocalizedString(@"您未安装微信", nil);
                    break;
                case kTTWeChatShareErrorTypeNotSupportAPI:
                    shareResultTip = NSLocalizedString(@"您的微信版本过低，无法支持分享", nil);
                    break;
                case kTTWeChatShareErrorTypeExceedMaxImageSize:
                    shareResultTip = NSLocalizedString(@"图片过大，分享图片不能超过10M", nil);
                    break;
                default:
                    shareResultTip = nil;
                    break;
            }
        } else {
            shareResultTip = NSLocalizedString(@"分享成功", nil);
        }
    }
    return shareResultTip;
}

- (UIImage *)shareResultImageWithError:(NSError *)error
{
    return [UIImage themedImageNamed:error ? @"close_popup_textpage.png" : @"doneicon_popup_textpage.png"];
}

#pragma mark - share platform delegate methods

- (void)weChatShare:(TTWeChatShare *)weChatShare sharedWithError:(NSError *)error customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo
{
    // 收到微信分享结果
    if (self.completion) {
        self.completion(customCallbackUserInfo, error);
    }
    [self commonHandleWithError:error];
}

- (void)weChatShare:(TTWeChatShare *)weChatShare receiveRequest:(BaseReq *)request
{
    // 收到微信分享请求
}

- (void)qqShare:(TTQQShare *)qqShare sharedWithError:(NSError *)error customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo
{
    // 收到qq分享结果
    if (self.completion) {
        self.completion(customCallbackUserInfo, error);
    }
    [self commonHandleWithError:error];
}

- (void)qqShare:(TTQQShare *)qqShare receiveRequest:(QQBaseReq *)request
{
    // 收到qq分享请求
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    if (self.smsCompletion) {
        self.smsCompletion(result);
    }
}

@end
