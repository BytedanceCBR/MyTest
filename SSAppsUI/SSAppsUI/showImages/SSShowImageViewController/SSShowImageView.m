//
//  SSShowImageView.m
//  Article
//
//  Created by Zhang Leonardo on 12-11-12.
//
//

#import "SSShowImageView.h"
#import "SSLazyImageView.h"
#import "SSSimpleCache.h"
#import "MBProgressHUD.h"
//#import "UIDevice-Hardware.h"
#import "ALAssetsLibrary+SSAddition.h"

#define MinZoomScale 1.f
#define MaxZoomScale 1.5f

#define saveButtonRightPadding  20.f
#define saveButtonBottomPadding 20.f

@interface SSShowImageView()<UIScrollViewDelegate, SSLazyImageViewDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, retain)UIScrollView * imageContentScrollView;
@property(nonatomic, retain)SSLazyImageView * largeImageView;
@property(nonatomic, retain)UITapGestureRecognizer * tapGestureRecognizer;
@property(nonatomic, retain)UITapGestureRecognizer * tapTwiceGestureRecognizer;
@property(nonatomic, retain)MBProgressHUD * progressView;
@property(nonatomic, retain)MBProgressHUD * savedTipView;
@property(nonatomic, retain)UIButton * saveButton;
@property(nonatomic, retain)UIImage * imageData;
@property(nonatomic, retain)ALAssetsLibrary * assetsLbr;

@end

@implementation SSShowImageView

@synthesize imageContentScrollView = _imageContentScrollView;
@synthesize largeImageView = _largeImageView;
@synthesize largeImageURLString = _largeImageURLString;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize tapTwiceGestureRecognizer = _tapTwiceGestureRecognizer;
@synthesize delegate = _delegate;
@synthesize progressView = _progressView;
@synthesize saveButton = _saveButton;
@synthesize savedTipView = _savedTipView;
@synthesize imageData = _imageData;
@synthesize imageInfosModel = _imageInfosModel;

- (void)dealloc
{
    self.assetsLbr = nil;
    self.delegate = nil;
    _tapGestureRecognizer.delegate = nil;
    [self removeGestureRecognizer:_tapGestureRecognizer];
    [self removeGestureRecognizer:_tapTwiceGestureRecognizer];
    self.tapGestureRecognizer = nil;
    self.largeImageView = nil;
    self.imageContentScrollView = nil;
    self.largeImageURLString = nil;
    self.tapTwiceGestureRecognizer = nil;
    self.progressView = nil;
    self.saveButton = nil;
    self.savedTipView = nil;
    self.imageData = nil;
    self.imageInfosModel = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildViews];
        [self addGesture];
    }
    return self;
}

#pragma mark -- target

- (void)saveButtonClicked
{
    NSData * data = nil;
    if ([_largeImageURLString length] > 0) {
        data = [[SSSimpleCache sharedCache] dataForUrl:_largeImageURLString];
    }
    if (data == nil && _imageInfosModel != nil) {
        data = [[SSSimpleCache sharedCache] dataForImageInfosModel:_imageInfosModel];
    }
    
    if (data == nil) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                         message:@"图片正在下载，请稍后再试"
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"确定", nil];
        [alert show];
        [alert release];
        
        return;
    }
 
    _savedTipView.labelText = @"图片存储中";
    [_savedTipView show:NO];
    [_savedTipView hide:NO afterDelay:2.f];
    

    self.assetsLbr = nil;
    self.assetsLbr = [[[ALAssetsLibrary alloc] init] autorelease];

    [_assetsLbr saveImg:[UIImage imageWithData:data]];

    trackEvent([SSCommon appName], @"image", @"download");

}

#pragma mark -- private

- (void)addGesture
{
    self.tapTwiceGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)] autorelease];
    _tapTwiceGestureRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:_tapTwiceGestureRecognizer];
    
    self.tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onceTapped:)] autorelease];
    _tapGestureRecognizer.numberOfTapsRequired = 1;
    _tapGestureRecognizer.delegate = self;
    [_tapGestureRecognizer requireGestureRecognizerToFail:_tapTwiceGestureRecognizer];
    [self addGestureRecognizer:_tapGestureRecognizer];
}


