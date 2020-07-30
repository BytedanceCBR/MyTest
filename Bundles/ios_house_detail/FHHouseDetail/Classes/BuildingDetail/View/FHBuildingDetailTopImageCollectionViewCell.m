//
//  FHBuildingDetailTopImageCollectionViewCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/7/28.
//

#import "FHBuildingDetailTopImageCollectionViewCell.h"
#import "FHBuildingDetailUtils.h"
#import "FHBuildDetailTopImageView.h"
#import "FHVideoAndImageItemCorrectingView.h"
#import <Masonry/Masonry.h>

@interface FHBuildingDetailTopImageCollectionViewCell() <UIScrollViewDelegate>


@property (nonatomic, strong) FHBuildingLocationModel *locationModel;
@property (nonatomic, strong) FHBuildDetailTopImageView *imageView;
@property (nonatomic, weak) FHVideoAndImageItemCorrectingView *saleStatusView;

@end

@implementation FHBuildingDetailTopImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.imageView = [[FHBuildDetailTopImageView alloc] initWithFrame:frame];
        [self.contentView addSubview:self.imageView];

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
