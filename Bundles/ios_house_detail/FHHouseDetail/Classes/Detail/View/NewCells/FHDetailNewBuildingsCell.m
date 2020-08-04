//
//  FHDetailNewBuildingsCell.m
//  Pods
//
//  Created by bytedance on 2020/6/28.
//

#import "FHDetailNewBuildingsCell.h"
#import "FHDetailHeaderView.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import "FHDetailCommonDefine.h"
#import "FHBuildingDetailUtils.h"
#import "FHBuildingDetailTopImageView.h"

@interface FHDetailNewBuildingsCell ()

@property (nonatomic, strong) UIImageView *shadowImage;

@property (nonatomic, strong) FHDetailHeaderView *headerView;

@property (nonatomic, strong) UIStackView *stackView;

@property (nonatomic, weak) UIView *detailImageView;


@end

@implementation FHDetailNewBuildingsCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    switch (houseType) {
        case FHHouseTypeNewHouse:
               return @"building";
        default:
            break;
    }
    return @"be_null";
}

- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    
    self.headerView = [[FHDetailHeaderView alloc] init];
    self.headerView.label.text = @"楼栋信息";
    //[self.headerView addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(15);
        make.right.mas_equalTo(self.contentView).mas_offset(-15);
        make.top.mas_equalTo(self.contentView).offset(20);
        make.height.mas_equalTo(46);
    }];
    
    self.stackView = [[UIStackView alloc] init];
    self.stackView.axis = UILayoutConstraintAxisVertical;
    [self.contentView addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(30);
        make.right.mas_offset(-30);
        make.top.mas_equalTo(self.headerView.mas_bottom).mas_offset(20);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-20);
        make.height.mas_equalTo(0);
    }];
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNewBuildingsCellModel class]]) {
        return;
    }
    [self.stackView.arrangedSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    FHDetailNewBuildingsCellModel *model = (FHDetailNewBuildingsCellModel *)data;
    adjustImageScopeType(model)
    CGFloat stackViewHeight = 0;
    CGFloat itemWidth = 58;
    if (model.buildingInfo.buildingImage.url.length) {
        CGSize size = [FHBuildingDetailUtils getDetailBuildingViewSize];
        UIView *containView = [[UIView alloc] init];
        [containView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.stackView);
            make.height.mas_equalTo(size.height + 20);
        }];
        stackViewHeight += size.height + 20;

        [self.stackView addArrangedSubview:containView];
        UIView *image = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        image.clipsToBounds = YES;
        image.layer.cornerRadius = 10;
        image.contentMode = UIViewContentModeCenter;
        CGSize imageSize = [FHBuildingDetailUtils getDetailBuildingImageViewSize];
        FHBuildingDetailTopImageView *imageView = [[FHBuildingDetailTopImageView alloc] initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
        imageView.center = image.center;
        imageView.userInteractionEnabled = NO;
        FHBuildingLocationModel *locationModel = [[FHBuildingLocationModel alloc] init];
        FHBuildingSaleStatusModel *saleModel = [[FHBuildingSaleStatusModel alloc] init];
        NSMutableArray *buildingArr = [NSMutableArray arrayWithCapacity:model.buildingInfo.list.count];
        for (FHDetailNewBuildingListItem *buildItem in model.buildingInfo.list) {
            FHBuildingDetailDataItemModel *building = [[FHBuildingDetailDataItemModel alloc] init];
            building.pointX = buildItem.pointX;
            building.pointY = buildItem.pointY;
            building.beginWidth = model.buildingInfo.buildingImage.width;
            building.beginHeight = model.buildingInfo.buildingImage.height;
            FHSaleStatusModel *saleStatus = [[FHSaleStatusModel alloc] init];
            saleStatus.content = buildItem.saleStatus;
            building.saleStatus = saleStatus;
            building.name = buildItem.name;
            [buildingArr addObject:building];
        }
        saleModel.buildingList = buildingArr.copy;
        locationModel.saleStatusList = [NSArray arrayWithObject:saleModel];
        locationModel.buildingImage = model.buildingInfo.buildingImage;
        [imageView updateWithData:locationModel];
        [imageView showAllButton];
        [containView addSubview:image];
        [image addSubview:imageView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTopImage:)];
        [image addGestureRecognizer:tapGesture];
    }
    
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor whiteColor];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.stackView);
        make.height.mas_equalTo(16);
    }];
    [self.stackView addArrangedSubview:topView];
    stackViewHeight += 16;
    
    UILabel *nameLabel = [self buildInfoLabel];
    nameLabel.text = model.buildingInfo.buildingNameText.length ? model.buildingInfo.buildingNameText : @"楼栋名称";
    [topView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(itemWidth);
    }];
    
    UILabel *layerLabel = [self buildInfoLabel];
    layerLabel.text = model.buildingInfo.layerText.length ? model.buildingInfo.layerText : @"层数";
    [topView addSubview:layerLabel];
    [layerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(topView);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(itemWidth);
    }];
    
    UILabel *familyLabel = [self buildInfoLabel];
    familyLabel.text = model.buildingInfo.family.length ? model.buildingInfo.family : @"户数";
    [topView addSubview:familyLabel];
    [familyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(itemWidth);
    }];
    
    if (model.buildingInfo.list.count) {
        stackViewHeight += (model.buildingInfo.list.count * (15 + 16 + 15 + 1));
        for (NSUInteger index = 0; index < model.buildingInfo.list.count; index ++) {
            FHDetailNewBuildingListItem *item = model.buildingInfo.list[index];
            
            FHDetailNewBuildingsInfoView *itemView = [[FHDetailNewBuildingsInfoView alloc] init];
            itemView.infoId = item.id;
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickInfoView:)];
            [itemView addGestureRecognizer:tapGesture];
            itemView.backgroundColor = [UIColor whiteColor];
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(self.stackView);
                make.height.mas_equalTo(15 + 16 + 15 + 1);
            }];
            [self.stackView addArrangedSubview:itemView];
            
            UILabel *nameValueLabel = [self buildingValueLabel];
            nameValueLabel.text = item.name;
            [itemView addSubview:nameValueLabel];
            [nameValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
                make.top.mas_equalTo(15);
                make.width.mas_equalTo(itemView.mas_width).multipliedBy(0.33);
            }];
            
            UILabel *layerValueLabel = [self buildingValueLabel];
            layerValueLabel.text = item.layers;
            [itemView addSubview:layerValueLabel];
            [layerValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(topView);
                make.top.mas_equalTo(15);
                make.width.mas_equalTo(itemWidth);
            }];
            
            UILabel *familyValueLabel = [self buildingValueLabel];
            familyValueLabel.text = item.family;
            [itemView addSubview:familyValueLabel];
            [familyValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(0);
                make.top.mas_equalTo(15);
                make.width.mas_equalTo(itemWidth);
            }];
            
            if (index < model.buildingInfo.list.count - 1) {
                //添加横线
                UIView *lineView = [[UIView alloc] init];
                lineView.backgroundColor = [UIColor colorWithHexString:@"e7e7e7"];
                [itemView addSubview:lineView];
                [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.mas_equalTo(0);
                    make.bottom.mas_equalTo(0);
                    make.height.mas_equalTo(1.0/UIScreen.mainScreen.scale);
                }];
            }
        }
    }
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.stackView addArrangedSubview:bottomView];
    stackViewHeight += (15 + 40 + 30);
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(15 + 40 + 30);
    }];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setBackgroundColor:[UIColor colorWithHexString:@"#fff8ef"]];
    moreButton.layer.masksToBounds = YES;
    moreButton.layer.cornerRadius = 20;
    NSString *title = model.buildingInfo.buttonText.length ? model.buildingInfo.buttonText : @"查看全部楼栋信息";
    [moreButton setTitle:title forState:UIControlStateNormal];
    [moreButton setTitleColor:[UIColor colorWithHexString:@"#ff9629"] forState:UIControlStateNormal];
    moreButton.titleLabel.font = [UIFont themeFontMedium:16];
    [moreButton addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:moreButton];
    [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(15);
        make.height.mas_equalTo(40);
    }];
    
    [self.stackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(stackViewHeight);
    }];
}


