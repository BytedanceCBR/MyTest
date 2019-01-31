//
//  FHTest1Cell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHTest1Cell.h"

@interface FHTest1Cell ()

@property (nonatomic, strong)   UILabel       *label;

@end

@implementation FHTest1Cell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}


- (void)refreshWithData:(id)data {
    
}

- (void)setupUI {
    // label
    _label = [[UILabel alloc] init];
    _label.text = @"猜你想搜";
    _label.font = [UIFont themeFontMedium:14];
    _label.textColor = [UIColor themeBlue1];
    [self addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(20);
        make.height.mas_equalTo(200);
        make.bottom.mas_equalTo(self).offset(-20);
    }];
}


@end
