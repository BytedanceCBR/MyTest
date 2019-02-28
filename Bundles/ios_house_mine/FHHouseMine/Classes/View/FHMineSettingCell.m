//
//  FHMineSettingCell.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHMineSettingCell.h"
#import <Masonry/Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"

@interface FHMineSettingCell ()

@property (nonatomic, strong) NSString *indicatorImageName;

@end

@implementation FHMineSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.indicatorImageName = @"setting-arrow";
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    self.indicatorView = [[UIImageView alloc] init];
    [self.contentView addSubview:_indicatorView];
    _indicatorView.image = [UIImage imageNamed:_indicatorImageName];
    [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.width.height.mas_equalTo(12);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    self.label = [[UILabel alloc] init];
    [self.contentView addSubview:_label];
    [self setLabelStyle:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(self.indicatorView.mas_left).offset(5);
    }];
}

- (void)setLabelStyle:(UILabel*) label {
    label.textColor = [UIColor themeBlack];
    label.font = [UIFont themeFontRegular:16];
}

- (void)updateCell:(NSDictionary *)dic {
    self.label.text = dic[@"name"];
}

@end
