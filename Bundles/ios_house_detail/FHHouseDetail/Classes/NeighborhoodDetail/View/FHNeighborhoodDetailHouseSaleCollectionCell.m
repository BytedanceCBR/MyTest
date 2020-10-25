//
//  FHNeighborhoodDetailHouseSaleCollectionCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/12.
//

#import "FHNeighborhoodDetailHouseSaleCollectionCell.h"
#import "FHSameHouseTagView.h"
#import "UIImageView+BDWebImage.h"

@interface FHNeighborhoodDetailHouseSaleCollectionCell () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic,strong) NSMutableArray *items;

@end

@implementation FHNeighborhoodDetailHouseSaleCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    return CGSizeMake(width, 201);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        self.flowLayout.minimumInteritemSpacing = 10;
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds)) collectionViewLayout:self.flowLayout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[FHNeighborhoodDetailHouseSaleItemCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHSearchHouseDataItemsModel class])];
        [self.collectionView registerClass:[FHNeighborhoodDetailHouseSaleMoreItemCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHNeighborhoodDetailHouseSaleMoreItemModel class])];

        [self.contentView addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView);
            make.left.mas_equalTo(self.contentView);
            make.right.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.contentView).offset(-20);
        }];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if(self.currentData == data || ![data isKindOfClass:[FHNeighborhoodDetailHouseSaleCellModel class]]){
        return;
    }
    self.currentData = data;
    
    FHNeighborhoodDetailHouseSaleCellModel *model = (FHNeighborhoodDetailHouseSaleCellModel *) data;
    if(model.neighborhoodSoldHouseData.items.count > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            self.items = [model.neighborhoodSoldHouseData.items mutableCopy];
            if(model.neighborhoodSoldHouseData.hasMore) {
                FHNeighborhoodDetailHouseSaleMoreItemModel *moreItem = [[FHNeighborhoodDetailHouseSaleMoreItemModel alloc] init];
                [self.items addObject:moreItem];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        });
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
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHSearchHouseDataItemsModel class]) forIndexPath:indexPath];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if(self.didSelectItem){
        self.didSelectItem(indexPath.row);
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.items.count) {
        id data = self.items[indexPath.row];
        if([data isKindOfClass:[FHNeighborhoodDetailHouseSaleMoreItemModel class]]){
            return CGSizeMake(94, 181);
        }
    }
    return CGSizeMake(140, 181);
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.willShowItem){
        self.willShowItem(indexPath);
    }
}

-(NSString *)elementType {
    return @"sale_same_neighborhood";
}

@end


@interface FHNeighborhoodDetailHouseSaleItemCollectionCell ()

@property(nonatomic,strong) UIImageView *houseImageView;
@property(nonatomic,strong) UILabel *descriptionLabel;
@property(nonatomic,strong) UILabel *pricePerUnitLabel;
@property(nonatomic,strong) UILabel *totalPriceLabel;
@property(nonatomic,strong) FHSameHouseTagView *tagView;
@property(nonatomic,strong) FHSameHouseTagImageView *tagImageView;
@property(nonatomic,strong) UILabel *tagLabel;
@end

@implementation FHNeighborhoodDetailHouseSaleItemCollectionCell

-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

