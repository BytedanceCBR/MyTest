//
//  FRPhotoBrowserCell.m
//  Article
//
//  Created by 王霖 on 17/1/18.
//
//

#import "FRPhotoBrowserCell.h"
#import "TTImageInfosModel.h"
#import "FRPhotoBrowserModel.h"
#import "TTImageLoadingView.h"
#import <VVeboImage.h>
#import <VVeboImageView.h>
#import <SDWebImageManager.h>
#import <UIImage+MultiFormat.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "TTIndicatorView.h"
#import "TTThemedAlertController.h"
#import "ALAssetsLibrary+TTImagePicker.h"
#import <SSViewBase.h>
#import <UIView+CustomTimingFunction.h>
#import "UIViewAdditions.h"
#import "TTBaseMacro.h"
#import "FRImageInfoModel.h"
#import "SSThemed.h"
#import "UIImage+TTThemeExtension.h"
#import "TTRoute.h"
#import "TTUIResponderHelper.h"
#import "TTUGCPodBridge.h"
#import "TTKitchenHeader.h"
#import "FRRequestManager.h"
#import "FRApiModel.h"

static const CGFloat kMinZoomScale = 1.f;
static const CGFloat kMaxZoomScale = 2.5f;

static NSString * const kShowImagePhotoPlaceholderImageViewGroupAnimationKey = @"kShowImagePhotoPlaceholderImageViewGroupAnimationKey";
static NSString * const kShowImagePhotoImageViewGroupAnimationKey = @"kShowImagePhotoImageViewGroupAnimationKey";

static NSString * const kHideImagePhotoPlaceholderImageViewGroupAnimationKey = @"kHideImagePhotoPlaceholderImageViewGroupAnimationKey";
static NSString * const kHideImagePhotoImageViewGroupAnimationKey = @"kHideImagePhotoImageViewGroupAnimationKey";

static NSString * const kUndownloadShowImagePhotoPlaceholderImageViewGroupAnimationKey = @"kUndownloadShowImagePhotoPlaceholderImageViewGroupAnimationKey";

static NSString * const kDownloadFinishShowImagePhotoPlaceholderImageViewGroupAnimation = @"kDownloadFinishShowImagePhotoPlaceholderImageViewGroupAnimation";
static NSString * const kDownloadFinishShowImagePhotoImageViewGroupAnimation = @"kDownloadFinishShowImagePhotoImageViewGroupAnimation";

static NSString * const kHideContentViewAnimation = @"kHideContentViewAnimation";

const NSTimeInterval kAnimationDuration = 0.28f;

typedef NS_ENUM(NSInteger, FRPhotoBrowserCellStatus) {
    FRPhotoBrowserCellStatusInitial,
    FRPhotoBrowserCellStatusDownloading,
    FRPhotoBrowserCellStatusDownloadSuccess,
    FRPhotoBrowserCellStatusDownloadFail
};

@interface FRPhotoBrowserCell () <CAAnimationDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) FRPhotoBrowserModel * model;
@property (nonatomic, strong) VVeboImage * gifImage;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, assign) BOOL isGIF;
@property (nonatomic, assign) NSUInteger currentDownloadImageURLIndex;
@property (nonatomic, assign) FRPhotoBrowserCellStatus status;
@property (nonatomic, strong) ALAssetsLibrary * assetsLbr;

@property (nonatomic, strong) UIScrollView * photoZoomingScrollView;
@property (nonatomic, strong) UIImageView * photoPlaceholderImageView;
@property (nonatomic, strong) UIImageView * photoImageView;
@property (nonatomic, strong) VVeboImageView * gifImageView;
@property (nonatomic, strong) TTImageLoadingView * loadingProgressView;

@property (nonatomic, strong) UITapGestureRecognizer * tapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer * doubleTapGestureRecognizer;

@property (nonatomic, strong) NSURL *qrURL;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@end

@implementation FRPhotoBrowserCell

#pragma mark - Life circle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createComponents];
        [self addGesture];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createComponents];
        [self addGesture];
    }
    return self;
}

