//
//  ExploreMomentImageAlbum.m
//  Article
//
//  Created by SunJiangting on 15-1-23.
//
//
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>

#import "ExploreMomentImageAlbum.h"
#import "TTImageView.h"


#define kGIFLabelWidth 22
#define kGIFLabelHeight 13
#define kGIFLabelFont 10

@interface ExploreMomentImageAlbum ()
/// 用来复用
@property (nonatomic, strong) NSMutableArray * imageViews;
@property (nonatomic, strong) NSMutableArray * gifLabelPools;
@property (nonatomic, strong) NSMutableDictionary * indexGIFLabelMap;

@end

@implementation ExploreMomentImageAlbum

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageViews = [NSMutableArray arrayWithCapacity:9];
        self.gifLabelPools = [NSMutableArray arrayWithCapacity:9];
        self.indexGIFLabelMap = [NSMutableDictionary dictionaryWithCapacity:9];
    }
    return self;
}

- (void)setImages:(NSArray *)images {
    _images = [images copy];
    NSInteger imageCount = images.count, viewCount = self.imageViews.count;
    if (imageCount > viewCount) {
        // 如果view的数目小于图片的数目，则说明有一部分需要重新创建的view
        for (NSInteger i = viewCount; i < imageCount; i ++) {
            TTImageView *imageView = [[TTImageView alloc] init];
            if (_albumStyle == ExploreMomentImageAlbumUIStyleForward) {
                imageView.backgroundColorThemeKey = kColorBackground4;
            }
            else if (_albumStyle == ExploreMomentImageAlbumUIStyleMoment) {
                imageView.backgroundColorThemeKey = kColorBackground3;
            }
            imageView.userInteractionEnabled = YES;
            imageView.tag = 1000 + i;
            imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
            UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_imageTapActionFired:)]; 
            [imageView addGestureRecognizer:tapGesture];
            [self addSubview:imageView];
            [self.imageViews addObject:imageView];
        }
    }
    for (int i = 0; i < self.imageViews.count; i ++) {
        TTImageView *imageView = self.imageViews[i];
        imageView.hidden = i >= imageCount;
    }
    [self reloadImages];
}

- (void)reloadImages {
    NSArray *images = self.images;
    for (int i = 0; i < images.count; i ++) {
        CGRect frame = [self rectForImageAtIndex:i];
        TTImageView *imageView = self.imageViews[i];
        SSThemedLabel * tipLabel = nil;
        if (!imageView.placeHolderView) {
            tipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
            tipLabel.text = @"加载中...";
            tipLabel.font = [UIFont systemFontOfSize:10];
            tipLabel.numberOfLines = 1;
            [tipLabel sizeToFit];
            tipLabel.backgroundColor = [UIColor clearColor];
            tipLabel.textColorThemeKey = kColorText3;
        }
        
        TTImageInfosModel * imageModel = images[i];
        [imageView setImageWithModel:imageModel placeholderView:tipLabel ? tipLabel : imageView.placeHolderView];
        imageView.frame = frame;
        
        if (imageModel.imageFileType == TTImageFileTypeGIF) {
            [self showGIFLabelAtIndex:i];
        } else {
            [self hideGIFLabelAtIndex:i];
        }
    }
}

- (void)showGIFLabelAtIndex:(NSUInteger)index
{
    UILabel * gifLabel = [_indexGIFLabelMap objectForKey:@(index)];
    TTImageView *imageView = self.imageViews[index];
    if (gifLabel) {
        gifLabel.origin = CGPointMake((imageView.width) - kGIFLabelWidth, (imageView.height) - kGIFLabelHeight);
        return;
    }
    
    gifLabel = [_gifLabelPools lastObject];
    if (gifLabel) {
        [_gifLabelPools removeLastObject];
    } else {
        gifLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kGIFLabelWidth, kGIFLabelHeight)];
        [gifLabel setText:@"GIF"];
        [gifLabel setTextColor:[UIColor tt_themedColorForKey:kColorText4]];
        [gifLabel setFont:[UIFont systemFontOfSize:kGIFLabelFont]];
        [gifLabel setTextAlignment:NSTextAlignmentCenter];
        gifLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground5];
    }
    
    gifLabel.origin = CGPointMake((imageView.width) - kGIFLabelWidth, (imageView.height) - kGIFLabelHeight);
    [imageView addSubview:gifLabel];
    [_indexGIFLabelMap setObject:gifLabel forKey:@(index)];
}

