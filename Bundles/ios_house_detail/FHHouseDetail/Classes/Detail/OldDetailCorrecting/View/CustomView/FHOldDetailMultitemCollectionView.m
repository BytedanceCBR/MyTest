//
//  FHDetailMultitemCollectionCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/15.
//

#import "FHOldDetailMultitemCollectionView.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "UILabel+House.h"
#import <FHHouseBase/FHBaseCollectionView.h>
#import "FHDetailSameNeighborhoodHouseCell.h"
#import "FHDetailSurroundingAreaCell.h"

@interface FHOldDetailMultitemCollectionView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, copy)     NSString       *cellIdentifier;
@property (nonatomic, strong)   NSMutableDictionary       *houseShowCache;
@property (nonatomic, strong)   NSArray       *datas;// 数据数组

@end

@implementation FHOldDetailMultitemCollectionView

- (instancetype)initWithFlowLayout:(UICollectionViewFlowLayout *)flowLayout viewHeight:(CGFloat)collectionViewHeight datas:(NSArray *)datas
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        [self setupUIWithFlowLayout:flowLayout viewHeight:collectionViewHeight];
        self.datas = datas;
        self.houseShowCache = [NSMutableDictionary new];
        _collectionContainer.delegate = self;
        _collectionContainer.dataSource = self;
    }
    return self;
}

- (void)registerCell:(Class)cell forIdentifier:(NSString *)cellIdentifier {
     [self registerCls:cell forIdentifier:cellIdentifier];
}

- (void)setupUIWithFlowLayout:(UICollectionViewFlowLayout *)flowLayout viewHeight:(CGFloat)collectionViewHeight {
    if (flowLayout) {
        _collectionContainer = [[FHBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionContainer.showsHorizontalScrollIndicator = NO;
        _collectionContainer.backgroundColor = UIColor.whiteColor;
        
        [self addSubview:_collectionContainer];
        [_collectionContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
            make.height.mas_equalTo(collectionViewHeight);
        }];
    }
}

- (void)registerCls:(Class)cls forIdentifier:(NSString *)cellIdentifier {
    [_collectionContainer registerClass:cls forCellWithReuseIdentifier:cellIdentifier];
    self.cellIdentifier = cellIdentifier;
}

- (void)reloadData {
    [self.collectionContainer reloadData];
}

#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datas.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id data = self.datas[indexPath.row];
    FHDetailBaseCollectionCell *cell;
    NSString *identifier = NSStringFromClass([data class]);//[self cellIdentifierForEntity:data];
    if (identifier.length > 0) {
          cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        if (indexPath.row < self.datas.count) {
            [cell refreshWithData:self.datas[indexPath.row]];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (self.clickBlk) {
        self.clickBlk(indexPath.row);
    }
}

// house_show埋点
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    if ([self.houseShowCache valueForKey:tempKey]) {
        return;
    }
    [self.houseShowCache setValue:@(YES) forKey:tempKey];
    // 添加埋点
    if (self.displayCellBlk) {
        self.displayCellBlk(indexPath.row);
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id data = self.datas[indexPath.row];
    if ([data isKindOfClass:[FHDetailMoreItemModel class]]) {
        return CGSizeMake(94, 210);
    }
    return CGSizeMake(150, 210);
}
@end
