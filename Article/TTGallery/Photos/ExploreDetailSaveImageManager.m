//
//  ExploreDetailSaveImageManager.m
//  Article
//
//  Created by 王双华 on 15/11/6.
//
//

#import "ExploreDetailSaveImageManager.h"
#import <TTImage/TTWebImageManager.h>
#import "ALAssetsLibrary+TTImagePicker.h"
#import "VVeboImageView.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "TTThemedAlertController.h"
#import "UIImage+MultiFormat.h"


@interface ExploreDetailSaveImageManager()
@property(nonatomic, strong)TTSaveImageAlertView * saveImageAlertView;
@property(nonatomic, strong)UIImage *imageData;
@property(nonatomic, strong)ALAssetsLibrary * assetsLbr;
@property(nonatomic, strong)VVeboImage *gifVVeboImage;
@property(nonatomic, assign)BOOL isGIF;
@end
@implementation ExploreDetailSaveImageManager

- (void)dealloc
{
    //NSLog(@"dealloced");
}

- (instancetype) init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)showOnWindowFromViewController:(UIViewController<TTSaveImageAlertViewDelegate> *)viewController
{
    self.saveImageAlertView = [[TTSaveImageAlertView alloc] init];
    _saveImageAlertView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _saveImageAlertView.delegate = viewController;
    //5.4:web图集不提供分享单张图片入口
    _saveImageAlertView.hideShareButton = YES;
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [_saveImageAlertView showActivityOnWindow:keyWindow];
}

- (void)saveImageData
{
    [self downloadImageWithUrl:self.imageUrl];
}

- (void)destructSaveAlert
{
    self.saveImageAlertView = nil;
}

- (void)saveImageToAlbum
{
    if (self.imageData == nil) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"图片下载失败，请稍后再试", nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
        UIViewController *topViewController = [TTUIResponderHelper topmostViewController];
        [alert showFrom:topViewController animated:YES];
        
        return;
    }
    
    
    self.assetsLbr = nil;
    self.assetsLbr = [[ALAssetsLibrary alloc] init];
    
    if (_isGIF && self.gifVVeboImage && self.gifVVeboImage.data) {
        [_assetsLbr tt_saveImageData:self.gifVVeboImage.data];
    } else {
        [_assetsLbr tt_saveImage:self.imageData];
    }
    
    wrapperTrackEvent(@"image", @"download");
}

- (void)downloadImageWithUrl:(NSString *)url
{
    if (isEmptyString(url)) {
        return;
    }
    __weak ExploreDetailSaveImageManager * wself = self;
    
    [[TTImageDownloader sharedInstance] downloadImageWithURL:url options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
        if (error) {
            TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"图片下载失败，请稍后再试", nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
            [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
            UIViewController *topViewController = [TTUIResponderHelper topmostViewController];
            [alert showFrom:topViewController animated:YES];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (data) {
                    [wself loadImageFromData:data];
                } else {
                    [wself loadFailed];
                }
                [wself saveImageToAlbum];
            });
        }
    }];
}

- (void)loadImageFromData:(NSData *)data
{
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (imageSource) {
        CFStringRef imageSourceContainerType = CGImageSourceGetType(imageSource);
        _isGIF = UTTypeConformsTo(imageSourceContainerType, kUTTypeGIF);
        if (_isGIF) {
            size_t imageCount = CGImageSourceGetCount(imageSource);
            if (imageCount > 0) {
                CGImageRef frameImageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
                if (frameImageRef) {
                    self.imageData = [UIImage imageWithCGImage:frameImageRef]; // 根据image大小layout
                    CGImageRelease(frameImageRef);
                    frameImageRef = nil;
                }
            }
            self.gifVVeboImage = [VVeboImage gifWithData:data];
            self.imageData = [self.gifVVeboImage nextImage];
        } else {
            UIImage *image = [UIImage sd_imageWithData:data];
            self.imageData = image;
        }
        CFRelease(imageSource);
    } else {
        UIImage *image = [UIImage sd_imageWithData:data];
        self.imageData = image;
    }
}

- (void)loadFailed
{
    self.imageData = nil;
}

@end
