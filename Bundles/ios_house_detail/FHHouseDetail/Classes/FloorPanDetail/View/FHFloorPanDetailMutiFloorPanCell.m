//
//  FHDetailNewMutiFloorPanCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/17.
//

#import "FHFloorPanDetailMutiFloorPanCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "UILabel+House.h"
#import "FHDetailHeaderView.h"
#import "FHDetailMultitemCollectionView.h"
#import "FHDetailFloorPanDetailInfoModel.h"
#import "FHHouseDetailSubPageViewController.h"
#import "FHDetailCommonDefine.h"
@interface FHFloorPanDetailMutiFloorPanCell ()

#define ITEM_HEIGHT 170
#define ITEM_WIDTH  140

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, strong) UIImageView *shadowImage;
@end

@implementation FHFloorPanDetailMutiFloorPanCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"related";
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHFloorPanDetailMutiFloorPanCellModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    
    //
    FHFloorPanDetailMutiFloorPanCellModel *model = (FHFloorPanDetailMutiFloorPanCellModel *)data;
    adjustImageScopeType(model);
    
    if (model.recommend) {
        
        for (NSInteger i = 0; i < model.recommend.count; i++) {
            FHDetailFloorPanDetailInfoDataRecommendModel *listItemModel = model.recommend[i];
            listItemModel.index = i;
        }
        
        self.headerView.label.text = @"推荐居室户型";
        self.headerView.label.font = [UIFont themeFontMedium:20];
        self.headerView.isShowLoadMore = NO;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
        flowLayout.itemSize = CGSizeMake(ITEM_WIDTH, ITEM_HEIGHT);
        flowLayout.minimumLineSpacing = 10;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        NSString *identifier = NSStringFromClass([FHFloorPanDetailMutiFloorPanCollectionCell class]);
        FHDetailMultitemCollectionView *colView = [[FHDetailMultitemCollectionView alloc] initWithFlowLayout:flowLayout viewHeight:ITEM_HEIGHT cellIdentifier:identifier cellCls:[FHFloorPanDetailMutiFloorPanCollectionCell class] datas:model.recommend];
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
            make.bottom.mas_equalTo(self.containerView).mas_equalTo(-30);
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
    [self.contentView addSubview:self.shadowImage];
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"推荐居室户型";
    
    
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.shadowImage).offset(15);
        make.right.mas_equalTo(self.shadowImage).offset(-15);
        make.top.mas_equalTo(self.shadowImage).offset(30);
        make.height.mas_equalTo(46);
    }];
    [self.headerView addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _containerView = [[UIView alloc] init];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).mas_offset(30);
        make.left.mas_equalTo(self.shadowImage).mas_offset(15);
        make.right.mas_equalTo(self.shadowImage).mas_offset(-15);
        make.bottom.mas_equalTo(self.shadowImage).offset(-20);
    }];
}

// 查看更多
- (void)moreButtonClick:(UIButton *)button {
    
}

