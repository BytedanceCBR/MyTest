//
//  FHDetailNewMutiFloorPanCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/17.
//

#import "FHDetailNewMutiFloorPanCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "UILabel+House.h"
#import "FHDetailHeaderView.h"
#import "FHHouseNewDetailViewModel.h"
#import "FHDetailMultitemCollectionView.h"
#import <TTAccountSDK/TTAccount.h>
#import <FHHouseBase/FHHouseIMClueHelper.h>
#import "FHEnvContext.h"

#define ITEM_HEIGHT 242
#define ITEM_BOTTOM_HEIGHT 35
#define ITEM_WIDTH  184

@interface FHDetailNewMutiFloorPanCell ()

@property (nonatomic, strong) FHDetailHeaderView *headerView;
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, strong) UIImageView *shadowImage;

@end

@implementation FHDetailNewMutiFloorPanCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNewMutiFloorPanCellModel class]]) {
        return;
    }
    self.currentData = data;
    UIView *collectionView = [self.containerView viewWithTag:100];
    [collectionView removeFromSuperview];
    
    FHDetailNewMutiFloorPanCellModel *currentModel = (FHDetailNewMutiFloorPanCellModel *)data;
    adjustImageScopeType(currentModel)

    FHDetailNewDataFloorpanListModel *model = currentModel.floorPanList;
    if (model.list) {
        
        BOOL hasIM = NO;
        for (NSInteger i = 0; i < model.list.count; i++) {
            FHDetailNewDataFloorpanListListModel *listItemModel = model.list[i];
            listItemModel.index = i;
            if (listItemModel.imOpenUrl.length > 0) {
                hasIM = YES;
            }
        }
        if (model.totalNumber.length > 0) {
            self.headerView.label.text = [NSString stringWithFormat:@"户型介绍（%@）",model.totalNumber];
        }else {
            self.headerView.label.text = @"户型介绍";
        }
        self.headerView.isShowLoadMore = model.hasMore;
        CGFloat itemHeight = ITEM_HEIGHT;
        if (hasIM) {
            itemHeight = ITEM_HEIGHT + ITEM_BOTTOM_HEIGHT;
        }
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
        flowLayout.itemSize = CGSizeMake(ITEM_WIDTH, itemHeight);
        flowLayout.minimumLineSpacing = 10;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        NSString *identifier = NSStringFromClass([FHDetailNewMutiFloorPanCollectionCell class]);
        FHDetailMultitemCollectionView *colView = [[FHDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:itemHeight cellIdentifier:identifier cellCls:[FHDetailNewMutiFloorPanCollectionCell class] datas:model.list];
        colView.tag = 100;
        [self.containerView addSubview:colView];
        __weak typeof(self) wSelf = self;
        colView.clickBlk = ^(NSInteger index) {
            [wSelf collectionCellClick:index];
        };
        colView.itemClickBlk = ^(NSInteger index, UIView *itemView, FHDetailBaseCollectionCell *cell) {
            [wSelf collectionCellItemClick:index item:itemView cell: cell];
        };
        colView.displayCellBlk = ^(NSInteger index) {
            [wSelf collectionDisplayCell:index];
        };
        [colView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.right.mas_equalTo(self.containerView);
//            make.height.mas_equalTo(242);
            make.bottom.mas_equalTo(self.containerView).mas_offset(-30);
        }];
        [colView reloadData];
    }
    
    [self layoutIfNeeded];
}

// 不重复调用
- (void)collectionDisplayCell:(NSInteger)index
{
    FHDetailNewMutiFloorPanCellModel *currentModel = (FHDetailNewMutiFloorPanCellModel *)self.currentData;
    FHDetailNewDataFloorpanListModel *model = currentModel.floorPanList;
    if (model.list && model.list.count > 0 && index >= 0 && index < model.list.count) {
        // 点击cell处理
        FHDetailNewDataFloorpanListListModel *itemModel = model.list[index];
        // house_show
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"slide";
        tracerDic[@"log_pb"] = itemModel.logPb ? itemModel.logPb : @"be_null";
        tracerDic[@"house_type"] = @"house_model";
        tracerDic[@"element_type"] = @"house_model";
        if (itemModel.logPb) {
            [tracerDic addEntriesFromDictionary:itemModel.logPb];
        }
        if (itemModel.searchId) {
            [tracerDic setValue:itemModel.searchId forKey:@"search_id"];
        }
        if ([itemModel.groupId isKindOfClass:[NSString class]] && itemModel.groupId.length > 0) {
            [tracerDic setValue:itemModel.groupId forKey:@"group_id"];
        }else
        {
            [tracerDic setValue:itemModel.id forKey:@"group_id"];
        }
        if (itemModel.imprId) {
            [tracerDic setValue:itemModel.imprId forKey:@"impr_id"];
        }
        [tracerDic removeObjectForKey:@"enter_from"];
        [tracerDic removeObjectForKey:@"element_from"];
        [FHUserTracker writeEvent:@"house_show" params:tracerDic];
    }
}

