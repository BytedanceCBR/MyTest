//
//  FHPostDetailHeaderCell.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/13.
//

#import "FHPostDetailHeaderCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"

@interface FHPostDetailHeaderCell ()

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UILabel *sourceLabel;
@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) UIButton *joinBtn;

@end

@implementation FHPostDetailHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHPostDetailHeaderModel class]]) {
        return;
    }
    self.currentData = data;
//    CGFloat height = ((FHPostDetailHeaderModel *)data).lineHeight;
    
    _titleLabel.text = @"世纪城";
    _descLabel.text = @"88热帖·9221人";
    _sourceLabel.text = @"附近推荐";
    [self.icon bd_setImageWithURL:[NSURL URLWithString:@"http://p1.pstatp.com/thumb/fea7000014edee1159ac"] placeholder:nil];
}


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
    self.icon = [[UIImageView alloc] init];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.layer.masksToBounds = YES;
    _icon.layer.cornerRadius = 24;
    _icon.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_icon];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontRegular:15] textColor:[UIColor themeGray1]];
    [self.contentView addSubview:_titleLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor themeGray3]];
    [self.contentView addSubview:_descLabel];
    
    self.sourceLabel = [self LabelWithFont:[UIFont themeFontRegular:10] textColor:[UIColor themeGray3]];
    [self.contentView addSubview:_sourceLabel];
    
    self.joinBtn = [[UIButton alloc] init];
    _joinBtn.layer.masksToBounds = YES;
    _joinBtn.layer.cornerRadius = 4;
    _joinBtn.layer.borderColor = [[UIColor themeRed1] CGColor];
    _joinBtn.layer.borderWidth = 0.5;
    [_joinBtn setTitle:@"加入" forState:UIControlStateNormal];
    [_joinBtn setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    _joinBtn.titleLabel.font = [UIFont themeFontRegular:12];
    [self addSubview:_joinBtn];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(11);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.width.height.mas_equalTo(48);
    }];
    
    [self.joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.width.mas_equalTo(58);
        make.height.mas_equalTo(24);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10);
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.right.mas_equalTo(self.joinBtn.mas_left).offset(-10);
        make.height.mas_equalTo(21);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(1);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(14);
    }];
    
    [self.sourceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLabel.mas_bottom);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(14);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end


// FHPostDetailHeaderModel

@implementation FHPostDetailHeaderModel


@end
