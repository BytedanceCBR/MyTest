//
//  TTShowImageView.m
//  Article
//
//  Created by Zhang Leonardo on 12-11-12.
//  Edited by Cao Hua from 13-10-12.
//

#import "TTShowImageView.h"
#import "UIDevice+TTAdditions.h"
#import "ALAssetsLibrary+TTAddition.h"
#import "TTIndicatorView.h"
#import "VVeboImageView.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreGraphics/CoreGraphics.h>
#import "TTImageLoadingView.h"
#import "TTThemedAlertController.h"
#import "TTUIShortTapGestureRecognizer.h"
#import "UIImage+MultiFormat.h"
#import "TTImageDownloader.h"
#import "NSData+ImageContentType.h"
#import "TTSaveImageAlertView.h"
#import "SSThemed.h"
#import "UIImage+TTThemeExtension.h"
#import "ALAssetsLibrary+TTImagePicker.h"
#import "UIViewAdditions.h"
#import "TTTracker.h"
#import <TTImage/TTImageView.h>
#import <TTImage/TTWebImageManager.h>
#import <BDWebImage/BDWebImageDownloader.h>
#import <BDWebImage/BDWebImageManager.h>
#define MinZoomScale 1.f
#define MaxZoomScale 2.5f

#define kDefaultSecondsToCache 60.0 * 60.0 * 12

@interface TTShowImageView()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, strong)UIScrollView * imageContentScrollView;
@property(nonatomic, strong)UIImageView * largeImageView;
@property(nonatomic, strong)TTUIShortTapGestureRecognizer * tapTwiceGestureRecognizer;
@property(nonatomic, strong)UILongPressGestureRecognizer * longPressGestureRecognizer;
@property(nonatomic, strong)ALAssetsLibrary * assetsLbr;

// gif 支持
@property(nonatomic, strong)VVeboImage *gifVVeboImage;
@property(nonatomic, strong)VVeboImageView *gifVVeboImageView;

// Loading progress view
@property(nonatomic, strong)TTImageLoadingView * imageloadingProgressView;

@property(nonatomic, strong)TTSaveImageAlertView * saveImageAlertView;

@property(nonatomic, assign, readwrite)BOOL isDownloading;
@property(nonatomic, strong)NSDate *singleTapTime;

@end

@implementation TTShowImageView
{
    int _currentTryIndex;
    BOOL _isGIF;
}

- (void)dealloc
{
   
    self.delegate = nil;
    
    self.imageContentScrollView.delegate = nil;
    self.imageContentScrollView = nil;
    self.largeImageView = nil;

    _tapGestureRecognizer.delegate = nil;
    [self removeGestureRecognizer:_tapGestureRecognizer];
    self.tapGestureRecognizer = nil;
    
    _tapTwiceGestureRecognizer.delegate = nil;
    [self removeGestureRecognizer:_tapTwiceGestureRecognizer];
    self.tapTwiceGestureRecognizer = nil;
    
    _longPressGestureRecognizer.delegate = nil;
    [self removeGestureRecognizer:_longPressGestureRecognizer];
    self.longPressGestureRecognizer = nil;
    
    self.imageData = nil;
    self.assetsLbr = nil;
    
    self.gifVVeboImage = nil;
    self.gifVVeboImageView.image = nil;
    self.gifVVeboImageView = nil;
     
    self.placeholderImage = nil;
    
    self.imageloadingProgressView = nil;
 
    self.gifVVeboImageView.image = nil;
    
    self.saveImageAlertView = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentTryIndex = 0;
        _gifRepeatIfHave = YES;
        _visible = NO;
        _isDownloading = NO;
        [self buildViews];
        [self addGesture];
        
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    BOOL singleTapDuration = NO;
    if (_singleTapTime){
        singleTapDuration = [[NSDate new] timeIntervalSinceDate:_singleTapTime] < .5;
    }
    if (!singleTapDuration){
        [self refreshUI];
        _imageloadingProgressView.center = self.center;
    }
}

#pragma mark -- target

- (void)saveImage
{
    if (self.imageData == nil) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"图片正在下载，请稍后再试", nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
        [alert showFrom:self.viewController animated:YES];
        
        return;
    }
    
    
    self.assetsLbr = nil;
    self.assetsLbr = [[ALAssetsLibrary alloc] init];
    
    if (_isGIF && self.gifVVeboImage && self.gifVVeboImage.data) {
        [_assetsLbr tt_saveImageData:self.gifVVeboImage.data];
    } else {
        [_assetsLbr tt_saveImage:self.imageData];
    }

