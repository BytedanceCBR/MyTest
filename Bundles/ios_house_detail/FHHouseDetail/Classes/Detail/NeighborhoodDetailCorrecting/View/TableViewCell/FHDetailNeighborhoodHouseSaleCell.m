//
//  FHDetailNeighborhoodHouseSaleCell.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/2/24.
//

#import "FHDetailNeighborhoodHouseSaleCell.h"
#import "FHDetailHeaderView.h"
#import "UIImageView+BDWebImage.h"
#import "FHSameHouseTagView.h"
#import "UILabel+House.h"
#import "FHDetailSurroundingAreaCell.h"
#import "FHOldDetailMultitemCollectionView.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHDetailNeighborhoodHouseStatusModel.h"
@interface FHDetailNeighborhoodHouseSaleCell()
@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong)   UIView       *containerView;
@end
@implementation FHDetailNeighborhoodHouseSaleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodHouseSaleModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    //
    FHDetailNeighborhoodHouseSaleModel *model = (FHDetailNeighborhoodHouseSaleModel *)data;
    self.shadowImage.image = model.shadowImage;
    if (model.shadowImageType == FHHouseShdowImageTypeLTR) {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.shadowImage).offset(-25);
        }];
    }
    if (model.shadowImageType == FHHouseShdowImageTypeLBR) {
        [self.headerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.shadowImage).offset(-5);
        }];
    }
    if (model.neighborhoodSoldHouseData) {
        self.headerView.label.text = [NSString stringWithFormat:@"在售套数 (%@)",model.neighborhoodSoldHouseData.total];
        self.headerView.isShowLoadMore = model.neighborhoodSoldHouseData.hasMore;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        NSMutableArray *dataArr = [[NSMutableArray alloc]initWithArray:model.neighborhoodSoldHouseData.items];
        if (model.neighborhoodSoldHouseData.hasMore && dataArr.count>3) {
            FHDetailMoreItemModel *moreItem = [[FHDetailMoreItemModel alloc]init];
            [dataArr addObject:moreItem];
        }
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        NSString *identifier = NSStringFromClass([FHSearchHouseDataItemsModel class]);
        NSString *moreIdentifier = NSStringFromClass([FHDetailMoreItemModel class]);
//        FHDetailMultitemCollectionView *colView = [[FHDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:210 cellIdentifier:identifier cellCls:[FHDetailSameNeighborhoodHouseCollectionCell class] datas:model.sameNeighborhoodHouseData.items];
        FHOldDetailMultitemCollectionView *colView = [[FHOldDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:210 datas:dataArr];
        [colView registerCell:[FHDetailNeighborhoodHouseSaleCollectionCell class] forIdentifier:identifier];
        [colView registerCell:[FHDetailMoreItemCollectionCell class] forIdentifier:moreIdentifier];
        [self.containerView addSubview:colView];
        __weak typeof(self) wSelf = self;
        colView.clickBlk = ^(NSInteger index) {
            if (index == model.neighborhoodSoldHouseData.items.count) {
                [wSelf moreButtonClick];
            }else {
                [wSelf collectionCellClick:index];
            }
        };
        colView.displayCellBlk = ^(NSInteger index) {
            [wSelf collectionDisplayCell:index];
        };
        [colView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(20);
            make.left.mas_equalTo(self.containerView).offset(15);
            make.right.mas_equalTo(self.containerView).offset(-15);
            make.bottom.mas_equalTo(self.containerView).offset(-10);
        }];
        [colView reloadData];
    }
    
    [self layoutIfNeeded];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"同小区房源";
    _headerView.loadMore.text = @"";
    _headerView.label.font = [UIFont themeFontMedium:20];
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.top.mas_equalTo(self.shadowImage).offset(30);
        make.height.mas_equalTo(46);
    }];
    [self.headerView addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.shadowImage).offset(-32);
    }];
}

