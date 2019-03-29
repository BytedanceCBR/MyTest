//
//  FHPriceValuationNSearchView.m
//  FHHouseList
//
//  Created by 张元科 on 2019/3/27.
//

#import "FHPriceValuationNSearchView.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"
#import "FHExtendHotAreaButton.h"

@interface FHPriceValuationNSearchView ()

@property (nonatomic, strong)   UIView       *searchAreaPanel;
@property (nonatomic, strong)   UIImageView       *searchIcon;

@end

@implementation FHPriceValuationNSearchView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupData];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor themeGray7];
    // searchAreaPanel
    _searchAreaPanel = [[UIView alloc] init];
    _searchAreaPanel.backgroundColor = [UIColor whiteColor];
    _searchAreaPanel.layer.masksToBounds = YES;
    _searchAreaPanel.layer.cornerRadius = 4.0;
    _searchAreaPanel.layer.borderWidth = 1.0;
    _searchAreaPanel.layer.borderColor = [UIColor themeGray6].CGColor;
    [self addSubview:_searchAreaPanel];
    [_searchAreaPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(20);
        make.height.mas_equalTo(44);
        make.right.mas_equalTo(-20);
    }];
    
    // searchIcon
    _searchIcon = [[UIImageView alloc] init];
    _searchIcon.image = [UIImage imageNamed:@"icon-search-titlebar"];
    [_searchAreaPanel addSubview:_searchIcon];
    [_searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchAreaPanel).offset(15);
        make.height.width.mas_equalTo(12);
        make.centerY.mas_equalTo(self.searchAreaPanel);
    }];
    
    // searchInput
    _searchInput = [[UITextField alloc] init];
    _searchInput.background = NULL;
    _searchInput.font = [UIFont themeFontRegular:14];
    _searchInput.textColor = [UIColor themeGray1];
    _searchInput.tintColor = [UIColor themeGray1];
    _searchInput.returnKeyType = UIReturnKeySearch;
    _searchInput.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_searchAreaPanel addSubview:_searchInput];
    [_searchInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchIcon.mas_right).offset(7);
        make.height.mas_equalTo(21);
        make.centerY.mas_equalTo(self.searchAreaPanel);
        make.right.mas_equalTo(self.searchAreaPanel).offset(-5);
    }];
    NSString *str = @"_clearButton";
    UIButton *btn = [_searchInput valueForKey:str];
    [btn setImage:[UIImage imageNamed:@"search_delete"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"search_delete"] forState:UIControlStateHighlighted];
}

- (void)setupData {
    [self setSearchPlaceHolderText:@"请输入小区名称"];
}

- (void)setSearchPlaceHolderText:(NSString *)text {
    if (text.length > 0) {
        NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:15],NSForegroundColorAttributeName:[UIColor themeGray3]};
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:attr];
        _searchInput.attributedPlaceholder = attrStr;
    }
}

@end
