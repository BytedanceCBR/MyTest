//
//  AKPhotoCarouselCellView.m
//  Article
//
//  Created by chenjiesheng on 2018/3/6.
//

#import "AKPhotoCarouselCellModel.h"
#import "AKPhotoCarouselCellView.h"

#import <UIImageView+BDWebImage.h>
#import <TTAnimatedImageView.h>
@interface AKPhotoCarouselCellView ()

@property (nonatomic, strong)TTAnimatedImageView    *imageView;

@end

@implementation AKPhotoCarouselCellView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createComponent];
    }
    return self;
}

- (void)createComponent
{
    [self createImageView];
}

- (void)createImageView
{
    _imageView = ({
        TTAnimatedImageView *view = [[TTAnimatedImageView alloc] initWithFrame:self.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.contentMode = UIViewContentModeScaleAspectFit;
        view;
    });
    [self addSubview:_imageView];
}

- (void)setupContentWithModel:(AKPhotoCarouselCellModel *)cellModel
{
    [self.imageView setImageWithURLString:cellModel.imageURL];
}

@end
