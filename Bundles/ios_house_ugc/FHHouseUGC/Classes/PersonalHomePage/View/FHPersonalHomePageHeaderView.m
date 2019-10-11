//
//  FHPersonalHomePageHeaderView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/11.
//

#import "FHPersonalHomePageHeaderView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "TTDeviceHelper.h"
#import <UIView+XWAddForRoundedCorner.h>
#import "FHPersonalHomePageItemView.h"
#import <UIImageView+BDWebImage.h>
#import <TTRoute.h>

#define iconWidth 76
#define topMargin 20
#define leftMargin 20
#define rightMargin 20
#define middleMargin 15

@interface FHPersonalHomePageHeaderView ()

@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) FHPersonalHomePageItemView *commentView;
@property(nonatomic, strong) FHPersonalHomePageItemView *focusView;

@end

@implementation FHPersonalHomePageHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor whiteColor];
    
    self.icon = [[UIImageView alloc] init];
    _icon.backgroundColor = [UIColor themeGray7];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.layer.masksToBounds = YES;
    [_icon xw_roundedCornerWithRadius:iconWidth/2 cornerColor:[UIColor whiteColor]];
    [self addSubview:_icon];
    
    __weak typeof(self) wself = self;
    self.commentView = [[FHPersonalHomePageItemView alloc] initWithFrame:CGRectZero];
    _commentView.itemClickBlock = ^{
        [wself commentClicked];
    };
    [self addSubview:_commentView];
    
    self.focusView = [[FHPersonalHomePageItemView alloc] initWithFrame:CGRectZero];
    _focusView.itemClickBlock = ^{
        [wself focusClicked];
    };
    [self addSubview:_focusView];
}

- (void)initConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(topMargin);
        make.left.mas_equalTo(self).offset(leftMargin);
        make.width.height.mas_equalTo(iconWidth);
    }];
    
    CGFloat x = leftMargin + iconWidth + middleMargin;
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - x - rightMargin)/2;
    
    [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right).offset(middleMargin);
        make.centerY.mas_equalTo(self.icon);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(38);
    }];
    
    [self.focusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.commentView.mas_right);
        make.centerY.mas_equalTo(self.icon);
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(self.commentView);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)updateData {
    [self.icon bd_setImageWithURL:[NSURL URLWithString:@"http://p99.pstatp.com/origin/dae90013969ce8c8e4f0"] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
    [self.commentView updateWithTopContent:@"1012" bottomContent:@"评论"];
    [self.focusView updateWithTopContent:@"8" bottomContent:@"TA的关注"];
}

- (void)commentClicked {
    NSLog(@"in");
}

- (void)focusClicked {
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"person_id"] = @"";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    //跳转到关注列表
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_focus_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

@end
