//
//  FHTopicHeaderInfo.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/12.
//

#import "FHTopicHeaderInfo.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"

@implementation FHTopicHeaderInfo

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
    _infoLabel = [[UILabel alloc] init];
    _infoLabel.text = @"";
    _infoLabel.numberOfLines = 0;
    _infoLabel.textColor = [UIColor themeGray1];
    _infoLabel.font = [UIFont themeFontRegular:12];
    [self addSubview:_infoLabel];
    [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-10);
    }];
}

@end
