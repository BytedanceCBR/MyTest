//
//  FHBuildingDetailInfoCollectionViewCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/7/2.
//

#import "FHBuildingDetailInfoCollectionViewCell.h"
#import "FHBuildingDetailModel.h"
#import <FHHouseBase/FHBaseCollectionView.h>

CGFloat const FHBuildingDetailInfoListCellMinimumLineSpacing = 25 + 12;

@interface FHBuildingDetailInfoCollectionViewCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, copy) NSArray<FHBuildingDetailDataItemModel *> *buildingList;
@end

@implementation FHBuildingDetailInfoCollectionViewCell

//[[UIImage imageNamed:@"top_left_right_bottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(30,25,30,25) resizingMode:UIImageResizingModeStretch];

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsZero;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 12;
        layout.minimumInteritemSpacing = 0;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.contentView.bounds collectionViewLayout:layout];
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        [self.contentView addSubview:collectionView];
        self.collectionView = collectionView;
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        [self.collectionView registerClass:[FHBuildingDetailInfoListCell class] forCellWithReuseIdentifier:NSStringFromClass([FHBuildingDetailInfoListCell class])];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (data && [data isKindOfClass:[FHBuildingDetailModel class]]) {
        FHBuildingDetailModel *model = (FHBuildingDetailModel *)data;
        self.buildingList = model.data.buildingList;
        [self.collectionView reloadData];
        
        //判断
        if (self.buildingList.count > 1) {
            UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:self.buildingList.count inSection:0]];
            if (self.currentIndexPath) {
                attributes = [self.collectionView layoutAttributesForItemAtIndexPath:self.currentIndexPath];
            }
            [self.collectionView setContentOffset:CGPointMake(attributes.frame.origin.x - FHBuildingDetailInfoListCellMinimumLineSpacing, 0)];
        }
    }
}

- (void)updateIndexPahtAtPosition:(NSIndexPath *)indexPath {
    if (self.indexDidChanged) {
        self.indexDidChanged(indexPath.row % self.buildingList.count);
    }
}

#pragma mark - UICollectionViewDelegate
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    CGPoint contentOffset = CGPointMake(self.collectionView.contentOffset.x + CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
//    NSIndexPath *currentIndexPath = [self.collectionView indexPathForItemAtPoint:contentOffset];
//    if (currentIndexPath.row != indexPath.row) {
//        UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
//        [self.collectionView setContentOffset:CGPointMake(attributes.frame.origin.x - FHBuildingDetailInfoListCellMinimumLineSpacing, 0) animated:YES];
//    }
//}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.buildingList.count == 1) {
        return 1;
    }
    return self.buildingList.count * 3;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHBuildingDetailInfoListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHBuildingDetailInfoListCell class]) forIndexPath:indexPath];
    [cell refreshWithData:self.buildingList[indexPath.row % self.buildingList.count]];
    return cell;
}

#pragma mark -
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(collectionView.frame);
    CGFloat height = 172;
    if (self.buildingList.count == 1) {
        return CGSizeMake(width - 15 * 2, height);
    } else {
        return CGSizeMake(width - 12 * 2 - 25 * 2, height);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.buildingList.count == 1) {
        return UIEdgeInsetsMake(0, 15, 0, 15);
    }
    return UIEdgeInsetsZero;
}

#pragma mark -
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

    CGPoint contentOffset = CGPointMake(self.collectionView.contentOffset.x + CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
    self.currentIndexPath = [self.collectionView indexPathForItemAtPoint:contentOffset];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint contentOffset = CGPointMake(self.collectionView.contentOffset.x + CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:contentOffset];
    if (indexPath) {
//        [self updateCheckmarkAtPosition:indexPath];
    }

}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGPoint contentOffset = CGPointMake(self.collectionView.contentOffset.x + CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:contentOffset];
    UICollectionViewLayoutAttributes *attributes = nil;
    if (indexPath.row < self.buildingList.count) {
        attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:self.buildingList.count + indexPath.row inSection:0]];
    } else if (indexPath.row > self.buildingList.count * 2 - 1) {
        attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row - self.buildingList.count inSection:0]];
    }
    if (attributes) {
        [self.collectionView setContentOffset:CGPointMake(attributes.frame.origin.x - FHBuildingDetailInfoListCellMinimumLineSpacing, 0)];
    }
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{

    CGPoint contentOffset = CGPointMake(self.collectionView.contentOffset.x + CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds));
    NSIndexPath *toIndexPath = [self.collectionView indexPathForItemAtPoint:contentOffset];
    if (toIndexPath.item != self.currentIndexPath.item && abs((int)(toIndexPath.item-self.currentIndexPath.item))==1) {
        [self updateIndexPahtAtPosition:toIndexPath];
        UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:toIndexPath];
        *targetContentOffset = CGPointMake(attributes.frame.origin.x - FHBuildingDetailInfoListCellMinimumLineSpacing, 0);
    }else{
        if (velocity.x > 0.3) {
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForItem:self.currentIndexPath.item+1 inSection:self.currentIndexPath.section];
            if (scrollIndexPath.item < [self.collectionView numberOfItemsInSection:0]) {
                [self updateIndexPahtAtPosition:scrollIndexPath];
                UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:scrollIndexPath];
                *targetContentOffset = CGPointMake(attributes.frame.origin.x - FHBuildingDetailInfoListCellMinimumLineSpacing, 0);
            }
        }
        else if (velocity.x < -0.3) {
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForItem:self.currentIndexPath.item-1 inSection:self.currentIndexPath.section];
            if (self.currentIndexPath.item > 0) {
                [self updateIndexPahtAtPosition:scrollIndexPath];
                UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:scrollIndexPath];
                *targetContentOffset = CGPointMake(attributes.frame.origin.x - FHBuildingDetailInfoListCellMinimumLineSpacing, 0);
            }
        }
        else{
            UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:self.currentIndexPath];
            *targetContentOffset = CGPointMake(attributes.frame.origin.x - FHBuildingDetailInfoListCellMinimumLineSpacing, 0);
        }
    }
}