// 查看更多
- (void)moreButtonClick {
     FHDetailNeighborhoodHouseSaleModel *model = (FHDetailNeighborhoodHouseSaleModel *)self.currentData;
    if (model.neighborhoodSoldHouseData  && model.neighborhoodSoldHouseData.hasMore) {
        FHDetailNeighborhoodModel *detailModel = (FHDetailNeighborhoodModel*)self.baseViewModel.detailData;
        NSString *neighborhood_id = @"be_null";
        if (detailModel && detailModel.data.neighborhoodInfo.id.length > 0) {
            neighborhood_id = detailModel.data.neighborhoodInfo.id;
        }
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"enter_type"] = @"click";
        tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
        tracerDic[@"category_name"] = @"same_neighborhood_list";
        tracerDic[@"element_from"] = @"same_neighborhood";
        tracerDic[@"enter_from"] = @"neighborhood_detail";
        [tracerDic removeObjectsForKeys:@[@"page_type",@"card_type"]];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        userInfo[@"tracer"] = tracerDic;
        userInfo[@"house_type"] = @(FHHouseTypeSecondHandHouse);
        if (detailModel.data.neighborhoodInfo.name.length > 0) {
            if (model.neighborhoodSoldHouseData.total.length > 0) {
                userInfo[@"title"] = [NSString stringWithFormat:@"小区房源(%@)",model.neighborhoodSoldHouseData.total];
            } else {
                userInfo[@"title"] = @"小区房源";
            }
        } else {
            userInfo[@"title"] = @"小区房源";// 默认值
        }
        if (neighborhood_id.length > 0) {
            userInfo[@"neighborhood_id"] = neighborhood_id;
        }
        if (self.baseViewModel.houseId.length > 0) {
            userInfo[@"house_id"] = self.baseViewModel.houseId;
        }
        if (model.neighborhoodSoldHouseData.searchId.length > 0) {
            userInfo[@"search_id"] = model.neighborhoodSoldHouseData.searchId;
        }
        userInfo[@"list_vc_type"] = @(5);
        
        TTRouteUserInfo *userInf = [[TTRouteUserInfo alloc] initWithInfo:userInfo];
        NSString * urlStr = [NSString stringWithFormat:@"snssdk1370://house_list_in_neighborhood"];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInf];
        }
    }
}
// cell 点击
- (void)collectionCellClick:(NSInteger)index {
    FHDetailNeighborhoodHouseSaleModel *model = (FHDetailNeighborhoodHouseSaleModel *)self.currentData;
    if (model.neighborhoodSoldHouseData && model.neighborhoodSoldHouseData.items.count > 0 && index >= 0 && index < model.neighborhoodSoldHouseData.items.count) {
        // 点击cell处理
        FHSearchHouseDataItemsModel *dataItem = model.neighborhoodSoldHouseData.items[index];
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"left_pic";
        tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:FHHouseTypeSecondHandHouse];
        tracerDic[@"element_from"] = @"same_neighborhood";
        tracerDic[@"enter_from"] = @"neighborhood_detail";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDic,@"house_type":@(FHHouseTypeSecondHandHouse)}];
        NSString * urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",dataItem.hid];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}
// 不重复调用
- (void)collectionDisplayCell:(NSInteger)index {
    FHDetailNeighborhoodHouseSaleModel *model = (FHDetailNeighborhoodHouseSaleModel *)self.currentData;
    if (model.neighborhoodSoldHouseData && model.neighborhoodSoldHouseData.items.count > 0 && index >= 0 && index < model.neighborhoodSoldHouseData.items.count) {
        // cell 显示 处理
        FHSearchHouseDataItemsModel *dataItem = model.neighborhoodSoldHouseData.items[index];
        // house_show
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"left_pic";
        tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:self.baseViewModel.houseType];
        tracerDic[@"element_type"] = @"sale_same_neighborhood";
        tracerDic[@"search_id"] = dataItem.searchId.length > 0 ? dataItem.searchId : @"be_null";
        tracerDic[@"group_id"] = dataItem.groupId.length > 0 ? dataItem.groupId : (dataItem.hid ? dataItem.hid : @"be_null");
        tracerDic[@"impr_id"] = dataItem.imprId.length > 0 ? dataItem.imprId : @"be_null";
        [FHUserTracker writeEvent:@"house_show" params:tracerDic];
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"sale_same_neighborhood";
}
@end
// FHDetailNeighborhoodItemCollectionCell
@interface FHDetailNeighborhoodHouseSaleCollectionCell ()

@property(nonatomic, strong) UILabel *imageTagLabel;
@property(nonatomic, strong) FHSameHouseTagView *imageTagLabelBgView;

@property (nonatomic, strong) UIImageView *imageBacView;
@end

@implementation FHDetailNeighborhoodHouseSaleCollectionCell

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
            self.imageTagLabelBgView.backgroundColor = [UIColor colorWithHexStr:@"#f3ae0c"];
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
        _imageTagLabelBgView.backgroundColor = [UIColor colorWithHexStr:@"#f3ae0c"];
        _imageTagLabelBgView.hidden = YES;
    }
    return _imageTagLabelBgView;
}
@end
