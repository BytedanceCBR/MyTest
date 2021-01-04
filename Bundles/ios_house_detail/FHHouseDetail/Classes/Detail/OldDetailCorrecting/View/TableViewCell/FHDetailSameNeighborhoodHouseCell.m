//
//  FHDetailSameNeighborhoodHouseCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/17.
//

#import "FHDetailSameNeighborhoodHouseCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "UILabel+House.h"
#import "FHDetailHeaderView.h"
#import "FHDetailMultitemCollectionView.h"
#import "FHSameHouseTagView.h"
#import "FHOldDetailMultitemCollectionView.h"
#import "FHDetailSurroundingAreaCell.h"
@interface FHDetailSameNeighborhoodHouseCell ()
@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong)   UIView       *containerView;

@end

@implementation FHDetailSameNeighborhoodHouseCell



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailSameNeighborhoodHouseModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    //
    FHDetailSameNeighborhoodHouseModel *model = (FHDetailSameNeighborhoodHouseModel *)data;
    self.shadowImage.image = model.shadowImage;
//    if (model.shadowImageType == FHHouseShdowImageTypeLTR) {
//        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.bottom.mas_equalTo(self.contentView);
//        }];
//    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    if (model.shadowImageType == FHHouseShdowImageTypeLTR) {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.shadowImage).offset(-25);
        }];
    }
    if (model.sameNeighborhoodHouseData) {
        self.headerView.label.text = [NSString stringWithFormat:@"同小区房源 (%@)",model.sameNeighborhoodHouseData.total];
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        NSMutableArray *dataArr = [[NSMutableArray alloc]initWithArray:model.sameNeighborhoodHouseData.items];
        if (model.sameNeighborhoodHouseData.hasMore) {
            FHDetailSameNeighborhoodHouseSaleMoreItemModel *moreItem = [[FHDetailSameNeighborhoodHouseSaleMoreItemModel alloc] init];
            [dataArr addObject:moreItem];
        }
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        NSString *identifier = NSStringFromClass([FHSearchHouseDataItemsModel class]);
        NSString *moreIdentifier = NSStringFromClass([FHDetailSameNeighborhoodHouseSaleMoreItemModel class]);
//        FHDetailMultitemCollectionView *colView = [[FHDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:210 cellIdentifier:identifier cellCls:[FHDetailSameNeighborhoodHouseCollectionCell class] datas:model.sameNeighborhoodHouseData.items];
        FHOldDetailMultitemCollectionView *colView = [[FHOldDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:216 datas:dataArr];
        [colView registerCell:[FHDetailSameNeighborhoodHouseSaleItemCollectionCell class] forIdentifier:identifier];
        [colView registerCell:[FHDetailSameNeighborhoodHouseSaleMoreItemCollectionCell class] forIdentifier:moreIdentifier];
        [self.containerView addSubview:colView];
        __weak typeof(self) wSelf = self;
        colView.clickBlk = ^(NSInteger index) {
            if (index == model.sameNeighborhoodHouseData.items.count) {
                [wSelf moreButtonClick];
            }else {
                [wSelf collectionCellClick:index];
            }
        };
        colView.displayCellBlk = ^(NSInteger index) {
            [wSelf collectionDisplayCell:index];
        };
        [colView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.containerView).offset(6);
            make.left.mas_equalTo(self.containerView).offset(15);
            make.right.mas_equalTo(self.containerView).offset(-15);
            make.bottom.mas_equalTo(self.containerView).offset(-10);
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
        make.top.equalTo(self.contentView).offset(-14);
        make.bottom.equalTo(self.contentView).offset(14);
    }];
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"同小区房源";
    _headerView.loadMore.text = @"";
    _headerView.label.font = [UIFont themeFontMedium:20];
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.top.mas_equalTo(self.shadowImage).offset(20);
        make.height.mas_equalTo(46);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.shadowImage).offset(-20);
    }];
}

