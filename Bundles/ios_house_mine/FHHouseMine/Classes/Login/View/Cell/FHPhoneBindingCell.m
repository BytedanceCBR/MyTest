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
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.text = @"手机号";
    self.titleLabel.font = [UIFont themeFontRegular:16];
    self.titleLabel.textColor = [UIColor themeBlack];
    self.contentLabel = [[UILabel alloc]init];
    self.contentLabel.text = @"";
    self.contentLabel.font = [UIFont themeFontRegular:14];
    self.contentLabel.textColor = [UIColor themeGray3];
    self.contentLabel.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.contentLabel];
    
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
