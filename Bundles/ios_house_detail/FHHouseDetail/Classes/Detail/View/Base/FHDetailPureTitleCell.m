//
//  FHDetailPureTitleCell.m
//  Pods
//
//  Created by 张静 on 2019/2/18.
//

#import "FHDetailPureTitleCell.h"

@interface FHDetailPureTitleCell ()

@property(nonatomic , strong) UILabel *titleLabel;

@end

@implementation FHDetailPureTitleCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHDetailPureTitleModel class]]) {
        return;
    }
    self.currentData = data;
    NSString *title = ((FHDetailPureTitleModel *)data).title;
    self.titleLabel.text = title;
}

- (void)setupUI
{
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.contentView).mas_offset(20);
        make.height.mas_equalTo(25);
        make.bottom.mas_equalTo(self.contentView).mas_offset(-20);
    }];
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont themeFontMedium:18];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.text = @"价格分析";
    }
    return _titleLabel;
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

@implementation FHDetailPureTitleModel

@end
