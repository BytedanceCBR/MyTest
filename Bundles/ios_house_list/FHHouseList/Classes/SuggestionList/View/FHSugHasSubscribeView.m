//
//  FHSugHasSubscribeView.m
//  FHHouseList
//
//  Created by 张元科 on 2019/3/20.
//

#import "FHSugHasSubscribeView.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "TTDeviceHelper.h"
#import "FHUserTracker.h"

@interface FHSugHasSubscribeView ()

@property (nonatomic, strong)   UILabel       *label;
@property (nonatomic, strong)   UIButton       *rightButton;
@property (nonatomic, strong)   UIButton       *headerButton;
@property (nonatomic, strong)   NSMutableArray       *tempViews;

@end

@implementation FHSugHasSubscribeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.hasSubscribeViewHeight = 194;
        self.totalCount = 0;
        self.tempViews = [NSMutableArray new];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // headerButton
    _headerButton = [[UIButton alloc] init];
    _headerButton.backgroundColor = [UIColor whiteColor];
    [self addSubview:_headerButton];
    // label
    _label = [[UILabel alloc] init];
    _label.text = @"已订阅搜索";
    _label.font = [UIFont themeFontMedium:14];
    _label.textColor = [UIColor themeGray1];
    [self addSubview:_label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    // rightButton
    _rightButton = [[UIButton alloc] init];
    [_rightButton setImage:[UIImage imageNamed:@"arrowicon-feed"] forState:UIControlStateNormal];
    [_rightButton setImage:[UIImage imageNamed:@"arrowicon-feed"] forState:UIControlStateHighlighted];
    [self addSubview:_rightButton];
    [_rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.width.mas_equalTo(20);
    }];
    _rightButton.userInteractionEnabled = NO;
    // headerButton
    [_headerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(30);
    }];
    [_headerButton addTarget:self action:@selector(headerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)headerButtonClick:(UIButton *)button {
    
}

// 先设置totalCount
- (void)setSubscribeItems:(NSArray<FHSugSubscribeDataDataItemsModel> *)subscribeItems {
    _subscribeItems = subscribeItems;
     [self reAddViews];
}

- (void)reAddViews {
    for (UIView *v in self.tempViews) {
        [v removeFromSuperview];
    }
    [self.tempViews removeAllObjects];
    if (self.subscribeItems.count <= 0) {
        self.hasSubscribeViewHeight = CGFLOAT_MIN;
        return;
    }
    // 高度计算
    if (self.subscribeItems.count <= 2) {
        self.hasSubscribeViewHeight = 124;
    } else {
         self.hasSubscribeViewHeight = 194;
    }
    if (self.totalCount > 4) {
        // 显示右边箭头 可点击
        self.rightButton.hidden = NO;
        self.headerButton.hidden = NO;
    } else {
        self.rightButton.hidden = YES;
        self.headerButton.hidden = YES;
    }
    // 添加Views
    
}

@end