- (UIImageView *)shadowImage
{
    if (!_shadowImage) {
        _shadowImage = [[UIImageView alloc] init];
        [self.contentView addSubview:_shadowImage];
    }
    return _shadowImage;
}


- (UILabel *)buildInfoLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont themeFontRegular:14];
    label.textColor = [UIColor themeGray3];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor whiteColor];
    return label;
}

- (UILabel *)buildingValueLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont themeFontRegular:16];
    label.textColor = [UIColor themeGray1];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor whiteColor];
    return label;
}

//进入楼栋详情页
- (void)goBuildingDetail:(NSString *)originId{
    if (!self.baseViewModel.houseId.length) {
        return;
    }
    NSMutableDictionary *traceParam = [NSMutableDictionary dictionary];
    
    traceParam[@"enter_from"] = @"new_detail";
    traceParam[@"log_pb"] = self.baseViewModel.detailTracerDic[@"log_pb"];
    traceParam[@"origin_from"] = self.baseViewModel.detailTracerDic[@"origin_from"];
    traceParam[@"card_type"] = @"left_pic";
//    traceParam[@"rank"] = @(floorPanInfoModel.index);
    traceParam[@"origin_search_id"] = self.baseViewModel.detailTracerDic[@"origin_search_id"];
    traceParam[@"element_from"] = @"building";
    traceParam[@"page_type"] = @"building_detail";
    
//    NSDictionary *dict = @{@"house_id":self.baseViewModel.houseId?:@"",
//                           @"tracer": traceParam
//                           };
    
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
//    infoDict[@"house_type"] = @(1);
//    [infoDict setValue:floorPanInfoModel.id forKey:@"floor_plan_id"];
    NSMutableDictionary *subPageParams = [self.baseViewModel subPageParams].mutableCopy;
    subPageParams[@"contact_phone"] = nil;
    [infoDict addEntriesFromDictionary:subPageParams];
    infoDict[@"tracer"] = traceParam;
    infoDict[@"house_id"] = self.baseViewModel.houseId?:@"";
    infoDict[@"origin_id"] = originId;
    
    if (self.baseViewModel.contactViewModel) {
        infoDict[@"contactViewModel"] = self.baseViewModel.contactViewModel;
    }
    
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];

    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://new_building_detail"] userInfo:info];
}

- (void)clickTopImage:(id)sender {
    [self addClickOptions:@"图片"];
    [self goBuildingDetail:nil];
}

- (void)clickInfoView:(UIGestureRecognizer *)sender {
    FHDetailNewBuildingsInfoView *view = (FHDetailNewBuildingsInfoView *)(sender.view);
    [self addClickOptions:@"外漏"];
    [self goBuildingDetail:view.infoId];
}

- (void)clickMoreButton:(id)sender {
    [self addClickOptions:@"查看更多"];
    [self goBuildingDetail:nil];
}

- (void)addClickOptions:(NSString *)clickPosition {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:self.baseViewModel.detailTracerDic];
    params[@"group_id"] = self.baseViewModel.houseId?:@"";
    params[@"click_position"] = clickPosition;
    params[@"element_type"] = @"building";
    [FHUserTracker writeEvent:@"click_options" params:params];
}



@end

@implementation FHDetailNewBuildingsCellModel


@end

@implementation FHDetailNewBuildingsInfoView


@end
