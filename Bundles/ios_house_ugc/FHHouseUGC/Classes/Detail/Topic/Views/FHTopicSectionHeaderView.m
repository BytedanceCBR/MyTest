//
//  FHTopicSectionHeaderView.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/8/21.
//

#import "FHTopicSectionHeaderView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"

@interface FHTopicSectionHeaderView()

@property (nonatomic, strong)   UILabel       *infoLabel;

@end


@implementation FHTopicSectionHeaderView

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
    _infoLabel.text = @"最新 最热 - 暂时不用";
    _infoLabel.textColor = [UIColor themeGray1];
    _infoLabel.font = [UIFont themeFontMedium:16];
    [self addSubview:_infoLabel];
    [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(23);
    }];
}
@end
