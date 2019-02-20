//
//  FHDetailRelatedNeighborhoodCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/15.
//

#import "FHDetailRelatedNeighborhoodCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "UILabel+House.h"
#import "FHDetailHeaderView.h"
#import "FHDetailMultitemCollectionView.h"

@interface FHDetailRelatedNeighborhoodCell ()

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, strong)   UIView       *containerView;

@end

@implementation FHDetailRelatedNeighborhoodCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailRelatedNeighborhoodModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    //
    FHDetailRelatedNeighborhoodModel *model = (FHDetailRelatedNeighborhoodModel *)data;
    if (model.relatedNeighborhoodData) {
        self.headerView.label.text = [NSString stringWithFormat:@"周边小区(%@)",model.relatedNeighborhoodData.total];
        self.headerView.isShowLoadMore = model.relatedNeighborhoodData.hasMore;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        flowLayout.itemSize = CGSizeMake(156, 170);
        flowLayout.minimumLineSpacing = 10;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        NSString *identifier = NSStringFromClass([FHDetailNeighborhoodItemCollectionCell class]);
        FHDetailMultitemCollectionView *colView = [[FHDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:170 cellIdentifier:identifier cellCls:[FHDetailNeighborhoodItemCollectionCell class] datas:model.relatedNeighborhoodData.items];
        [self.containerView addSubview:colView];
        __weak typeof(self) wSelf = self;
        colView.clickBlk = ^(NSInteger index) {
            [wSelf collectionCellClick:index];
        };
        [colView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(20);
            make.left.right.mas_equalTo(self.containerView);
            make.bottom.mas_equalTo(self.containerView);
        }];
        [colView reloadData];
    }
    
    [self layoutIfNeeded];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"周边小区";
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(46);
    }];
    [self.headerView addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    _containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView).offset(-20);
    }];
}

// 查看更多
- (void)moreButtonClick:(UIButton *)button {
    FHDetailRelatedNeighborhoodModel *model = (FHDetailRelatedNeighborhoodModel *)self.currentData;
    if (model.relatedNeighborhoodData && model.relatedNeighborhoodData.hasMore) {
        // 点击事件处理
    }
}
// cell 点击
- (void)collectionCellClick:(NSInteger)index {
    FHDetailRelatedNeighborhoodModel *model = (FHDetailRelatedNeighborhoodModel *)self.currentData;
    if (model.relatedNeighborhoodData && model.relatedNeighborhoodData.items.count > 0 && index >= 0 && index < model.relatedNeighborhoodData.items.count) {
        // 点击cell处理
        FHDetailRelatedNeighborhoodResponseDataItemsModel *itemModel = model.relatedNeighborhoodData.items[index];
        
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"neighborhood_nearby"; // 周边小区
}

@end

// FHDetailNeighborhoodItemCollectionCell
@interface FHDetailNeighborhoodItemCollectionCell ()

@end

@implementation FHDetailNeighborhoodItemCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
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
                [self.icon bd_setImageWithURL:[NSURL URLWithString:urlStr] placeholder:[UIImage imageNamed:@"default_image"]];
            } else {
                self.icon.image = [UIImage imageNamed:@"default_image"];
            }
        } else {
            self.icon.image = [UIImage imageNamed:@"default_image"];
        }
        self.descLabel.text = model.displayTitle;
        self.priceLabel.text = model.displayPricePerSqm;
        self.spaceLabel.text = model.displayBuiltYear;
    }
    [self layoutIfNeeded];
}

- (void)setupUI {
    _icon = [[UIImageView alloc] init];
    _icon.layer.cornerRadius = 4.0;
    _icon.layer.masksToBounds = YES;
    _icon.layer.borderWidth = 0.5;
    _icon.layer.borderColor = [[UIColor colorWithHexString:@"#e8eaeb"] CGColor];
    [self addSubview:_icon];
    
    _descLabel = [UILabel createLabel:@"" textColor:@"#081f33" fontSize:16];
    [self addSubview:_descLabel];
    
    _priceLabel = [UILabel createLabel:@"" textColor:@"#f85959" fontSize:16];
    [self addSubview:_priceLabel];
    
    _spaceLabel = [UILabel createLabel:@"" textColor:@"#ffffff" fontSize:12];
    [self addSubview:_spaceLabel];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.width.mas_equalTo(156);
        make.height.mas_equalTo(116);
        make.top.mas_equalTo(self);
    }];
    
    UIColor *topColor = RGBA(255, 255, 255, 0);
    UIColor *bottomColor = RGBA(0, 0, 0, 0.5);
    NSArray *gradientColors = [NSArray arrayWithObjects:(id)(topColor.CGColor), (id)(bottomColor.CGColor), nil];
    NSArray *gradientLocations = @[@(0),@(1)];
    CAGradientLayer *gradientlayer = [[CAGradientLayer alloc] init];
    gradientlayer.colors = gradientColors;
    gradientlayer.locations = gradientLocations;
    gradientlayer.frame = CGRectMake(0, 0, 156, 120);
    gradientlayer.cornerRadius = 4.0;
    [self.icon.layer addSublayer:gradientlayer];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.icon.mas_bottom).offset(10);
    }];
    
    [self.spaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(17);
        make.right.mas_equalTo(self).offset(-6);
        make.bottom.mas_equalTo(self.icon.mas_bottom).offset(-6);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.descLabel.mas_bottom);
        make.bottom.mas_equalTo(self);
    }];
}

@end

// FHDetailRelatedNeighborhoodModel

@implementation FHDetailRelatedNeighborhoodModel

@end