- (void)createComponents {
    self.photoZoomingScrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    self.photoZoomingScrollView.scrollsToTop = YES;
    self.photoZoomingScrollView.delegate = self;
    if (@available(iOS 11.0, *)) {
        self.photoZoomingScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.photoZoomingScrollView.contentSize = self.contentView.size;
    self.photoZoomingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.photoZoomingScrollView.minimumZoomScale = kMinZoomScale;
    self.photoZoomingScrollView.maximumZoomScale = kMaxZoomScale;
    [self.contentView addSubview:self.photoZoomingScrollView];
    
    self.photoPlaceholderImageView = [[UIImageView alloc] init];
    self.photoPlaceholderImageView.hidden = YES;
    self.photoPlaceholderImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoPlaceholderImageView.clipsToBounds = YES;
    [self.photoZoomingScrollView addSubview:self.photoPlaceholderImageView];
    
    self.photoImageView = [[UIImageView alloc] init];
    self.photoImageView.hidden = YES;
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoImageView.clipsToBounds = YES;
    [self.photoZoomingScrollView addSubview:self.photoImageView];
    
    self.gifImageView = [[VVeboImageView alloc] init];
    self.gifImageView.repeats = YES;
    self.gifImageView.hidden = YES;
    [self.photoZoomingScrollView addSubview:self.gifImageView];
    
    self.loadingProgressView = [[TTImageLoadingView alloc] init];
    self.loadingProgressView.center = CGPointMake(self.width/2, self.height/2);
    self.loadingProgressView.hidden = YES;
    self.loadingProgressView.percentLabel.hidden = YES;
    [self.contentView addSubview:self.loadingProgressView];
}

- (void)addGesture {
    if ([KitchenMgr getBOOL:kKCUGCBrowserQRCode]) {
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        _longPressGestureRecognizer.minimumPressDuration = 0.3f;
        [self.contentView addGestureRecognizer:_longPressGestureRecognizer];
    }
    
    self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    self.doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [self.doubleTapGestureRecognizer requireGestureRecognizerToFail:self.longPressGestureRecognizer];
    [self.contentView addGestureRecognizer:self.doubleTapGestureRecognizer];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    self.tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.tapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
    [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    

}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetComponents];
}

- (void)resetComponents {
    if (self.photoZoomingScrollView.zoomScale != kMinZoomScale) {
        [self.photoZoomingScrollView setZoomScale:kMinZoomScale
                                         animated:NO];
    }
    
    self.gifImage = nil;
    self.image = nil;
    
    self.isGIF = NO;
    self.currentDownloadImageURLIndex = 0;
    self.status = FRPhotoBrowserCellStatusInitial;
    
    self.photoPlaceholderImageView.hidden = YES;
    self.photoPlaceholderImageView.image = nil;
    self.photoPlaceholderImageView.frame = CGRectZero;
    
    self.photoImageView.hidden = YES;
    self.photoImageView.image = nil;
    [self scanQRCode];
    self.photoImageView.frame = CGRectZero;
    
    self.gifImageView.hidden = YES;
    self.gifImageView.image = nil;
    
    self.loadingProgressView.hidden = YES;
    self.loadingProgressView.loadingProgress = 0;
    
    self.photoZoomingScrollView.contentSize = self.contentView.size;
}

#pragma mark - Actions

- (void)doubleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.status == FRPhotoBrowserCellStatusDownloadSuccess) {
        [self.photoZoomingScrollView setZoomScale:(kMaxZoomScale == self.photoZoomingScrollView.zoomScale ? kMinZoomScale : kMaxZoomScale)
                                         animated:YES];
    }
}

- (void)tap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapPhotoBrowserCell:)]) {
        [self.delegate tapPhotoBrowserCell:self];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIImageView * imageView = self.isGIF?self.gifImageView:self.photoImageView;
    
    float imageViewW = imageView.width;
    float parentViewW = self.photoZoomingScrollView.width;
    
    float imageViewH = imageView.height;
    float parentViewH = self.photoZoomingScrollView.height;
    
    float centerW = 0.f;
    float centerH = 0.f;
    
    if (imageViewW <= parentViewW) {
        centerW = parentViewW / 2.f;
    }else {
        centerW = imageViewW / 2.f;
    }
    
    if (imageViewH <= parentViewH) {
        centerH = parentViewH / 2.f;
    }else {
        centerH = imageViewH / 2.f;
    }
    CGPoint newCenter = CGPointMake(centerW, centerH);
    imageView.center = newCenter;
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return (self.isGIF ? self.gifImageView : self.photoImageView);
}

#pragma mark - Download image

