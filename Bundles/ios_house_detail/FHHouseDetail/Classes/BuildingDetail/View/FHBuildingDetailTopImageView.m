//
//  FHBuildingDetailTopImageView.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/7/28.
//

#import "FHBuildingDetailTopImageView.h"
#import "FHBuildingDetailImageViewButton.h"
#import <BDWebImage.h>
#import "FHBuildingDetailScrollView.h"
#import "UIColor+Theme.h"

@interface FHBuildingDetailTopImageView ()<UIScrollViewDelegate>

@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong) FHBuildingLocationModel *locationModel;
//@property (nonatomic, copy) NSArray<FHBuildingDetailImageViewButton *> *buildingButtons;
@property (nonatomic, copy) NSArray *saleStatusButtons;
@property (nonatomic, strong) FHBuildingDetailScrollView *scrollView;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, strong) UIImageView *placeHolder;
@property (nonatomic, strong) FHBuildingIndexModel *indexModel;

@end

@implementation FHBuildingDetailTopImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageSize = frame.size;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        self.imageView = imageView;
        FHBuildingDetailScrollView *scrollView = [[FHBuildingDetailScrollView alloc] initWithFrame:frame];
        scrollView.delegate = self;
        scrollView.minimumZoomScale = 1.0;
        scrollView.maximumZoomScale = 3.0;
        [scrollView setShowsVerticalScrollIndicator:NO];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView = scrollView;
        self.scrollView.contentSize = CGSizeMake(frame.size.width + 0.4, frame.size.height + 0.4);
        [self addSubview:scrollView];

        self.placeHolder = [[UIImageView alloc] initWithFrame:frame];
        self.placeHolder.image = [UIImage imageNamed:@"default_image"];
        [self.scrollView addSubview:imageView];
        [self addSubview:self.placeHolder];
    }
    return self;
}

- (void)updateWithData:(id)data {
    if (data && [data isKindOfClass:[FHBuildingLocationModel class]]) {
        FHBuildingLocationModel *model = (FHBuildingLocationModel *)data;
        self.locationModel = model;
        for (NSArray *buttonAry in self.saleStatusButtons) {
            for (FHBuildingDetailImageViewButton *button in buttonAry) {
                [button removeFromSuperview];
            }
        }
        self.saleStatusButtons = nil;
        [self.placeHolder setHidden:NO];
        NSURL *url = [NSURL URLWithString:model.buildingImage.url];
        __weak typeof(self) wSelf = self;
        [self.imageView bd_setImageWithURL:url placeholder:nil options:BDImageRequestDefaultPriority completion:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
            if (image && wSelf) {
                [wSelf.placeHolder setHidden:YES];
            }
        }];

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
                [button setButtonIndexDidSelect:^(FHBuildingDetailOperatType type, FHBuildingIndexModel *_Nonnull index) {
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

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self move:self.imageView.frame.size];
}

- (void)move:(CGSize)newSize {
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
    self.indexModel = indexModel;
    FHBuildingSaleStatusModel *saleStatusModel = self.locationModel.saleStatusList[indexModel.saleStatus];
    NSArray *buttonAry = self.saleStatusButtons[indexModel.saleStatus];
    for (NSInteger buildingIndex = 0; buildingIndex < buttonAry.count; buildingIndex++) {
        FHBuildingDetailImageViewButton *button = buttonAry[buildingIndex];
        FHBuildingDetailDataItemModel *itemModel = saleStatusModel.buildingList[buildingIndex];
        button.isSelected = NO;
        if (itemModel.pointX.length && itemModel.pointY.length) {
            [button setHidden:NO];
            if ([indexModel isEqual:itemModel.buildingIndex]) {
                button.isSelected = YES;
                [self.scrollView bringSubviewToFront:button];
                [self move:self.imageView.frame.size];
                [self pointMoveToCenter:[button getButtonPosition]];
            }
        }
    }
}

- (void)showAllButton {
    for (NSArray *buttonAry in self.saleStatusButtons) {
        for (FHBuildingDetailImageViewButton *button in buttonAry) {
            [button setHidden:NO];
            button.isSelected = YES;
        }
    }
}

@end