- (void)buildViews
{
    self.imageContentScrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
    _imageContentScrollView.backgroundColor = [UIColor blackColor];

    [self refreshContentSize];
    _imageContentScrollView.delegate = self;
    _imageContentScrollView.userInteractionEnabled = YES;
    _imageContentScrollView.minimumZoomScale = MinZoomScale;
    _imageContentScrollView.maximumZoomScale = MaxZoomScale;
    _imageContentScrollView.multipleTouchEnabled = YES;
    
    [self addSubview:_imageContentScrollView];
    
    self.largeImageView = [[[SSLazyImageView alloc] initWithFrame:CGRectZero] autorelease];
    _largeImageView.delegate = self;
    _largeImageView.backgroundColor = [UIColor blackColor];
    [_imageContentScrollView addSubview:_largeImageView];
    
    self.progressView = [[[MBProgressHUD alloc] initWithView:self] autorelease];
    _progressView.mode = MBProgressHUDModeDeterminate;
    _progressView.labelText = @"Loading";
    [self addSubview:_progressView];
    
    self.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_saveButton addTarget:self action:@selector(saveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_saveButton setImage:[UIImage resourceImageNamed:@"downToPic.png"] forState:UIControlStateNormal];
    [_saveButton setImage:[UIImage resourceImageNamed:@"downToPic_press.png"] forState:UIControlStateSelected];
    float saveButtonWidth = 60.f;
    float saveButtonHeight = 44.f;
    _saveButton.frame = CGRectMake(self.frame.size.width - saveButtonWidth - saveButtonRightPadding, self.frame.size.height - saveButtonHeight - saveButtonBottomPadding, saveButtonWidth, saveButtonHeight);
    _saveButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;

    [self addSubview:_saveButton];
    
    self.savedTipView = [[[MBProgressHUD alloc] initWithView:self] autorelease];
    [self addSubview:_savedTipView];
}

- (void)refreshUI
{
    _imageContentScrollView.frame = self.bounds;

    [self refreshLargeImageViewOrigin];
    [self refreshContentSize];
    
    [self refreshLargeImageViewSizeWithImage:_imageData];
    [self refreshLargeImageViewOrigin];
}

- (void)refreshContentSize
{
    if (_imageData == nil) {
        return;
    }
    float imgW = _imageData.size.width;
    float imgH = _imageData.size.height;
    
    float showW = self.frame.size.width;
    float showH = showW * imgH / imgW;
    
    float contentSizeH = MAX(showH, self.bounds.size.height);
    float contentSizeW = MAX(showW, self.bounds.size.width);
    _imageContentScrollView.contentSize = CGSizeMake(contentSizeW, contentSizeH);

}

- (void)refreshLargeImageViewSizeWithImage:(UIImage *)img
{
    if(img == nil){
        _largeImageView.frame = CGRectZero;
    }
    else {

        CGRect resizeRect = CGRectMake(0, 0, _imageContentScrollView.bounds.size.width, (_imageContentScrollView.bounds.size.width * img.size.height) / img.size.width);
        _largeImageView.frame = resizeRect;
    }
}

- (void)refreshLargeImageViewOrigin
{    
    float imageViewW = _largeImageView.frame.size.width;
    float parentViewW = _imageContentScrollView.frame.size.width;
    
    float imageViewH = _largeImageView.frame.size.height;
    float parentViewH = _imageContentScrollView.frame.size.height;
    
    float centerW = 0.f;
    float centerH = 0.f;
    
    if (imageViewW <= parentViewW) {
        centerW = parentViewW / 2.f;
    }
    else {
        centerW = imageViewW / 2.f;
    }

    if (imageViewH <= parentViewH) {
        centerH = parentViewH / 2.f;
    }
    else {
        centerH = imageViewH / 2.f;
    }
    _largeImageView.center = CGPointMake(centerW, centerH);
    
}

- (void)loadFinishedImageData:(NSData *)data
{
    self.imageData = [UIImage imageWithData:data];
    [self refreshLargeImageViewSizeWithImage:_imageData];
    [self refreshLargeImageViewOrigin];
    [_progressView hide:YES];
    
    [self refreshContentSize];
}