- (void)downloadImageWithIndex:(NSUInteger)index {
    self.status = FRPhotoBrowserCellStatusDownloading;
    self.loadingProgressView.hidden = NO;
    NSString * url = [self.model.imageInfosModel urlStringAtIndex:index];
    
    FRPhotoBrowserModel * model = self.model;
    
    
    NSURL *URL = [[TTUGCPodBridge sharedInstance] ugcImageURLWithString:url];
    if (URL == nil) {
        URL = [NSURL URLWithString:url];
    }
    WeakSelf;
    [[SDWebImageManager sharedManager] loadImageWithURL:URL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * targetURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (model == wself.model) {
                //保证cell被复用的时候，上个model不会对当前的UI造成影响
                wself.loadingProgressView.loadingProgress = ((double)receivedSize)/expectedSize;
            }
        });
    } completed:^(UIImage * image, NSData * data, NSError * error, SDImageCacheType cacheType, BOOL finished, NSURL * imageURL) {
        if (model == wself.model) {
            if (error || nil == image) {
                wself.currentDownloadImageURLIndex++;
                if (wself.currentDownloadImageURLIndex >= wself.model.imageInfosModel.url_list.count) {
                    //图片下载失败
                    [wself downloadImageFail];
                }else {
                    //下载下一张图片
                    [wself downloadImageWithIndex:wself.currentDownloadImageURLIndex];
                }
            }else {
                [wself downloadImageSuccessWithData:data];
            }
        }
        
    }];
    
}

- (void)downloadImageFail {
    self.status = FRPhotoBrowserCellStatusDownloadFail;
    self.loadingProgressView.hidden = YES;
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                              indicatorText:@"加载失败"
                             indicatorImage:[UIImage themedImageNamed:@"excalmatoryicon_loading.png"]
                                autoDismiss:YES
                             dismissHandler:nil];
}

- (void)downloadImageSuccessWithData:(NSData *)data {
    self.loadingProgressView.hidden = YES;
    
    self.isGIF = [[self class] isGIFWithData:data];
    CGRect fromFrame = self.photoPlaceholderImageView.frame;
    CGRect toFrame = CGRectZero;
    if (self.isGIF) {
        self.gifImage = [VVeboImage gifWithData:data];
        self.image = [self.gifImage nextImage];
        toFrame = [[self class] getImageViewFrameWithImage:self.image
                                             containerSize:self.contentView.size];
        self.gifImageView.frame = toFrame;
        self.photoImageView.image = self.image;
    }else {
        self.image = [UIImage sd_imageWithData:data];
        toFrame = [[self class] getImageViewFrameWithImage:self.image
                                             containerSize:self.contentView.size];
        self.photoImageView.image = self.image;
        [self scanQRCode];
    }
    self.photoImageView.frame = fromFrame;
    self.photoImageView.alpha = 0;
    self.photoPlaceholderImageView.frame = fromFrame;
    self.photoImageView.hidden = NO;
    
    [UIView animateWithDuration:.22 customTimingFunction:CustomTimingFunctionSineOut delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animation:^{
        self.photoPlaceholderImageView.frame = toFrame;
        self.photoImageView.frame = toFrame;
    } completion:^(BOOL finished) {
        self.photoPlaceholderImageView.hidden = YES;

        if (self.isGIF) {
            self.gifImageView.image = self.gifImage;
            self.gifImageView.hidden = NO;
            self.photoImageView.hidden = YES;
        }
        self.photoZoomingScrollView.contentSize = self.photoImageView.size;
        self.status = FRPhotoBrowserCellStatusDownloadSuccess;
    }];
    [UIView animateWithDuration:.05 delay:.02 options:0 animations:^{
        self.photoImageView.alpha = 1;
    } completion:nil];
}

#pragma mark - Publics

- (UIImageView *)getImageView{
    
    if (!self.gifImageView.hidden){
        return self.gifImageView;
    }

    if (!self.photoImageView.hidden){
        return self.photoImageView;
    }
    
    return self.photoPlaceholderImageView;
}

- (void)resetImageViews{
    if (_photoPlaceholderImageView.hidden){
        return;
    }
    if (self.gifImageView.hidden == NO || self.photoImageView.hidden == NO){
        _photoPlaceholderImageView.hidden = YES;
    }
}

- (void)refreshWithModel:(FRPhotoBrowserModel *)model {
    self.model = model;
}

