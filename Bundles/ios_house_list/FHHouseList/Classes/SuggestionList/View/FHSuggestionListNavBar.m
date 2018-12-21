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

@interface FHSuggestionListNavBar ()

@property (nonatomic, strong)   UIView       *searchAreaPanel;
@property (nonatomic, strong)   UILabel       *searchTypeLabel;
@property (nonatomic, strong)   UIImageView       *triangleImage;
@property (nonatomic, strong)   UIView       *verticalLineView;
@property (nonatomic, strong)   UIImageView       *searchIcon;
@property (nonatomic, strong)   UITextField       *searchInput;

@end

@implementation FHSuggestionListNavBar

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
    _searchAreaPanel.backgroundColor = [UIColor colorWithHexString:@"#f2f4f5"];
    _searchAreaPanel.layer.masksToBounds = YES;
    _searchAreaPanel.layer.cornerRadius = 4.0;
    [self addSubview:_searchAreaPanel];
    // backBtn
    _backBtn = [[FHExtendHotAreaButton alloc] init];
    [_backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_backBtn setTitle:@"取消" forState:UIControlStateHighlighted];
    _backBtn.titleLabel.font = [UIFont themeFontRegular:16];
    [_backBtn setTitleColor:[UIColor themeBlue1] forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor themeBlue1] forState:UIControlStateHighlighted];
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
    _searchTypeLabel.textColor = [UIColor colorWithHexString:@"#505050"];
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
        make.left.mas_equalTo(self.searchTypeLabel.mas_right).offset(6).priorityHigh();
        make.height.width.mas_equalTo(9);
        make.centerY.mas_equalTo(self.searchAreaPanel);
    }];
    // verticalLineView
    _verticalLineView = [[UIView alloc] init];
    _verticalLineView.backgroundColor = [UIColor colorWithHexString:@"#d8d8d8"];
    _verticalLineView.layer.masksToBounds = YES;
//    _verticalLineView.layer.borderColor = [UIColor whiteColor].CGColor;
//    _verticalLineView.layer.borderWidth = 0.5;
    [_searchAreaPanel addSubview:_verticalLineView];
    [_verticalLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(15);
        make.centerY.mas_equalTo(self.searchAreaPanel);
        make.left.mas_equalTo(self.triangleImage.mas_right).offset(10);
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
    _searchInput.font = [UIFont themeFontRegular:12];
    _searchInput.textColor = [UIColor colorWithHexString:@"#081f33"];
    _searchInput.returnKeyType = UIReturnKeySearch;
    _searchInput.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_searchAreaPanel addSubview:_searchInput];
    [_searchInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchIcon.mas_right).offset(8);
        make.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.searchAreaPanel);
        make.right.mas_equalTo(self.searchAreaPanel);
    }];
    NSString *str = @"_clearButton";
    UIButton *btn = [_searchInput valueForKey:str];
    [btn setImage:[UIImage imageNamed:@"search_delete"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"search_delete"] forState:UIControlStateHighlighted];
}

@end


// FHExtendHotAreaButton

@implementation FHExtendHotAreaButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isExtend = YES;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    CGFloat widthDelta = bounds.size.width;
    CGFloat heightDelta = bounds.size.height;
    CGFloat dx = 0;
    CGFloat dy = 0;
    if (_isExtend) {
        dx = widthDelta / 2;
        dy = heightDelta / 2;
        // 小屏幕手机
        if ([UIScreen mainScreen].bounds.size.width < 330) {
            dx = widthDelta / 4;
            dy = heightDelta / 4;
        }
    } else {
        dx = 0;
        dy = 0;
    }
    bounds = CGRectMake(bounds.origin.x - dx, bounds.origin.y - dy, widthDelta + 2 * dx, heightDelta + 2 * dy);
    return CGRectContainsPoint(bounds, point);
}

@end
