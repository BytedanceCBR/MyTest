//
//  FHNeighborhoodDetailHouseSaleCollectionCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/12.
//

#import "FHNeighborhoodDetailHouseSaleCollectionCell.h"
#import "FHSameHouseTagView.h"
#import "UIImageView+BDWebImage.h"
#import "FHDetailSurroundingAreaCell.h"

@interface FHNeighborhoodDetailHouseSaleCollectionCell () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic,strong) NSMutableArray *items;

@end

@implementation FHNeighborhoodDetailHouseSaleCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    return CGSizeMake(width, 210);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        self.flowLayout.itemSize = CGSizeMake(120, 190);
        self.flowLayout.minimumLineSpacing = 0;
        self.flowLayout.minimumInteritemSpacing = 0;
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds)) collectionViewLayout:self.flowLayout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[FHNeighborhoodDetailHouseSaleItemCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHSearchHouseDataItemsModel class])];
        [self.collectionView registerClass:[FHDetailMoreItemCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHDetailMoreItemModel class])];

        [self.contentView addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(self.contentView).offset(15);
            make.right.mas_equalTo(self.contentView).offset(-15);
            make.bottom.mas_equalTo(self.contentView).offset(-10);
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
    if(model.neighborhoodSoldHouseData) {
        self.items = model.neighborhoodSoldHouseData.items.mutableCopy;
        if(model.neighborhoodSoldHouseData.hasMore && self.items.count > 3) {
            FHDetailMoreItemModel *moreItem = [[FHDetailMoreItemModel alloc] init];
            [self.items addObject:moreItem];
        }
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
    return [[FHDetailBaseCollectionCell alloc] init];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    FHNeighborhoodDetailHouseSaleCellModel *model = (FHNeighborhoodDetailHouseSaleCellModel *) self.currentData;
    if(indexPath.row == model.neighborhoodSoldHouseData.items.count) {
        if(self.didSelectMoreItem){
            self.didSelectMoreItem();
        }
    } else {
        if(self.didSelectItem){
            self.didSelectItem(indexPath.row);
        }
    }
}


@end


@interface FHNeighborhoodDetailHouseSaleItemCollectionCell ()

@property(nonatomic, strong) UILabel *imageTagLabel;
@property(nonatomic, strong) FHSameHouseTagView *imageTagLabelBgView;

@property (nonatomic, strong) UIImageView *imageBacView;
@end

@implementation FHNeighborhoodDetailHouseSaleItemCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHSearchHouseDataItemsModel class]]) {
        return;
    }
    self.currentData = data;
    FHSearchHouseDataItemsModel *model = (FHSearchHouseDataItemsModel *)data;
    if (model) {
        if (model.houseImage.count > 0) {
            FHImageModel *imageModel = model.houseImage[0];
            NSString *urlStr = imageModel.url;
            if ([urlStr length] > 0) {
                [self.icon bd_setImageWithURL:[NSURL URLWithString:urlStr] placeholder:[UIImage imageNamed:@"default_image"]];
            } else {
                self.icon.image = [UIImage imageNamed:@"default_image"];
            }
        } else {
            self.icon.image = [UIImage imageNamed:@"default_image"];
        }
        
        if (model.houseImageTag.text) {
            self.imageTagLabel.textColor = [UIColor whiteColor];
            self.imageTagLabel.text = model.houseImageTag.text;
            self.imageTagLabelBgView.backgroundColor = [UIColor themeOrange4];
            self.imageTagLabelBgView.hidden = NO;
        }else {
            self.imageTagLabelBgView.hidden = YES;
        }
        
        self.houseVideoImageView.hidden = !model.houseVideo.hasVideo;
        
        NSString *str = model.displaySameNeighborhoodTitle;
        if (str == nil) {
            str = @"";
        }
        NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:str];
        attributeText.yy_font = [UIFont themeFontMedium:16];
        attributeText.yy_color = [UIColor themeGray1];
        self.descLabel.attributedText = attributeText;
        self.priceLabel.text = model.displayPrice;
        self.spaceLabel.text = model.displayPricePerSqm;
    }
    [self layoutIfNeeded];
}