- (void)showModel {
    if (nil == self.model || nil == self.model.imageInfosModel) {
        [self resetComponents];
        return;
    }
    
    NSString * cacheImageURL = [[self class] getImageURLOfDiskExistsWithImageInfosModel:self.model.imageInfosModel];
    if (cacheImageURL) {
        //图片已下载
        NSString * defaultPath = [[SDImageCache sharedImageCache] defaultCachePathForKey:cacheImageURL];
        NSData * data = [NSData dataWithContentsOfFile:defaultPath];
        
        self.isGIF = [[self class] isGIFWithData:data];
        if (self.isGIF) {
            self.gifImage = [VVeboImage gifWithData:data];
            self.image = [self.gifImage nextImage];
            self.gifImageView.frame = [[self class] getImageViewFrameWithImage:self.image
                                                                 containerSize:self.contentView.size];
            self.gifImageView.image = self.gifImage;
            self.gifImageView.hidden = NO;
            
            self.photoZoomingScrollView.contentSize = self.gifImageView.size;
        }else {
            self.image = [UIImage sd_imageWithData:data];
            self.photoImageView.frame = [[self class] getImageViewFrameWithImage:self.image containerSize:self.contentView.size];
            self.photoImageView.image = self.image;
            [self scanQRCode];
            self.photoImageView.hidden = NO;
            
            self.photoZoomingScrollView.contentSize = self.photoImageView.size;
        }
        self.status = FRPhotoBrowserCellStatusDownloadSuccess;
    }else {
        //图片还没下载
        if (self.model.originalFrame) {
            CGRect originalFrame = self.model.originalFrame.CGRectValue;
            self.photoPlaceholderImageView.frame = CGRectMake(self.contentView.width/2 - originalFrame.size.width/2, self.contentView.height/2 - originalFrame.size.height/2, originalFrame.size.width, originalFrame.size.height);
        }else {
            self.photoPlaceholderImageView.frame = CGRectMake(self.contentView.width/2, self.contentView.height/2, 0, 0);
        }
        
        self.photoPlaceholderImageView.image = self.model.placeholderImage;
        self.photoPlaceholderImageView.hidden = NO;
        [self downloadImageWithIndex:self.currentDownloadImageURLIndex];
    }
}

- (void)show {
    if (nil == self.model || nil == self.model.imageInfosModel) {
        [self resetComponents];
        if (self.delegate && [self.delegate respondsToSelector:@selector(showCompleteWithModel:)]) {
            [self.delegate showCompleteWithModel:self.model];
        }
        return;
    }
    
    NSString * cacheImageURL = [[self class] getImageURLOfDiskExistsWithImageInfosModel:self.model.imageInfosModel];
    
    if (cacheImageURL) {
        //图片已下载
        NSString * defaultPath = [[SDImageCache sharedImageCache] defaultCachePathForKey:cacheImageURL];//特殊用法
        NSData * data = [NSData dataWithContentsOfFile:defaultPath];
        
        CGRect fromFrame = CGRectZero;
        CGRect toFrame = CGRectZero;
        if (self.model.originalFrame) {
            fromFrame = [self.photoZoomingScrollView convertRect:self.model.originalFrame.CGRectValue fromView:nil];
        }else {
            fromFrame = CGRectMake(self.width/2, self.height/2, 0, 0);
        }
        
        self.photoPlaceholderImageView.image = self.model.placeholderImage;
        self.photoPlaceholderImageView.hidden = NO;
        
        self.isGIF = [[self class] isGIFWithData:data];
        
        if (self.isGIF) {
            self.gifImage = [VVeboImage gifWithData:data];
            self.image = [self.gifImage nextImage];
            toFrame = [[self class] getImageViewFrameWithImage:self.image
                                                 containerSize:self.contentView.size];
            self.gifImageView.frame = toFrame;
            self.photoImageView.image = self.image;
        }else {
            self.image = [UIImage sd_imageWithData:data];
            toFrame = [[self class] getImageViewFrameWithImage:self.image
                                                 containerSize:self.contentView.size];
            self.photoImageView.image = self.image;
            [self scanQRCode];
        }
        
        self.photoPlaceholderImageView.frame = fromFrame;
        self.photoImageView.frame = fromFrame;
        self.photoImageView.hidden = NO;
        self.photoImageView.alpha = 0;
        [UIView animateWithDuration:.22 customTimingFunction:CustomTimingFunctionSineOut delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animation:^{
            self.photoPlaceholderImageView.frame = toFrame;
            self.photoImageView.frame = toFrame;
        } completion:^(BOOL finished) {
            self.photoPlaceholderImageView.hidden = YES;
            if (self.isGIF) {
                self.gifImageView.image = self.gifImage;
                self.gifImageView.hidden = NO;
                self.photoImageView.hidden = YES;
            }
            self.photoZoomingScrollView.contentSize = self.photoImageView.size;
            self.status = FRPhotoBrowserCellStatusDownloadSuccess;
            if (self.delegate && [self.delegate respondsToSelector:@selector(showCompleteWithModel:)]) {
                [self.delegate showCompleteWithModel:self.model];
            }

        }];
        [UIView animateWithDuration:.05 delay:.02 options:0 animations:^{
            self.photoImageView.alpha = 1;
        } completion:nil];
    }else {
        //图片还没下载
        CGRect fromFrame = CGRectZero;
        CGRect toFrame = CGRectZero;
        if (self.model.originalFrame) {
            CGRect originalFrame = self.model.originalFrame.CGRectValue;
            fromFrame = [self.photoZoomingScrollView convertRect:originalFrame
                                                        fromView:nil];
            toFrame = CGRectMake(self.contentView.width/2 - originalFrame.size.width/2, self.contentView.height/2 - originalFrame.size.height/2, originalFrame.size.width, originalFrame.size.height);
        }else {
            fromFrame = CGRectMake(self.width/2, self.height/2, 0, 0);
            toFrame = CGRectMake(self.contentView.width/2, self.contentView.height/2, 0, 0);
        }
        self.photoPlaceholderImageView.image = self.model.placeholderImage;
        self.photoPlaceholderImageView.hidden = NO;
        self.photoPlaceholderImageView.frame = toFrame;
        self.photoPlaceholderImageView.frame = toFrame;
        
        CAAnimationGroup * undownloadPhotoPlaceholderImageViewShowGroupAnimation = [CAAnimationGroup animation];
        undownloadPhotoPlaceholderImageViewShowGroupAnimation.removedOnCompletion = NO;
        undownloadPhotoPlaceholderImageViewShowGroupAnimation.delegate = self;
        undownloadPhotoPlaceholderImageViewShowGroupAnimation.duration = kAnimationDuration;
        undownloadPhotoPlaceholderImageViewShowGroupAnimation.timingFunction = [[self class] getAnimationTimingFunction];
        undownloadPhotoPlaceholderImageViewShowGroupAnimation.fillMode = kCAFillModeBoth;
        
        CABasicAnimation * undownloadPhotoPlaceholderImageViewPositionChangeAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        undownloadPhotoPlaceholderImageViewPositionChangeAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(fromFrame.origin.x + fromFrame.size.width/2, fromFrame.origin.y + fromFrame.size.height/2)];
        undownloadPhotoPlaceholderImageViewPositionChangeAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(toFrame.origin.x + toFrame.size.width/2, toFrame.origin.y + toFrame.size.height/2)];
        
        CABasicAnimation * undownloadPhotoPlaceholderImageViewBoundsChangeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        undownloadPhotoPlaceholderImageViewBoundsChangeAnimation.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, fromFrame.size.width, fromFrame.size.height)];
        undownloadPhotoPlaceholderImageViewBoundsChangeAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, toFrame.size.width, toFrame.size.height)];
        
        undownloadPhotoPlaceholderImageViewShowGroupAnimation.animations = @[undownloadPhotoPlaceholderImageViewPositionChangeAnimation, undownloadPhotoPlaceholderImageViewBoundsChangeAnimation];
        [self.photoPlaceholderImageView.layer addAnimation:undownloadPhotoPlaceholderImageViewShowGroupAnimation forKey:kUndownloadShowImagePhotoPlaceholderImageViewGroupAnimationKey];
    }
}

