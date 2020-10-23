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
    return CGSizeMake(width, 115);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
        self.flowLayout.minimumInteritemSpacing = 10;
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds)) collectionViewLayout:self.flowLayout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[FHNeighborhoodDetailFloorpanItemCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodSaleHouseInfoItemModel class])];

        [self.contentView addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView);
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
    return CGSizeMake(130, 105);
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
        [self initView];
    }
    return self;
}


-(void)initView {
    self.shadowView = [[UIView alloc] init];
    self.numberLabel = [[UILabel alloc] init];
    self.roomLabel = [[UILabel alloc] init];
    self.priceLabel = [[UILabel alloc] init];
    
    self.shadowView.backgroundColor = [UIColor themeWhite];
    self.shadowView.layer.cornerRadius = 10;
    self.shadowView.layer.masksToBounds = YES;
    self.numberLabel.textColor = [UIColor themeGray1];
    self.roomLabel.textColor = [UIColor themeGray1];
    self.roomLabel.font = [UIFont themeFontSemibold:12];
    self.priceLabel.font = [UIFont themeFontMedium:12];
    self.priceLabel.textColor = [UIColor themeOrange1];
    
    [self.contentView addSubview:self.shadowView];
    [self.contentView addSubview:self.numberLabel];
    [self.contentView addSubview:self.roomLabel];
    [self.contentView addSubview:self.priceLabel];
    
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(12);
        make.left.equalTo(self.contentView).offset(12);
        make.height.mas_equalTo(33);
    }];
    [self.roomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.numberLabel.mas_bottom).offset(8);
        make.left.equalTo(self.contentView).offset(12);
        make.height.mas_equalTo(17);
    }];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.roomLabel.mas_bottom).offset(2);
        make.left.equalTo(self.contentView).offset(12);
        make.height.mas_equalTo(17);
    }];
}

-(void)refreshWithData:(id)data {
    if(self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodSaleHouseInfoItemModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailNeighborhoodSaleHouseInfoItemModel *model =(FHDetailNeighborhoodSaleHouseInfoItemModel *) data;
    
    self.numberLabel.attributedText = nil;
    self.roomLabel.text = nil;
    
    if(model.count.length > 0) {
        NSString *numberText = [NSString stringWithFormat:@"%@套",model.count];
        NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:numberText];
        [attrText addAttribute:NSFontAttributeName value:[UIFont themeFontMedium:24] range:[numberText rangeOfString:model.count]];
        [attrText addAttribute:NSFontAttributeName value:[UIFont themeFontMedium:12] range:[numberText rangeOfString:@"套"]];
        self.numberLabel.attributedText = attrText;
    }
    
    if(model.roomNum.length > 0 && model.areaRange.length > 0){
        self.roomLabel.text = [NSString stringWithFormat:@"%@居室 %@",[self transformNumber:model.roomNum],model.areaRange];
    }
    
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
