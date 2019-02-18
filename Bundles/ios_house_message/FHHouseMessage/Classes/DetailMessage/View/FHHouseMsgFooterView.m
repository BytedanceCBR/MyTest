//
//  FHHouseMsgFooterView.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHHouseMsgFooterView.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "TTDeviceHelper.h"

@interface FHHouseMsgFooterView()

@property(nonatomic, strong) UIButton *openAllBtn;
@property(nonatomic, strong) UIView *topLine;
@property(nonatomic, strong) UIView *bottomLine;
@property(nonatomic, strong) UIImageView *settingArrowImageView;

@end

@implementation FHHouseMsgFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.openAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_openAllBtn addTarget:self action:@selector(openAll) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_openAllBtn];
    
    self.contentLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeBlack]];
    [self addSubview:_contentLabel];
    
    self.settingArrowImageView = [[UIImageView alloc] init];
    _settingArrowImageView.image = [UIImage imageNamed:@"arrowicon-msseage"];
    [self addSubview:_settingArrowImageView];
    
    self.topLine = [[UIView alloc] init];
    _topLine.backgroundColor = [UIColor themeGray7];
    [self addSubview:_topLine];
    
    self.bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [UIColor themeGray7];
    [self addSubview:_bottomLine];
}

- (void)initConstraints {
    [self.openAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self.settingArrowImageView.mas_left).offset(-20);
        make.centerY.mas_equalTo(self);
    }];
    
    [self.settingArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-14);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(18);
        make.height.mas_equalTo(18);
    }];
    
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self);
        make.height.mas_equalTo(1);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
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
