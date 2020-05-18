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
//242+34
#define ITEM_HEIGHT 276
#define ITEM_BOTTOM_HEIGHT 45
#define ITEM_WIDTH  184

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

- (UIImageView *)shadowImage
{
    if (!_shadowImage) {
        _shadowImage = [[UIImageView alloc]init];
    }
    return _shadowImage;
}

- (void)fhDetail_scrollViewDidScroll:(UIView *)vcParentView {
        if (vcParentView) {
            UIWindow* window = [UIApplication sharedApplication].keyWindow;
            CGFloat SH = [UIScreen mainScreen].bounds.size.height;
            CGPoint point = [self convertPoint:CGPointZero toView:vcParentView];
            CGFloat bottombarHight =  self.baseViewModel.houseType ==FHHouseTypeRentHouse? 64:80;
            if (SH -bottombarHight >point.y) {
              if ([self.houseShowCache valueForKey:@"isShowFloorPan"]) {
                    return;
              }else {
                  NSMutableArray * visibles = self.colView.collectionContainer.indexPathsForVisibleItems;
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
    for (UIView *v in self.tagBacView.subviews) {
        [v removeFromSuperview];
    }
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
        
        /*
         mock
         */
        model.pricing = @"约2000万/套";
        FHHouseTagsModel *tag = [[FHHouseTagsModel alloc]init];
        tag.content = rand()%2 == 0?@"啊啊啊":@"哈哈哈";
        tag.backgroundColor = @"#63A59F9C";
        tag.textColor = @"#a49a92";
        NSMutableArray *arr = [NSMutableArray arrayWithObject:tag];
        model.tags = arr.copy;
        
        //mock数据，删去这里到上面的注释，切记~~~~！！
        self.priceLabel.text = model.pricing;
        
        CGFloat width = [self getLabelWidth:self.descLabel withHeight:19.0];
        [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
        }];
        CGFloat left = 0.0;
        if (model.saleStatus) {
            UIColor *bacColor = [UIColor colorWithHexStr:model.saleStatus.backgroundColor];
            UIColor *texColor = [UIColor colorWithHexStr:model.saleStatus.textColor];
            UILabel *saleLabel = [self createLabelWithText:model.saleStatus.content tagBacColor:bacColor tagTextColor:texColor];
            CGFloat width = [self getLabelWidth:saleLabel withHeight:16.0];
            width += 8;
            [self.tagBacView addSubview:saleLabel];
            [saleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(left);
                make.width.mas_equalTo(width);
                make.height.mas_equalTo(16.0);
                make.top.mas_equalTo(0);
            }];
            left += width + 4;
        }
        if (model.tags.count > 0) {
            FHHouseTagsModel *tag = [model.tags firstObject];
            UIColor *bacColor = [UIColor colorWithHexStr:tag.backgroundColor];
            UIColor *texColor = [UIColor colorWithHexStr:tag.textColor];
            UILabel *tagLabel = [self createLabelWithText:tag.content tagBacColor:bacColor tagTextColor:texColor];
            CGFloat width = [self getLabelWidth:tagLabel withHeight:16.0];
            width += 8;
            [self.tagBacView addSubview:tagLabel];
            [tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(left);
                make.width.mas_equalTo(width);
                make.height.mas_equalTo(16.0);
                make.top.mas_equalTo(0);
            }];
        }
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
    
    _tagBacView = [UIView new];
    _tagBacView.clipsToBounds = YES;
    [self addSubview:_tagBacView];
    
    _spaceLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _spaceLabel.textColor = [UIColor themeGray3];
    [self addSubview:_spaceLabel];
    
    _priceLabel = [UILabel createLabel:@"" textColor:@"" fontSize:19];
    _priceLabel.textColor = [UIColor themeOrange1];
    _priceLabel.font = [UIFont themeFontSemibold:16];
    [self addSubview:_priceLabel];
    
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
        make.top.equalTo(self.contentView);
        make.left.right.equalTo(self.contentView);
        make.width.height.mas_equalTo(ITEM_WIDTH);
    }];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.iconView);
        make.width.height.equalTo(self.iconView);
    }];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconView.mas_bottom).mas_offset(10);
        make.left.equalTo(self.contentView);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(0);
    }];
    [self.tagBacView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.descLabel.mas_right).offset(4);
        make.right.mas_equalTo(self.iconView);
        make.bottom.mas_equalTo(self.descLabel);
        make.height.mas_equalTo(16);
    }];
    [self.spaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descLabel.mas_bottom).offset(7);
        make.left.equalTo(self.descLabel);
        make.right.equalTo(self.contentView);
        make.height.mas_equalTo(15);
    }];
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.spaceLabel.mas_bottom).offset(8);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(20);
    }];
    [self.consultDetailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.priceLabel.mas_bottom).offset(16);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(32);
    }];
}

- (void)consultDetailButtonAction:(UIButton *)sender {
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickCellItem:onCell:)]) {
        [self.delegate clickCellItem:sender onCell:self];
    }
}

- (UILabel *)createLabelWithText:(NSString *)text tagBacColor:(UIColor *)tagBacColor tagTextColor:(UIColor *)tagTextColor {
    UILabel *label = [[UILabel alloc]init];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = tagBacColor;
    label.textColor = tagTextColor;
    label.layer.cornerRadius = 2;
    label.layer.masksToBounds = YES;
    label.text = text;
    label.font = [UIFont themeFontMedium:10];
    return label;
}

- (CGFloat)getLabelWidth:(UILabel *)label withHeight:(CGFloat)height {
    [label sizeToFit];
    CGSize itemSize = [label sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, height)];
    return itemSize.width;
}

@end

@implementation FHDetailNewMutiFloorPanCellModel



@end