- (void)hide {
    if (self.status == FRPhotoBrowserCellStatusDownloadSuccess && self.model.originalFrame) {
        if (self.photoZoomingScrollView.zoomScale != kMinZoomScale) {
            [self.photoZoomingScrollView setZoomScale:kMinZoomScale
                                             animated:NO];
        }
        CGRect fromFrame = CGRectZero;
        if (self.isGIF) {
            fromFrame = self.gifImageView.frame;
            self.photoImageView.image = self.image;
            self.photoImageView.hidden = NO;
            self.gifImageView.hidden = YES;
        }else {
            fromFrame = self.photoImageView.frame;
        }
        CGRect toFrame = [self.photoZoomingScrollView convertRect:self.model.originalFrame.CGRectValue fromView:nil];
        
        self.photoImageView.layer.opacity = 0.f;
        self.photoImageView.frame = toFrame;
        self.photoPlaceholderImageView.frame = toFrame;
        self.photoPlaceholderImageView.image = self.model.placeholderImage;
        self.photoPlaceholderImageView.hidden = NO;
        
        //Photo place holder image view hide group animations
        CAAnimationGroup * photoPlaceholderImageViewHideGroupAnimation = [CAAnimationGroup animation];
        photoPlaceholderImageViewHideGroupAnimation.removedOnCompletion = NO;
        photoPlaceholderImageViewHideGroupAnimation.delegate = self;
        photoPlaceholderImageViewHideGroupAnimation.duration = kAnimationDuration;
        photoPlaceholderImageViewHideGroupAnimation.timingFunction = [[self class] getAnimationTimingFunction];
        photoPlaceholderImageViewHideGroupAnimation.fillMode = kCAFillModeBoth;
        
        CABasicAnimation * photoPlaceholderImageViewPositionChangeAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        photoPlaceholderImageViewPositionChangeAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(fromFrame.origin.x + fromFrame.size.width/2, fromFrame.origin.y + fromFrame.size.height/2)];
        photoPlaceholderImageViewPositionChangeAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(toFrame.origin.x + toFrame.size.width/2, toFrame.origin.y + toFrame.size.height/2)];
        
        CABasicAnimation * photoPlaceholderImageViewBoundsChangeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        photoPlaceholderImageViewBoundsChangeAnimation.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, fromFrame.size.width, fromFrame.size.height)];
        photoPlaceholderImageViewBoundsChangeAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, toFrame.size.width, toFrame.size.height)];
        
        photoPlaceholderImageViewHideGroupAnimation.animations = @[photoPlaceholderImageViewPositionChangeAnimation, photoPlaceholderImageViewBoundsChangeAnimation];
        [self.photoPlaceholderImageView.layer addAnimation:photoPlaceholderImageViewHideGroupAnimation
                                                    forKey:kHideImagePhotoPlaceholderImageViewGroupAnimationKey];
        
        //Photo image view hide group animations
        CAAnimationGroup * photoImageViewHideGroupAnimation = [CAAnimationGroup animation];
        photoImageViewHideGroupAnimation.removedOnCompletion = NO;
        photoImageViewHideGroupAnimation.delegate = self;
        photoImageViewHideGroupAnimation.duration = kAnimationDuration;
        photoImageViewHideGroupAnimation.timingFunction = [[self class] getAnimationTimingFunction];
        photoImageViewHideGroupAnimation.fillMode = kCAFillModeBoth;
        
        CABasicAnimation * photoImageViewPositionChangeAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        photoImageViewPositionChangeAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(fromFrame.origin.x + fromFrame.size.width/2, fromFrame.origin.y + fromFrame.size.height/2)];
        photoImageViewPositionChangeAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(toFrame.origin.x + toFrame.size.width/2, toFrame.origin.y + toFrame.size.height/2)];
        
        CABasicAnimation * photoImageViewBoundsChangeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        photoImageViewBoundsChangeAnimation.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, fromFrame.size.width, fromFrame.size.height)];
        photoImageViewBoundsChangeAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, toFrame.size.width, toFrame.size.height)];
        
        CABasicAnimation * photoImageViewAlphaChangeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        photoImageViewAlphaChangeAnimation.fromValue = [NSNumber numberWithDouble:1.f];
        photoImageViewAlphaChangeAnimation.toValue = [NSNumber numberWithDouble:0.f];
        
        photoImageViewHideGroupAnimation.animations = @[photoImageViewPositionChangeAnimation, photoImageViewBoundsChangeAnimation, photoImageViewAlphaChangeAnimation];
        [self.photoImageView.layer addAnimation:photoImageViewHideGroupAnimation
                                         forKey:kHideImagePhotoImageViewGroupAnimationKey];
    }else {
        self.contentView.layer.opacity = 0.f;
        CABasicAnimation * hideContentViewAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        hideContentViewAnimation.removedOnCompletion = NO;
        hideContentViewAnimation.delegate = self;
        hideContentViewAnimation.duration = kAnimationDuration;
        hideContentViewAnimation.timingFunction = [[self class] getAnimationTimingFunction];
        hideContentViewAnimation.fillMode = kCAFillModeBoth;
        hideContentViewAnimation.fromValue = [NSNumber numberWithDouble:1.f];
        hideContentViewAnimation.toValue = [NSNumber numberWithDouble:0.f];
        [self.contentView.layer addAnimation:hideContentViewAnimation
                                      forKey:kHideContentViewAnimation];
    }
}

