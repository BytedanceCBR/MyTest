//
//  TTImagePreviewPhotoView.m
//  Article
//
//  Created by SongChai on 2017/4/10.
//
//

#import "TTImagePreviewPhotoView.h"
#import "TTImagePickerManager.h"
#import "UIImage+GIF.h"
#import "UIViewAdditions.h"
#import "TTImagePickerLoadingView.h"
#import "TTBaseMacro.h"
#import "TTImagePreviewViewController.h"
#import "FLAnimatedImage.h"

@interface TTImagePreviewPhotoView()

@property (nonatomic,strong)TTImagePickerLoadingView *loadingView;

@end

@implementation TTImagePreviewPhotoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(10, 0, self.width - 20, self.height);
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.backgroundColor = [UIColor blackColor];
        [self addSubview:_scrollView];
        
        _imageContainerView = [[UIView alloc] init];
        _imageContainerView.clipsToBounds = YES;
        _imageContainerView.contentMode = UIViewContentModeScaleAspectFill;
        [_scrollView addSubview:_imageContainerView];
        
        _imageView = [[FLAnimatedImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [_imageContainerView addSubview:_imageView];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:tap1];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        tap2.numberOfTapsRequired = 2;
        [tap1 requireGestureRecognizerToFail:tap2];
        [self addGestureRecognizer:tap2];
        
      
    }
    return self;
}


- (void)setModel:(TTAssetModel *)model {
    _model = model;
    [_scrollView setZoomScale:1.0 animated:NO];
    
    
    if (model.type != TTAssetModelMediaTypePhotoGif) {
        if (_model.cacheImage) {
            self.imageView.image = _model.cacheImage;
            [self resizeSubviews];
          
        } else {
            /// 应对icloud
            self.imageView.image = _model.thumbImage;
        }
    } else {
        self.imageView.image = nil;
        /// 应对icloud
        self.imageView.image = _model.thumbImage;
    }
}

- (void)_initLoadingView
{
    self.myVC.loadingView = nil;
    _loadingView = nil;
    _loadingView = [[TTImagePickerLoadingView alloc]initWithFrame:CGRectMake(12, KScreenHeight - 32 -12, 32, 32)];
    _loadingView.inset = 3;
    _loadingView.isShowFailedLabel = YES;
    WeakSelf;
    _loadingView.retry = ^{
        StrongSelf;
        //重新开始加载图片
        [self photoViewDidDisplay];
    };
    self.myVC.loadingView = _loadingView;
    self.myVC.loadingView.hidden = YES;
    
}

- (void)photoViewDidDisplay {
    
    [self _initLoadingView];
    
    if (_model.cacheImage) {
        return;
    }
    
    //[[TTImagePickerManager manager].icloudDownloader cancelSingleIcloud];
    NSString *requestAssetID = _model.assetID;

    if (_model.type == TTAssetModelMediaTypePhotoGif) {

        //获取gif图片
        [[TTImagePickerManager manager] getOriginalPhotoDataWithAsset:_model.asset completion:^(NSData *data, BOOL isDegraded) {
            if (requestAssetID != _model.assetID) {
                return ;
            }
            if (!data) {
                _loadingView.isFailed = YES;
                return ;
            }
            
            if (!isDegraded ) {
                self.imageView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
                [self resizeSubviews];
            }
            if (self.imageView.animatedImage && !_model.thumbImage) {
                _model.thumbImage = self.imageView.animatedImage.posterImage;
            }
            
        } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            _loadingView.progress = progress;
        } isSingleTask:YES];
    }else{
        
        
        [[TTImagePickerManager manager] getPhotoWithAsset:_model.asset photoWidth:TTImagePickerImageWidthDefault completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (requestAssetID != _model.assetID) {
                return ;
            }
            if (isDegraded &&  !self.imageView.image && photo) {
                self.imageView.image = photo;
                [self resizeSubviews];

            }
            
            if (!isDegraded ) {
                _model.cacheImage = photo;
                
                if (photo) {
                    self.imageView.image = photo;
                    [self resizeSubviews];
                }else{
                    
                    _loadingView.isFailed = YES;
                }
            }
            if (self.imageView.image && !_model.thumbImage) {
                _model.thumbImage = self.imageView.image;
            }
            
            
        } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            
            _loadingView.progress = progress;
            NSLog(@"%f",progress);
            
        } isIcloudEabled:YES isSingleTask:YES];

    
    }
 
}



- (void)recoverSubviews {
    [_scrollView setZoomScale:1.0 animated:NO];
    [self resizeSubviews];
}

- (void)resizeSubviews {
    _imageContainerView.origin = CGPointZero;
    _imageContainerView.width = self.scrollView.width;
    
    UIImage *image = _imageView.image;
    if (image.size.height / image.size.width > self.height / self.scrollView.width) {
        _imageContainerView.height = floor(image.size.height / (image.size.width / self.scrollView.width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.scrollView.width;
        if (height < 1 || isnan(height)) height = self.height;
        height = floor(height);
        _imageContainerView.height = height;
        _imageContainerView.centerY = self.height / 2;
    }
    if (_imageContainerView.height > self.height && _imageContainerView.height - self.height <= 1) {
        _imageContainerView.height = self.height;
    }
    CGFloat contentSizeH = MAX(_imageContainerView.height, self.height);
    _scrollView.contentSize = CGSizeMake(self.scrollView.width, contentSizeH);
    [_scrollView scrollRectToVisible:self.bounds animated:NO];
    _scrollView.alwaysBounceVertical = _imageContainerView.height <= self.height ? NO : YES;
    _imageView.frame = _imageContainerView.bounds;
    [_imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
}

#pragma mark - UITapGestureRecognizer Event

- (void)doubleTap:(UITapGestureRecognizer *)tap {
    if (_scrollView.zoomScale > 1.0) {
        _scrollView.contentInset = UIEdgeInsetsZero;
        [_scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [tap locationInView:self.imageView];
        CGFloat newZoomScale = _scrollView.maximumZoomScale;
        CGFloat xsize = self.frame.size.width / newZoomScale;
        CGFloat ysize = self.frame.size.height / newZoomScale;
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    if (self.singleTapGestureBlock) {
        self.singleTapGestureBlock();
    }
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageContainerView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshImageContainerViewCenter];
}

#pragma mark - Private

- (void)refreshImageContainerViewCenter {
    CGFloat offsetX = (_scrollView.width > _scrollView.contentSize.width) ? ((_scrollView.width - _scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (_scrollView.height > _scrollView.contentSize.height) ? ((_scrollView.height - _scrollView.contentSize.height) * 0.5) : 0.0;
    self.imageContainerView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX, _scrollView.contentSize.height * 0.5 + offsetY);
}


@end