- (void)setupUI {
    
    [self.contentView addSubview:self.shadowImage];
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"楼盘户型";
    [self.headerView addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.shadowImage).offset(15);
        make.right.mas_equalTo(self.shadowImage).offset(-15);
        make.top.mas_equalTo(self.shadowImage).offset(30);
        make.height.mas_equalTo(46);
    }];
    
    _containerView = [[UIView alloc] init];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).mas_offset(30);
        make.left.mas_equalTo(self.shadowImage).mas_offset(15);
        make.right.mas_equalTo(self.shadowImage).mas_offset(-15);
        make.bottom.mas_equalTo(self.shadowImage).offset(-20);
    }];
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"house_model";
}

// 查看更多
- (void)moreButtonClick:(UIButton *)button {
    FHDetailNewMutiFloorPanCellModel *currentModel = (FHDetailNewMutiFloorPanCellModel *)self.currentData;
    FHDetailNewDataFloorpanListModel *model = currentModel.floorPanList;

    if ([model isKindOfClass:[FHDetailNewDataFloorpanListModel class]] && model.hasMore) {
        NSMutableDictionary *infoDict = [NSMutableDictionary new];
        [infoDict setValue:model.list forKey:@"court_id"];
        [infoDict addEntriesFromDictionary:[self.baseViewModel subPageParams]];
        infoDict[@"house_type"] = @(1);
        TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://floor_pan_list"] userInfo:info];
    }

}
// cell 点击
- (void)collectionCellClick:(NSInteger)index {
    FHDetailNewMutiFloorPanCellModel *currentModel = (FHDetailNewMutiFloorPanCellModel *)self.currentData;
    FHDetailNewDataFloorpanListModel *model = currentModel.floorPanList;
    if ([model isKindOfClass:[FHDetailNewDataFloorpanListModel class]]) {
        if (model.list.count > index) {
            FHDetailNewDataFloorpanListListModel *floorPanInfoModel = model.list[index];
            if ([floorPanInfoModel isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
                NSMutableDictionary *traceParam = [NSMutableDictionary new];
                traceParam[@"enter_from"] = @"new_detail";
                traceParam[@"log_pb"] = floorPanInfoModel.logPb;
                traceParam[@"origin_from"] = self.baseViewModel.detailTracerDic[@"origin_from"];
                traceParam[@"card_type"] = @"left_pic";
                traceParam[@"rank"] = @(floorPanInfoModel.index);
                traceParam[@"origin_search_id"] = self.baseViewModel.detailTracerDic[@"origin_search_id"];
                traceParam[@"element_from"] = @"house_model";
                
                NSDictionary *dict = @{@"house_type":@(1),
                                       @"tracer": traceParam
                                       };
                
                NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithDictionary:nil];
                infoDict[@"house_type"] = @(1);
                [infoDict setValue:floorPanInfoModel.id forKey:@"floor_plan_id"];
                NSMutableDictionary *subPageParams = [self.baseViewModel subPageParams];
                subPageParams[@"contact_phone"] = nil;
                [infoDict addEntriesFromDictionary:subPageParams];
                infoDict[@"tracer"] = traceParam;
                TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];

                [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://floor_plan_detail"] userInfo:info];
            }
        }
    }
}

