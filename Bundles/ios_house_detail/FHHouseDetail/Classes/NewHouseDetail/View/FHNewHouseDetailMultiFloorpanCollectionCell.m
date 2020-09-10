//
//  FHNewHouseDetailMultiFloorpanCollectionCell.m
//  Pods
//
//  Created by bytedance on 2020/9/7.
//

#import "FHNewHouseDetailMultiFloorpanCollectionCell.h"
#import "FHDetailHeaderView.h"
#import <FHHouseBase/FHHouseIMClueHelper.h>

@interface FHNewHouseDetailMultiFloorpanCollectionCell ()<UICollectionViewDelegate,UICollectionViewDataSource,FHDetailBaseCollectionCellDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@end

@implementation FHNewHouseDetailMultiFloorpanCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNewHouseDetailMultiFloorpanCellModel class]]) {
        CGFloat height = 46;
        height += 190;
        FHNewHouseDetailMultiFloorpanCellModel *model = (FHNewHouseDetailMultiFloorpanCellModel *)data;
        BOOL hasIM = NO;
        for (NSInteger i = 0; i < model.floorPanList.list.count; i++) {
            FHDetailNewDataFloorpanListListModel *listItemModel = model.floorPanList.list[i];
            listItemModel.index = i;
            if (listItemModel.imOpenUrl.length > 0) {
                hasIM = YES;
                break;
            }
        }
        if (hasIM) {
            height += 30;
        }
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"house_model";
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        self.flowLayout.itemSize = CGSizeMake(120, 190);
        self.flowLayout.minimumLineSpacing = 16;
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds)) collectionViewLayout:self.flowLayout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.contentView addSubview:self.collectionView];
        [self.collectionView registerClass:[FHDetailNewMutiFloorPanCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHDetailNewMutiFloorPanCollectionCell class])];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.right.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.contentView).mas_offset(-9);
        }];
        
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNewHouseDetailMultiFloorpanCellModel class]]) {
        return;
    }
    self.currentData = data;
    
    FHNewHouseDetailMultiFloorpanCellModel *currentModel = (FHNewHouseDetailMultiFloorpanCellModel *)data;

    FHDetailNewDataFloorpanListModel *model = currentModel.floorPanList;
    if (model.list) {
        BOOL hasIM = NO;
        for (NSInteger i = 0; i < model.list.count; i++) {
            FHDetailNewDataFloorpanListListModel *listItemModel = model.list[i];
            listItemModel.index = i;
            if (listItemModel.imOpenUrl.length > 0) {
                hasIM = YES;
            }
        }

        CGFloat itemHeight = 190;
        if (hasIM) {
            itemHeight = 190 + 30;
        }
        self.flowLayout.itemSize = CGSizeMake(120, itemHeight);
        
        [self.collectionView reloadData];
    }
    
    [self layoutIfNeeded];
}

- (void)clickCellItem:(UIView *)itemView onCell:(FHDetailBaseCollectionCell*)cell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if(self.imItemClick) {
        self.imItemClick(indexPath.row);
    }
}

#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [(FHNewHouseDetailMultiFloorpanCellModel *)self.currentData floorPanList].list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHNewHouseDetailMultiFloorpanCellModel *model = (FHNewHouseDetailMultiFloorpanCellModel *)self.currentData;
    FHDetailNewMutiFloorPanCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHDetailNewMutiFloorPanCollectionCell class]) forIndexPath:indexPath];
    if (indexPath.row < model.floorPanList.list.count) {
        [cell refreshWithData:model.floorPanList.list[indexPath.row]];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.delegate = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (self.didSelectItem) {
        self.didSelectItem(indexPath.row);
    }
}

// 不重复调用
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.willShowItem) {
        self.willShowItem(indexPath);
    }
}

@end

@implementation FHNewHouseDetailMultiFloorpanCellModel

@end
