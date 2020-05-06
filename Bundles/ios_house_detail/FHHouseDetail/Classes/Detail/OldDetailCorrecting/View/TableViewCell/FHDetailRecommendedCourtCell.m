//
//  FHDetailRecommendedCourtCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/5/3.
//

#import "FHDetailRecommendedCourtCell.h"
#import "FHDetailSurroundingAreaCell.h"
#import "FHOldDetailMultitemCollectionView.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "FHDetailCommonDefine.h"
#import "FHDetailHeaderView.h"
#import "UILabel+House.h"

@interface FHDetailRecommendedCourtCell ()

@property (nonatomic, strong) FHDetailHeaderView    *headerView;
@property (nonatomic, weak)   UIImageView           *shadowImage;
@property (nonatomic, strong) UIView                *containerView;

@end

@implementation FHDetailRecommendedCourtCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailRecommendedCourtModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    FHDetailRecommendedCourtModel *model = (FHDetailRecommendedCourtModel *)data;
    adjustImageScopeType(model);
    
    if (model.recommendedCourtData) {
        self.headerView.label.text = [NSString stringWithFormat:@"推荐新盘 (%@)",model.recommendedCourtData.total];
        self.headerView.isShowLoadMore = model.recommendedCourtData.hasMore;
        NSMutableArray *dataArr = [[NSMutableArray alloc] initWithArray:model.recommendedCourtData.items];
        if (model.recommendedCourtData.hasMore && dataArr.count>5) {
            FHDetailMoreItemModel *moreItem = [[FHDetailMoreItemModel alloc]init];
            [dataArr addObject:moreItem];
        }
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        NSString *identifier = NSStringFromClass([FHHouseListBaseItemModel class]);
        NSString *moreIdentifier = NSStringFromClass([FHDetailMoreItemModel class]);
        FHOldDetailMultitemCollectionView *colView = [[FHOldDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:210 datas:dataArr];
        [colView registerCell:[FHDetailRecommendedCourtItemCollectionCell class] forIdentifier:identifier];
        [colView registerCell:[FHDetailMoreItemCollectionCell class] forIdentifier:moreIdentifier];
        [self.containerView addSubview:colView];
        __weak typeof(self) wSelf = self;
        colView.clickBlk = ^(NSInteger index) {
            if (index == model.recommendedCourtData.items.count) {
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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI{
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView).offset(-12);
        make.bottom.mas_equalTo(self.contentView).offset(12);
    }];
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"推荐新盘";
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
- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}
// 查看更多
- (void)moreButtonClick {
    FHDetailRecommendedCourtModel *model = (FHDetailRecommendedCourtModel *)self.currentData;
    if (model.recommendedCourtData && model.recommendedCourtData.hasMore) {
        
        NSString *searchId = model.recommendedCourtData.searchId;
        
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"enter_type"] = @"click";
        tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
        tracerDic[@"category_name"] = @"neighborhood_nearby_list";
        tracerDic[@"element_type"] = @"be_null";
        tracerDic[@"element_from"] = @"neighborhood_nearby";
        
        NSMutableDictionary *infoDict = [NSMutableDictionary new];
        infoDict[@"tracer"] = tracerDic;
        infoDict[@"house_type"] = @(FHHouseTypeNeighborhood);
        infoDict[@"title"] = @"推荐新盘";
        // 周边小区跳转

        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
        NSString * urlStr = [NSString stringWithFormat:@"snssdk1370://related_neighborhood_list"];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

// cell 点击
- (void)collectionCellClick:(NSInteger)index {
    FHDetailRecommendedCourtModel *model = (FHDetailRecommendedCourtModel *)self.currentData;
    
    if (model.recommendedCourtData && model.recommendedCourtData.items.count > 0 && index >= 0 && index < model.recommendedCourtData.items.count) {
        FHHouseListBaseItemModel *dataItem = model.recommendedCourtData.items[index];
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"slide";
        tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:self.baseViewModel.houseType];
        tracerDic[@"element_from"] = @"related";
        tracerDic[@"enter_from"] = @"old_detail";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDic,@"house_type":@(FHHouseTypeNewHouse)}];
        NSString * urlStr = [NSString stringWithFormat:@"sslocal://new_house_detail?court_id=%@",dataItem.houseid];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

// 不重复调用
- (void)collectionDisplayCell:(NSInteger)index //注意联调时测试
{
    FHDetailRecommendedCourtModel *model = (FHDetailRecommendedCourtModel *)self.currentData;
    if (model.recommendedCourtData && model.recommendedCourtData.items.count > 0 && index >= 0 && index < model.recommendedCourtData.items.count) {
        // 点击cell处理
        FHHouseListBaseItemModel *dataItem = model.recommendedCourtData.items[index];
        // house_show
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"slide";
        tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:FHHouseTypeNeighborhood];
        tracerDic[@"element_type"] = @"neighborhood_nearby";
        tracerDic[@"search_id"] = dataItem.searchId.length > 0 ? dataItem.searchId : @"be_null";
        tracerDic[@"group_id"] = dataItem.groupId.length > 0 ? dataItem.groupId : (dataItem.id ? dataItem.id : @"be_null");
        tracerDic[@"impr_id"] = dataItem.imprId.length > 0 ? dataItem.imprId : @"be_null";
        [tracerDic removeObjectsForKeys:@[@"element_from"]];
        [FHUserTracker writeEvent:@"house_show" params:tracerDic];
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"recommended_court"; // 推荐新盘
}

@end

#pragma mark - FHDetailRecommendedCourtItemCollectionCell

@interface FHDetailRecommendedCourtItemCollectionCell()

@property(nonatomic, strong) UIImageView *imageBacView;

@end

@implementation FHDetailRecommendedCourtItemCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
    }
    return self;
}