- (void)collectionCellItemClick:(NSInteger)index item:(UIView *)itemView cell:(FHDetailBaseCollectionCell *)cell
{
    FHDetailNewMutiFloorPanCollectionCell *collectionCell = (FHDetailNewMutiFloorPanCollectionCell *)cell;
    if (![collectionCell isKindOfClass:[FHDetailNewMutiFloorPanCollectionCell class]]) {
        return;
    }
    // 一键咨询户型按钮点击
    FHDetailNewMutiFloorPanCellModel *currentModel = (FHDetailNewMutiFloorPanCellModel *)self.currentData;
    FHDetailNewDataFloorpanListModel *model = currentModel.floorPanList;
    if(collectionCell.consultDetailButton != itemView || ![model isKindOfClass:[FHDetailNewDataFloorpanListModel class]]) {
        return;
    }
    if (index < 0 || index >= model.list.count ) {
        return;
    }
    FHDetailNewDataFloorpanListListModel *floorPanInfoModel = model.list[index];
    if (![floorPanInfoModel isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
        return;
    }
    
    if([FHEnvContext isSwitchToIMNew] == NO) {
        FHHouseIMClueConfigModel *configModel = [[FHHouseIMClueConfigModel alloc]init];
        configModel.houseId = self.baseViewModel.houseId;
        configModel.houseType = self.baseViewModel.houseType;
        configModel.enterFrom = self.baseViewModel.detailTracerDic[@"enter_from"];
        configModel.elementFrom = @"house_model";
        configModel.logPb = floorPanInfoModel.logPb;
        configModel.originFrom = self.baseViewModel.detailTracerDic[@"origin_from"];
        configModel.rank = self.baseViewModel.detailTracerDic[@"rank"];
        configModel.originSearchId = self.baseViewModel.detailTracerDic[@"origin_search_id"];
        configModel.searchId = self.baseViewModel.detailTracerDic[@"search_id"];
        configModel.imprId = floorPanInfoModel.imprId;
        configModel.pageType = [self.baseViewModel pageTypeString];
        FHDetailContactModel *contactPhone = self.baseViewModel.contactViewModel.contactPhone;
        configModel.realtorId = contactPhone.realtorId;
        configModel.realtorRank = @"0";
        configModel.conversationId = @"be_null";// todo zjing test
        configModel.realtorLogpb = contactPhone.realtorLogpb;
        configModel.from = @"app_newhouse_floorplan";
        configModel.realtorPosition = @"house_model";
        configModel.sourceFrom = @"house_model";// todo zjing test
        configModel.clueEndpoint = @(FHClueEndPointTypeC);
        configModel.cluePage = @(FHClueIMPageTypeCNewHouseApartmentConsult);
        configModel.imOpenUrl = floorPanInfoModel.imOpenUrl;
        configModel.extraInfo = @{@"house_model_rank":@(index)};
        [FHHouseIMClueHelper jump2SessionPageWithConfigModel:configModel];
    }
    
    else {
    
        // IM 透传数据模型
        FHAssociateIMModel *associateIMModel = [FHAssociateIMModel new];
        associateIMModel.houseId = self.baseViewModel.houseId;
        associateIMModel.houseType = self.baseViewModel.houseType;
        if([self.baseViewModel.detailData isKindOfClass:FHDetailNewModel.class]) {
            FHDetailNewModel *detailNewModel = (FHDetailNewModel *)self.baseViewModel.detailData;
            if(detailNewModel.data.floorplanListAssociateInfo) {
                associateIMModel.associateInfo = detailNewModel.data.floorplanListAssociateInfo;
            }
        }
        // IM 相关埋点上报参数
        FHAssociateReportParams *reportParams = [FHAssociateReportParams new];
        reportParams.enterFrom = self.baseViewModel.detailTracerDic[@"enter_from"];
        reportParams.elementFrom = @"house_model";
        reportParams.logPb = floorPanInfoModel.logPb;
        reportParams.originFrom = self.baseViewModel.detailTracerDic[@"origin_from"];
        reportParams.rank = self.baseViewModel.detailTracerDic[@"rank"];
        reportParams.originSearchId = self.baseViewModel.detailTracerDic[@"origin_search_id"];
        reportParams.searchId = self.baseViewModel.detailTracerDic[@"search_id"];
        reportParams.pageType = [self.baseViewModel pageTypeString];
        FHDetailContactModel *contactPhone = self.baseViewModel.contactViewModel.contactPhone;
        reportParams.realtorId = contactPhone.realtorId;
        reportParams.realtorRank = @"0";
        reportParams.conversationId = @"be_null";
        reportParams.realtorLogpb = contactPhone.realtorLogpb;
        reportParams.realtorPosition = @"house_model";
        reportParams.sourceFrom = @"house_model";
        reportParams.extra = @{@"house_model_rank":@(index)};
        associateIMModel.reportParams = reportParams;
        
        // IM跳转链接
        associateIMModel.imOpenUrl = floorPanInfoModel.imOpenUrl;
        // 跳转IM
        [FHHouseIMClueHelper jump2SessionPageWithAssociateIM:associateIMModel];
    }
}

- (UIImageView *)shadowImage
{
    if (!_shadowImage) {
        _shadowImage = [[UIImageView alloc]init];
    }
    return _shadowImage;
}

@end

@interface FHDetailNewMutiFloorPanCollectionCell ()

@end

@implementation FHDetailNewMutiFloorPanCollectionCell

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
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailNewDataFloorpanListListModel *model = (FHDetailNewDataFloorpanListListModel *)data;
    if (model) {
        if (model.images.count > 0) {
            
            FHDetailNewDataFloorpanListListImagesModel *imageModel = model.images.firstObject;
            NSString *urlStr = imageModel.url;
            if ([urlStr length] > 0) {
                WeakSelf;
//                [self.icon bd_setImageWithURL:[NSURL URLWithString:urlStr] placeholder:[UIImage imageNamed:@"detail_new_floorpan_default"]];
                [[BDWebImageManager sharedManager] requestImage:[NSURL URLWithString:urlStr] options:BDImageRequestHighPriority complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
                    StrongSelf;
                    if (!error && image) {
                        self.icon.image = image;
                        self.icon.contentMode = UIViewContentModeScaleAspectFit;
                    }
                }];
            }
        }
        self.consultDetailButton.hidden = model.imOpenUrl.length > 0 ? NO : YES;
        self.descLabel.text = model.title;
        self.spaceLabel.text = [NSString stringWithFormat:@"建面 %@ 朝向 %@",model.squaremeter,model.facingDirection];
    }
    [self layoutIfNeeded];
}

