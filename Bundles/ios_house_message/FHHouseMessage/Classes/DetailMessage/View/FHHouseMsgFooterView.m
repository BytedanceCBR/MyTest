//
//  FHHouseMsgFooterView.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHHouseMsgFooterView.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHHouseMsgFooterView()

@property(nonatomic, strong) UIButton *openAllBtn;
@property(nonatomic, strong) UIView *topLine;
@property(nonatomic, strong) UIView *bottomLine;
@property(nonatomic, strong) UIImageView *settingArrowImageView;

@end

@implementation FHHouseMsgFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        [self initViews];
    }
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    self.contentView.backgroundColor = [UIColor themeWhite];
    self.openAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_openAllBtn addTarget:self action:@selector(openAll) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_openAllBtn];
    [self.openAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    self.contentLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray1]];
    [self.contentView addSubview:_contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self.settingArrowImageView.mas_left).offset(-20);
        make.centerY.mas_equalTo(self);
    }];
    
    self.settingArrowImageView = [[UIImageView alloc] init];
    _settingArrowImageView.image = [UIImage imageNamed:@"arrowicon-msseage"];
    [self.contentView addSubview:_settingArrowImageView];
    [self.settingArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-14);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(18);
        make.height.mas_equalTo(18);
    }];
    
    self.topLine = [[UIView alloc] init];
    _topLine.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:_topLine];
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.height.mas_equalTo([UIDevice btd_onePixel]);
    }];
    
    self.bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:_bottomLine];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo([UIDevice btd_onePixel]);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)openAll {
    if(self.footerViewClickedBlock){
        self.footerViewClickedBlock();
    }
}

@end
