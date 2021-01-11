//
//  FHNewHouseDetailBuildingCollectionCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/9.
//

#import "FHNewHouseDetailBuildingCollectionCell.h"
#import "FHBuildingDetailTopImageView.h"
#import "FHDetailNewModel.h"

@interface FHNewHouseDetailBuildingCollectionCell ()

@property (nonatomic, strong) UIStackView *stackView;

@end

@implementation FHNewHouseDetailBuildingCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (!data || ![data isKindOfClass:[FHNewHouseDetailBuildingModel class]]) {
        return CGSizeZero;
    }
    FHNewHouseDetailBuildingModel *model = (FHNewHouseDetailBuildingModel *)data;
    CGFloat height = 0;
    
    if (model.buildingInfo.buildingImage.url.length && ([model.buildingInfo.buildingImage.height floatValue] > 0) && ([model.buildingInfo.buildingImage.width floatValue] > 0)) {
        CGFloat imageWidth = width - 12 *2;
        CGFloat photoCellHeight = 177.0;
        photoCellHeight = round(imageWidth / 313.0f * photoCellHeight + 0.5);
        height += photoCellHeight + 12;
    }
    height += 18;
    if (model.buildingInfo.list) {
        height += (model.buildingInfo.list.count * (12 + 22 + 12 + 1));
    }
    height += 40 + 12;
    return CGSizeMake(width, height);
}

- (NSString *)elementType {
    return @"building";
}

- (void)setupUI {
    self.stackView = [[UIStackView alloc] init];
    self.stackView.axis = UILayoutConstraintAxisVertical;
    [self.contentView addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(12);
        make.right.mas_offset(-12);
        make.top.bottom.mas_equalTo(self);
    }];
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNewHouseDetailBuildingModel class]]) {
        return;
    }
    [self.stackView.arrangedSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    FHNewHouseDetailBuildingModel *model = (FHNewHouseDetailBuildingModel *)data;
    CGFloat stackViewHeight = 0;
    CGFloat itemWidth = 58;
    if (model.buildingInfo.buildingImage.url.length && ([model.buildingInfo.buildingImage.height floatValue] > 0) && ([model.buildingInfo.buildingImage.width floatValue] > 0)) {
        CGFloat width = CGRectGetWidth(self.contentView.bounds) - 12 *2;
        CGFloat photoCellHeight = 177.0;
        photoCellHeight = round(width / 313.0f * photoCellHeight + 0.5);
        CGSize size = CGSizeMake(width, photoCellHeight);
        UIView *containView = [[UIView alloc] init];
        [containView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.stackView);
            make.height.mas_equalTo(size.height + 12);
        }];
        stackViewHeight += size.height + 12;

        [self.stackView addArrangedSubview:containView];
        UIView *image = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        image.clipsToBounds = YES;
        image.layer.cornerRadius = 3;
        image.contentMode = UIViewContentModeCenter;
        
        photoCellHeight = round(width / 375.0f * 281 + 0.5);
        CGSize imageSize = CGSizeMake(width, photoCellHeight);
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
        locationModel.saleStatusList = [NSArray<FHBuildingSaleStatusModel> arrayWithObject:saleModel];
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
        make.height.mas_equalTo(18);
    }];
    [self.stackView addArrangedSubview:topView];
    stackViewHeight += 18;
    
    UILabel *nameLabel = [self buildInfoLabel];
    nameLabel.text = model.buildingInfo.buildingNameText.length ? model.buildingInfo.buildingNameText : @"楼栋名称";
    [topView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(topView);
        make.width.mas_equalTo(itemWidth);
    }];
    
    UILabel *layerLabel = [self buildInfoLabel];
    layerLabel.text = model.buildingInfo.layerText.length ? model.buildingInfo.layerText : @"层数";
    [topView addSubview:layerLabel];
    [layerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(topView);
        make.centerY.mas_equalTo(topView);
        make.width.mas_equalTo(itemWidth);
    }];
    
    UILabel *familyLabel = [self buildInfoLabel];
    familyLabel.text = model.buildingInfo.family.length ? model.buildingInfo.family : @"户数";
    [topView addSubview:familyLabel];
    [familyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(topView);
        make.width.mas_equalTo(itemWidth);
    }];
    
    if (model.buildingInfo.list.count) {
        stackViewHeight += (model.buildingInfo.list.count * (12 + 16 + 12 + 1));
        for (NSUInteger index = 0; index < model.buildingInfo.list.count; index ++) {
            FHDetailNewBuildingListItem *item = model.buildingInfo.list[index];
            
            FHNewHouseDetailBuildingInfoView *itemView = [[FHNewHouseDetailBuildingInfoView alloc] init];
            itemView.infoId = item.id;
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickInfoView:)];
            [itemView addGestureRecognizer:tapGesture];
            itemView.backgroundColor = [UIColor whiteColor];
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(self.stackView);
                make.height.mas_equalTo(12 + 22 + 12 + 1);
            }];
            [self.stackView addArrangedSubview:itemView];
            
            UILabel *nameValueLabel = [self buildingValueLabel];
            nameValueLabel.text = item.name;
            [itemView addSubview:nameValueLabel];
            [nameValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(0);
                make.centerY.mas_equalTo(itemView);
                make.width.mas_equalTo(itemView.mas_width).multipliedBy(0.33);
            }];
            
            UILabel *layerValueLabel = [self buildingValueLabel];
            layerValueLabel.text = item.layers;
            [itemView addSubview:layerValueLabel];
            [layerValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(topView);
                make.centerY.mas_equalTo(itemView);
                make.width.mas_equalTo(itemWidth);
            }];
            
            UILabel *familyValueLabel = [self buildingValueLabel];
            familyValueLabel.text = item.family;
            [itemView addSubview:familyValueLabel];
            [familyValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(0);
                make.centerY.mas_equalTo(itemView);
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
    stackViewHeight += (40 + 12);
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(40 + 12);
    }];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setBackgroundColor:[UIColor colorWithHexString:@"#fafafa"]];
    moreButton.layer.masksToBounds = YES;
    moreButton.layer.cornerRadius = 1;
    NSString *title = model.buildingInfo.buttonText.length ? model.buildingInfo.buttonText : @"查看全部楼栋信息";
    [moreButton setTitle:title forState:UIControlStateNormal];
    [moreButton setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    moreButton.titleLabel.font = [UIFont themeFontRegular:16];
    [moreButton addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:moreButton];
    [moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(40);
    }];
    
    [self.stackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(stackViewHeight);
    }];
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



- (void)clickTopImage:(id)sender {
    if (self.addClickOptions) {
        self.addClickOptions(@"图片");
    }
    if (self.goBuildingDetail) {
        self.goBuildingDetail(@"");
    }
}

- (void)clickInfoView:(UIGestureRecognizer *)sender {
    FHNewHouseDetailBuildingInfoView *view = (FHNewHouseDetailBuildingInfoView *)(sender.view);
    if (self.addClickOptions) {
        self.addClickOptions(@"外漏");
    }
    if (self.goBuildingDetail) {
        self.goBuildingDetail(view.infoId);
    }
}

- (void)clickMoreButton:(id)sender {
    if (self.addClickOptions) {
        self.addClickOptions(@"查看更多");
    }
    if (self.goBuildingDetail) {
        self.goBuildingDetail(@"");
    }
}



@end


@implementation FHNewHouseDetailBuildingModel


@end

@implementation FHNewHouseDetailBuildingInfoView


@end
