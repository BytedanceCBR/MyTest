//
// Created by zhulijun on 2019-06-12.
//

#import <Masonry/View+MASAdditions.h>
#import "FHCommunityDetailHeaderView.h"
#import "UIColor+Theme.h"
#import "UILabel+House.h"

@interface FHCommunityDetailHeaderView ()
@property(nonatomic, strong) UIImageView *topBack;
@property(nonatomic, strong) UIImageView *avatar;
@property(nonatomic, strong) UIView *labelContainer;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *descLabel;
@property(nonatomic, strong) UIButton *joniButton;
@end

@implementation FHCommunityDetailHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self initConstraints];
    }

    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor themeGray7];
    self.topBack = [[UIImageView alloc] init];
    self.avatar = [[UIImageView alloc] init];

    self.nameLabel = [[UILabel createLabel:@"世纪城" textColor:@"" fontSize:16] init];
    self.nameLabel.numberOfLines = 1;

    self.descLabel = [[UILabel createLabel:@"82930个成员" textColor:@"" fontSize:12] init];
    self.descLabel.numberOfLines = 1;

    self.labelContainer = [[UIView alloc] init];
    [self.labelContainer addSubview:self.nameLabel];
    [self.labelContainer addSubview:self.descLabel];

    self.joniButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [self addSubview:self.topBack];
    [self addSubview:self.avatar];
    [self addSubview:self.labelContainer];
    [self addSubview:self.joniButton];
}

- (void)initConstraints {
    [self.topBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self);
        make.height.mas_equalTo(190);
    }];

    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.bottom.mas_equalTo(self.topBack.mas_bottom).offset(-46);
        make.width.height.mas_equalTo(50);
    }];

    [self.joniButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.avatar);
        make.height.mas_equalTo(26);
        make.width.mas_equalTo(56);
        make.right.mas_equalTo(self).offset(-20);
    }];

    [self.labelContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.avatar);
        make.height.mas_equalTo(44);
        make.left.mas_equalTo(self.avatar).offset(8);
        make.right.mas_equalTo(self.joniButton).offset(-8);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.labelContainer);
    }];

    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.labelContainer);
    }];

}

@end