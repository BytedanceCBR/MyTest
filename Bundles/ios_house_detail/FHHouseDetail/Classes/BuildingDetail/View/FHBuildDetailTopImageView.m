//
//  FHBuildDetailTopImageView.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/7/28.
//

#import "FHBuildDetailTopImageView.h"
#import "FHBuildDetailImageViewButton.h"
#import <BDWebImage.h>
#import <Masonry/Masonry.h>
#import "FHVideoAndImageItemCorrectingView.h"

@interface FHBuildDetailTopImageView ()

@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, strong) FHBuildingLocationModel *locationModel;
//@property (nonatomic, copy) NSArray<FHBuildDetailImageViewButton *> *buildingButtons;
@property (nonatomic, copy) NSArray *saleStatusButtons;
@property (nonatomic, weak) FHVideoAndImageItemCorrectingView *saleStatusView;

@end

@implementation FHBuildDetailTopImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        self.imageView = imageView;
        [self addSubview:imageView];

    }
    return self;
}

- (void)updateWithData:(id)data {
    if (data && [data isKindOfClass:[FHBuildingLocationModel class]]) {
        FHBuildingLocationModel *model = (FHBuildingLocationModel *)data;
        self.locationModel = model;
        NSURL *url = [NSURL URLWithString:model.buildingImage.url];
        [self.imageView bd_setImageWithURL:url];
        NSMutableArray *saleButtons = [NSMutableArray arrayWithCapacity:model.saleStatusList.count];
        for (FHBuildingSaleStatusModel *StatusModel in model.saleStatusList) {
            NSMutableArray *buildingButtons = [NSMutableArray arrayWithCapacity:StatusModel.buildingList.count];
            for (FHBuildingDetailDataItemModel *building in StatusModel.buildingList) {
                FHBuildDetailImageViewButton *button = [[FHBuildDetailImageViewButton alloc] init];
                [button updateWithData:building];
                [self addSubview:button];
                [buildingButtons addObject:button];
            }
            [saleButtons addObject:buildingButtons.copy];
        }
        self.saleStatusButtons = saleButtons.copy;
        if (model.saleStatusContents.count > 1) {
            [self.saleStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self);
                make.bottom.mas_equalTo(self).offset(-36);
                make.width.mas_equalTo(self.saleStatusView.itemWidth * model.saleStatusContents.count);
                make.height.mas_equalTo(22);
            }];
            self.saleStatusView.titleArray = model.saleStatusContents;
        }
    }
    [self layoutIfNeeded];
}

- (FHVideoAndImageItemCorrectingView *)saleStatusView {
    if (!_saleStatusView) {
        FHVideoAndImageItemCorrectingView *saleView = [[FHVideoAndImageItemCorrectingView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 22)];
        [self addSubview:saleView];
        __weak typeof(self) wSelf = self;
        saleView.selectedBlock = ^(NSInteger index, NSString * _Nonnull name, NSString * _Nonnull value) {
            [wSelf clickSaleStatusItem:index];
        };
        _saleStatusView = saleView;
    }
    return _saleStatusView;
}

- (void)clickSaleStatusItem:(NSInteger)index {
    NSLog(@"选择了 %@",@(index));
}

- (void)switchSaleStatusItem:(FHBuildingIndexModel *)index {
    
    [self.saleStatusView selectedItem:self.locationModel.saleStatusContents[index.saleStatus]];
}

@end