// 查看更多
- (void)moreButtonClick {
    FHDetailSameNeighborhoodHouseModel *model = (FHDetailSameNeighborhoodHouseModel *)self.currentData;
    if (model.sameNeighborhoodHouseData && model.sameNeighborhoodHouseData.hasMore) {
        // click_loadmore 埋点不再需要
        FHDetailOldModel *oldDetail = self.baseViewModel.detailData;
        // 同小区房源
        NSString *group_id = @"be_null";
        if (oldDetail && oldDetail.data.neighborhoodInfo.id.length > 0) {
            group_id = oldDetail.data.neighborhoodInfo.id;
        }
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"enter_type"] = @"click";
        tracerDic[@"log_pb"] = self.baseViewModel.listLogPB;
        tracerDic[@"category_name"] = @"same_neighborhood_list";
        tracerDic[@"element_from"] = @"same_neighborhood";
        tracerDic[@"enter_from"] = @"old_detail";
        [tracerDic removeObjectsForKeys:@[@"page_type",@"card_type"]];
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        userInfo[@"tracer"] = tracerDic;
        userInfo[@"house_type"] = @(FHHouseTypeSecondHandHouse);
        if (oldDetail.data.neighborhoodInfo.name.length > 0) {
            if (model.sameNeighborhoodHouseData.total.length > 0) {
                userInfo[@"title"] = [NSString stringWithFormat:@"%@(%@)",oldDetail.data.neighborhoodInfo.name,model.sameNeighborhoodHouseData.total];
            } else {
                userInfo[@"title"] = [NSString stringWithFormat:@"%@",oldDetail.data.neighborhoodInfo.name];
            }
        } else {
            userInfo[@"title"] = @"同小区房源";// 默认值
        }
        if (oldDetail.data.neighborhoodInfo.id.length > 0) {
            userInfo[@"neighborhood_id"] = oldDetail.data.neighborhoodInfo.id;
        }
        if (self.baseViewModel.houseId.length > 0) {
            userInfo[@"house_id"] = self.baseViewModel.houseId;
        }
        if (model.sameNeighborhoodHouseData.searchId.length > 0) {
            userInfo[@"search_id"] = model.sameNeighborhoodHouseData.searchId;
        }
        userInfo[@"list_vc_type"] = @(1);
        
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
    FHDetailSameNeighborhoodHouseModel *model = (FHDetailSameNeighborhoodHouseModel *)self.currentData;
    if (model.sameNeighborhoodHouseData && model.sameNeighborhoodHouseData.items.count > 0 && index >= 0 && index < model.sameNeighborhoodHouseData.items.count) {
        // 点击cell处理
        FHSearchHouseDataItemsModel *dataItem = model.sameNeighborhoodHouseData.items[index];
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"slide";
        tracerDic[@"log_pb"] = dataItem.logPb;
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:FHHouseTypeSecondHandHouse];
        tracerDic[@"element_from"] = @"same_neighborhood";
        tracerDic[@"enter_from"] = @"old_detail";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDic,@"house_type":@(FHHouseTypeSecondHandHouse)}];
        NSString * urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",dataItem.hid];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

// 不重复调用
- (void)collectionDisplayCell:(NSInteger)index
{
    FHDetailSameNeighborhoodHouseModel *model = (FHDetailSameNeighborhoodHouseModel *)self.currentData;
    if (model.sameNeighborhoodHouseData && model.sameNeighborhoodHouseData.items.count > 0 && index >= 0 && index < model.sameNeighborhoodHouseData.items.count) {
        // cell 显示 处理
        FHSearchHouseDataItemsModel *dataItem = model.sameNeighborhoodHouseData.items[index];
        // house_show
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"slide";
        tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:self.baseViewModel.houseType];
        tracerDic[@"element_type"] = @"same_neighborhood";
        tracerDic[@"search_id"] = dataItem.searchId.length > 0 ? dataItem.searchId : @"be_null";
        tracerDic[@"group_id"] = dataItem.groupId.length > 0 ? dataItem.groupId : (dataItem.hid.length > 0  ? dataItem.hid : @"be_null");
        tracerDic[@"impr_id"] = dataItem.imprId.length > 0 ? dataItem.imprId : @"be_null";
        [tracerDic removeObjectsForKeys:@[@"element_from"]];
        [FHUserTracker writeEvent:@"house_show" params:tracerDic];
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"same_neighborhood";// 同小区房源
}


@end

@interface FHDetailSameNeighborhoodHouseSaleItemCollectionCell ()

@property(nonatomic,strong) UIImageView *houseImageView;
@property(nonatomic,strong) UILabel *descriptionLabel;
@property(nonatomic,strong) UILabel *pricePerUnitLabel;
@property(nonatomic,strong) UILabel *totalPriceLabel;
@property(nonatomic,strong) FHSameHouseTagView *tagView;
@property(nonatomic,strong) FHSameHouseTagImageView *tagImageView;
@property(nonatomic,strong) UILabel *tagLabel;
@end

@implementation FHDetailSameNeighborhoodHouseSaleItemCollectionCell

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
        make.height.mas_equalTo(135);
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

@interface FHDetailSameNeighborhoodHouseSaleMoreItemCollectionCell ()
@property(nonatomic,strong) UIView *shadowView;
@property(nonatomic,strong) UIImageView *moreImageView;
@property(nonatomic,strong) UILabel *moreLabel;
@end

@implementation FHDetailSameNeighborhoodHouseSaleMoreItemCollectionCell

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
        make.height.mas_equalTo(135);
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

@implementation FHDetailSameNeighborhoodHouseSaleMoreItemModel

@end

@implementation FHDetailSameNeighborhoodHouseModel


@end