//    [TTTracker event:@"image" label:@"download"];
}

- (void)destructSaveImageAlert
{
    self.saveImageAlertView = nil;
}

#pragma mark -- private

- (void)addGesture
{
    
    // tapTwiceGestureRecognizer
    self.tapTwiceGestureRecognizer = [[TTUIShortTapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    _tapTwiceGestureRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:_tapTwiceGestureRecognizer];
    
    // tapGestureRecognizer
    self.tapGestureRecognizer = [[TTUIShortTapGestureRecognizer alloc] initWithTarget:self action:@selector(onceTapped:)];
    _tapGestureRecognizer.numberOfTapsRequired = 1;
    //_tapGestureRecognizer.delegate = self;
    [_tapGestureRecognizer requireGestureRecognizerToFail:_tapTwiceGestureRecognizer];
    [self addGestureRecognizer:_tapGestureRecognizer];
    
    //longPressGestureRecognizer
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    _longPressGestureRecognizer.minimumPressDuration = .5f;
    [_longPressGestureRecognizer requireGestureRecognizerToFail:_tapTwiceGestureRecognizer];
    [self addGestureRecognizer:_longPressGestureRecognizer];
}


- (void)buildViews
{
    // imageContentScrollView
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame =self.bounds;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:button];
    self.imageContentScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.imageContentScrollView.scrollsToTop = NO;
    _imageContentScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _imageContentScrollView.contentSize = self.bounds.size;
    _imageContentScrollView.delegate = self;
    _imageContentScrollView.backgroundColor = [UIColor clearColor];
    _imageContentScrollView.minimumZoomScale = MinZoomScale;
    _imageContentScrollView.maximumZoomScale = MaxZoomScale;
    //_imageContentScrollView.alwaysBounceHorizontal = YES;
    
    [self addSubview:_imageContentScrollView];
    
    // image loading progress view
    self.imageloadingProgressView = [[TTImageLoadingView alloc] init];
    _imageloadingProgressView.center = self.center;
    _imageloadingProgressView.hidden = YES;
    [self addSubview:_imageloadingProgressView];
}

- (UIImageView *)imageView
{
    return (_isGIF ? _gifVVeboImageView : _largeImageView);
}

- (void)refreshUI
{
    _imageContentScrollView.frame = self.bounds;
    
    [self refreshLargeImageViewOrigin];
    [self refreshLargeImageViewSizeWithImage:self.imageView.image];
    _imageContentScrollView.contentSize = self.imageView.frame.size;
    _imageContentScrollView.zoomScale = MinZoomScale;
    [self refreshLargeImageViewOrigin];
    
    _imageContentScrollView.contentOffset = CGPointZero;
    if ([[UIDevice currentDevice] orientation] != UIDeviceOrientationLandscapeLeft && [[UIDevice currentDevice] orientation] != UIDeviceOrientationLandscapeRight){
        self.largeImageView.center = CGPointMake(self.largeImageView.center.x, self.largeImageView.center.y);
    }
}

- (void)refreshLargeImageViewOrigin
{
#warning to be add !!!! @yadong
    //[[TTPhotoDetailManager shareInstance] setTransitionActionValid:YES];
    
    float imageViewW = self.imageView.frame.size.width;
    float parentViewW = _imageContentScrollView.frame.size.width;
    
    float imageViewH = self.imageView.frame.size.height;
    float parentViewH = _imageContentScrollView.frame.size.height;
    
    float centerW = 0.f;
    float centerH = 0.f;
    
    if (imageViewW <= parentViewW) {
        centerW = parentViewW / 2.f;
    }
    else {
        centerW = imageViewW / 2.f;
#warning to be add !!!! @yadong
        //[[TTPhotoDetailManager shareInstance] setTransitionActionValid:NO];
    }
    
    if (imageViewH <= parentViewH) {
        centerH = parentViewH / 2.f;
    }
    else {
        centerH = imageViewH / 2.f;
#warning to be add !!!! @yadong
        //[[TTPhotoDetailManager shareInstance] setTransitionActionValid:NO];
    }
    CGPoint newCenter = CGPointMake(centerW, centerH);
    self.imageView.center = newCenter;

}

