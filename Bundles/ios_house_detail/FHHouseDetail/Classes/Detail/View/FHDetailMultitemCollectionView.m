//
//  FHDetailMultitemCollectionCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/15.
//

#import "FHDetailMultitemCollectionView.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "UILabel+House.h"

@interface FHDetailMultitemCollectionView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong)   UICollectionView       *collectionContainer;
@property (nonatomic, copy)     NSString       *cellIdentifier;

@property (nonatomic, strong)   NSArray       *datas;// 数据数组

@end

@implementation FHDetailMultitemCollectionView

- (instancetype)initWithFlowLayout:(UICollectionViewFlowLayout *)flowLayout viewHeight:(CGFloat)collectionViewHeight cellIdentifier:(NSString *)cellIdentifier datas:(NSArray *)datas
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.cellIdentifier = cellIdentifier;
        self.datas = datas;
        [self setupUIWithFlowLayout:flowLayout viewHeight:collectionViewHeight];
    }
    return self;
}

- (void)setupUIWithFlowLayout:(UICollectionViewFlowLayout *)flowLayout viewHeight:(CGFloat)collectionViewHeight {
    if (flowLayout) {
        _collectionContainer = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionContainer.showsHorizontalScrollIndicator = NO;
        _collectionContainer.backgroundColor = UIColor.whiteColor;
        
        [self addSubview:_collectionContainer];
        [_collectionContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
            make.height.mas_equalTo(collectionViewHeight);
        }];
        _collectionContainer.delegate = self;
        _collectionContainer.dataSource = self;
        [_collectionContainer reloadData];
    }
}

#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datas.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHDetailBaseCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.datas.count) {
        [cell refreshWithData:self.datas[indexPath.row]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
