//
//  FHSearchBar.m
//  FHCommonUI
//
//  Created by 张静 on 2019/4/18.
//

#import "FHSearchBar.h"
#import <Masonry.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/UIButton+TTAdditions.h>

@interface FHSearchBar ()

@property (nonatomic, strong)   UIView       *searchAreaPanel;
@property (nonatomic, strong)   UIImageView       *searchIcon;
@property (nonatomic, strong)   UIView       *bottomLineView;

@end

@implementation FHSearchBar

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
    // searchAreaPanel
    _searchAreaPanel = [[UIView alloc] init];
    _searchAreaPanel.backgroundColor = [UIColor themeGray7];
    _searchAreaPanel.layer.masksToBounds = YES;
    _searchAreaPanel.layer.cornerRadius = 4.0;
    [self addSubview:_searchAreaPanel];
    // backBtn
    _backBtn = [[UIButton alloc] init];
    _backBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -5, -5, -10);
    [_backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_backBtn setTitle:@"取消" forState:UIControlStateHighlighted];
    _backBtn.titleLabel.font = [UIFont themeFontRegular:16];
    [_backBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateHighlighted];
    [self addSubview:_backBtn];
    [_searchAreaPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self).offset(statusBarHeight + 4);
        if ([UIScreen mainScreen].bounds.size.width < 350) {
            make.right.mas_equalTo(self.backBtn.mas_left).offset(-15);
        } else {
            make.right.mas_equalTo(self.backBtn.mas_left).offset(-20);
        }
        make.height.mas_equalTo(33);
    }];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(26);
        make.width.mas_equalTo(32);
        make.centerY.mas_equalTo(self.searchAreaPanel);
    }];
    
    // searchIcon
    _searchIcon = [[UIImageView alloc] init];
    _searchIcon.image = [UIImage imageNamed:@"icon-search-titlebar"];
    [_searchAreaPanel addSubview:_searchIcon];
    [_searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchAreaPanel.mas_left).offset(10);
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
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.searchAreaPanel);
        make.right.mas_equalTo(self.searchAreaPanel);
    }];
    NSString *str = @"_clearButton";
    UIButton *btn = [_searchInput valueForKey:str];
    [btn setImage:[UIImage imageNamed:@"search_delete"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"search_delete"] forState:UIControlStateHighlighted];
    _bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = [UIColor themeGray6];
    [self addSubview:_bottomLineView];
    [_bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(self);
    }];
}

- (void)setupData {
    [self setSearchPlaceHolderText:@"请输入城市名称"];
}

- (void)setSearchPlaceHolderText:(NSString *)text {
    if (text.length > 0) {
        NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:14],NSForegroundColorAttributeName:[UIColor themeGray3]};
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:attr];
        _searchInput.attributedPlaceholder = attrStr;
    }
}

@end

