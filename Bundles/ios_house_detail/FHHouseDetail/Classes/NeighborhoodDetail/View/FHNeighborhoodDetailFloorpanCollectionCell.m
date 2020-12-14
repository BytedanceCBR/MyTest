//
//  FHNeighborhoodDetailFloorpanCollectionCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/14.
//

#import "FHNeighborhoodDetailFloorpanCollectionCell.h"

@interface FHNeighborhoodDetailFloorpanCollectionCell () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic,strong) NSArray *items;

@end


@implementation FHNeighborhoodDetailFloorpanCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    return CGSizeMake(width, 95 + 12);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 15);
        self.flowLayout.minimumLineSpacing = 8;
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds)) collectionViewLayout:self.flowLayout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[FHNeighborhoodDetailFloorpanItemCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodSaleHouseInfoItemModel class])];

        [self.contentView addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(12);
            make.left.mas_equalTo(self.contentView);
            make.right.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.contentView).offset(-10);
        }];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if(self.currentData == data || ![data isKindOfClass:[FHNeighborhoodDetailFloorpanCellModel class]]){
        return;
    }
    self.currentData = data;

    FHNeighborhoodDetailFloorpanCellModel *model = (FHNeighborhoodDetailFloorpanCellModel *) data;
    if(model.saleHouseInfoModel.neighborhoodSaleHouseList.count > 0) {
        self.items = model.saleHouseInfoModel.neighborhoodSaleHouseList;
        [self.collectionView reloadData];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.items.count) {
        id data = self.items[indexPath.row];
        NSString *identifier = NSStringFromClass([data class]);
        if(identifier.length > 0) {
            FHDetailBaseCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
            if(cell) {
                [cell refreshWithData:data];
                return cell;
            }
        }
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodSaleHouseInfoItemModel class]) forIndexPath:indexPath];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if(self.didSelectItem){
        self.didSelectItem(indexPath.row);
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(130, 85);
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.willShowItem){
        self.willShowItem(indexPath);
    }
}

-(NSString *)elementType {
    return @"neighborhood_model";
}

@end


@interface FHNeighborhoodDetailFloorpanItemCollectionCell ()
@property(nonatomic,strong) UIView *shadowView;
@property(nonatomic,strong) UILabel *numberLabel;
@property(nonatomic,strong) UILabel *roomLabel;
@property(nonatomic,strong) UILabel *priceLabel;
@end

@implementation FHNeighborhoodDetailFloorpanItemCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]) {
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor themeGray6].CGColor;
        self.layer.cornerRadius = 4;
        [self initView];
    }
    return self;
}


-(void)initView {
    
    self.roomLabel = [[UILabel alloc] init];
    self.roomLabel.textColor = [UIColor themeGray1];
    self.roomLabel.font = [UIFont themeFontMedium:16];
    [self.contentView addSubview:self.roomLabel];
    
    self.numberLabel = [[UILabel alloc] init];
    self.numberLabel.textColor = [UIColor themeGray1];
    self.numberLabel.font = [UIFont themeFontRegular:12];
    [self.contentView addSubview:self.numberLabel];
    
    self.priceLabel = [[UILabel alloc] init];
    self.priceLabel.font = [UIFont themeFontMedium:16];
    self.priceLabel.textColor = [UIColor themeOrange1];
    [self.contentView addSubview:self.priceLabel];
    
    [self.roomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.top.mas_equalTo(8);
        make.height.mas_equalTo(22);
        make.right.mas_equalTo(0);
    }];
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.roomLabel);
        make.top.mas_equalTo(self.roomLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(17);
        make.right.mas_equalTo(0);
    }];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.roomLabel);
        make.top.mas_equalTo(self.numberLabel.mas_bottom).offset(4);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(22);
    }];
}

-(void)refreshWithData:(id)data {
    if(self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodSaleHouseInfoItemModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailNeighborhoodSaleHouseInfoItemModel *model =(FHDetailNeighborhoodSaleHouseInfoItemModel *) data;
    self.roomLabel.text = [NSString stringWithFormat:@"%@居室",[self transformNumber:model.roomNum]];
    NSString *info = model.areaRange;
    if(model.count.length > 0) {
        info = [NSString stringWithFormat:@"%@ %@套", info, model.count];
    }
    self.numberLabel.text = info;
    self.priceLabel.text = model.priceRange;
}

-(NSString *)transformNumber:(NSString *)roomNumber {
    NSArray *numberArray =@[@"零",@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十"];
    NSInteger number = [roomNumber integerValue];
    if(number <= 10){
        return numberArray[number];
    }
    return @"多";
}

@end

@implementation FHNeighborhoodDetailFloorpanCellModel

@end