- (void)savePhoto {
    switch (self.status) {
        case FRPhotoBrowserCellStatusDownloading:{
            TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"图片正在下载，请稍后再试", nil)
                                                                                    message:nil
                                                                              preferredType:TTThemedAlertControllerTypeAlert];
            [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
            [alert showFrom:self.viewController animated:YES];
        }
            return;
        case FRPhotoBrowserCellStatusDownloadFail:
        case FRPhotoBrowserCellStatusInitial: {
            TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"图片下载失败", nil)
                                                                                    message:nil
                                                                              preferredType:TTThemedAlertControllerTypeAlert];
            [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
            [alert showFrom:self.viewController animated:YES];
        }
            return;
        case FRPhotoBrowserCellStatusDownloadSuccess: {
            self.assetsLbr = nil;
            self.assetsLbr = [[ALAssetsLibrary alloc] init];
            
            if (_isGIF && self.gifImage && self.gifImage.data) {
                [self.assetsLbr tt_saveImageData:self.gifImage.data];
            } else {
                [self.assetsLbr tt_saveImage:self.image];
            }
        }
            return;
    }
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (anim == [self.photoPlaceholderImageView.layer animationForKey:kShowImagePhotoPlaceholderImageViewGroupAnimationKey]) {
        self.photoPlaceholderImageView.hidden = YES;
        [self.photoPlaceholderImageView.layer removeAnimationForKey:kShowImagePhotoPlaceholderImageViewGroupAnimationKey];
        [self.photoImageView.layer removeAnimationForKey:kShowImagePhotoImageViewGroupAnimationKey];
        
        if (self.isGIF) {
            self.gifImageView.image = self.gifImage;
            self.gifImageView.hidden = NO;
            self.photoImageView.hidden = YES;
        }
        self.photoZoomingScrollView.contentSize = self.photoImageView.size;
        self.status = FRPhotoBrowserCellStatusDownloadSuccess;
        if (self.delegate && [self.delegate respondsToSelector:@selector(showCompleteWithModel:)]) {
            [self.delegate showCompleteWithModel:self.model];
        }
    }else if (anim == [self.photoPlaceholderImageView.layer animationForKey:kUndownloadShowImagePhotoPlaceholderImageViewGroupAnimationKey]) {
        [self.photoPlaceholderImageView.layer removeAnimationForKey:kUndownloadShowImagePhotoPlaceholderImageViewGroupAnimationKey];
        if (self.delegate && [self.delegate respondsToSelector:@selector(showCompleteWithModel:)]) {
            [self.delegate showCompleteWithModel:self.model];
        }
        //download image
        [self downloadImageWithIndex:self.currentDownloadImageURLIndex];
    }else if (anim == [self.photoPlaceholderImageView.layer animationForKey:kDownloadFinishShowImagePhotoPlaceholderImageViewGroupAnimation]) {
        self.photoPlaceholderImageView.hidden = YES;
        [self.photoPlaceholderImageView.layer removeAnimationForKey:kDownloadFinishShowImagePhotoPlaceholderImageViewGroupAnimation];
        [self.photoImageView.layer removeAnimationForKey:kDownloadFinishShowImagePhotoImageViewGroupAnimation];
        
        if (self.isGIF) {
            self.gifImageView.image = self.gifImage;
            self.gifImageView.hidden = NO;
            self.photoImageView.hidden = YES;
        }
        self.photoZoomingScrollView.contentSize = self.photoImageView.size;
        self.status = FRPhotoBrowserCellStatusDownloadSuccess;
    }else if (anim == [self.photoPlaceholderImageView.layer animationForKey:kHideImagePhotoPlaceholderImageViewGroupAnimationKey]) {
        [self.photoPlaceholderImageView.layer removeAnimationForKey:kHideImagePhotoPlaceholderImageViewGroupAnimationKey];
        self.photoImageView.hidden = YES;
        [self.photoImageView.layer removeAnimationForKey:kHideImagePhotoImageViewGroupAnimationKey];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(hideCompleteWithModel:)]) {
            [self.delegate hideCompleteWithModel:self.model];
        }
    }else if (anim == [self.photoZoomingScrollView.layer animationForKey:kHideContentViewAnimation]) {
        [self.contentView.layer removeAnimationForKey:kHideContentViewAnimation];
        if (self.delegate && [self.delegate respondsToSelector:@selector(hideCompleteWithModel:)]) {
            [self.delegate hideCompleteWithModel:self.model];
        }
    }
}

