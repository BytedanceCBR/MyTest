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

@interface FHDetailNewBuildingsCell ()

@property (nonatomic, strong) UIImageView *shadowImage;

@property (nonatomic, strong) FHDetailHeaderView *headerView;

@property (nonatomic, strong) UIStackView *stackView;

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

- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    
    self.headerView = [[FHDetailHeaderView alloc] init];
    self.headerView.label.text = @"楼栋信息";
    [self.headerView addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(15);
        make.right.mas_equalTo(self.contentView).mas_offset(-15);
        make.top.mas_equalTo(self.contentView).offset(30);
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
            
            UIView *itemView = [[UIView alloc] init];
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
                make.width.mas_equalTo(itemWidth);
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
    [moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
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
- (void)moreButtonAction:(id)sender {
    if (!self.baseViewModel.houseId.length) {
        return;
    }
    NSMutableDictionary *traceParam = [NSMutableDictionary dictionary];
    traceParam[@"enter_from"] = @"new_detail";
//    traceParam[@"log_pb"] = floorPanInfoModel.logPb;
    traceParam[@"origin_from"] = self.baseViewModel.detailTracerDic[@"origin_from"];
    traceParam[@"card_type"] = @"left_pic";
//    traceParam[@"rank"] = @(floorPanInfoModel.index);
    traceParam[@"origin_search_id"] = self.baseViewModel.detailTracerDic[@"origin_search_id"];
    traceParam[@"element_from"] = @"house_model";
    
//    NSDictionary *dict = @{@"house_id":self.baseViewModel.houseId?:@"",
//                           @"tracer": traceParam
//                           };
    
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithDictionary:nil];
//    infoDict[@"house_type"] = @(1);
//    [infoDict setValue:floorPanInfoModel.id forKey:@"floor_plan_id"];
    NSMutableDictionary *subPageParams = [self.baseViewModel subPageParams];
    subPageParams[@"contact_phone"] = nil;
    [infoDict addEntriesFromDictionary:subPageParams];
    infoDict[@"tracer"] = traceParam;
    infoDict[@"house_id"] = self.baseViewModel.houseId?:@"";
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];

    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://new_building_detail"] userInfo:info];
}

@end

@implementation FHDetailNewBuildingsCellModel


@end
