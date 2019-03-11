//
//  FHSuggestionListNavBar.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHSuggestionListNavBar.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"
#import "FHExtendHotAreaButton.h"

@interface FHSuggestionListNavBar ()

@property (nonatomic, strong)   UIView       *searchAreaPanel;
@property (nonatomic, strong)   UIImageView       *triangleImage;
@property (nonatomic, strong)   UIView       *verticalLineView;
@property (nonatomic, strong)   UIImageView       *searchIcon;
@property (nonatomic, strong)   UIView       *bottomLineView;

@end

@implementation FHSuggestionListNavBar

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
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    CGFloat statusBarHeight = (isIphoneX ? 44 : 20);
    // searchAreaPanel
    _searchAreaPanel = [[UIView alloc] init];
    _searchAreaPanel.backgroundColor = [UIColor themeGray7];
    _searchAreaPanel.layer.masksToBounds = YES;
    _searchAreaPanel.layer.cornerRadius = 4.0;
    [self addSubview:_searchAreaPanel];
    // backBtn
    _backBtn = [[FHExtendHotAreaButton alloc] init];
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
    // searchTypeLabel
    _searchTypeLabel = [[UILabel alloc] init];
    _searchTypeLabel.textColor = [UIColor themeGray1];
    _searchTypeLabel.font = [UIFont themeFontRegular:14];
    [_searchAreaPanel addSubview:_searchTypeLabel];
    [_searchTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchAreaPanel).offset(10);
        make.centerY.mas_equalTo(self.searchAreaPanel);
        make.width.mas_equalTo(42);
    }];
    
    // triangleImage
    _triangleImage = [[UIImageView alloc] init];
    _triangleImage.image = [UIImage imageNamed:@"icon-triangle-open"];
    [_searchAreaPanel addSubview:_triangleImage];
    [_triangleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchTypeLabel.mas_right).offset(6);
        make.height.width.mas_equalTo(9);
        make.centerY.mas_equalTo(self.searchAreaPanel);
    }];
    // verticalLineView
    _verticalLineView = [[UIView alloc] init];
    _verticalLineView.backgroundColor = [UIColor themeGray6];
    _verticalLineView.layer.masksToBounds = YES;
    // _verticalLineView.layer.borderColor = [UIColor whiteColor].CGColor;
    // _verticalLineView.layer.borderWidth = 0.5;
    [_searchAreaPanel addSubview:_verticalLineView];
    [_verticalLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(15);
        make.centerY.mas_equalTo(self.searchAreaPanel);
        make.left.mas_equalTo(self.triangleImage.mas_right).offset(10);
    }];
    
    // searchTypeBtn
    _searchTypeBtn = [[UIButton alloc] init];
    _searchTypeBtn.backgroundColor = UIColor.clearColor;
    [_searchAreaPanel addSubview:_searchTypeBtn];
    [_searchTypeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self.searchAreaPanel);
        make.right.mas_equalTo(self.verticalLineView.mas_left);
    }];
    
    // searchIcon
    _searchIcon = [[UIImageView alloc] init];
    _searchIcon.image = [UIImage imageNamed:@"icon-search-titlebar"];
    [_searchAreaPanel addSubview:_searchIcon];
    [_searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.verticalLineView.mas_right).offset(10);
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
    [self setSearchPlaceHolderText:@"二手房/租房/小区"];
}

- (void)setSearchPlaceHolderText:(NSString *)text {
    if (text.length > 0) {
        NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:14],NSForegroundColorAttributeName:[UIColor themeGray3]};
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:attr];
        _searchInput.attributedPlaceholder = attrStr;
    }
}

@end

