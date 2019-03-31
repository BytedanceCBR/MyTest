//
//  FHPriceValuationNSCell.m
//  FHHouseList
//
//  Created by 张元科 on 2019/3/27.
//

#import "FHPriceValuationNSCell.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"
#import "FHSuggestionListNavBar.h"
#import "FHExtendHotAreaButton.h"

@implementation FHPriceValuationNSCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // label
    _label = [[UILabel alloc] init];
    _label.font = [UIFont themeFontRegular:15];
    _label.textColor = [UIColor themeGray1];
    _label.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(self.contentView);
        make.height.mas_equalTo(21);
        make.right.mas_equalTo(self.contentView).offset(-20);
    }];
    // sepLine
    _sepLine = [[UIView alloc] init];
    _sepLine.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_sepLine];
    [_sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
}

@end
