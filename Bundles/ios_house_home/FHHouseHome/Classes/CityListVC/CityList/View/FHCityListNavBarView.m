//
//  FHCityListNavBarView.m
//  FHHouseHome
//
//  Created by 张元科 on 2018/12/26.
//

#import "FHCityListNavBarView.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"
#import "FHSuggestionListNavBar.h"
#import "FHExtendHotAreaButton.h"

@interface FHCityListNavBarView ()

@property (nonatomic, strong)   UIView       *bottomLineView;

@end

@implementation FHCityListNavBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    CGFloat statusBarHeight = (isIphoneX ? 44 : 20);
    // backBtn
    _backBtn = [[FHExtendHotAreaButton alloc] init];
    [_backBtn setImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
    [_backBtn setImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
    [self addSubview:_backBtn];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(24);
        make.left.mas_equalTo(self).offset(18);
        make.bottom.mas_equalTo(self).offset(-16);
    }];
    // _searchBtn
    _searchBtn = [[UIButton alloc] init];
    _searchBtn.backgroundColor = [UIColor colorWithHexString:@"#f2f4f5"];
    _searchBtn.layer.cornerRadius = 4.0;
    [self addSubview:_searchBtn];
    [_searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backBtn.mas_right).offset(18);
        make.centerY.mas_equalTo(self.backBtn);
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(32);
    }];
    // searchIcon
    _searchIcon = [[UIImageView alloc] init];
    _searchIcon.image = [UIImage imageNamed:@"icon-search-titlebar"];
    [_searchBtn addSubview:_searchIcon];
    [_searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchBtn).offset(10);
        make.height.width.mas_equalTo(12);
        make.centerY.mas_equalTo(self.searchBtn);
    }];
    
    // searchLabel
    _searchLabel = [[UILabel alloc] init];
    _searchLabel.textColor = [UIColor colorWithHexString:@"#8a9299"];
    _searchLabel.font = [UIFont themeFontRegular:12];
    _searchLabel.text = @"请输入城市名";
    [_searchBtn addSubview:_searchLabel];
    [_searchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchIcon.mas_right).offset(10);
        make.centerY.mas_equalTo(self.searchBtn);
        make.right.mas_equalTo(self.searchBtn).offset(-10);
        make.height.mas_equalTo(17);
    }];
    
    _bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = [UIColor colorWithHexString:@"#e8eaeb"];
    [self addSubview:_bottomLineView];
    [_bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(self);
    }];
}

@end
