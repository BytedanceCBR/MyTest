//
//  FHSugSubscribeItemCell.m
//  FHHouseList
//
//  Created by 张元科 on 2019/3/19.
//

#import "FHSugSubscribeItemCell.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"
#import "FHUserTracker.h"

@interface FHSugSubscribeItemCell ()

@property (nonatomic, strong)   UILabel       *unValidLabel; // 已失效
@property (nonatomic, strong)   UIImageView       *rightIcon; //
@property (nonatomic, strong)   UIView       *bottomLine;

@end

@implementation FHSugSubscribeItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.isValid = YES;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"";
    _titleLabel.font = [UIFont themeFontMedium:14];
    _titleLabel.textColor = [UIColor themeGray1];
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.left.mas_equalTo(20);
        make.height.mas_equalTo(24);
    }];
    // rightIcon
    _rightIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon-feed"]];
    [self addSubview:_rightIcon];
    [_rightIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(-15);
        make.height.width.mas_equalTo(16);
    }];
    // sugLabel
    _sugLabel = [[UILabel alloc] init];
    _sugLabel.text = @"";
    _sugLabel.numberOfLines = 2;
    _sugLabel.font = [UIFont themeFontRegular:12];
    _sugLabel.textColor = [UIColor themeGray3];
    [self addSubview:_sugLabel];
    [_sugLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-15.5);
    }];
    // unValidLabel
    _unValidLabel = [[UILabel alloc] init];
    _unValidLabel.layer.cornerRadius = 2.0;
    _unValidLabel.layer.borderColor = [UIColor themeGray6].CGColor;
    _unValidLabel.layer.borderWidth = 0.5;
    _unValidLabel.text = @"已失效";
    _unValidLabel.textAlignment = NSTextAlignmentCenter;
    _unValidLabel.backgroundColor = [UIColor themeGray7];
    _unValidLabel.font = [UIFont themeFontRegular:10];
    _unValidLabel.textColor = [UIColor themeGray3];
    [self addSubview:_unValidLabel];
    [_unValidLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(6);
        make.right.mas_lessThanOrEqualTo(self).offset(-20);
        make.height.mas_equalTo(15);
        make.width.mas_equalTo(36);
    }];
    // bottomLine
    _bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [UIColor themeGray6];
    [self addSubview:_bottomLine];
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)setIsValid:(BOOL)isValid {
    _isValid = isValid;
    if (isValid) {
        _titleLabel.textColor = [UIColor themeGray1];
        _sugLabel.textColor = [UIColor themeGray3];
        [self.unValidLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.right.mas_lessThanOrEqualTo(self).offset(-40);
        }];
        _rightIcon.hidden = NO;
    } else {
        _titleLabel.textColor = [UIColor themeGray3];
        _sugLabel.textColor = [UIColor themeGray4];
        [self.unValidLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(36);
            make.right.mas_lessThanOrEqualTo(self).offset(-20);
        }];
        _rightIcon.hidden = YES;
    }
}

@end
