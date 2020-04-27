//
//  FHPhoneBindingCell.m
//  FHHouseMine
//
//  Created by luowentao on 2020/4/21.
//

#import "FHPhoneBindingCell.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "Masonry.h"

@implementation FHPhoneBindingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _titleLabel = [[UILabel alloc]init];
    _titleLabel.text = @"手机号";
    _titleLabel.font = [UIFont themeFontRegular:16];
    _titleLabel.textColor = [UIColor themeBlack];
    _contentLabel = [[UILabel alloc]init];
    _contentLabel.text = @"";
    _contentLabel.font = [UIFont themeFontRegular:14];
    _contentLabel.textColor = [UIColor themeGray3];
    _contentLabel.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:_titleLabel];
    [self.contentView addSubview:_contentLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self).offset(20);
        make.width.mas_equalTo(50);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-44);
        make.width.mas_equalTo(85);
        make.centerY.mas_equalTo(self.contentView);
        make.height.mas_equalTo(22);
    }];
}

@end