-(UIImageView *)imageBacView
{
    if (!_imageBacView) {
        _imageBacView = [[UIImageView alloc]init];
        [_imageBacView setImage:[UIImage imageNamed:@"old_detail_house"]];
        _imageBacView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageBacView;
}

- (void)setupUI {
    self.clipsToBounds = YES;
    [self.contentView addSubview:self.imageBacView];
    _icon = [[UIImageView alloc] init];
    _icon.layer.cornerRadius = 10.0;
    _icon.layer.borderWidth = 0.5;
    _icon.clipsToBounds = YES;
    _icon.layer.borderColor = [[UIColor themeGray6] CGColor];
    _icon.layer.shadowColor = [UIColor blackColor].CGColor;
    _icon.layer.shadowOffset = CGSizeMake(5, 5);
    _icon.layer.shadowOpacity = 1;
    _icon.image = [UIImage imageNamed:@"default_image"];
    [self.contentView addSubview:_icon];
    
    _houseVideoImageView = [[UIImageView alloc] init];
    _houseVideoImageView.image = [UIImage imageNamed:@"icon_list_house_video"];
    _houseVideoImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_houseVideoImageView];
    
    _descLabel = [[YYLabel alloc] init];
    [self.contentView addSubview:_descLabel];
    
    _priceLabel = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _priceLabel.textColor = [UIColor colorWithHexStr:@"fe5500"];
    _priceLabel.font = [UIFont themeFontMedium:16];
    [self.contentView addSubview:_priceLabel];
    
    _spaceLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _spaceLabel.textColor = [UIColor themeGray3];
    [self.contentView addSubview:_spaceLabel];
    
    [self.contentView addSubview:self.imageTagLabelBgView];
    [self.imageTagLabelBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon);
        make.top.mas_equalTo(self.icon).mas_offset(0);
        make.height.mas_equalTo(@20);
    }];
    
    [self.imageTagLabelBgView addSubview:self.imageTagLabel];
    [self.imageTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(6);
        make.right.mas_equalTo(-6);
        make.center.mas_equalTo(self.imageTagLabelBgView);
    }];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.width.mas_equalTo(140);
        make.height.mas_equalTo(120);
        make.top.mas_equalTo(self.contentView).offset(6);
    }];
    [self.imageBacView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(-10);
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(140);
        make.top.mas_equalTo(self.contentView);
    }];
    [self.houseVideoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.icon);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.icon);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.icon.mas_bottom).offset(10);
    }];
    [_priceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_priceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.spaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon);
        make.right.mas_equalTo(self.icon);
        make.height.mas_equalTo(17);
        make.top.mas_equalTo(self.descLabel.mas_bottom).offset(3);
    }];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.spaceLabel.mas_bottom).offset(8);
    }];
}

- (UILabel *)imageTagLabel
{
    if (!_imageTagLabel) {
        _imageTagLabel = [[UILabel alloc]init];
        _imageTagLabel.textAlignment = NSTextAlignmentCenter;
        _imageTagLabel.font = [UIFont themeFontRegular:12];
        _imageTagLabel.textColor = [UIColor whiteColor];
    }
    return _imageTagLabel;
}

- (FHSameHouseTagView *)imageTagLabelBgView
{
    if (!_imageTagLabelBgView) {
        _imageTagLabelBgView = [[FHSameHouseTagView alloc]init];
        _imageTagLabelBgView.backgroundColor = [UIColor themeOrange4];
        _imageTagLabelBgView.hidden = YES;
    }
    return _imageTagLabelBgView;
}
@end


@implementation FHNeighborhoodDetailHouseSaleCellModel

@end