@end

@implementation FHBuildingDetailInfoListCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        UIImageView *shadowImageView = [[UIImageView alloc] init];
        shadowImageView.image = [[UIImage imageNamed:@"top_left_right_bottom"] resizableImageWithCapInsets:UIEdgeInsetsMake(30,25,30,25) resizingMode:UIImageResizingModeStretch];
        [self.contentView addSubview:shadowImageView];
        [shadowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(-20, -15, -20, -15));
        }];
        
        self.stackView = [[UIStackView alloc] init];
        self.stackView.axis = UILayoutConstraintAxisVertical;
        [self.contentView addSubview:self.stackView];
        [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(30, 16, 24, 16));
        }];
        
        UIView *titleItemView = [[UIView alloc] init];
        [self.stackView addArrangedSubview:titleItemView];
        [titleItemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(36);
            make.width.mas_equalTo(self.stackView.mas_width);
        }];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont themeFontMedium:24];
        self.titleLabel.textColor = [UIColor themeGray1];
        [titleItemView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_equalTo(0);
        }];
        
        self.saleStatusLabel = [[UILabel alloc] init];
        self.saleStatusLabel.font = [UIFont themeFontMedium:12];
        self.saleStatusLabel.layer.masksToBounds = YES;
        self.saleStatusLabel.layer.cornerRadius = 10;
        self.saleStatusLabel.textAlignment = NSTextAlignmentCenter;
        [titleItemView addSubview:self.saleStatusLabel];
        [self.saleStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40, 20));
            make.left.mas_equalTo(self.titleLabel.mas_right).mas_offset(8);
            make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        }];
        
        NSMutableArray *infosView = [NSMutableArray arrayWithCapacity:6];
        for (NSUInteger i = 0; i < 3; i++) {
            UIView *stackItemView = [[UIView alloc] init];
            [self.stackView addArrangedSubview:stackItemView];
            [stackItemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(self.stackView);
                make.left.mas_equalTo(self.stackView);
                make.height.mas_equalTo(12 + 8 + 8);
            }];
            FHPropertyListCorrectingRowView *row1 = [self customRowView];
            [stackItemView addSubview:row1];
            [infosView addObject:row1];
            [row1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
                make.top.mas_equalTo(0);
                make.width.mas_equalTo(stackItemView.mas_width).with.multipliedBy(0.5);
                make.height.mas_equalTo(stackItemView);
            }];
            
            FHPropertyListCorrectingRowView *row2 = [self customRowView];
            [stackItemView addSubview:row2];
            [infosView addObject:row2];
            [row2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(row1.mas_right);
                make.top.mas_equalTo(0);
                make.width.mas_equalTo(row1);
                make.height.mas_equalTo(row1);
            }];
        }
        self.infosView = infosView.copy;
    }
    return self;
}

- (FHPropertyListCorrectingRowView *)customRowView {
    FHPropertyListCorrectingRowView *rowView = [[FHPropertyListCorrectingRowView alloc] init];
    rowView.keyLabel.font = [UIFont themeFontRegular:14];
    rowView.valueLabel.font = [UIFont themeFontMedium:14];
    rowView.keyLabel.textColor = [UIColor colorWithHexStr:@"#aeadad"];
    rowView.valueLabel.textColor = [UIColor themeGray2];
    // 布局
    [rowView.keyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [rowView.valueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(38);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    return rowView;
}

- (void)refreshWithData:(id)data {
    if (data && [data isKindOfClass:[FHBuildingDetailDataItemModel class]]) {
        FHBuildingDetailDataItemModel *model = (FHBuildingDetailDataItemModel *)data;
        
        self.titleLabel.text = model.name;
        if (model.saleStatus) {
            self.saleStatusLabel.hidden = NO;
            self.saleStatusLabel.backgroundColor = [UIColor colorWithHexString:model.saleStatus.backgroundColor];
            self.saleStatusLabel.textColor = [UIColor colorWithHexString:model.saleStatus.textColor];
            self.saleStatusLabel.text = model.saleStatus.content;
        } else {
            self.saleStatusLabel.hidden = YES;
        }
        
        [model.baseInfo enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx >= 6) {
                *stop = YES;
            }
            if ([obj isKindOfClass:[FHHouseBaseInfoModel class]]) {
                FHHouseBaseInfoModel *info = (FHHouseBaseInfoModel *)obj;
                FHPropertyListCorrectingRowView *rowView = self.infosView[idx];
                rowView.keyLabel.text = info.attr;
                rowView.valueLabel.text = info.value;
            }
        }];
    }
}

@end
