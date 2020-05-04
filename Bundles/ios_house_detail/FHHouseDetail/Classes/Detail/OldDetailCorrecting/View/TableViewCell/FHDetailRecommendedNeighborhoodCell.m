//
//  FHDetailRecommendedNeighborhoodCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/5/3.
//

#import "FHDetailRecommendedNeighborhoodCell.h"
#import "FHDetailSurroundingAreaCell.h"
#import "FHOldDetailMultitemCollectionView.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "FHDetailCommonDefine.h"
#import "FHDetailHeaderView.h"
#import "UILabel+House.h"

@interface FHDetailRecommendedNeighborhoodCell ()

@property (nonatomic, strong) FHDetailHeaderView    *headerView;
@property (nonatomic, weak)   UIImageView           *shadowImage;
@property (nonatomic, strong) UIView                *containerView;

@end

@implementation FHDetailRecommendedNeighborhoodCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailRecommendedNeighborhoodModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    FHDetailRecommendedNeighborhoodModel *model = (FHDetailRecommendedNeighborhoodModel *)data;
    adjustImageScopeType(model);
    
    if (model.relatedNeighborhoodData) {
        self.headerView.label.text = [NSString stringWithFormat:@"推荐新盘 (%@)",model.relatedNeighborhoodData.total];
        self.headerView.isShowLoadMore = model.relatedNeighborhoodData.hasMore;
        NSMutableArray *dataArr = [[NSMutableArray alloc] initWithArray:model.relatedNeighborhoodData.items];
        if (model.relatedNeighborhoodData.hasMore && dataArr.count>5) {
            FHDetailMoreItemModel *moreItem = [[FHDetailMoreItemModel alloc]init];
            [dataArr addObject:moreItem];
        }
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        flowLayout.minimumLineSpacing = 10;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        NSString *identifier = NSStringFromClass([FHDetailRelatedNeighborhoodResponseDataItemsModel class]);
        NSString *moreIdentifier = NSStringFromClass([FHDetailMoreItemModel class]);
        FHOldDetailMultitemCollectionView *colView = [[FHOldDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:210 datas:dataArr];
        [colView registerCell:[FHDetailRecommendedNeighborhoodItemCollectionCell class] forIdentifier:identifier];
        [colView registerCell:[FHDetailMoreItemCollectionCell class] forIdentifier:moreIdentifier];
        [self.containerView addSubview:colView];
        __weak typeof(self) wSelf = self;
        colView.clickBlk = ^(NSInteger index) {
            if (index == model.relatedNeighborhoodData.items.count) {
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
            make.left.mas_equalTo(self.containerView);
            make.right.mas_equalTo(self.containerView);
            make.bottom.mas_equalTo(self.containerView).offset(-28);
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
        make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.bottom.mas_equalTo(self.shadowImage).offset(-12);
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
    FHDetailRecommendedNeighborhoodModel *model = (FHDetailRecommendedNeighborhoodModel *)self.currentData;
    if (model.relatedNeighborhoodData && model.relatedNeighborhoodData.hasMore) {
        
        NSString *searchId = model.relatedNeighborhoodData.searchId;
        
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
        if (model.neighborhoodId.length > 0) {
            infoDict[@"neighborhood_id"] = model.neighborhoodId;
        }

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
    FHDetailRecommendedNeighborhoodModel *model = (FHDetailRecommendedNeighborhoodModel *)self.currentData;
    if (model.relatedNeighborhoodData && model.relatedNeighborhoodData.items.count > 0 && index >= 0 && index < model.relatedNeighborhoodData.items.count) {
        // 点击cell处理
        FHDetailRelatedNeighborhoodResponseDataItemsModel *dataItem = model.relatedNeighborhoodData.items[index];
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"slide";
        tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:FHHouseTypeNeighborhood];
        tracerDic[@"element_from"] = @"neighborhood_nearby";
        tracerDic[@"enter_from"] = @"old_detail";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDic,@"house_type":@(FHHouseTypeNeighborhood)}];
        NSString * urlStr = [NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@",dataItem.id];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

// 不重复调用
- (void)collectionDisplayCell:(NSInteger)index
{
    FHDetailRecommendedNeighborhoodModel *model = (FHDetailRecommendedNeighborhoodModel *)self.currentData;
    if (model.relatedNeighborhoodData && model.relatedNeighborhoodData.items.count > 0 && index >= 0 && index < model.relatedNeighborhoodData.items.count) {
        // 点击cell处理
        FHDetailRelatedNeighborhoodResponseDataItemsModel *itemModel = model.relatedNeighborhoodData.items[index];
        // house_show
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"slide";
        tracerDic[@"log_pb"] = itemModel.logPb ? itemModel.logPb : @"be_null";
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:FHHouseTypeNeighborhood];
        tracerDic[@"element_type"] = @"neighborhood_nearby";
        tracerDic[@"search_id"] = itemModel.searchId.length > 0 ? itemModel.searchId : @"be_null";
        tracerDic[@"group_id"] = itemModel.groupId.length > 0 ? itemModel.groupId : (itemModel.id ? itemModel.id : @"be_null");
        tracerDic[@"impr_id"] = itemModel.imprId.length > 0 ? itemModel.imprId : @"be_null";
        [tracerDic removeObjectsForKeys:@[@"element_from"]];
        [FHUserTracker writeEvent:@"house_show" params:tracerDic];
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"recommended_neighborhood"; // 周边小区
}

@end

#pragma mark - FHDetailRecommendedNeighborhoodItemCollectionCell

@interface FHDetailRecommendedNeighborhoodItemCollectionCell()

@property(nonatomic, strong) UIImageView *imageBacView;

@end

@implementation FHDetailRecommendedNeighborhoodItemCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
    }
    return self;
}

- (void)refreshWithData:(id)data{
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
        self.nameLabel.text = model.displayTitle;
        self.priceLabel.text = model.displayPricePerSqm;
        self.spaceLabel.text = model.displayBuiltYear;
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
    [self addSubview:_icon];
    
    _nameLabel = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _nameLabel.font = [UIFont themeFontMedium:16];
    _nameLabel.textColor = [UIColor themeGray1];
    [self addSubview:_nameLabel];
    
    _spaceLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _spaceLabel.font = [UIFont themeFontRegular:12];
    _spaceLabel.textColor = [UIColor themeGray3];
    [self addSubview:_spaceLabel];
    
    _priceLabel = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _priceLabel.font = [UIFont themeFontMedium:16];
    _priceLabel.textColor = [UIColor themeOrange1];
    
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

@implementation FHDetailRecommendedNeighborhoodModel


@end
