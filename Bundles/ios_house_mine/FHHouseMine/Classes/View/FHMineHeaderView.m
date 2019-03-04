//
//  FHMineHeaderView.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHMineHeaderView.h"
#import "BDWebImage.h"
#import <Masonry/Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import <UIImageView+BDWebImage.h>

@interface FHMineHeaderView ()

@end


@implementation FHMineHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self){
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self initView];
    [self initConstaints];
}

- (void)initView {
    self.icon = [[UIImageView alloc] init];
    self.icon.clipsToBounds = YES;
    self.icon.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_icon];
    _icon.layer.cornerRadius = 31;
    _icon.layer.masksToBounds = YES;
    
    self.userNameLabel = [[UILabel alloc] init];
    [self addSubview:_userNameLabel];
    [self setNameLabelStyle:_userNameLabel];
    
    self.descLabel = [[UILabel alloc] init];
    [self addSubview:_descLabel];
    [self setDesclabelStyle:_descLabel];
    
    self.editIcon = [[UIImageView alloc] init];
    _editIcon.image = [UIImage imageNamed:@"pencil-simple-line-icons"];
    [self addSubview:_editIcon];
}

- (void)initConstaints {
    [_icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(39);
        make.width.height.mas_equalTo(62);
    }];

    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(34);
        make.top.mas_equalTo(43);
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_lessThanOrEqualTo(self.icon.mas_left).offset(-10).priorityHigh();
    }];
    
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.userNameLabel.mas_bottom);
        make.right.mas_lessThanOrEqualTo(self.icon.mas_left).offset(-10);
        make.height.mas_equalTo(34);
    }];
    
    [_editIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(16);
        make.left.mas_equalTo(self.descLabel.mas_right).mas_offset(5);
        make.centerY.mas_equalTo(self.descLabel);
    }];
}

-(void)setNameLabelStyle: (UILabel*) nameLabel {
    nameLabel.font = [UIFont themeFontMedium:24];
    nameLabel.textColor = [UIColor themeGray1];
}

-(void)setDesclabelStyle: (UILabel*) descLabel {
    descLabel.font = [UIFont themeFontRegular:14];
    descLabel.textColor = [UIColor themeGray3];
}

-(void)updateAvatar:(NSString *)avatarUrl
{
    [_icon bd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholder:[UIImage imageNamed:@"default-avatar-icons"]];
}

// state:0 展示username，居中，desc不显示，不可点击；（默认）
// state:1 展示username，展示desc，点击toast提示；
// state:2 展示username，展示desc，点击到编辑页面
- (void)setUserInfoState:(NSInteger)state hasLogin:(BOOL)hasLogin
{
    NSInteger vState = state;
    if (vState > 2 || vState < 0) {
        vState = 0;
    }
    
    if (vState == 0 && hasLogin) {
        _descLabel.hidden = YES;
        _editIcon.hidden = YES;
        
        [_userNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(34);
            make.centerY.mas_equalTo(self.icon);
            make.left.mas_equalTo(self).offset(20);
            make.right.mas_lessThanOrEqualTo(self.icon.mas_left).offset(-10).priorityHigh();
        }];
    }else{
        _descLabel.hidden = NO;
        _editIcon.hidden = NO;
        
        [_userNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(34);
            make.top.mas_equalTo(43);
            make.left.mas_equalTo(self).offset(20);
            make.right.mas_lessThanOrEqualTo(self.icon.mas_left).offset(-10).priorityHigh();
        }];
    }
    
}

@end
