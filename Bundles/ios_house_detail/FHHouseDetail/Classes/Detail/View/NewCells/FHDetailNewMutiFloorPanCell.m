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
#import "FHDetailMultitemCollectionView.h"

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
        
        for (NSInteger i = 0; i < model.list.count; i++) {
            FHDetailNewDataFloorpanListListModel *listItemModel = model.list[i];
            listItemModel.index = i;
        }
        if (model.totalNumber.length > 0) {
            self.headerView.label.text = [NSString stringWithFormat:@"户型介绍（%@）",model.totalNumber];
        }else {
            self.headerView.label.text = @"户型介绍";
        }
        self.headerView.isShowLoadMore = model.hasMore;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
        flowLayout.itemSize = CGSizeMake(184, 242);
        flowLayout.minimumLineSpacing = 10;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        NSString *identifier = NSStringFromClass([FHDetailNewMutiFloorPanCollectionCell class]);
        FHDetailMultitemCollectionView *colView = [[FHDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:242 cellIdentifier:identifier cellCls:[FHDetailNewMutiFloorPanCollectionCell class] datas:model.list];
        colView.tag = 100;
        [self.containerView addSubview:colView];
        __weak typeof(self) wSelf = self;
        colView.clickBlk = ^(NSInteger index) {
            [wSelf collectionCellClick:index];
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
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:FHHouseTypeNewHouse];
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
        [tracerDic removeObjectForKey:@"house_type"];
        
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
                [infoDict addEntriesFromDictionary:subPageParams];
                infoDict[@"tracer"] = traceParam;
                TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];

                [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://floor_plan_detail"] userInfo:info];
            }
        }
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
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.width.height.mas_equalTo(184);
        make.top.mas_equalTo(self);
    }];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(20);
        make.top.mas_equalTo(self.icon.mas_bottom).mas_offset(10);
    }];
    [self.spaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.descLabel);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(15);
        make.top.mas_equalTo(self.descLabel.mas_bottom).offset(6);
        make.bottom.equalTo(self);
    }];
}


@end

@implementation FHDetailNewMutiFloorPanCellModel



@end

