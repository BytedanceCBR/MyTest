//
//  FHSuggestionSearchBar.m
//  FHHouseList
//
//  Created by xubinbin on 2020/4/20.
//

#import "FHSuggestionSearchBar.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHExtendHotAreaButton.h"

@interface FHSuggestionSearchBar()

@property (nonatomic, strong)   UIView       *searchAreaPanel;
@property (nonatomic, strong)   UIImageView       *searchIcon;

@end

@implementation FHSuggestionSearchBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupUI];
    }
    return self;
}

- (void) setupUI
{
    _searchAreaPanel = [[UIView alloc] init];
    _searchAreaPanel.backgroundColor = [UIColor themeWhite];
    _searchAreaPanel.layer.masksToBounds = YES;
    _searchAreaPanel.layer.cornerRadius = 17;
    _searchAreaPanel.layer.borderWidth = 0.5;
    _searchAreaPanel.layer.borderColor = [[UIColor themeGray6] CGColor];
     [self addSubview:_searchAreaPanel];
    [_searchAreaPanel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.mas_equalTo(15);
       make.top.mas_equalTo(10);
       make.height.mas_equalTo(34);
       make.right.mas_equalTo(-62);
    }];
    
    // searchIcon
    _searchIcon = [[UIImageView alloc] init];
    _searchIcon.image = [UIImage imageNamed:@"icon-search-titlebar"];
    [_searchAreaPanel addSubview:_searchIcon];
    [_searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.height.width.mas_equalTo(8);
        make.centerY.mas_equalTo(self.searchInput);
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
        make.left.mas_equalTo(self.searchIcon.mas_right).offset(4);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.searchAreaPanel);
        make.right.mas_equalTo(self.searchAreaPanel);
    }];
    
    // backBtn
    _backBtn = [[FHExtendHotAreaButton alloc] init];
    [_backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_backBtn setTitle:@"取消" forState:UIControlStateHighlighted];
    _backBtn.titleLabel.font = [UIFont themeFontRegular:16];
    [_backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self addSubview:_backBtn];
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(32);
        make.centerY.mas_equalTo(self.searchAreaPanel);
    }];
    
}

- (void)setSearchPlaceHolderText:(NSString *)text {
    if (text.length > 0) {
        NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:14],NSForegroundColorAttributeName:[UIColor themeGray3]};
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:attr];
        _searchInput.attributedPlaceholder = attrStr;
    }
}

@end
