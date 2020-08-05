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

#define ITEM_WIDTH  120

@interface FHDetailNewMutiFloorPanCell ()<FHDetailScrollViewDidScrollProtocol>

@property (nonatomic, strong) FHDetailHeaderView *headerView;
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, strong) UIImageView *shadowImage;
@property (nonatomic, strong)   NSMutableDictionary *houseShowCache;
@property (nonatomic, strong)   NSMutableDictionary *subHouseShowCache;
@property (strong, nonatomic)  FHDetailMultitemCollectionView *colView;

@end

@implementation FHDetailNewMutiFloorPanCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        self.houseShowCache = [NSMutableDictionary new];
        self.subHouseShowCache = [NSMutableDictionary new];
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
            if (model.totalNumber.integerValue >= 3) {
                self.headerView.isShowLoadMore = YES;
                self.headerView.userInteractionEnabled = YES;
            } else {
                self.headerView.isShowLoadMore = NO;
                self.headerView.userInteractionEnabled = NO;
            }
        } else {
            self.headerView.label.text = @"户型介绍";
            self.headerView.isShowLoadMore = NO;
            self.headerView.userInteractionEnabled = NO;
        }
        CGFloat itemHeight = 190;
        if (hasIM) {
            itemHeight = 190 + 30;
        }
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        flowLayout.itemSize = CGSizeMake(ITEM_WIDTH, itemHeight);
        flowLayout.minimumLineSpacing = 16;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        NSString *identifier = NSStringFromClass([FHDetailNewMutiFloorPanCollectionCell class]);
        _colView = [[FHDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:itemHeight cellIdentifier:identifier cellCls:[FHDetailNewMutiFloorPanCollectionCell class] datas:model.list];
        _colView.tag = 100;
        _colView.isNewHouseFloorPan = YES;
        [self.containerView addSubview:_colView];
        __weak typeof(self) wSelf = self;
        _colView.clickBlk = ^(NSInteger index) {
            [wSelf collectionCellClick:index];
        };
        _colView.itemClickBlk = ^(NSInteger index, UIView *itemView, FHDetailBaseCollectionCell *cell) {
            [wSelf collectionCellItemClick:index item:itemView cell: cell];
        };
        _colView.displayCellBlk = ^(NSInteger index) {
            [wSelf collectionDisplayCell:index];
        };
        [_colView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.right.mas_equalTo(self.containerView);
//            make.height.mas_equalTo(242);
            make.bottom.mas_equalTo(self.containerView).mas_offset(-30);
        }];
        [_colView reloadData];
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

    if ([model isKindOfClass:[FHDetailNewDataFloorpanListModel class]]) {
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
//                NSDictionary *dict = @{@"house_type":@(1),
//                                       @"tracer": traceParam
//                                       };
                NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
                infoDict[@"house_type"] = @(1);
                [infoDict setValue:floorPanInfoModel.id forKey:@"floor_plan_id"];
                NSMutableDictionary *subPageParams = [self.baseViewModel subPageParams].mutableCopy;
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
    
    // IM 透传数据模型
    FHAssociateIMModel *associateIMModel = [FHAssociateIMModel new];
    associateIMModel.houseId = self.baseViewModel.houseId;
    associateIMModel.houseType = self.baseViewModel.houseType;
    associateIMModel.associateInfo = floorPanInfoModel.associateInfo;

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
    reportParams.realtorRank = @(0);
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

- (UIImageView *)shadowImage
{
    if (!_shadowImage) {
        _shadowImage = [[UIImageView alloc]init];
    }
    return _shadowImage;
}

- (void)fhDetail_scrollViewDidScroll:(UIView *)vcParentView {
        if (vcParentView) {
//            UIWindow* window = [UIApplication sharedApplication].keyWindow;
            CGFloat SH = [UIScreen mainScreen].bounds.size.height;
            CGPoint point = [self convertPoint:CGPointZero toView:vcParentView];
            CGFloat bottombarHight =  self.baseViewModel.houseType ==FHHouseTypeRentHouse? 64:80;
            if (SH -bottombarHight >point.y) {
              if ([self.houseShowCache valueForKey:@"isShowFloorPan"]) {
                    return;
              }else {
                  NSArray * visibles = self.colView.collectionContainer.indexPathsForVisibleItems;
                  [self.houseShowCache setValue:@(YES) forKey:@"isShowFloorPan"];
                  [visibles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                      NSIndexPath *indexPath = (NSIndexPath *)obj;
                      [self collectionDisplayCell:indexPath.row];
                      NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
                      [self.subHouseShowCache setValue:@(YES) forKey:tempKey];
                  }];
                  _colView.subHouseShowCache = self.subHouseShowCache;
              }
            }
    }
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
    [self.tagBacView removeAllTag];
    if (model) {
        if (model.images.count > 0) {
            FHImageModel *imageModel = model.images.firstObject;
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
//        self.spaceLabel.text = [NSString stringWithFormat:@"%@ %@",model.squaremeter,model.facingDirection];
        
//        NSMutableArray *tagArr = [NSMutableArray array];
//        self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",model.title,model.squaremeter];;
        self.titleLabel.text = model.title;
        self.spaceLabel.text = model.squaremeter;
        
        self.priceLabel.text = model.pricing;
        [self.priceLabel sizeToFit];
        CGSize itemSize = [self.priceLabel sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIFont themeFontSemibold:16].lineHeight)];
        CGFloat width = itemSize.width;
        
//        [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(width);
//        }];
        //1.0.2 需求缩小户型图大小，横屏查看2.5个左右，不能显示更多tag
        [self.tagBacView refreshWithTags:model.tags withNum:model.tags.count withMaxLen:ITEM_WIDTH - width - 4];
    }
    [self layoutIfNeeded];
}

