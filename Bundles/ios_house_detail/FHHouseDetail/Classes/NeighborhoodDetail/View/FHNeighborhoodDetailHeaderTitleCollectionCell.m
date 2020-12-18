//
//  FHNeighborhoodDetailHeaderTitleCollectionCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/10.
//

#import "FHNeighborhoodDetailHeaderTitleCollectionCell.h"
#import "FHDetailTopBannerView.h"
#import "FHHouseTagsModel.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHNeighborhoodDetailHeaderTitleCollectionCell ()

@property (nonatomic, strong) FHDetailTopBannerView *topBanner;
@property (nonatomic, weak) UIView *tagBacView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *subnameLabel;
@property (nonatomic, weak) UIButton *mapBtn;//仅小区展示
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;

@end

@implementation FHNeighborhoodDetailHeaderTitleCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNeighborhoodDetailHeaderTitleModel class]]) {
        FHNeighborhoodDetailHeaderTitleModel *model = (FHNeighborhoodDetailHeaderTitleModel *)data;
        CGFloat height = 0;
        height += 12; //title margin
        height += [model.titleStr btd_sizeWithFont:[UIFont themeFontRegular:20] width:width - 12 * 2 maxLine:1].height;
        NSString *subTitleStr = [NSString stringWithFormat:@"%@  %@  %@",model.districtName?:@"",model.tradeAreaName?:@"",model.areaName?:@""];
        height += [subTitleStr btd_sizeWithFont:[UIFont themeFontRegular:14] width:width - 12 * 2 maxLine:1].height;
        height += 4;
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (NSString *)elementType {
    return @"house_info";
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *mapBtn = [[UIButton alloc]init];
        [mapBtn setImage:[UIImage imageNamed:@"plot_mapbtn"] forState:UIControlStateNormal];
        [mapBtn setImageEdgeInsets:UIEdgeInsetsMake(22, 29, 18, 11)];
        [mapBtn addTarget:self action:@selector(clickMapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:mapBtn];
        self.mapBtn = mapBtn;
        
        UILabel *nameLabel = [UILabel createLabel:@"" textColor:@"" fontSize:20];
        nameLabel.textColor = [UIColor themeGray1];
        nameLabel.font = [UIFont themeFontMedium:20];
        [self addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        UILabel *addressLab = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        addressLab.textColor = [UIColor themeGray1];
        addressLab.font = [UIFont themeFontRegular:14];
        addressLab.numberOfLines = 2;
        [self addSubview:addressLab];
        self.subnameLabel = addressLab;
        self.nameLabel.numberOfLines = 1;
        self.subnameLabel.numberOfLines = 1;
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(12);
            make.right.mas_equalTo(self).offset(-12);
            make.top.mas_equalTo(self).offset(12);
        }];
        
        [self.subnameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(12);
            make.right.mas_equalTo(self.mapBtn.mas_left).offset(17);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(4);
            make.bottom.mas_equalTo(self);
        }];
        
        [self.mapBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.right.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(80, 80));
        }];
        
    }
    return self;
}

- (void)clickMapAction:(UIButton *)btn {
    if(self.mapBtnClickBlock){
        self.mapBtnClickBlock();
    }
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNeighborhoodDetailHeaderTitleModel class]]) {
        return;
    }
    self.currentData = data;
    FHNeighborhoodDetailHeaderTitleModel *model = (FHNeighborhoodDetailHeaderTitleModel *)data;
    self.latitude = [model.gaodeLat doubleValue];
    self.longitude = [model.gaodeLng doubleValue];
    self.nameLabel.text = model.titleStr;
    self.subnameLabel.text = [NSString stringWithFormat:@"%@  %@  %@",model.districtName?:@"",model.areaName?:@"",model.address?:@""];
}

- (void)bindViewModel:(id)viewModel {
    [self refreshWithData:viewModel];
}

@end

@implementation FHNeighborhoodDetailHeaderTitleModel

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return self == object;
}


@end