#pragma mark -- protected

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self trySSLayoutSubviews];
}

- (void)ssLayoutSubviews
{
    [super ssLayoutSubviews];
    [self refreshUI];
}

#pragma mark -- getter & setter

- (void)setLargeImageURLString:(NSString *)largeImageURLString
{
    if (_largeImageURLString != largeImageURLString) {
        [largeImageURLString retain];
        [_largeImageURLString release];
        _largeImageURLString = largeImageURLString;

        
        
        NSData * data = [[SSSimpleCache sharedCache] dataForUrl:_largeImageURLString];
        self.imageData = [UIImage imageWithData:data];
        [_largeImageView setNetImageUrl:_largeImageURLString];
        
        if (data != nil) {
            [self loadFinishedImageData:data];
        }
        else {
            [_progressView show:YES];
        }
    
    }
}

- (void)setImageInfosModel:(SSImageInfosModel *)imageInfosModel
{
    if (imageInfosModel != _imageInfosModel) {
        [imageInfosModel retain];
        [_imageInfosModel release];
        _imageInfosModel = imageInfosModel;

        NSData * data = [[SSSimpleCache sharedCache] dataForImageInfosModel:_imageInfosModel];
        self.imageData = [UIImage imageWithData:data];
        [_largeImageView setNetImageInfosModel:_imageInfosModel];
        
        if (data != nil) {
            [self loadFinishedImageData:data];
        }
        else {
            [_progressView show:YES];
        }
    }
}

//- (void)setLargeImageURLWithHeaders:(NSArray *)largeImageURLWithHeaders
//{
//    if (_largeImageURLWithHeaders != largeImageURLWithHeaders) {
//        [largeImageURLWithHeaders retain];
//        [_largeImageURLWithHeaders release];
//        _largeImageURLWithHeaders = largeImageURLWithHeaders;
//
//        
//        
//        NSData * data = [[SSSimpleCache sharedCache] dataForURLAndHeaders:largeImageURLWithHeaders];
//        self.imageData = [UIImage imageWithData:data];
//        [_largeImageView setNetImageURLAndHeaders:largeImageURLWithHeaders];
//        
//        if (data != nil) {
//            [self loadFinishedImageData:data];
//        }
//        else {
//            [_progressView show:YES];
//        }
//    }
//}

#pragma mark -- UIScrollViewDelegate


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    [self refreshLargeImageViewOrigin];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _largeImageView;
}


#pragma mark -- SSLazyImageViewDelegate

- (void)lazyImageView:(SSLazyImageView *)imageView didDownloadImageData:(NSData *)data
{
    [self loadFinishedImageData:data];
    
}

- (void)lazyImageView:(SSLazyImageView *)imageView requestFailed:(NSError *)error
{
    _savedTipView.labelText = @"下载失败，请稍后重试";
    [_savedTipView show:NO];
    [_savedTipView hide:NO afterDelay:2.f];
}

- (void)lazyImageView:(SSLazyImageView *)imageView requestProgress:(float)progress
{
    [_progressView setProgress:progress];
}


#pragma mark -- gesture delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.superview != nil) {
        if ([touch.view isKindOfClass:[UIButton class]]) {
            return NO;
        }
    }
    return YES;

}

- (void)onceTapped:(UITapGestureRecognizer *)recognizer
{
    if ([_delegate respondsToSelector:@selector(showImageViewOnceTap:)]) {
        [_delegate performSelector:@selector(showImageViewOnceTap:) withObject:self];
    }
}   

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer
{
    [UIView animateWithDuration:0.3f animations:^{
        _imageContentScrollView.zoomScale = _imageContentScrollView.zoomScale == MaxZoomScale ? MinZoomScale : MaxZoomScale;
        [self refreshLargeImageViewOrigin];
    }];
    
    
    if ([_delegate respondsToSelector:@selector(showImageViewDoubleTap:)]) {
        [_delegate performSelector:@selector(showImageViewDoubleTap:) withObject:self];
    }

}

#pragma mark -- public

- (void)resetZoom
{
    _imageContentScrollView.zoomScale = MinZoomScale;
}

@end
