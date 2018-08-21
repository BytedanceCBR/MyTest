//
//  AKProfilePhotoCarouselViewCell.m
//  Article
//
//  Created by chenjiesheng on 2018/3/7.
//

#import "AKProfilePhotoCarouselViewCell.h"

@interface AKProfilePhotoCarouselViewCell ()

@property (nonatomic, strong, readwrite)AKPhotoCarouselView           *carouselView;

@end

@implementation AKProfilePhotoCarouselViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createComponent];
    }
    return self;
}

- (void)createComponent
{
    _carouselView = ({
        AKPhotoCarouselView *view = [[AKPhotoCarouselView alloc] initWithModels:nil];
        view.scrollDuration = 3;
        view.frame = self.bounds;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view;
    });
    [self.contentView addSubview:_carouselView];
}

- (void)refreshPhotoCarouselViewWithCellModels:(NSArray<AKPhotoCarouselCellModel *> *)cellModels
{
    [self.carouselView refreshCellModel:cellModels];
}

- (void)refreshPhotoCarouselViewScrollDuration:(NSTimeInterval)duration
{
    [self.carouselView setScrollDuration:duration];
}

@end
