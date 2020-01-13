//
//  FHUGCReplyListEmptyView.m
//  Pods
//
//  Created by 张元科 on 2019/7/18.
//

#import "FHUGCReplyListEmptyView.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"

@interface FHUGCReplyListEmptyView ()

@end

@implementation FHUGCReplyListEmptyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    
    self.descLabel = [self labelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray3]];
    [self addSubview:_descLabel];
    [self setupConstraints];
}

- (void)setupConstraints {
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(200);
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