- (void)refreshLargeImageViewSizeWithImage:(UIImage *)img
{
    if(img == nil){
        self.imageView.frame = CGRectZero;
    } else {
        CGFloat imageWidth = img.size.width;
        CGFloat imageHeight = img.size.height;
        
        CGFloat maxWidth = CGRectGetWidth(self.bounds);
        CGFloat maxHeight = CGRectGetHeight(self.bounds);
        
        CGFloat imgViewWidth;
        CGFloat imgViewHeight;
        
        // 普通图片(除细长图外)适配屏幕宽高比等比缩放；
        // 默认 imageHeight >= imageWidth * 3 的图片为细长图，宽度按屏幕宽处理，高度等比缩放。
        if (imageWidth/imageHeight > maxWidth/maxHeight || imageHeight >= imageWidth * 3) {
            imgViewWidth = maxWidth;
            imgViewHeight = maxWidth * imageHeight / imageWidth;
        } else {
            imgViewHeight = maxHeight;
            imgViewWidth = imageWidth / imageHeight * maxHeight;
        }
        
        self.imageView.frame = CGRectMake(0, 0, imgViewWidth, imgViewHeight);
    }
    #warning to be add !!!! @yadong
    //[[TTPhotoDetailManager shareInstance] setTransitionActionValid:YES];
}

- (void)loadFinishedWithImage:(UIImage *)image
{
    if (!_largeImageView) {
        self.largeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _largeImageView.contentMode = UIViewContentModeScaleAspectFill;
        _largeImageView.clipsToBounds = YES;
        _largeImageView.backgroundColor = [UIColor clearColor];
    }
    
    if (_gifVVeboImageView.superview) {
        [_gifVVeboImageView removeFromSuperview];
    }
    
    CGRect beginFrame = self.largeImageView.frame;
    [self.largeImageView setImage:image];
    self.imageData = image;
    [self refreshUI];
    
    if (self.largeImageView.superview != _imageContentScrollView) {
        [self.largeImageView removeFromSuperview];
        [_imageContentScrollView addSubview:self.largeImageView];
    }
    self.largeImageView.hidden = NO;
    
    if (self.loadingCompletedAnimationBlock) {
        self.loadingCompletedAnimationBlock();
    } else if (_placeholderImage && self.isVisible) {
        CGRect endFrame = self.largeImageView.frame;
        self.largeImageView.frame = beginFrame;
        [UIView animateWithDuration:.4f animations:^{
            self.largeImageView.frame = endFrame;
            self.placeholderImage = nil;
        }];
    }
}

- (void)showGifView
{
    self.placeholderImage = nil;
    self.imageData = [self.gifVVeboImage nextImage];
    _largeImageView.hidden = YES;// for dismiss animation
    
    _gifVVeboImageView.image = self.gifVVeboImage;
    _gifVVeboImageView.repeats = self.gifRepeatIfHave;
    
    if (_gifVVeboImageView.superview != _imageContentScrollView) {
        [_imageContentScrollView addSubview:_gifVVeboImageView];
    }
    
    [self refreshUI];
}

- (void)loadFinishedWithGIFData:(NSData *)gifData
{
    if (self.gifVVeboImageView == nil) {
        self.gifVVeboImageView = [[VVeboImageView alloc] initWithImage:nil];
        _gifVVeboImageView.backgroundColor = [UIColor clearColor];
    }
    
    self.gifVVeboImage = [VVeboImage gifWithData:gifData];
    
    CGRect beginFrame = self.largeImageView.frame;
    self.imageData = [self.gifVVeboImage nextImage];
    [self.largeImageView setImage:self.imageData];
    _isGIF = NO;
    [self refreshUI];
    _isGIF = YES;
    
    if (self.largeImageView.superview != _imageContentScrollView) {
        [self.largeImageView removeFromSuperview];
        self.largeImageView.hidden = NO;
        [_imageContentScrollView addSubview:self.largeImageView];
    }
    
    if (self.loadingCompletedAnimationBlock) {
        self.loadingCompletedAnimationBlock();
    } else if (_placeholderImage && self.isVisible) {
        CGRect endFrame = _largeImageView.frame;
        self.largeImageView.frame = beginFrame;
        
        [UIView animateWithDuration:.4f animations:^{
            self.largeImageView.frame = endFrame;
        } completion:^(BOOL finished) {
            [self showGifView];
        }];
    } else {
        [self showGifView];
    }
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
            [self loadFinishedWithGIFData:data];
        } else {
            UIImage *image = [UIImage sd_imageWithData:data];
            [self loadFinishedWithImage:image];
        }
        CFRelease(imageSource);
    } else {
        UIImage *image = [UIImage sd_imageWithData:data];
        [self loadFinishedWithImage:image];
    }
}