- (void)setupUI {
    
    _iconView = [[UIView alloc]init];
    _iconView.layer.borderWidth = 0.5;
    _iconView.layer.borderColor = [[UIColor themeGray6] CGColor];
    _iconView.layer.cornerRadius = 10.0;
    _iconView.layer.masksToBounds = YES;
    self.iconView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.left.right.equalTo(self.contentView);
        make.width.height.mas_equalTo(ITEM_WIDTH);
    }];
    
    _icon = [[UIImageView alloc] init];
    _icon.image = [UIImage imageNamed:@"detail_new_floorpan_default"];
    [_iconView addSubview:_icon];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.iconView);
        make.width.height.equalTo(self.iconView);
    }];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont themeFontMedium:14];
    _titleLabel.textColor = [UIColor themeGray1];
    [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self addSubview:_titleLabel];
    
    _spaceLabel = [[UILabel alloc] init];;
    _spaceLabel.font = [UIFont themeFontMedium:14];
    _spaceLabel.textColor = [UIColor themeGray1];
    [_spaceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self addSubview:_spaceLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconView.mas_bottom).mas_offset(8);
        make.left.equalTo(self.contentView);
        make.height.mas_equalTo(19);
//        make.width.mas_equalTo(0);
    }];
    
    [self.spaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_top);
        make.left.equalTo(self.titleLabel.mas_right).mas_offset(2);
        make.right.equalTo(self.contentView);
        make.height.mas_equalTo(self.titleLabel.mas_height);
    }];
    
    _priceLabel = [[UILabel alloc] init];
    _priceLabel.textColor = [UIColor themeOrange1];
    _priceLabel.font = [UIFont themeFontRegular:14];
    [self addSubview:_priceLabel];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(6);
        make.left.equalTo(self.contentView);
        make.height.mas_equalTo(16);
    }];
    
    _tagBacView = [[FHDetailTagBackgroundView alloc] initWithLabelHeight:16.0 withCornerRadius:2.0];
    [_tagBacView setMarginWithTagMargin:4.0 withInsideMargin:4.0];
    _tagBacView.textFont = [UIFont themeFontMedium:10.0];
    [self addSubview:_tagBacView];
    [self.tagBacView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.priceLabel.mas_right).offset(4);
        make.right.mas_equalTo(self.iconView);
        make.centerY.mas_equalTo(self.priceLabel);
        make.height.mas_equalTo(16);
    }];
    
    _consultDetailButton = [[UIButton alloc] init];
    [_consultDetailButton setTitle:@"咨询户型" forState:UIControlStateNormal];
    [_consultDetailButton setTitleColor:[UIColor colorWithHexString:@"ff9629"] forState:UIControlStateNormal];
    _consultDetailButton.titleLabel.font = [UIFont themeFontMedium:12];
    _consultDetailButton.backgroundColor = [UIColor colorWithHexString:@"#fff8ef"];
    _consultDetailButton.layer.masksToBounds = YES;
    _consultDetailButton.layer.cornerRadius = 14;
    [_consultDetailButton addTarget:self action:@selector(consultDetailButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_consultDetailButton];
    _consultDetailButton.hidden = YES;
    [self.consultDetailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.priceLabel.mas_bottom).offset(12);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(28);
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

