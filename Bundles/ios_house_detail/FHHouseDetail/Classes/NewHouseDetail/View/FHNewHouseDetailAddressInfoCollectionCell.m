//
//  FHNewHouseDetailAddressInfoCollectionCell.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailAddressInfoCollectionCell.h"
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHNewHouseDetailAddressInfoCollectionCell ()
@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *mapBtn;
@property (nonatomic, strong) UIImageView *rightArrow;
@property (nonatomic, strong) UIControl *actionBtn;
@end

@implementation FHNewHouseDetailAddressInfoCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    return CGSizeMake(width, 44 + 15 * 2);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.topLine = [[UIView alloc] init];
        self.topLine.backgroundColor = [UIColor colorWithHexString:@"#e7e7e7"];
        [self.contentView addSubview:self.topLine];
        [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView).mas_offset(15);
            make.right.mas_equalTo(self.contentView).mas_offset(-15);
            make.height.mas_equalTo([UIDevice btd_onePixel]);
            make.top.mas_equalTo(0);
        }];
        
        self.mapBtn = [[UIButton alloc] init];
        [self.mapBtn setImage:[UIImage imageNamed:@"plot_mapbtn"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.mapBtn];
        [self.mapBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.width.height.mas_equalTo(44);
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        UIImage *img = ICON_FONT_IMG(16, @"\U0000e670", [UIColor themeGray3]); //@"detail_entrance_arrow"
        self.rightArrow = [[UIImageView alloc] initWithImage:img];
        [self.contentView addSubview:self.rightArrow];
        [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView).mas_offset(-15);
            make.width.height.mas_equalTo(18);
            make.centerY.equalTo(self.contentView);
        }];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont themeFontMedium:16];
        self.titleLabel.textColor = [UIColor themeGray2];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mapBtn.mas_right).mas_offset(15);
            make.right.mas_equalTo(self.rightArrow.mas_left).mas_offset(-15);
            make.centerY.mas_equalTo(self.contentView);
        }];

        self.actionBtn = [[UIControl alloc]init];
        [self.actionBtn addTarget:self action:@selector(clickMapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.actionBtn];
        [self.actionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.rightArrow);
            make.left.mas_equalTo(self.mapBtn);
            make.top.bottom.equalTo(self.titleLabel);
        }];
    }
    return self;
}

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHNewHouseDetailAddressInfoCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHNewHouseDetailAddressInfoCellModel *model = (FHNewHouseDetailAddressInfoCellModel *)data;
    self.titleLabel.text = model.courtAddress;
}

- (void)clickMapAction:(UIButton *)btn
{
    if (self.mapDetailActionBlock) {
        self.mapDetailActionBlock();
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"";
}

@end

@implementation FHNewHouseDetailAddressInfoCellModel

@end