- (void)loadFailed
{
    self.imageData = nil;
    _imageloadingProgressView.hidden = YES;
    [TTTracker event:@"image" label:@"fail"];;
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"加载失败" indicatorImage:[UIImage themedImageNamed:@"excalmatoryicon_loading.png"] autoDismiss:YES dismissHandler:nil];
}

#pragma mark -- protected


#pragma mark -- getter & setter

- (void)setLargeImageURLString:(NSString *)largeImageURLString
{
    _imageloadingProgressView.hidden = YES;
    if (_largeImageURLString != largeImageURLString) {
 
        _largeImageURLString = largeImageURLString;
        _imageInfosModel = nil;
        if (_gifVVeboImageView.superview) {
            [_gifVVeboImageView removeFromSuperview];
        }
        self.imageData = nil;

        [self showPlaceholderIfNeeded];
        [self downloadImageWithUrl:largeImageURLString];
    }
}

- (void)setImageInfosModel:(TTImageInfosModel *)imageInfosModel
{
    _imageloadingProgressView.hidden = YES;
    if (imageInfosModel != _imageInfosModel) {
 
        _imageInfosModel = imageInfosModel;
        _largeImageURLString = nil;
        if (_gifVVeboImageView.superview) {
            [_gifVVeboImageView removeFromSuperview];
        }

        if (_imageInfosModel) {
            self.imageData = nil;
            _currentTryIndex = 0;
            [self downloadImageWithUrl:[_imageInfosModel urlStringAtIndex:_currentTryIndex]];
        }
    }
}

- (void)setImage:(UIImage *)image
{
    _imageloadingProgressView.hidden = YES;
    [self loadFinishedWithImage:image];
}

- (UIImage *)image
{
    return _imageData ? _imageData : _placeholderImage;
}

- (void)setAsset:(ALAsset *)asset
{
    _imageloadingProgressView.hidden = YES;
    if (_asset != asset) {
        _asset = asset;
        if (_asset) {
            [self loadImageFromAsset:_asset];
        }
    }
}

- (UIImageView *)largeImageView
{
    if (!_largeImageView) {
        self.largeImageView = [[UIImageView alloc] init];
        _largeImageView.contentMode = UIViewContentModeScaleAspectFill;
        _largeImageView.clipsToBounds = YES;
        _largeImageView.backgroundColor = [UIColor clearColor];
    }
    
    return _largeImageView;
}

- (void)tryLoadNextUrlIfFailed
{
    if (_imageInfosModel) {
        _currentTryIndex += 1;
        NSString * urlString = [_imageInfosModel urlStringAtIndex:_currentTryIndex];
        if (!isEmptyString(urlString)) {
            [self downloadImageWithUrl:urlString];
        } else {
            [self loadFailed];
        }
    }
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshLargeImageViewOrigin];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [self imageView];
}

- (void)onceTapped:(UITapGestureRecognizer *)recognizer
{
    _singleTapTime = [[NSDate alloc] init];
    if (_delegate && [_delegate respondsToSelector:@selector(showImageViewOnceTap:)]) {
        [_delegate performSelector:@selector(showImageViewOnceTap:) withObject:self];
    }
}   

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer
{
    [_imageContentScrollView setZoomScale:(_imageContentScrollView.zoomScale==MaxZoomScale?MinZoomScale:MaxZoomScale)
                                 animated:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(showImageViewDoubleTap:)]) {
        [_delegate performSelector:@selector(showImageViewDoubleTap:) withObject:self];
    }

}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.saveImageAlertView = [[TTSaveImageAlertView alloc] init];
        _saveImageAlertView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if ([self.viewController conformsToProtocol:@protocol(TTSaveImageAlertViewDelegate)]) {
            _saveImageAlertView.delegate = (UIViewController <TTSaveImageAlertViewDelegate> *)self.viewController;
            UIWindow * keyWindow = SSGetMainWindow();
            [_saveImageAlertView showOnWindow:keyWindow];
            [((UIViewController <TTSaveImageAlertViewDelegate> *)self.viewController) alertDidShow];
        }
    }
}