#pragma - mark QRCode
- (void)scanQRCode {
    self.longPressGestureRecognizer.enabled = [KitchenMgr getBOOL:kKCUGCBrowserQRCode];
    if (![KitchenMgr getBOOL:kKCUGCBrowserQRCode]) {
        return;
    }
    
    if (self.isGIF || self.image == nil) {
        self.qrURL = nil;
    } else {
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyLow }];
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:self.image.CGImage]];
        if (features.count >=1) {
            /**结果对象 */
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            self.qrURL = [NSURL URLWithString:scannedResult];
        }
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan
        && self.qrURL != nil) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil]];
        __block NSURL *schema = self.qrURL;
        WeakSelf;
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"识别图中二维码", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              StrongSelf;
                                                              FRUgcThreadLinkV1ConvertRequestModel *requestModel = [[FRUgcThreadLinkV1ConvertRequestModel alloc] init];
                                                              requestModel.url = schema.absoluteString;
                                                              [FRRequestManager requestModel:requestModel callBackWithMonitor:^(NSError *error, FRUgcThreadLinkV1ConvertResponseModel *responseModel, FRForumMonitorModel *monitorModel) {
                                                                  if (error == nil && responseModel != nil && responseModel.url_info.url != nil) {
                                                                      schema = [NSURL URLWithString:responseModel.url_info.url];
                                                                  }
                                                                  BOOL dismiss = NO;
                                                                  if ([[TTRoute sharedRoute] canOpenURL:schema]) {
                                                                      [[TTRoute sharedRoute] openURLByPushViewController:schema];
                                                                      dismiss = YES;
                                                                  } else {
                                                                      NSString *linkStr = schema.absoluteString;
                                                                      if (!isEmptyString(linkStr)) {
                                                                          dismiss = YES;
                                                                          [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://webview"] userInfo:TTRouteUserInfoWithDict(@{@"url":linkStr})];
                                                                      }
                                                                  }
                                                                  if (dismiss) {
                                                                      if (self.delegate && [self.delegate respondsToSelector:@selector(tapPhotoBrowserCell:)]) {
                                                                          self.hidden = YES;
                                                                          [self.delegate tapPhotoBrowserCell:self];
                                                                      }
                                                                  }
                                                              }];
                                                          }]];
        
        alertController.popoverPresentationController.sourceView = self;
        alertController.popoverPresentationController.sourceRect = self.bounds;
        
        UIViewController *topVC = [TTUIResponderHelper topViewControllerFor:self];
        [topVC presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - Utils

+ (NSString *)getImageURLOfDiskExistsWithImageInfosModel:(FRImageInfoModel *)imageInfosModel {

    NSURL *URL = [[TTUGCPodBridge sharedInstance] ugcImageURLWithString:imageInfosModel.url];
    NSString * cacheKey = [[SDWebImageManager sharedManager] cacheKeyForURL:URL];
    BOOL isExist = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:cacheKey];
    
    return isExist? cacheKey: nil;
}

