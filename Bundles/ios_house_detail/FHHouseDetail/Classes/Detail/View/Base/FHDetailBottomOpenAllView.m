//
//  FHDetailBottomOpenAllView.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/17.
//

#import "FHDetailBottomOpenAllView.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "UILabel+House.h"

@interface FHDetailBottomOpenAllView ()

@property (nonatomic, strong)   UIButton       *openAllBtn;
@property (nonatomic, strong)   UILabel       *title;
@property (nonatomic, strong)   UIImageView       *settingArrowImageView;
@property (nonatomic, strong)   UIView       *topBorderView;


@end

@implementation FHDetailBottomOpenAllView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _openAllBtn = [[UIButton alloc] init];
    [self addSubview:_openAllBtn];
    
    _title = [[UILabel alloc] init];
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:@"查看更多" attributes:@{NSFontAttributeName:[UIFont themeFontRegular:16],NSForegroundColorAttributeName:[UIColor themeGray1]}];
    _title.backgroundColor = [UIColor whiteColor];
    _title.attributedText = attriStr;
    [self addSubview:_title];
    
    _settingArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting-arrow-1"]];
    [self addSubview:_settingArrowImageView];
    
    _topBorderView = [[UIView alloc] init];
    _topBorderView.backgroundColor = [UIColor themeGray6];
    [self addSubview:_topBorderView];
    CGFloat topBorderHeight = 0.5;
    if (UIScreen.mainScreen.scale > 2) {
        topBorderHeight = 0.34;
    }
    [self.topBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self);
        make.height.mas_equalTo(topBorderHeight);
    }];
    
    [self.openAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.top.mas_equalTo(6);
        make.bottom.mas_equalTo(-6);
    }];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.openAllBtn).offset(-9);
        make.centerY.mas_equalTo(self.openAllBtn);
    }];
    [self.settingArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(16);
        make.centerY.mas_equalTo(self.openAllBtn);
        make.left.mas_equalTo(self.title.mas_right).offset(1);
    }];
    
    [self.openAllBtn addTarget:self action:@selector(openButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)openButtonClick:(UIButton *)button {
    if (self.didClickCellBlk) {
        self.didClickCellBlk();
    }
}

@end