#pragma mark -- public

- (void)resetZoom
{
    _imageContentScrollView.zoomScale = MinZoomScale;
}

#pragma mark - download image data

- (void)downloadImageWithUrl:(NSString *)url
{
    if (isEmptyString(url)) {
        return;
    }

    if (_placeholderImage) {
        self.largeImageView.center = CGPointMake(self.width / 2.f, self.height / 2.f);
    }

    UIImage *image  = [[BDWebImageManager sharedManager].imageCache imageForKey:url];
    if (image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _isDownloading = NO;
            _imageloadingProgressView.hidden = YES;
            [self loadFinishedWithImage:image];
        });
        return;
    }
    _isDownloading = YES;
    if (_isDownloading) {
        [self showPlaceholderIfNeeded];
    }

    _imageloadingProgressView.hidden = NO;
    _imageloadingProgressView.loadingProgress = 0;


    __weak TTShowImageView * wself = self;
    [[BDWebImageManager sharedManager]requestImage:[NSURL URLWithString:url] alternativeURLs:nil options:BDImageRequestHighPriority cacheName:url transformer:nil progress:^(BDWebImageRequest *request, NSInteger receivedSize, NSInteger expectedSize) {
        if (!wself.imageloadingProgressView.hidden) {
            wself.imageloadingProgressView.loadingProgress = receivedSize/(expectedSize*1.0f);
        }
    } complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
        _isDownloading = NO;
        if (error) {
            [wself tryLoadNextUrlIfFailed];

            wself.imageloadingProgressView.hidden = YES;
            [TTTracker event:@"image" label:@"fail"];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                wself.imageloadingProgressView.hidden = YES;

                if (image) {
                    [wself loadFinishedWithImage:image];
                }else if (data) {
                    [wself loadImageFromData:data];
                } else {
                    [wself loadFailed];
                }
            });
        }
    }];

}

- (void)loadImageFromAsset:(ALAsset *)asset
{
    if (asset) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            
            UIImage * image = [ALAssetsLibrary tt_getBigImageFromAsset:asset];
            
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self loadFinishedWithImage:image];
                });
            }
        });
    }
}


- (void)restartGifIfNeeded
{
    if (_isGIF && _gifVVeboImageView) {
        _gifVVeboImageView.image = _gifVVeboImage;
    }
}

- (void)showGifIfNeeded
{
    if (_isGIF && _gifVVeboImageView) {
        [self showGifView];
    }
}

- (void)hideGifIfNeeded
{
    if (_isGIF && _gifVVeboImageView) {
        _gifVVeboImageView.hidden = YES;
    }
}

/*
- (void)setPlaceholderImage:(UIImage *)placeholder withSourceViewFrame:(CGRect)sourceViewFrame
{
    self.placeholderImage = placeholder;
    self.placeholderSourceViewFrame = sourceViewFrame;
}
*/
- (void)showPlaceholderIfNeeded
{
    if (!self.largeImageView) {
        self.largeImageView = [[UIImageView alloc] initWithImage:_placeholderImage];
        _largeImageView.contentMode = UIViewContentModeScaleAspectFill;
        _largeImageView.clipsToBounds = YES;
        _largeImageView.backgroundColor = [UIColor clearColor];
    } else {
        [self.largeImageView setImage:_placeholderImage];
    }
    
    [self.largeImageView sizeToFit];
    [self refreshUI];
    self.largeImageView.hidden = NO;
    
    [self.largeImageView removeFromSuperview];
    [self.gifVVeboImageView removeFromSuperview];
    [self.imageContentScrollView setContentSize:self.bounds.size];
    [self.imageContentScrollView addSubview:self.largeImageView];
    
    if (!CGRectEqualToRect(_placeholderSourceViewFrame, CGRectZero)) {
        self.largeImageView.frame = _placeholderSourceViewFrame;
    }
    
    self.largeImageView.center = CGPointMake(self.width / 2.f, self.height / 2.f);
}

- (UIImageView *)displayImageView
{
    return _largeImageView;
}

- (UIImageView *)currentImageView{
    return self.imageView;
}

- (CGRect)currentImageViewFrame {
    if (_isGIF && _gifVVeboImage) {
        return _gifVVeboImageView.frame;
    }
    else{
        return _largeImageView.frame;
    }
}

@end
