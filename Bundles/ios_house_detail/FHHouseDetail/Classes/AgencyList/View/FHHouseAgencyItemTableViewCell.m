//
//  FHHouseAgencyItemTableViewCell.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/5/5.
//

#import "FHHouseAgencyItemTableViewCell.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import "Masonry.h"

@interface FHHouseAgencyItemTableViewCell ()

@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation FHHouseAgencyItemTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self.contentView addSubview:self.selectIcon];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.bottomLine];
    
    [self.selectIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.centerY.mas_equalTo(self.contentView);
        make.width.height.mas_equalTo(18);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.selectIcon.mas_right).mas_offset(10);
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(-16);
        make.height.mas_equalTo(25);
    }];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.right.mas_equalTo(-16);
        make.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
}

- (UIImageView *)selectIcon
{
    if (!_selectIcon) {
        _selectIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@""]];
    }
    return _selectIcon;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont themeFontRegular:18];
        _titleLabel.textColor = [UIColor themeGray1];
    }
    return _titleLabel;
}

-(UIView *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor themeGray6];
    }
    return _bottomLine;
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