- (void)hideGIFLabelAtIndex:(NSUInteger)index
{
    UILabel * gifLabel = [_indexGIFLabelMap objectForKey:@(index)];
    if (!gifLabel) {
        return;
    }
    
    [gifLabel removeFromSuperview];
    [_gifLabelPools addObject:gifLabel];
    [_indexGIFLabelMap removeObjectForKey:@(index)];
}

- (CGRect)rectForImageAtIndex:(NSInteger)index {
    return [[self class] _rectInImages:self.images atIndex:index constrainedToWidth:self.width margin:self.margin];
}

- (void)_imageTapActionFired:(UITapGestureRecognizer *)tapGestureRecognizer {
    TTImageView *imageView = (TTImageView *)tapGestureRecognizer.view;
    NSInteger index = imageView.tag - 1000;
    if (index < self.images.count) {
        if ([self.delegate respondsToSelector:@selector(imageAlbum:didClickImageAtIndex:)]) {
            [self.delegate imageAlbum:self didClickImageAtIndex:index];
        }
    }
}

+ (CGFloat)heightForImages:(NSArray *)images constrainedToWidth:(CGFloat)width margin:(CGFloat)margin {
    if (images.count == 0) {
        return 0;
    }
    CGRect bottomImageFrame = [self _rectInImages:images atIndex:(images.count - 1) constrainedToWidth:width margin:margin];
    return CGRectGetMaxY(bottomImageFrame);
}

+ (CGRect)_rectInImages:(NSArray *)images
                atIndex:(NSUInteger)index
     constrainedToWidth:(CGFloat)width
                 margin:(CGFloat)margin {
    if (index >= images.count) {
        return CGRectZero;
    }
    if ([images count] == 4 && (index == 2 || index == 3)) {//产品需求， 4图的时候学微信排版。
        index ++;
    }
    CGFloat elementWidth = (width - 2 * margin) / 3.0;
    if (elementWidth <= 0) {
        return CGRectZero;
    }
    if (images.count == 1) {
        TTImageInfosModel *imageModel = images[0];
        if (imageModel.width == 0 || imageModel.height == 0) {
            return CGRectZero;
        }
        
        CGFloat width = 0.f, height = 0.f;
        CGFloat imageLongEdge = MAX(imageModel.height, imageModel.width);
        CGFloat imageShortEdge = MIN(imageModel.height, imageModel.width);
        if (imageLongEdge > imageShortEdge * 3) {
            imageLongEdge = imageShortEdge * 3;
        }
        
        CGFloat singleImageMaxSize = [TTUIResponderHelper screenSize].width / 2.f;
        CGFloat scale = singleImageMaxSize / imageLongEdge;
        if (imageModel.height > imageModel.width) {
            height = singleImageMaxSize;
            width = imageShortEdge * scale;
        } else {
            width = singleImageMaxSize;
            height = imageShortEdge * scale;
        }
        
        return CGRectMake(0, 0, width, height);
    } else {
        NSInteger rowIndex = index / 3;
        NSInteger columnIndex = index % 3;
        return CGRectMake(columnIndex * (elementWidth + margin), rowIndex * (elementWidth + margin), elementWidth, elementWidth);
    }
}

#pragma mark -- Getters/Setters
- (NSArray *)displayImages
{
    NSMutableArray * mutDisplayImages = [NSMutableArray arrayWithCapacity:[self.imageViews count]];
    for (NSUInteger i = 0; i < [self.imageViews count]; ++i) {
        TTImageView *imageView = self.imageViews[i];
        UIImage * image = imageView.imageView.image;
        if (image) {
            [mutDisplayImages addObject:image];
        } else {
            [mutDisplayImages addObject:[NSNull null]];
        }
    }
    
    return mutDisplayImages;
}

- (NSArray *)displayImageViewFrames
{
    NSMutableArray * mutDisplayImageViewFrames = [NSMutableArray arrayWithCapacity:[self.imageViews count]];
    for (NSUInteger i = 0; i < [_imageViews count]; ++i) {
        UIView * imageView = [_imageViews objectAtIndex:i];
        CGRect frame = [self convertRect:imageView.frame toView:nil];
        [mutDisplayImageViewFrames addObject:[NSValue valueWithCGRect:frame]];
    }
    
    return mutDisplayImageViewFrames;
}

@end
