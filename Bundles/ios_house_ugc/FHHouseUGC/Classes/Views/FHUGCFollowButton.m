//
//  FHUGCFollowButton.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/14.
//

#import "FHUGCFollowButton.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"

@interface FHUGCFollowButton ()

@property (nonatomic, strong)   UILabel       *titleLabel;

@end

@implementation FHUGCFollowButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        self.followed = NO;
    }
    return self;
}

- (void)setFollowed:(BOOL)followed {
    _followed = followed;
    if (followed) {
        self.layer.borderColor = [[UIColor themeGray4] CGColor];
        self.titleLabel.textColor = [UIColor themeGray4];
        self.titleLabel.text = @"已关注";
    } else {
        self.layer.borderColor = [[UIColor themeRed1] CGColor];
        self.titleLabel.textColor = [UIColor themeRed1];
        self.titleLabel.text = @"关注";
    }
}

- (void)setupUI {
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 4;
    self.layer.borderColor = [[UIColor themeRed1] CGColor];
    self.layer.borderWidth = 0.5;
    self.backgroundColor = [UIColor whiteColor];
    self.titleLabel = [self labelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeRed1]];
    [self addSubview:_titleLabel];
    self.titleLabel.text = @"关注";
    self.titleLabel.font = [UIFont themeFontRegular:12];
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (UILabel *)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = font;
    label.textColor = textColor;
    return label;
}


@end
