//
//  FHNeighborhoodDetailSurroundingNeighborCollectionCell.m
//  FHHouseDetail
//
//  Created by 谢雷 on 2020/12/11.
//

#import "FHNeighborhoodDetailSurroundingNeighborCollectionCell.h"
#import "FHDetailSurroundingAreaCell.h"
#import <BDWebImage/BDWebImage.h>
#import "FHDetailRelatedNeighborhoodResponseModel.h"

@interface FHNeighborhoodDetailSurroundingNeighborItemCell : FHDetailBaseCollectionCell

@property (nonatomic, weak) UIImageView *coverImageView;

@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) UILabel *infoLabel;

@property (nonatomic, weak) UILabel *priceLabel;

@end

@implementation FHNeighborhoodDetailSurroundingNeighborItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 140, 120)];
        coverImageView.layer.masksToBounds = YES;
        coverImageView.layer.cornerRadius = 4.0;
        [self.contentView addSubview:coverImageView];
        self.coverImageView = coverImageView;
        [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.mas_equalTo(0);
            make.height.mas_equalTo(120);
        }];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont themeFontMedium:16];
        titleLabel.textColor = [UIColor themeGray1];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.coverImageView.mas_bottom).mas_offset(6);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(22);
        }];
        
        UILabel *infoLabel = [[UILabel alloc] init];
        infoLabel.font = [UIFont themeFontRegular:12];
        infoLabel.textColor = [UIColor themeGray1];
        [self.contentView addSubview:infoLabel];
        self.infoLabel = infoLabel;
        [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(2);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(17);
        }];
        
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.font = [UIFont themeFontMedium:16];
        priceLabel.textColor = [UIColor colorWithHexString:@"#fe5500"];
        [self.contentView addSubview:priceLabel];
        self.priceLabel = priceLabel;
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.infoLabel.mas_bottom).mas_offset(4);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(19);
        }];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailRelatedNeighborhoodResponseDataItemsModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailRelatedNeighborhoodResponseDataItemsModel *model = (FHDetailRelatedNeighborhoodResponseDataItemsModel *)data;
    if (model) {
        if (model.images.count > 0) {
            FHDetailRelatedNeighborhoodResponseDataItemsImagesModel *imageModel = model.images[0];
            NSString *urlStr = imageModel.url;
            if ([urlStr length] > 0) {
                [self.coverImageView bd_setImageWithURL:[NSURL URLWithString:urlStr] placeholder:[UIImage imageNamed:@"default_image"]];
            } else {
                self.coverImageView.image = [UIImage imageNamed:@"default_image"];
            }
        } else {
            self.coverImageView.image = [UIImage imageNamed:@"default_image"];
        }
        self.titleLabel.text = model.displayTitle;
        self.priceLabel.text = model.displayPricePerSqm;
        NSMutableString *infoString = [NSMutableString string];
        if (model.displayBuiltYear) {
            [infoString appendString:model.displayBuiltYear];
        }
        if (model.displayBuiltType) {
            if (infoString.length) {
                [infoString appendFormat:@" | %@",model.displayBuiltType];
            } else {
                [infoString appendString:model.displayBuiltType];
            }
        }
        self.infoLabel.text = infoString.copy;
    }
    [self layoutIfNeeded];
}

@end

@interface FHNeighborhoodDetailSurroundingNeighborCollectionCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy , nullable) NSArray<FHDetailRelatedNeighborhoodResponseDataItemsModel> *items;

@end

@implementation FHNeighborhoodDetailSurroundingNeighborCollectionCell

- (NSString *)elementType {
    return @"neighborhood_nearby";
}

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    return CGSizeMake(width, 208);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
        layout.minimumInteritemSpacing = 12;
        layout.minimumLineSpacing = 12;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.contentView.bounds collectionViewLayout:layout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self.collectionView registerClass:[FHNeighborhoodDetailSurroundingNeighborItemCell class] forCellWithReuseIdentifier:NSStringFromClass([FHNeighborhoodDetailSurroundingNeighborItemCell class])];
        [self.contentView addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data) {
        return;
    }
    if ([data isKindOfClass:[FHDetailRelatedNeighborhoodResponseDataModel class]]) {
        self.currentData = data;
        
        self.items = [(FHDetailRelatedNeighborhoodResponseDataModel *)data items];
        [self.collectionView reloadData];
    }
}

#pragma mark - Delegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.houseShowBlock) {
        self.houseShowBlock(indexPath.item);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectIndexBlock) {
        self.selectIndexBlock(indexPath.item);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHNeighborhoodDetailSurroundingNeighborItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHNeighborhoodDetailSurroundingNeighborItemCell class]) forIndexPath:indexPath];
    [cell refreshWithData:self.items[indexPath.item]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    //需要显示 2 + 1/4 个模块
    
    CGFloat width = ceil((CGRectGetWidth(self.collectionView.frame) - 12 * 3) / 9.0 * 4.0);
    return CGSizeMake(width, CGRectGetHeight(collectionView.frame));
}

@end
