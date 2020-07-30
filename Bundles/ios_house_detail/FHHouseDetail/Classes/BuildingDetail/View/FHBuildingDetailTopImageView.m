//
//  FHBuildingDetailTopImageView.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/7/28.
//

#import "FHBuildingDetailTopImageView.h"
#import "FHBuildingDetailImageViewButton.h"
#import <BDWebImage.h>
#import "UIColor+Theme.h"



@interface FHBuildingDetailTopImageView ()<UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong) FHBuildingLocationModel *locationModel;
//@property (nonatomic, copy) NSArray<FHBuildingDetailImageViewButton *> *buildingButtons;
@property (nonatomic, copy) NSArray *saleStatusButtons;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, strong) UIImage *placeHolder;
@property (nonatomic, strong) FHBuildingIndexModel *indexModel;
@property (nonatomic, strong) UIView *bottomGradientView;
@end

@implementation FHBuildingDetailTopImageView

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
        [self addSubview:self.bottomGradientView];
        
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
                FHBuildingDetailImageViewButton *button = [[FHBuildingDetailImageViewButton alloc] init];
                button.hidden = YES;
                [button updateWithData:building];
                [button buttonMoveWithSize:self.imageView.frame.size];
                [self.scrollView addSubview:button];
                __weak typeof(self) wSelf = self;
                [button setButtonIndexDidSelect:^(FHBuildingDetailOperatType type, FHBuildingIndexModel * _Nonnull index) {
                    [wSelf catchButtonClick:type indexModel:index];
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

- (UIView *)bottomGradientView {
    if (!_bottomGradientView) {
        CGRect frame = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 25);
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = frame;
        gradientLayer.colors = @[
                                 (__bridge id)[UIColor colorWithWhite:1 alpha:0].CGColor,
                                 (__bridge id)[UIColor themeGray7].CGColor
                                 ];
        gradientLayer.startPoint = CGPointMake(0.5, 0);
        gradientLayer.endPoint = CGPointMake(0.5, 0.9);
        frame.origin.y = self.frame.size.height - 25;
        _bottomGradientView = [[UIView alloc] initWithFrame:frame];
        [_bottomGradientView.layer addSublayer:gradientLayer];
    }
    return _bottomGradientView;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self move:self.imageView.frame.size];
}

- (void)move:(CGSize)newSize{
    NSArray *buttonAry = self.saleStatusButtons[self.indexModel.saleStatus];
    for (FHBuildingDetailImageViewButton *button in buttonAry) {
        [button buttonMoveWithSize:newSize];
    }
}

- (void)catchButtonClick:(FHBuildingDetailOperatType)type indexModel:(FHBuildingIndexModel *)index {
    if (self.buttonDidSelect) {
        self.buttonDidSelect(type, index);
    }
}

- (void)pointMoveToCenter:(CGPoint)point {
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
//唯一响应
- (void)updateWithIndexModel:(FHBuildingIndexModel *)indexModel {
    if (indexModel.saleStatus != self.indexModel.saleStatus) {
        NSArray *buttonAry = self.saleStatusButtons[self.indexModel.saleStatus];
        for (FHBuildingDetailImageViewButton *button in buttonAry) {
            [button setHidden:YES];
        }
    }
    NSArray *buttonAry = self.saleStatusButtons[indexModel.saleStatus];
    for (FHBuildingDetailImageViewButton *button in buttonAry) {
        [button setHidden:NO];
        button.isSelected = NO;
    }

    self.indexModel = indexModel;
    
    FHBuildingDetailImageViewButton *button = buttonAry[indexModel.buildingIndex];
    button.isSelected = YES;
    [self bringSubviewToFront:button];
    [self move:self.imageView.frame.size];
    [self pointMoveToCenter:[button getButtonPosition]];
}

@end