// cell 点击
- (void)collectionCellClick:(NSInteger)index {
    
    FHFloorPanDetailMutiFloorPanCellModel *model = (FHFloorPanDetailMutiFloorPanCellModel *)self.currentData;
    if ([model isKindOfClass:[FHFloorPanDetailMutiFloorPanCellModel class]]) {
        if (model.recommend.count > index) {
            FHDetailFloorPanDetailInfoDataRecommendModel *floorPanInfoModel = model.recommend[index];
            if ([floorPanInfoModel isKindOfClass:[FHDetailFloorPanDetailInfoDataRecommendModel class]]) {
                
            
                NSMutableDictionary *traceParam = [NSMutableDictionary new];
                traceParam[@"enter_from"] = @"house_model_detail";
                traceParam[@"log_pb"] = floorPanInfoModel.logPb; 
                traceParam[@"origin_from"] = self.baseViewModel.detailTracerDic[@"origin_from"];
                traceParam[@"card_type"] = @"left_pic";
                traceParam[@"rank"] = @(floorPanInfoModel.index);
                traceParam[@"origin_search_id"] = self.baseViewModel.detailTracerDic[@"origin_search_id"];
                traceParam[@"element_from"] = @"related";
                
                NSMutableDictionary *infoDict = @{@"house_type":@(1),
                                       @"tracer": traceParam
                                       }.mutableCopy;
                [infoDict setValue:floorPanInfoModel.id forKey:@"floor_plan_id"];
                NSMutableDictionary *subPageParams = model.subPageVC.subPageParams;
                subPageParams[@"contact_phone"] = nil;

//                subPageParams[@"tracer"] = nil;
                if (subPageParams) {
                    [infoDict addEntriesFromDictionary:subPageParams];
                }
                infoDict[@"tracer"] = traceParam;
                TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
                [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://floor_plan_detail"] userInfo:info];
            }
        }
    }
    
}

- (void)collectionDisplayCell:(NSInteger)index {
    FHFloorPanDetailMutiFloorPanCellModel *model = (FHFloorPanDetailMutiFloorPanCellModel *)self.currentData;
      if ([model isKindOfClass:[FHFloorPanDetailMutiFloorPanCellModel class]]) {
          if (model.recommend.count > index) {
              FHDetailFloorPanDetailInfoDataRecommendModel *floorPanInfoModel = model.recommend[index];
              if ([floorPanInfoModel isKindOfClass:[FHDetailFloorPanDetailInfoDataRecommendModel class]]) {
                // house_show
                NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
                tracerDic[@"rank"] = @(index);
                tracerDic[@"card_type"] = @"left_pic";
                tracerDic[@"log_pb"] = floorPanInfoModel.logPb ? floorPanInfoModel.logPb : @"be_null";
                tracerDic[@"element_from"] = @"house_model";
                tracerDic[@"page_type"] = @"house_model_detail";
                [FHUserTracker writeEvent:@"house_show" params:tracerDic];
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

@interface FHFloorPanDetailMutiFloorPanCollectionCell ()

@end

@implementation FHFloorPanDetailMutiFloorPanCollectionCell

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
    if (self.currentData == data || ![data isKindOfClass:[FHDetailFloorPanDetailInfoDataRecommendModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailFloorPanDetailInfoDataRecommendModel *model = (FHDetailFloorPanDetailInfoDataRecommendModel *)data;
    if (model) {
        if (model.images.count > 0) {
            FHImageModel *imageModel = model.images.firstObject;
            NSString *urlStr = imageModel.url;
            if ([urlStr length] > 0) {
                [self.icon bd_setImageWithURL:[NSURL URLWithString:urlStr] placeholder:[UIImage imageNamed:@"default_image"]];
            } else {
                self.icon.image = [UIImage imageNamed:@"default_image"];
            }
        } else {
            self.icon.image = [UIImage imageNamed:@"default_image"];
        }
        self.icon.contentMode = UIViewContentModeScaleAspectFit;
        
        NSMutableAttributedString *textAttrStr = [NSMutableAttributedString new];
        NSMutableAttributedString *titleAttrStr = [[NSMutableAttributedString alloc] initWithString:model.title ? [NSString stringWithFormat:@"%@",model.title] : @""];
        NSDictionary *attributeSelect = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont themeFontMedium:16],NSFontAttributeName,
                                         [UIColor themeGray1],NSForegroundColorAttributeName,nil];
        [titleAttrStr addAttributes:attributeSelect range:NSMakeRange(0, titleAttrStr.length)];
        
        [textAttrStr appendAttributedString:titleAttrStr];
        self.descLabel.attributedText = textAttrStr;
        if (model.saleStatus) {
            self.statusLabel.hidden = NO;
            UIColor *tagBacColor = [UIColor colorWithHexString:@"#FFEAD3"];
            UIColor *tagTextColor = [UIColor colorWithHexString:@"#ff9300"];
            self.statusLabel.textAlignment = NSTextAlignmentCenter;
            self.statusLabel.backgroundColor = tagBacColor;
            self.statusLabel.textColor = tagTextColor;
            self.statusLabel.layer.cornerRadius = 10;
            self.statusLabel.layer.masksToBounds = YES;
            self.statusLabel.text = model.saleStatus.content;
            [self.descLabel sizeToFit];
            CGSize itemSize = [self.descLabel sizeThatFits:CGSizeMake(ITEM_WIDTH, 20)];
            CGFloat itemWidth = itemSize.width;
            if (itemWidth > ITEM_WIDTH - 42) {
                itemWidth = ITEM_WIDTH - 42;
            }
            
            //宽为W,总长度为ITEM_WIDTH 那么标题的右端点就是 ITEM_WIDTH-W 又因为一定要保证销售状态的出现，需要预留42的空间。
            [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(itemWidth);
            }];
            
        }
        else{
            [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(ITEM_WIDTH);
            }];
            self.statusLabel.hidden = YES;
        }
        
//        self.priceLabel.text = model.pricingPerSqm;
//        self.spaceLabel.text = [NSString stringWithFormat:@"建面 %@",model.squaremeter];;
    }
    [self layoutIfNeeded];
}

- (void)setupUI {
     _iconView = [[UIView alloc]init];
     _iconView.layer.borderWidth = 1.0;
     _iconView.layer.borderColor = [[UIColor colorWithHexString:@"#ededed"] CGColor];
     _iconView.layer.cornerRadius = 10.0;
      _iconView.layer.masksToBounds = YES;
     [self addSubview:_iconView];

     _icon = [[UIImageView alloc] init];
     _icon.image = [UIImage imageNamed:@"detail_new_floorpan_default"];
     [_iconView addSubview:_icon];
     _icon.contentMode = UIViewContentModeScaleAspectFill;

    
    _descLabel = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _descLabel.textColor = [UIColor themeGray1];
    [self addSubview:_descLabel];
    
    _statusLabel = [UILabel createLabel:@"" textColor:@"" fontSize:12];
    _statusLabel.textColor = [UIColor themeGray1];
    _statusLabel.layer.masksToBounds = YES;
    _statusLabel.textAlignment = UITextAlignmentCenter;
    _statusLabel.layer.cornerRadius = 9;
    [self addSubview:_statusLabel];

    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.width.mas_equalTo(ITEM_WIDTH);
        make.height.mas_equalTo(ITEM_WIDTH);
        make.top.mas_equalTo(self);
    }];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.iconView);
        make.width.height.equalTo(self.iconView);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.height.mas_equalTo(19);
        make.top.mas_equalTo(self.iconView.mas_bottom).offset(10);
        make.width.mas_equalTo(ITEM_WIDTH - 42);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.descLabel.mas_right).offset(2);
        make.centerY.equalTo(self.descLabel);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(40);
        make.bottom.mas_equalTo(self);
    }];
}

@end

@implementation FHFloorPanDetailMutiFloorPanCellModel


@end