+ (BOOL)isGIFWithData:(NSData *)data {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (imageSource) {
        CFStringRef imageSourceContainerType = CGImageSourceGetType(imageSource);
        CFRelease(imageSource);
        return UTTypeConformsTo(imageSourceContainerType, kUTTypeGIF);
    } else {
        return NO;
    }
}

+ (CGRect)getImageViewFrameWithImage:(UIImage *)image containerSize:(CGSize)containerSize {
    if(nil == image){
        return CGRectMake(containerSize.width/2, containerSize.height/2, 0, 0);
    } else {
        CGFloat imageWidth = image.size.width;
        CGFloat imageHeight = image.size.height;
        
        CGFloat maxWidth = containerSize.width;
        CGFloat maxHeight = containerSize.height;
        
        CGFloat imgViewWidth;
        CGFloat imgViewHeight;
        
        //默认 imageHeight >= imageWidth * 3 的图片为细长图
        if (imageWidth/imageHeight > maxWidth/maxHeight || imageHeight >= imageWidth * 3) {
            //图片宽高比大于容器宽高比 或者 图片是细长图，宽度按容器宽度处理，高度等比缩放
            imgViewWidth = maxWidth;
            imgViewHeight = maxWidth * imageHeight / imageWidth;
            if (imageHeight >= imageWidth*3) {
                //细长图，图片置顶显示
                return CGRectMake(0, 0, imgViewWidth, imgViewHeight);
            }else {
                //图片宽高比大于容器宽高比，图片居中显示
                return CGRectMake(0, (containerSize.height - imgViewHeight)/2, imgViewWidth, imgViewHeight);
            }
        } else {
            imgViewHeight = maxHeight;
            imgViewWidth = imageWidth / imageHeight * maxHeight;
            return CGRectMake((containerSize.width - imgViewWidth)/2, 0, imgViewWidth, imgViewHeight);
        }
    }
}

+ (CGRect)getImageViewFrameWithPlaceholderImageSize:(CGSize)placeholderImageSize containerSize:(CGSize)containerSize {
    if (placeholderImageSize.width <= containerSize.width && placeholderImageSize.height <= containerSize.height) {
        return CGRectMake((containerSize.width - placeholderImageSize.width)/2, (containerSize.height - placeholderImageSize.height)/2, placeholderImageSize.width, placeholderImageSize.height);
    }
    
    CGSize resultSize = CGSizeZero;
    if (placeholderImageSize.width/placeholderImageSize.height > containerSize.width/containerSize.height) {
        resultSize.width = containerSize.width;
        resultSize.height = resultSize.width * placeholderImageSize.height / placeholderImageSize.width;
        return CGRectMake(0, (containerSize.height - resultSize.height)/2, resultSize.width, resultSize.height);
    }else {
        resultSize.height = containerSize.height;
        resultSize.width = resultSize.height * placeholderImageSize.width / placeholderImageSize.height;
        return CGRectMake((containerSize.width - resultSize.width)/2, 0, resultSize.width, resultSize.height);
    }
}

+ (CAMediaTimingFunction *)getAnimationTimingFunction {
    return [CAMediaTimingFunction functionWithControlPoints:0.14 :1 :0.34 :1];
}

@end
