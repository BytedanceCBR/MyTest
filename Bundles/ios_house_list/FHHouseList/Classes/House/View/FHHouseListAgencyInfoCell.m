//
//  FHHouseListAgencyInfoCell.m
//  FHHouseList
//
//  Created by 张静 on 2019/7/29.
//

#import "FHHouseListAgencyInfoCell.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry/Masonry.h>
#import <FHHouseBase/UIImage+FIconFont.h>
#import <TTDeviceHelper.h>
#import <FHHouseBase/FHSearchHouseModel.h>
@interface FHHouseListAgencyInfoCell ()


@end

@implementation FHHouseListAgencyInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.font = [UIFont themeFontMedium:[TTDeviceHelper isScreenWidthLarge320] ? 14 : 12];
    _titleLabel.textColor = [UIColor themeGray1];
    [self.contentView addSubview:_titleLabel];

    _allWebHouseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_allWebHouseBtn setImage:ICON_FONT_IMG(14,@"\U0000e6ad",[UIColor themeGray3]) forState:UIControlStateNormal];
    [_allWebHouseBtn addTarget:self action:@selector(allWebHouseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_allWebHouseBtn];
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 40 - 6 - 14;
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(-10);
        make.width.mas_lessThanOrEqualTo(maxWidth);
    }];
    [_allWebHouseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(14);
        make.centerY.mas_equalTo(self.titleLabel);
        make.left.mas_equalTo(self.titleLabel.mas_right).mas_offset(6);
    }];
}

- (void)allWebHouseBtnClick:(UIButton *)btn
{
    if (self.btnClickBlock) {
        self.btnClickBlock();
    }
}

- (void)refreshUI 
{
    
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[FHSearchRealHouseAgencyInfo class]]) {
        FHSearchRealHouseAgencyInfo *agencyInfoModel = (FHSearchRealHouseAgencyInfo *)data;

        NSString *agencyCount = [NSString stringWithFormat:@"%@家",agencyInfoModel.agencyTotal ? : @""];
        NSString *houseCount = [NSString stringWithFormat:@"%@套",agencyInfoModel.houseTotal ? : @""];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:@"已为您找到全网" attributes:@{NSForegroundColorAttributeName:[UIColor themeGray1]}];
        [attr appendAttributedString:[[NSAttributedString alloc] initWithString:agencyCount attributes:@{NSForegroundColorAttributeName:[UIColor themeRed3]}]];
        [attr appendAttributedString:[[NSAttributedString alloc] initWithString:@"经纪公司的" attributes:@{NSForegroundColorAttributeName:[UIColor themeGray1]}]];
        [attr appendAttributedString:[[NSAttributedString alloc] initWithString:houseCount attributes:@{NSForegroundColorAttributeName:[UIColor themeRed3]}]];
        [attr appendAttributedString:[[NSAttributedString alloc] initWithString:@"房源" attributes:@{NSForegroundColorAttributeName:[UIColor themeGray1]}]];
        self.titleLabel.attributedText = attr;
    }
}

+ (CGFloat)heightForData:(id)data
{
    return 40;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