- (void)refreshWithData:(id)data{
    if (self.currentData == data || ![data isKindOfClass:[FHHouseListBaseItemModel class]]) {
        return;
    }
    self.currentData = data;
    FHHouseListBaseItemModel *model = (FHHouseListBaseItemModel *)data;
    if (model) {
        if (model.images.count > 0) {
            FHImageModel *imageModel = model.houseImage.firstObject;
            NSString *urlStr = imageModel.url;
            if ([urlStr length] > 0) {
                [self.icon bd_setImageWithURL:[NSURL URLWithString:urlStr] placeholder:[UIImage imageNamed:@"default_image"]];
            } else {
                self.icon.image = [UIImage imageNamed:@"default_image"];
            }
        } else {
            self.icon.image = [UIImage imageNamed:@"default_image"];
        }
        self.nameLabel.text = model.displayTitle;
        self.priceLabel.text = model.displayPricePerSqm;
        self.spaceLabel.text = model.displayDescription;
    }
    [self layoutIfNeeded];
}

-(UIImageView *)imageBacView {
    if (!_imageBacView) {
        _imageBacView = [[UIImageView alloc]init];
        [_imageBacView setImage:[UIImage imageNamed:@"old_detail_house"]];
        _imageBacView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imageBacView;
}

- (void)setupUI {
    self.clipsToBounds = YES;
    _icon = [[UIImageView alloc] init];
    _icon.layer.cornerRadius = 10.0;
    _icon.layer.masksToBounds = YES;
    _icon.layer.borderColor = [[UIColor themeGray6] CGColor];
    _icon.layer.borderWidth = 0.5;
    [self.contentView addSubview:_icon];
    
    _nameLabel = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _nameLabel.font = [UIFont themeFontMedium:16];
    _nameLabel.textColor = [UIColor themeGray1];
    [self.contentView addSubview:_nameLabel];
    
    _spaceLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _spaceLabel.font = [UIFont themeFontRegular:12];
    _spaceLabel.textColor = [UIColor themeGray3];
    [self.contentView addSubview:_spaceLabel];
    
    _priceLabel = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _priceLabel.font = [UIFont themeFontMedium:16];
    _priceLabel.textColor = [UIColor themeOrange1];
    [self.contentView addSubview:_priceLabel];
    
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
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.icon);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.icon.mas_bottom).offset(10);
    }];
    [self.spaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.icon);
        make.height.mas_equalTo(14);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(5);
    }];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.icon);
        make.height.mas_equalTo(20);
        make.top.mas_equalTo(self.spaceLabel.mas_bottom).offset(11);
    }];
}

@end

@implementation FHDetailRecommendedCourtModel


@end
