//
//  FHBuildingDetailTopImageCollectionViewCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/7/28.
//

#import "FHBuildingDetailTopImageCollectionViewCell.h"
#import "FHBuildingDetailUtils.h"
#import "FHBuildingDetailTopImageView.h"
#import "FHVideoAndImageItemCorrectingView.h"
#import <Masonry/Masonry.h>

@interface FHBuildingDetailTopImageCollectionViewCell() <UIScrollViewDelegate>


@property (nonatomic, strong) FHBuildingLocationModel *locationModel;
@property (nonatomic, strong) FHBuildingDetailTopImageView *imageView;
@property (nonatomic, weak) FHVideoAndImageItemCorrectingView *saleStatusView;
@property (nonatomic, strong) FHBuildingIndexModel *indexModel;

@end

@implementation FHBuildingDetailTopImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        FHBuildingDetailTopImageView *imageView = [[FHBuildingDetailTopImageView alloc] initWithFrame:frame];
        self.imageView = imageView;
        [self.contentView addSubview:self.imageView];
        __weak typeof(self) wSelf = self;
        [imageView setButtonDidSelect:^(FHBuildingDetailOperatType type, FHBuildingIndexModel * _Nonnull index) {
            [wSelf clickItem:type indexModel:index];
        }];

    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (data && [data isKindOfClass:[FHBuildingLocationModel class]]) {
        FHBuildingLocationModel *model = (FHBuildingLocationModel *)data;
        self.locationModel = model;
        [self.imageView updateWithData:model];
        
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
}

- (FHVideoAndImageItemCorrectingView *)saleStatusView {
    if (!_saleStatusView) {
        FHVideoAndImageItemCorrectingView *saleView = [[FHVideoAndImageItemCorrectingView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 22)];
        [self addSubview:saleView];
        __weak typeof(self) wSelf = self;
        saleView.selectedBlock = ^(NSInteger index, NSString * _Nonnull name, NSString * _Nonnull value) {
            [wSelf clickItem:FHBuildingDetailOperatTypeSaleStatus indexModel:[FHBuildingIndexModel indexModelWithSaleStatus:index withBuildingIndex:0]];
        };
        _saleStatusView = saleView;
    }
    return _saleStatusView;
}

- (void)clickItem:(FHBuildingDetailOperatType)type indexModel:(FHBuildingIndexModel *)indexModel {
    if (self.IndexDidSelect) {
        self.IndexDidSelect(type, indexModel);
    }
}

- (void)updateWithIndexModel:(FHBuildingIndexModel *)indexModel {
    
    [_saleStatusView selectedItem:self.locationModel.saleStatusContents[indexModel.saleStatus]];
    [self.imageView updateWithIndexModel:indexModel];
    self.indexModel = indexModel;
    
}


@end
