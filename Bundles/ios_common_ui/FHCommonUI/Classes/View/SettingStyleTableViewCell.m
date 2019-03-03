//
//  SettingStyleTableViewCell.m
//  AFgzipRequestSerializer
//
//  Created by leo on 2018/11/11.
//

#import "SettingStyleTableViewCell.h"
#import <Masonry/Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"
@interface SettingStyleTableViewCell ()
@property (nonatomic, weak) UIView* seperateLineView;
@property (nonatomic, strong) NSString* indicatorImageName;
@end

@implementation SettingStyleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.indicatorImageName = @"arrow";
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {

    self.seperateLineView = [[UIView alloc] init];
    _seperateLineView.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:_seperateLineView];
    [_seperateLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.right.bottom.mas_equalTo(self.contentView);
        make.left.mas_equalTo(20);
    }];

    self.indicatorView = [[UIImageView alloc] init];
    [self.contentView addSubview:_indicatorView];
    _indicatorView.image = [UIImage imageNamed:_indicatorImageName];
    [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.width.height.mas_equalTo(16);
        make.centerY.mas_equalTo(self.contentView);
    }];

    self.label = [[UILabel alloc] init];
    [self.contentView addSubview:_label];
    [self setLabelStyle:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.bottom.mas_equalTo(-20);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(_indicatorView.mas_left).offset(5);
    }];

}

- (void)setLabelStyle:(UILabel*) label {
    label.textColor = [UIColor themeGray1];
    label.font = [UIFont themeFontRegular:16];
}

@end
