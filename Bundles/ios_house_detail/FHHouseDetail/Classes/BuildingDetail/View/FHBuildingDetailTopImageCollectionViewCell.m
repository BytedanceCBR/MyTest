//
//  FHBuildingDetailTopImageCollectionViewCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/7/28.
//

#import "FHBuildingDetailTopImageCollectionViewCell.h"
#import "FHBuildingDetailUtils.h"
#import "FHBuildDetailTopImageView.h"

@interface FHBuildingDetailTopImageCollectionViewCell() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) FHBuildingLocationModel *locationModel;
@property (nonatomic, strong) FHBuildDetailTopImageView *imageView;

@end

@implementation FHBuildingDetailTopImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
        scrollView.delegate = self;
        scrollView.minimumZoomScale = 1.0;
        scrollView.maximumZoomScale = 3.0;
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView = scrollView;
        self.scrollView.contentSize = CGSizeMake(frame.size.width + 0.4, frame.size.height + 0.4);
        [self.contentView addSubview:scrollView];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (data && [data isKindOfClass:[FHBuildingLocationModel class]]) {
        FHBuildingLocationModel *model = (FHBuildingLocationModel *)data;
        self.locationModel = model;
        CGSize size = [FHBuildingDetailUtils getTopImageViewSize];
        FHBuildDetailTopImageView *imageView = [[FHBuildDetailTopImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        [self.scrollView addSubview:imageView];
        [imageView updateWithData:model];
        self.imageView = imageView;
        
        
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView.imageView;
}

@end
