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
#import "UIDevice+BTDAdditions.h"


CGFloat getSameNeighborhoodHouseImageWidth(void);
CGFloat getSameNeighborhoodHouseImageHeight(void);
@interface FHDetailSameNeighborhoodHouseCell () <UICollectionViewDataSource,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) FHDetailHeaderView *headerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic,strong) NSArray *dataList;
@property (nonatomic, strong) NSMutableDictionary *houseShowCache;
@end

@implementation FHDetailSameNeighborhoodHouseCell

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
        NSMutableArray *dataArr = [[NSMutableArray alloc]initWithArray:model.sameNeighborhoodHouseData.items];
        if (model.sameNeighborhoodHouseData.hasMore) {
            FHDetailSameNeighborhoodHouseSaleMoreItemModel *moreItem = [[FHDetailSameNeighborhoodHouseSaleMoreItemModel alloc] init];
            [dataArr addObject:moreItem];
            UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting-arrow-1"]];
            UILabel *moreLabel = [[UILabel alloc] init];
            moreLabel.font = [UIFont themeFontRegular:14];
            moreLabel.textColor = [UIColor themeGray1];
            moreLabel.text = @"查看全部";
            [self.headerView addSubview:moreLabel];
            [self.headerView addSubview:arrowView];
            [arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.headerView).offset(16);
                make.right.equalTo(self.headerView).offset(-12);
                make.width.height.mas_equalTo(14);
            }];
            [moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.headerView).offset(16);
                make.right.equalTo(self.headerView).offset(-28);
                make.height.mas_equalTo(14);
                make.width.mas_equalTo(56);
            }];
            moreLabel.userInteractionEnabled = YES;
            arrowView.userInteractionEnabled = YES;
            [moreLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreButtonClick)]];
            [arrowView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreButtonClick)]];
        }
        self.dataList = dataArr;
        self.houseShowCache = [NSMutableDictionary dictionary];
        [self initCollectionView];
    }
    
    [self layoutIfNeeded];
}

- (void)initCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.minimumInteritemSpacing = 12;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    NSString *identifier = NSStringFromClass([FHSearchHouseDataItemsModel class]);
    NSString *moreIdentifier = NSStringFromClass([FHDetailSameNeighborhoodHouseSaleMoreItemModel class]);
    [collectionView registerClass:[FHDetailSameNeighborhoodHouseSaleItemCollectionCell class] forCellWithReuseIdentifier:identifier];
    [collectionView registerClass:[FHDetailSameNeighborhoodHouseSaleMoreItemCollectionCell class] forCellWithReuseIdentifier:moreIdentifier];
    
    [self.containerView addSubview:collectionView];
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView).offset(0);
        make.left.mas_equalTo(self.containerView).offset(21);
        make.right.mas_equalTo(self.containerView).offset(-9);
        make.bottom.mas_equalTo(self.containerView).offset(0);
        make.height.mas_equalTo(getSameNeighborhoodHouseImageHeight() + 80);
    }];
    [collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id data = self.dataList[indexPath.row];
    FHDetailBaseCollectionCell *cell;
    NSString *identifier = NSStringFromClass([data class]);
    if (identifier.length > 0) {
          cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        if (indexPath.row < self.dataList.count) {
            [cell refreshWithData:self.dataList[indexPath.row]];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id data = self.dataList[indexPath.row];
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if ([data isKindOfClass:[FHDetailSameNeighborhoodHouseSaleMoreItemModel class]]) {
        [self moreButtonClick];
    }else {
        [self collectionCellClick:indexPath.row];
    }
}

// house_show埋点
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    if ([self.houseShowCache valueForKey:tempKey]) {
        return;
    }
    [self.houseShowCache setValue:@(YES) forKey:tempKey];
    // 添加埋点
    [self collectionDisplayCell:indexPath.row];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id data = self.dataList[indexPath.row];
    if ([data isKindOfClass:[FHDetailSameNeighborhoodHouseSaleMoreItemModel class]]) {
        return CGSizeMake(94, getSameNeighborhoodHouseImageHeight() + 60);
    }
    return CGSizeMake(getSameNeighborhoodHouseImageWidth(), getSameNeighborhoodHouseImageHeight() + 60);
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
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(-4.5, 0, -4.5, 0));
    }];
    
    _headerView = [[FHDetailHeaderView alloc] init];
    [_headerView updateLayoutWithOldDetail];
    _headerView.label.text = @"同小区房源";
    _headerView.loadMore.text = @"";
    //_headerView.label.font = [UIFont themeFontMedium:20];
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(9);
        make.right.mas_equalTo(self.contentView).offset(-9);
        make.top.mas_equalTo(self.contentView).offset(4.5);
        make.height.mas_equalTo(32);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(4);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView).offset(-4.5);
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
        make.height.mas_equalTo(getSameNeighborhoodHouseImageHeight());
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
        make.height.mas_equalTo(getSameNeighborhoodHouseImageHeight());
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

CGFloat getSameNeighborhoodHouseImageWidth() {
    CGFloat width = 180;
    if([UIDevice btd_isScreenWidthLarge320]) {
        width = ceil((SCREEN_WIDTH - (15 * 2 + 16 + 10)) * 4.0 / 7.0);
    }
    return width;
}

CGFloat getSameNeighborhoodHouseImageHeight() {
    return ceil(getSameNeighborhoodHouseImageWidth() * 0.75);
}
