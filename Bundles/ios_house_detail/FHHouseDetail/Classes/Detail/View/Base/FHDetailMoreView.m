//
//  FHDetailMoreView.m
//  FHHouseDetail
//
//  Created by wangzhizhou on 2021/1/10.
//

#import "FHDetailMoreView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "UIImage+FIconFont.h"
#import <Masonry.h>

@implementation FHDetailMoreView

+ (UIImage *)moreArrowImage {
    static UIImage *rightArrowImage = nil;
    if(!rightArrowImage) {
    static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            rightArrowImage = ICON_FONT_IMG(14, @"\U0000E670", [UIColor themeGray1]);
        });
    }
    return rightArrowImage;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.font = [UIFont themeFontRegular:14];
        _titleLabel.text = @"查看全部";
    }
    return _titleLabel;
}

- (UIImageView *)rightArrowImageView {
    if(!_rightArrowImageView) {
        _rightArrowImageView = [[UIImageView alloc] initWithImage:[FHDetailMoreView moreArrowImage]];
    }
    return _rightArrowImageView;
}

- (instancetype)init {
    if(self = [super init]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.rightArrowImageView];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.equalTo(self);
            make.right.equalTo(self.rightArrowImageView.mas_left);
            make.height.mas_equalTo(22);
        }];
        
        [self.rightArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(14);
            make.centerY.equalTo(self.titleLabel);
            make.right.equalTo(self);
        }];
    }
    return self;
}
@end
