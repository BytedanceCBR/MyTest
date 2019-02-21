//
//  FHDetailRentSameNeighborhoodHouseCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/18.
//

#import "FHDetailRentSameNeighborhoodHouseCell.h"
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

@interface FHDetailRentSameNeighborhoodHouseCell ()

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, strong)   UIView       *containerView;

@end

@implementation FHDetailRentSameNeighborhoodHouseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailRentSameNeighborhoodHouseModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    //
    FHDetailRentSameNeighborhoodHouseModel *model = (FHDetailRentSameNeighborhoodHouseModel *)data;
    if (model.sameNeighborhoodHouseData) {
        self.headerView.label.text = [NSString stringWithFormat:@"同小区房源(%@)",model.sameNeighborhoodHouseData.total];
        self.headerView.isShowLoadMore = model.sameNeighborhoodHouseData.hasMore;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        flowLayout.itemSize = CGSizeMake(156, 166);
        flowLayout.minimumLineSpacing = 10;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        NSString *identifier = NSStringFromClass([FHDetailRentSameNeighborhoodHouseCollectionCell class]);
        FHDetailMultitemCollectionView *colView = [[FHDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:166 cellIdentifier:identifier cellCls:[FHDetailRentSameNeighborhoodHouseCollectionCell class] datas:model.sameNeighborhoodHouseData.items];
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
    _headerView.label.text = @"同小区房源";
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
    FHDetailRentSameNeighborhoodHouseModel *model = (FHDetailRentSameNeighborhoodHouseModel *)self.currentData;
    if (model.sameNeighborhoodHouseData && model.sameNeighborhoodHouseData.hasMore) {
        // 点击事件处理
    }
}
// cell 点击
- (void)collectionCellClick:(NSInteger)index {
    FHDetailRentSameNeighborhoodHouseModel *model = (FHDetailRentSameNeighborhoodHouseModel *)self.currentData;
    if (model.sameNeighborhoodHouseData && model.sameNeighborhoodHouseData.items.count > 0 && index >= 0 && index < model.sameNeighborhoodHouseData.items.count) {
        // 点击cell处理
        FHHouseRentDataItemsModel *itemModel = model.sameNeighborhoodHouseData.items[index];
        
    }
}


@end


// FHDetailRentSameNeighborhoodHouseCollectionCell
@interface FHDetailRentSameNeighborhoodHouseCollectionCell ()

@end

@implementation FHDetailRentSameNeighborhoodHouseCollectionCell

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
    if (self.currentData == data || ![data isKindOfClass:[FHHouseRentDataItemsModel class]]) {
        return;
    }
    self.currentData = data;
    FHHouseRentDataItemsModel *model = (FHHouseRentDataItemsModel *)data;
    if (model) {
        if (model.houseImage.count > 0) {
            FHSearchHouseDataItemsHouseImageModel *imageModel = model.houseImage[0];
            NSString *urlStr = imageModel.url;
            if ([urlStr length] > 0) {
                [self.icon bd_setImageWithURL:[NSURL URLWithString:urlStr] placeholder:[UIImage imageNamed:@"default_image"]];
            } else {
                self.icon.image = [UIImage imageNamed:@"default_image"];
            }
        } else {
            self.icon.image = [UIImage imageNamed:@"default_image"];
        }
        NSString *str = model.title;
        if (str == nil) {
            str = @"";
        }
        NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:str];
        attributeText.yy_font = [UIFont themeFontRegular:16];
        attributeText.yy_color = [UIColor colorWithHexString:@"#081f33"];
        self.descLabel.attributedText = attributeText;
        self.priceLabel.text = model.pricing;
    }
    [self layoutIfNeeded];
}

- (void)setupUI {
    _icon = [[UIImageView alloc] init];
    _icon.layer.cornerRadius = 4.0;
    _icon.layer.masksToBounds = YES;
    _icon.layer.borderWidth = 0.5;
    _icon.layer.borderColor = [[UIColor colorWithHexString:@"#e8eaeb"] CGColor];
    _icon.image = [UIImage imageNamed:@"default_image"];
    [self addSubview:_icon];
    
    _descLabel = [[YYLabel alloc] init];
    [self addSubview:_descLabel];
    
    _priceLabel = [UILabel createLabel:@"" textColor:@"#f85959" fontSize:16];
    _priceLabel.font = [UIFont themeFontMedium:16];
    [self addSubview:_priceLabel];
    
    _spaceLabel = [UILabel createLabel:@"" textColor:@"#a1aab3" fontSize:12];
    [self addSubview:_spaceLabel];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.width.mas_equalTo(156);
        make.height.mas_equalTo(116);
        make.top.mas_equalTo(self);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.icon.mas_bottom).offset(9);
    }];
    [_priceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_priceLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.descLabel.mas_bottom).offset(3);
    }];
    
    [self.spaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.priceLabel.mas_right).offset(6);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(22);
        make.centerY.mas_equalTo(self.priceLabel.mas_centerY);
        make.bottom.mas_equalTo(self);
    }];
}

@end


// FHDetailRentSameNeighborhoodHouseModel
@implementation FHDetailRentSameNeighborhoodHouseModel


@end