-(void)initView {
    self.houseImageView = [[UIImageView alloc] init];
    self.houseImageView.layer.cornerRadius = 10;
    self.houseImageView.layer.masksToBounds = YES;
    self.houseImageView.layer.borderWidth = 1;
    self.houseImageView.layer.borderColor = [UIColor themeGray6].CGColor;
    self.descriptionLabel = [[UILabel alloc] init];
    self.pricePerUnitLabel = [[UILabel alloc] init];
    self.totalPriceLabel = [[UILabel alloc] init];
    self.tagView = [[FHSameHouseTagView alloc] init];
    self.tagImageView = [[FHSameHouseTagImageView alloc] init];
    self.tagLabel = [[UILabel alloc] init];
    
    self.descriptionLabel.font = [UIFont themeFontMedium:16];
    self.descriptionLabel.textColor = [UIColor themeGray1];
    self.descriptionLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.pricePerUnitLabel.font = [UIFont themeFontRegular:12];
    self.pricePerUnitLabel.textColor = [UIColor themeGray3];
    self.totalPriceLabel.font = [UIFont themeFontMedium:16];
    self.totalPriceLabel.textColor = [UIColor themeOrange1];
    self.tagView.backgroundColor = [UIColor themeOrange4];
    self.tagView.hidden = YES;
    self.tagImageView.backgroundColor = [UIColor themeOrange4];
    self.tagImageView.hidden = YES;
    self.tagLabel.textColor = [UIColor themeWhite];
    self.tagLabel.textAlignment = NSTextAlignmentCenter;
    self.tagLabel.font = [UIFont themeFontRegular:12];

    [self.contentView addSubview:self.houseImageView];
    [self.contentView addSubview:self.descriptionLabel];
    [self.contentView addSubview:self.pricePerUnitLabel];
    [self.contentView addSubview:self.totalPriceLabel];
    [self.contentView addSubview:self.tagImageView];
    [self.tagView addSubview:self.tagLabel];
    [self.contentView addSubview:self.tagView];
    
    [self.houseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(120);
    }];
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.houseImageView.mas_bottom).mas_offset(12);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(22);
    }];
    [self.totalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descriptionLabel.mas_bottom).offset(6);
        make.left.equalTo(self.contentView);
        make.height.mas_equalTo(21);
    }];
    [self.pricePerUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descriptionLabel.mas_bottom).offset(10);
        make.left.equalTo(self.totalPriceLabel.mas_right).offset(4);
        make.height.mas_equalTo(14);
    }];
    [self.tagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView);
        make.height.mas_equalTo(20);
    }];
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.tagView);
        make.left.equalTo(self.tagView).offset(6);
        make.right.equalTo(self.tagView).offset(-6);
    }];
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
        return;
    }
    self.currentData = data;
    FHSearchHouseDataItemsModel *model = (FHSearchHouseDataItemsModel *)data;
    
    self.houseImageView.image = [UIImage imageNamed:@"default_image"];
    self.tagImageView.hidden = YES;
    self.tagView.hidden = YES;
    
    if (model.houseImage.count > 0) {
        FHImageModel *imageModel = model.houseImage.firstObject;
        if(imageModel.url.length > 0) {
            [self.houseImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed:@"default_image"]];
        }
    }
    
    //优先展示企业担保标签，然后展示降价房源标签
    if(model.tagImage.count > 0) {
        FHImageModel *imageModel = model.tagImage.firstObject;
        if(imageModel.url.length > 0) {
            [self.tagImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url]];
            self.tagImageView.hidden = NO;
        }
    } else if(model.houseImageTag.text.length > 0){
        self.tagLabel.text = model.houseImageTag.text;
        self.tagView.hidden = NO;
    }
    
    self.descriptionLabel.text = model.displayNewNeighborhoodTitle;
    self.totalPriceLabel.text = model.displayPrice;
    self.pricePerUnitLabel.text = model.displayPricePerSqm;
}


@end

@interface FHNeighborhoodDetailHouseSaleMoreItemCollectionCell ()
@property(nonatomic,strong) UIView *shadowView;
@property(nonatomic,strong) UIImageView *moreImageView;
@property(nonatomic,strong) UILabel *moreLabel;
@end

@implementation FHNeighborhoodDetailHouseSaleMoreItemCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initView];
    }
    return self;
}

- (void)initView {
    self.shadowView = [[UIView alloc] init];
    self.moreImageView = [[UIImageView alloc] init];
    self.moreLabel = [[UILabel alloc] init];
    
    self.shadowView.backgroundColor = [UIColor themeGray7];
    self.shadowView.layer.cornerRadius  = 10;
    self.moreImageView.image = [UIImage imageNamed:@"more_house"];
    self.moreLabel.font = [UIFont themeFontRegular:14];
    self.moreLabel.textColor = [UIColor colorWithHexStr:@"#aeadad"];
    self.moreLabel.text = @"查看更多";
    
    [self.contentView addSubview:self.shadowView];
    [self.contentView addSubview:self.moreImageView];
    [self.contentView addSubview:self.moreLabel];
    
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(120);
    }];
    [self.moreImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView).offset(34);
        make.size.mas_equalTo(CGSizeMake(26, 26));
    }];
    
    [self.moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.moreImageView.mas_bottom).offset(10);
    }];
}

@end


@implementation FHSameHouseTagImageView

- (void)layoutSubviews {
    [super layoutSubviews];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = self.bounds;
    layer.path = maskPath.CGPath;
    self.layer.mask = layer;
}

@end

@implementation FHNeighborhoodDetailHouseSaleCellModel

@end

@implementation FHNeighborhoodDetailHouseSaleMoreItemModel

@end
