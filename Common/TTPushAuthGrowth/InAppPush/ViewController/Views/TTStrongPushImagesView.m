//
//  TTStrongPushImagesView.m
//  Article
//
//  Created by liuzuopeng on 03/07/2017.
//
//

#import "TTStrongPushImagesView.h"
#import <BDWebImage/SDWebImageAdapter.h>


@interface TTStrongPushImagesView ()

@property (nonatomic, strong) SSThemedScrollView *imageScrollView;

@property (nonatomic, strong) NSMutableArray<SSThemedImageView *> *imageViewArray;

@end

@implementation TTStrongPushImagesView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setupCustomViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupCustomViews];
    }
    return self;
}

- (void)setupCustomViews
{
    [self addSubview:self.imageScrollView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self doLayoutImageViews];
}

- (void)doLayoutImageViews
{
    self.imageScrollView.frame = self.bounds;
    
    CGFloat imageWidth = CGRectGetWidth(self.imageScrollView.frame);
    CGFloat spacingInImages = [TTDeviceUIUtils tt_newPadding:6.f];
    NSInteger numberOfImages = [self.imageViewArray count];
    
    if (numberOfImages > 1) {
        imageWidth = (self.width - spacingInImages * (numberOfImages - 1)) / MIN(3, numberOfImages);
    }
    
    self.imageScrollView.contentSize = CGSizeMake(imageWidth * numberOfImages, self.height);
    
    [self.imageViewArray enumerateObjectsUsingBlock:^(SSThemedImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(idx * (imageWidth + spacingInImages), 0, imageWidth, self.height);
    }];
}

- (SSThemedImageView *)createImageView
{
    SSThemedImageView *aImageView = [[SSThemedImageView alloc] init];
    aImageView.enableNightCover = YES;
    aImageView.clipsToBounds = YES;
    aImageView.contentMode = UIViewContentModeScaleAspectFill;
    aImageView.backgroundColor = [UIColor clearColor];
    return aImageView;
}

#pragma mark - public methods

- (BOOL)containsImage
{
    return ([self.images count] > 0);
}

- (NSInteger)numberOfImages
{
    return [self.images count];
}

#pragma mark - setter/getter

- (void)setImages:(NSArray *)images
{
    if (_images == images) return;
    
    // remove old imageViews
    [_imageViewArray enumerateObjectsUsingBlock:^(SSThemedImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [_imageViewArray removeAllObjects];
    
    _images = images;
    
    // render new imageViews
    [images enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SSThemedImageView *aImageView = [self createImageView];
        
        if ([obj isKindOfClass:[UIImage class]]) {
            aImageView.image = (UIImage *)obj;
        } else if ([obj isKindOfClass:[NSString class]]) {
            NSURL *imageURL = [NSURL URLWithString:(NSString *)obj];
            if ([imageURL isFileURL]) {
                UIImage *image = [UIImage imageWithContentsOfFile:imageURL.absoluteString];
                aImageView.image = image;
            } else if ([imageURL.absoluteString hasPrefix:@"http"]) {
                [aImageView sda_setImageWithURL:(NSURL *)obj completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    
                }];
            } else {
                UIImage *image = [UIImage imageNamed:(NSString *)obj];
                aImageView.image = image;
            }
        } else if ([obj isKindOfClass:[NSURL class]]) {
            NSURL *imageURL = (NSURL *)obj;
            if ([imageURL isFileURL]) {
                UIImage *image = [UIImage imageWithContentsOfFile:imageURL.absoluteString];
                aImageView.image = image;
            } else if ([imageURL.absoluteString hasPrefix:@"http"]) {
                [aImageView sda_setImageWithURL:(NSURL *)obj completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    
                }];
            }
        }
        
        if (aImageView) {
            [self.imageScrollView addSubview:aImageView];
            [self.imageViewArray addObject:aImageView];
        }
    }];
}

- (NSMutableArray<SSThemedImageView *> *)imageViewArray
{
    if (!_imageViewArray) {
        _imageViewArray = [NSMutableArray arrayWithCapacity:5];
    }
    return _imageViewArray;
}

- (SSThemedScrollView *)imageScrollView
{
    if (!_imageScrollView) {
        _imageScrollView = [[SSThemedScrollView alloc] initWithFrame:CGRectZero];
        _imageScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _imageScrollView.scrollIndicatorInsets = _imageScrollView.contentInset;
        _imageScrollView.clipsToBounds = YES;
        _imageScrollView.bounces = NO;
        _imageScrollView.showsHorizontalScrollIndicator = NO;
        _imageScrollView.showsVerticalScrollIndicator = NO;
        _imageScrollView.backgroundColor = [UIColor clearColor];
    }
    return _imageScrollView;
}

@end
