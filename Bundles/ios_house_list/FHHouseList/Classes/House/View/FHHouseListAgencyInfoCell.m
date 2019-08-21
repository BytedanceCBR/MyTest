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
    _titleLabel.font = [UIFont themeFontMedium:14];
    _titleLabel.textColor = [UIColor themeGray1];
    [self.contentView addSubview:_titleLabel];

    _allWebHouseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_allWebHouseBtn setImage:ICON_FONT_IMG(14,@"\U0000e6ad",[UIColor themeGray3]) forState:UIControlStateNormal];
    [_allWebHouseBtn addTarget:self action:@selector(allWebHouseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_allWebHouseBtn];
    
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 40 - 6 - 14;
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(20);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(0);
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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
