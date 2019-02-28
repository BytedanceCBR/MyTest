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
        colView.displayCellBlk = ^(NSInteger index) {
            [wSelf collectionDisplayCell:index];
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

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"same_neighborhood";// 同小区房源
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
        FHRentDetailResponseModel *detailData = self.baseViewModel.detailData;
        NSString *neighborhood_id = @"";
        NSString *house_id = @"";
        if (detailData && detailData.data.neighborhoodInfo.id.length > 0) {
            neighborhood_id = detailData.data.neighborhoodInfo.id;
        }
        if (self.baseViewModel.houseId.length > 0) {
            house_id = self.baseViewModel.houseId;
        }
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"enter_type"] = @"click";
        tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
        tracerDic[@"category_name"] = @"same_neighborhood_list";
        tracerDic[@"element_from"] = @"same_neighborhood";
        tracerDic[@"enter_from"] = @"rent_detail";
        [tracerDic removeObjectsForKeys:@[@"page_type",@"card_type"]];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        userInfo[@"tracer"] = tracerDic;
        userInfo[@"house_type"] = @(FHHouseTypeRentHouse);
        if (detailData.data.neighborhoodInfo.name.length > 0) {
            if (model.sameNeighborhoodHouseData.total.length > 0) {
                userInfo[@"title"] = [NSString stringWithFormat:@"%@(%@)",detailData.data.neighborhoodInfo.name,model.sameNeighborhoodHouseData.total];
            } else {
                userInfo[@"title"] = [NSString stringWithFormat:@"%@",detailData.data.neighborhoodInfo.name];
            }
        } else {
            userInfo[@"title"] = @"同小区房源";// 默认值
        }
        if (neighborhood_id.length > 0) {
            userInfo[@"neighborhood_id"] = neighborhood_id;
        }
        if (house_id.length > 0) {
            userInfo[@"house_id"] = house_id;
        }
        if (model.sameNeighborhoodHouseData.searchId.length > 0) {
            userInfo[@"search_id"] = model.sameNeighborhoodHouseData.searchId;
        }
        userInfo[@"list_vc_type"] = @(7);
        
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
    FHDetailRentSameNeighborhoodHouseModel *model = (FHDetailRentSameNeighborhoodHouseModel *)self.currentData;
    if (model.sameNeighborhoodHouseData && model.sameNeighborhoodHouseData.items.count > 0 && index >= 0 && index < model.sameNeighborhoodHouseData.items.count) {
        // 点击cell处理
        FHHouseRentDataItemsModel *dataItem = model.sameNeighborhoodHouseData.items[index];
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"slide";
        tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:FHHouseTypeRentHouse];
        tracerDic[@"element_from"] = @"same_neighborhood";
        tracerDic[@"enter_from"] = @"rent_detail";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDic,@"house_type":@(FHHouseTypeRentHouse)}];
        NSString * urlStr = [NSString stringWithFormat:@"sslocal://rent_detail?house_id=%@",dataItem.id];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

// 不重复调用
- (void)collectionDisplayCell:(NSInteger)index
{
    FHDetailRentSameNeighborhoodHouseModel *model = (FHDetailRentSameNeighborhoodHouseModel *)self.currentData;
    if (model.sameNeighborhoodHouseData && model.sameNeighborhoodHouseData.items.count > 0 && index >= 0 && index < model.sameNeighborhoodHouseData.items.count) {
        // cell 显示 处理
        FHHouseRentDataItemsModel *dataItem = model.sameNeighborhoodHouseData.items[index];
        // house_show
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"slide";
        tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:self.baseViewModel.houseType];
        tracerDic[@"element_type"] = @"same_neighborhood";
        tracerDic[@"search_id"] = dataItem.searchId ? dataItem.searchId : @"be_null";
        tracerDic[@"group_id"] = dataItem.groupId ? dataItem.groupId : (dataItem.id ? dataItem.id : @"be_null");
        tracerDic[@"impr_id"] = dataItem.imprId ? dataItem.imprId : @"be_null";
        [tracerDic removeObjectsForKeys:@[@"element_from"]];
        [FHUserTracker writeEvent:@"house_show" params:tracerDic];
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
