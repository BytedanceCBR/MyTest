//
// Created by zhulijun on 2019-06-12.
//

#import <Masonry/View+MASAdditions.h>
#import "FHCommunityDetailHeaderView.h"
#import "UIColor+Theme.h"
#import "UILabel+House.h"
#import "WDDefines.h"
#import "IMConsDefine.h"
#import "FHUGCFollowButton.h"
#import "SSViewBase.h"

@interface FHCommunityDetailHeaderView ()
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
    //刘海平多出24
    self.headerBackHeight = [TTDeviceHelper isIPhoneXSeries] ? 214 : 190;
    self.backgroundColor = [UIColor themeGray7];

    self.topBack = [[UIImageView alloc] init];
    self.topBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fh_ugc_community_detail_header_back"]];
    self.topBack.contentMode = UIViewContentModeScaleAspectFill;

    self.avatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_avatar"]];
    self.avatar.layer.borderWidth = 0.5;
    self.avatar.layer.borderColor = [UIColor themeGray6].CGColor;
    self.avatar.layer.cornerRadius = 25;
    self.avatar.clipsToBounds = YES;

    self.nameLabel = [UILabel createLabel:@"世纪城" textColor:@"" fontSize:16];
    self.nameLabel.textColor = [UIColor themeWhite];
    self.nameLabel.numberOfLines = 1;

    self.subtitleLabel = [UILabel createLabel:@"82930个成员" textColor:@"" fontSize:12];
    self.subtitleLabel.textColor = [UIColor themeWhite];
    self.subtitleLabel.numberOfLines = 1;

    self.labelContainer = [[UIView alloc] init];
    [self.labelContainer addSubview:self.nameLabel];
    [self.labelContainer addSubview:self.subtitleLabel];

    self.followButton = [[FHUGCFollowButton alloc] initWithFrame:CGRectZero style:FHUGCFollowButtonStyleNoBorder];
    self.followButton.followed = NO;

    self.publicationsLabel = [UILabel createLabel:@"公告" textColor:@"" fontSize:13];
    self.publicationsLabel.textColor = [UIColor themeRed1];

    self.publicationsContentLabel = [UILabel createLabel:@"此讨论组为世纪城委员会成员自发组织加入，大家自行加入共同建立家园" textColor:@"" fontSize:13];
    self.publicationsContentLabel.textColor = [UIColor themeGray1];
    self.publicationsContentLabel.numberOfLines = 0;
    [self.publicationsContentLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    self.publicationsContainer = [[UIView alloc] init];
    self.publicationsContainer.backgroundColor = [UIColor themeWhite];
    [self.publicationsContainer addSubview:self.publicationsLabel];
    [self.publicationsContainer addSubview:self.publicationsContentLabel];
    [self.publicationsContainer.layer setCornerRadius:4.0f];
    self.publicationsContainer.layer.borderWidth = 0.5f;
    self.publicationsContainer.layer.borderColor = [UIColor themeGray6].CGColor;

    self.publicationsContainer.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    self.publicationsContainer.layer.shadowOffset = CGSizeMake(0, 2);//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    self.publicationsContainer.layer.shadowOpacity = 0.1;//0.8;//阴影透明度，默认0
    self.publicationsContainer.layer.shadowRadius = 4;//8;//阴影半径，默认3

    [self addSubview:self.topBack];
    [self addSubview:self.avatar];
    [self addSubview:self.labelContainer];
    [self addSubview:self.followButton];
    [self addSubview:self.publicationsContainer];
}

- (void)initConstraints {
    self.topBack.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.headerBackHeight);

    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.topBack).offset(20);
        make.bottom.mas_equalTo(self.topBack).offset(-46);
        make.width.height.mas_equalTo(50);
    }];

    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.avatar);
        make.height.mas_equalTo(26);
        make.width.mas_equalTo(56);
        make.right.mas_equalTo(self).offset(-20);
    }];

    [self.labelContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.avatar);
        make.height.mas_equalTo(44);
        make.left.mas_equalTo(self.avatar.mas_right).offset(8);
        make.right.mas_equalTo(self.followButton.mas_left).offset(-8);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.labelContainer);
        make.height.mas_equalTo(22);
    }];

    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.labelContainer);
        make.height.mas_equalTo(17);
    }];

    [self.publicationsContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.top.mas_equalTo(self.topBack.mas_bottom).offset(-30);
        make.bottom.mas_equalTo(self.publicationsContentLabel).offset(15).priorityHigh();
    }];

    [self.publicationsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self.publicationsContainer).offset(15);
        make.width.mas_equalTo(26);
        make.height.mas_equalTo(20);
    }];

    [self.publicationsContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.publicationsContainer).offset(15);
        make.left.mas_equalTo(self.publicationsLabel.mas_right).offset(10);
        make.right.mas_equalTo(self.publicationsContainer).offset(-15);
    }];

    [self resize];
}

- (void)resize {
    [self layoutIfNeeded];
    CGFloat height = CGRectGetMaxY(self.publicationsContainer.frame);
    CGRect frame = self.frame;
    frame.size.height = height + 10;
    self.frame = frame;
}
@end
