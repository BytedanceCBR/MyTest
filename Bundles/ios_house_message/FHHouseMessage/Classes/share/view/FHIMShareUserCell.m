//
//  FHIMShareUserCell.m
//  ios_house_im
//
//  Created by leo on 2019/4/14.
//

#import "FHIMShareUserCell.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"

@interface FHIMShareUserCell ()
@end

@implementation FHIMShareUserCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.avator = [[UIImageView alloc] init];
    _avator.layer.masksToBounds = YES;
    _avator.layer.cornerRadius = 22;
    _avator.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_avator];
    [_avator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
        make.left.mas_equalTo(20);
        make.width.height.mas_equalTo(44);
    }];

    self.title = [[UILabel alloc] init];
    _title.font = [UIFont themeFontMedium:16];
    _title.textColor = [UIColor themeGray1];
    [self.contentView addSubview:_title];
    [_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avator.mas_right).mas_equalTo(12);
        make.height.mas_equalTo(22);
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(self.avator);
    }];
    _title.text = @"经纪人";
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
