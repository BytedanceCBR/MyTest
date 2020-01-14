//
//  FHUGCUserFollowTC.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/10/16.
//

#import "FHUGCUserFollowTC.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"
#import "FHUGCFollowButton.h"
#import "FHUGCConfig.h"
#import "TTRoute.h"
#import "FHUGCUserFollowModel.h"

@interface FHUGCUserFollowTC ()

@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UIImageView *icon;

@end

@implementation FHUGCUserFollowTC

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHUGCUserFollowDataFollowListModel class]]) {
        return;
    }
    self.currentData = data;
    
    FHUGCUserFollowDataFollowListModel *model = (FHUGCUserFollowDataFollowListModel *)self.currentData;
    
    _nameLabel.text = model.userName;
    _descLabel.text = [NSString stringWithFormat:@"%@",model.followTime];
    [self.icon bd_setImageWithURL:[NSURL URLWithString:model.avatarUrl] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
    if (model.followTime.length > 0) {
        self.descLabel.hidden = NO;
        [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.icon).offset(3);
            make.left.mas_equalTo(self.icon.mas_right).offset(10);
            make.right.mas_equalTo(self).offset(-20);
            make.height.mas_equalTo(21);
        }];
        
        [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(2);
            make.left.mas_equalTo(self.nameLabel);
            make.right.mas_equalTo(self.nameLabel);
            make.height.mas_equalTo(19);
        }];
    } else {
        self.descLabel.hidden = YES;
        [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.left.mas_equalTo(self.icon.mas_right).offset(10);
            make.right.mas_equalTo(self).offset(-20);
            make.height.mas_equalTo(21);
        }];
    }
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
    
    self.nameLabel = [self LabelWithFont:[UIFont themeFontRegular:15] textColor:[UIColor themeGray1]];
    [self.contentView addSubview:_nameLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self.contentView addSubview:_descLabel];
    
    [self setupConstraints];
}


- (void)setupConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.width.height.mas_equalTo(48);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon).offset(3);
        make.left.mas_equalTo(self.icon.mas_right).offset(10);
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(21);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(2);
        make.left.mas_equalTo(self.nameLabel);
        make.right.mas_equalTo(self.nameLabel);
        make.height.mas_equalTo(19);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 1;
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end

// FHUGCUserFollowSectionHeader
@interface FHUGCUserFollowSectionHeader ()

@end

@implementation FHUGCUserFollowSectionHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    self.sectionLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    [self addSubview:_sectionLabel];
    
    [self setupConstraints];
}


- (void)setupConstraints {
    
    [self.sectionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(-10);
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(17);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 1;
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
