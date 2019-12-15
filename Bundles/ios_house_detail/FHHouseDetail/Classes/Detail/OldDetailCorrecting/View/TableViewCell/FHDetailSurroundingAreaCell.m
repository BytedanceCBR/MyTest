//
//  FHDetailSurroundingAreaCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/15.
//

#import "FHDetailSurroundingAreaCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "UILabel+House.h"
#import "FHDetailHeaderView.h"
#import "FHOldDetailMultitemCollectionView.h"
@class FHDetailRelatedNeighborhoodResponseDataItemsModel;
@interface FHDetailSurroundingAreaCell ()

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong)   UIView       *containerView;

@end

@implementation FHDetailSurroundingAreaCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailSurroundingAreaModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    //
    FHDetailSurroundingAreaModel *model = (FHDetailSurroundingAreaModel *)data;
    self.shadowImage.image = model.shadowImage;
//    if (model.shadowImageType == FHHouseShdowImageTypeLBR) {
//        [self.headerView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.contentView);
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
    if (model.relatedNeighborhoodData) {
        self.headerView.label.text = [NSString stringWithFormat:@"周边小区 (%@)",model.relatedNeighborhoodData.total];
        self.headerView.isShowLoadMore = model.relatedNeighborhoodData.hasMore;
        NSMutableArray *dataArr = [[NSMutableArray alloc]initWithArray:model.relatedNeighborhoodData.items];
        if (model.relatedNeighborhoodData.hasMore && dataArr.count>3) {
            FHDetailMoreItemModel *moreItem = [[FHDetailMoreItemModel alloc]init];
            [dataArr addObject:moreItem];
        }
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        flowLayout.minimumLineSpacing = 10;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        NSString *identifier = NSStringFromClass([FHDetailRelatedNeighborhoodResponseDataItemsModel class]);
        NSString *moreIdentifier = NSStringFromClass([FHDetailMoreItemModel class]);
        FHOldDetailMultitemCollectionView *colView = [[FHOldDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:210 datas:model.relatedNeighborhoodData.items];
        [colView registerCell:[FHDetailSurroundingAreaItemCollectionCell class] forIdentifier:identifier];
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
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"周边小区";
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
        make.top.mas_equalTo(self.headerView);
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
    FHDetailSurroundingAreaModel *model = (FHDetailSurroundingAreaModel *)self.currentData;
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
        infoDict[@"title"] = @"周边小区";
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
    FHDetailSurroundingAreaModel *model = (FHDetailSurroundingAreaModel *)self.currentData;
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
    FHDetailSurroundingAreaModel *model = (FHDetailSurroundingAreaModel *)self.currentData;
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
    return @"neighborhood_nearby"; // 周边小区
}

@end

// FHDetailSurroundingAreaItemCollectionCell
@interface FHDetailSurroundingAreaItemCollectionCell ()
@property (nonatomic, strong) UIImageView *imageBacView;
@end

@implementation FHDetailSurroundingAreaItemCollectionCell

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
    _icon = [[UIImageView alloc] init];
    _icon.layer.cornerRadius = 10.0;
    _icon.layer.masksToBounds = YES;
    _icon.layer.borderColor = [[UIColor themeGray6] CGColor];
//    _icon.layer.shadowColor = [UIColor blackColor].CGColor;
//    _icon.layer.shadowOffset = CGSizeMake(3, 3);
//      _icon.layer.shadowOpacity = .5;
    _icon.layer.borderWidth = 0.5;
    _icon.layer.borderColor = [[UIColor themeGray6] CGColor];
    [self addSubview:_icon];
    
    _descLabel = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _descLabel.font = [UIFont themeFontMedium:16];
    _descLabel.textColor = [UIColor themeGray1];
    [self addSubview:_descLabel];
    
    _priceLabel = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _priceLabel.textColor = [UIColor colorWithHexStr:@"fe5500"];
    _priceLabel.font = [UIFont themeFontMedium:16];
    [self addSubview:_priceLabel];
    
    _spaceLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _spaceLabel.textColor = [UIColor themeGray3];
    [self addSubview:_spaceLabel];
    
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
        make.left.right.mas_equalTo(self.icon);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.icon.mas_bottom).offset(10);
    }];
    
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

@end

// FHDetailSurroundingAreaModel

@implementation FHDetailSurroundingAreaModel

@end

@interface FHDetailMoreItemCollectionCell()
@property (weak, nonatomic)UIView *bacView;
@property (weak, nonatomic)UIImageView *moreImage;
@property (weak, nonatomic)UILabel *moreLabel;



@end
@implementation FHDetailMoreItemCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.bacView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(6);
        make.width.mas_equalTo(94);
        make.height.mas_equalTo(120);
    }];
    [self.moreImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bacView);
        make.top.equalTo(self.bacView).offset(34);
        make.size.mas_offset(CGSizeMake(26, 26));
    }];
    [self.moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bacView);
        make.top.equalTo(self.moreImage.mas_bottom).offset(10);
    }];
}

- (UIView *)bacView {
    if (!_bacView) {
        UIView *bacView = [[UIView alloc]init];
        bacView.backgroundColor = [UIColor colorWithHexStr:@"#f5f5f5"];
        bacView.layer.cornerRadius = 10;
        [self.contentView addSubview:bacView];
        _bacView = bacView;
    }
    return _bacView;
}
- (UIImageView *)moreImage {
    if (!_moreImage) {
        UIImageView *moreImage = [[UIImageView alloc]init];
        moreImage.image = [UIImage imageNamed:@"more_house"];
        [self.bacView addSubview:moreImage];
        _moreImage = moreImage;
    }
    return _moreImage;
}

- (UILabel *)moreLabel
{
    if (!_moreLabel) {
        UILabel *moreLabel = [[UILabel alloc]init];
        moreLabel.font = [UIFont themeFontRegular:14];
        moreLabel.text = @"查看更多";
        moreLabel.textColor = [UIColor colorWithHexStr:@"#aeadad"];
        [self.bacView addSubview:moreLabel];
        _moreLabel = moreLabel;
    }
    return _moreLabel;
}
- (void)refreshWithData:(id)data {
    
}
@end
@implementation FHDetailMoreItemModel

@end