- (void)setupUI {
    
    _iconView = [[UIView alloc]init];
    _iconView.layer.borderWidth = 0.5;
    _iconView.layer.borderColor = [[UIColor colorWithHexString:@"#ededed"] CGColor];
    _iconView.layer.cornerRadius = 10.0;
     _iconView.layer.masksToBounds = YES;
    [self addSubview:_iconView];

    _icon = [[UIImageView alloc] init];
    _icon.image = [UIImage imageNamed:@"detail_new_floorpan_default"];
    [_iconView addSubview:_icon];
    _icon.contentMode = UIViewContentModeScaleAspectFill;

    _descLabel = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _descLabel.font = [UIFont themeFontMedium:16];
    _descLabel.textColor = [UIColor themeGray1];
    [self addSubview:_descLabel];
    
    _spaceLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _spaceLabel.textColor = [UIColor themeGray3];
    [self addSubview:_spaceLabel];
    
    _consultDetailButton = [[UIButton alloc] init];
    [_consultDetailButton setTitle:@"一键咨询户型详情" forState:UIControlStateNormal];
    [_consultDetailButton setTitleColor:[UIColor themeOrange4] forState:UIControlStateNormal];
    _consultDetailButton.titleLabel.font = [UIFont themeFontMedium:14];
    _consultDetailButton.backgroundColor = [UIColor colorWithHexStr:@"#FFF8EF"];
    _consultDetailButton.layer.masksToBounds = YES;
    _consultDetailButton.layer.cornerRadius = 16;
    [_consultDetailButton addTarget:self action:@selector(consultDetailButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_consultDetailButton];
    _consultDetailButton.hidden = YES;
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.right.equalTo(self);
        make.width.height.mas_equalTo(ITEM_WIDTH);
    }];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.iconView);
        make.width.height.equalTo(self.iconView);
    }];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconView.mas_bottom).mas_offset(10);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(20);
        
    }];
    [self.spaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descLabel.mas_bottom).offset(6);
        make.left.equalTo(self.descLabel);
        make.right.equalTo(self);
        make.height.mas_equalTo(15);
    }];
    
    [self.consultDetailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.spaceLabel.mas_bottom).offset(10);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(32);
    }];
}

- (void)consultDetailButtonAction:(UIButton *)sender {
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickCellItem:onCell:)]) {
        [self.delegate clickCellItem:sender onCell:self];
    }
}

@end

@implementation FHDetailNewMutiFloorPanCellModel



@end

