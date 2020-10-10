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
@property (nonatomic, weak) UILabel *addressLab;

@end

@implementation FHNeighborhoodDetailHeaderTitleCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNeighborhoodDetailHeaderTitleModel class]]) {
        FHNeighborhoodDetailHeaderTitleModel *model = (FHNeighborhoodDetailHeaderTitleModel *)data;
        CGFloat height = 0;
        height += 20; //title margin
        height += [model.titleStr btd_sizeWithFont:[UIFont themeFontRegular:24] width:width - 15 * 2 maxLine:2].height;
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
        self.topBanner = [[FHDetailTopBannerView alloc] init];
        [self addSubview:self.topBanner];
        [self.topBanner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
        self.topBanner.hidden = YES;
        
        UILabel *nameLabel = [UILabel createLabel:@"" textColor:@"" fontSize:24];
        nameLabel.textColor = [UIColor themeGray1];
        nameLabel.font = [UIFont themeFontMedium:24];
        nameLabel.numberOfLines = 2;
        [self addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(15);
            make.right.mas_equalTo(self).offset(-15);
            make.top.mas_equalTo(self.topBanner.mas_bottom).offset(20);
        }];
        
        UILabel *addressLab = [UILabel createLabel:@"" textColor:@"" fontSize:14];
        addressLab.textColor = [UIColor themeGray3];
        addressLab.font = [UIFont themeFontRegular:14];
        addressLab.numberOfLines = 2;
        [self addSubview:addressLab];
        self.addressLab = addressLab;
        self.nameLabel.numberOfLines = 1;
        self.addressLab.numberOfLines = 1;
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(31);
            make.right.mas_equalTo(self).offset(-100);
            make.top.mas_equalTo(self.topBanner.mas_bottom);
        }];
        
        [self.addressLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(31);
            make.right.mas_equalTo(self).offset(-100);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(4);
            make.bottom.mas_equalTo(self);
        }];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNeighborhoodDetailHeaderTitleModel class]]) {
        return;
    }
    self.currentData = data;
    FHNeighborhoodDetailHeaderTitleModel *model = (FHNeighborhoodDetailHeaderTitleModel *)data;
    self.nameLabel.text = model.titleStr;
    self.addressLab.text = model.address;
    
}

@end

@implementation FHNeighborhoodDetailHeaderTitleModel



@end
