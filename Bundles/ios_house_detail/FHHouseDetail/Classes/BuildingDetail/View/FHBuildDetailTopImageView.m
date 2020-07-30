//
//  FHBuildDetailTopImageView.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/7/28.
//

#import "FHBuildDetailTopImageView.h"
#import "FHBuildDetailImageViewButton.h"
#import <BDWebImage.h>



@interface FHBuildDetailTopImageView ()<UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong) FHBuildingLocationModel *locationModel;
//@property (nonatomic, copy) NSArray<FHBuildDetailImageViewButton *> *buildingButtons;
@property (nonatomic, copy) NSArray *saleStatusButtons;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, strong) UIImage *placeHolder;

@end

@implementation FHBuildDetailTopImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageSize = frame.size;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        self.imageView = imageView;
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
        scrollView.delegate = self;
        scrollView.minimumZoomScale = 1.0;
        scrollView.maximumZoomScale = 3.0;
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView = scrollView;
        self.scrollView.contentSize = CGSizeMake(frame.size.width + 0.4, frame.size.height + 0.4);
        [self addSubview:scrollView];
        [self.scrollView addSubview:imageView];
    }
    return self;
}

- (void)updateWithData:(id)data {
    if (data && [data isKindOfClass:[FHBuildingLocationModel class]]) {
        FHBuildingLocationModel *model = (FHBuildingLocationModel *)data;
        self.locationModel = model;
        NSURL *url = [NSURL URLWithString:model.buildingImage.url];
        [self.imageView bd_setImageWithURL:url placeholder:self.placeHolder];
        NSMutableArray *saleButtons = [NSMutableArray arrayWithCapacity:model.saleStatusList.count];
        for (FHBuildingSaleStatusModel *StatusModel in model.saleStatusList) {
            NSMutableArray *buildingButtons = [NSMutableArray arrayWithCapacity:StatusModel.buildingList.count];
            for (FHBuildingDetailDataItemModel *building in StatusModel.buildingList) {
                FHBuildDetailImageViewButton *button = [[FHBuildDetailImageViewButton alloc] init];
                [button updateWithData:building];
                [button buttonMoveWithSize:self.imageView.frame.size];
                [self.scrollView addSubview:button];
                __weak typeof(self) wSelf = self;
                [button setIndexDidSelect:^(CGPoint p) {
                    [wSelf pointMoveToCenter:p];
                }];
                [buildingButtons addObject:button];
            }
            [saleButtons addObject:buildingButtons.copy];
        }
        self.saleStatusButtons = saleButtons.copy;
        
    }
    [self layoutIfNeeded];
}

- (UIImage *)placeHolder {
    if (!_placeHolder) {
        _placeHolder = [UIImage imageNamed:@"default_image"];
    }
    return _placeHolder;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self move:self.imageView.frame.size];
}

- (void)move:(CGSize)newSize{
    for (NSArray *buttonAry in self.saleStatusButtons) {
        for (FHBuildDetailImageViewButton *button in buttonAry) {

            [button buttonMoveWithSize:newSize];
        }
    }
}

- (void)pointMoveToCenter:(CGPoint)point{
    CGSize size = self.imageSize;
    CGSize edgeSize = self.imageView.frame.size;
    CGFloat offsetX = point.x - size.width / 2.0;
    if (offsetX < 0) {
        offsetX = 0;
    }
    if (offsetX + size.width > edgeSize.width) {
        offsetX = edgeSize.width - size.width;
    }
    CGFloat offsetY = point.y - size.height / 2.0;
    if (offsetY < 0) {
        offsetY = 0;
    }
    if (offsetY + size.height > edgeSize.height) {
        offsetY = edgeSize.height - size.height;
    }
    [self.scrollView setContentOffset:CGPointMake(offsetX, offsetY) animated:YES];
}


@end
