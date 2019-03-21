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
    if (self.clickHeader) {
        self.clickHeader();
    }
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
    CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - 40 - 11) / 2.0;
    CGFloat topOffset = 54;
    [self.subscribeItems enumerateObjectsUsingBlock:^(FHSugSubscribeDataDataItemsModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx >= 4) {
            *stop = YES;
        }
        NSInteger row = idx / 2;
        NSInteger column = idx % 2;
        CGRect frame = CGRectMake(20 + column * (itemWidth + 11), topOffset + row * (60 + 10), itemWidth, 60);
        FHSubscribeView *itemView = [[FHSubscribeView alloc] initWithFrame:frame];
        itemView.titleLabel.text = obj.title;
        itemView.sugLabel.text = obj.text;
        itemView.isValid = obj.status;
        itemView.tag = idx;
        [itemView addTarget:self action:@selector(subscribeViewClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:itemView];
        [self.tempViews addObject:itemView];
    }];
}

- (void)subscribeViewClick:(FHSubscribeView *)v {
    NSInteger idx = v.tag;
    if (idx >= 0 && idx < self.subscribeItems.count) {
        FHSugSubscribeDataDataItemsModel*  obj = self.subscribeItems[idx];
        if (self.clickBlk) {
            self.clickBlk(obj);
        }
    }
}

@end


@interface FHSubscribeView ()

@property (nonatomic, strong)   UILabel       *unValidLabel; // 已失效

@end

@implementation FHSubscribeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor themeGray7];
        self.layer.cornerRadius = 4.0;
        self.isValid = YES;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // titleLabel
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"";
    _titleLabel.font = [UIFont themeFontMedium:14];
    _titleLabel.textColor = [UIColor themeGray1];
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(8);
        make.left.mas_equalTo(14);
        make.height.mas_equalTo(24);
    }];
    // sugLabel
    _sugLabel = [[UILabel alloc] init];
    _sugLabel.text = @"";
    _sugLabel.font = [UIFont themeFontRegular:12];
    _sugLabel.textColor = [UIColor themeGray3];
    [self addSubview:_sugLabel];
    [_sugLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(-14);
        make.height.mas_equalTo(20);
    }];
    // unValidLabel
    _unValidLabel = [[UILabel alloc] init];
    _unValidLabel.layer.cornerRadius = 2.0;
    _unValidLabel.layer.borderColor = [UIColor themeGray6].CGColor;
    _unValidLabel.layer.borderWidth = 0.5;
    _unValidLabel.text = @"已失效";
    _unValidLabel.textAlignment = NSTextAlignmentCenter;
    _unValidLabel.backgroundColor = [UIColor themeGray7];
    _unValidLabel.font = [UIFont themeFontRegular:10];
    _unValidLabel.textColor = [UIColor themeGray3];
    [self addSubview:_unValidLabel];
    [_unValidLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(4);
        make.right.mas_equalTo(self).offset(-14);
        make.height.mas_equalTo(15);
        make.width.mas_equalTo(36);
    }];
}

- (void)setIsValid:(BOOL)isValid {
    _isValid = isValid;
    self.enabled = isValid;
    if (isValid) {
        self.backgroundColor = [UIColor themeGray7];
        self.layer.borderColor = [UIColor themeGray7].CGColor;
        self.layer.borderWidth = 0;
        _titleLabel.textColor = [UIColor themeGray1];
        _sugLabel.textColor = [UIColor themeGray3];
        [self.unValidLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.right.mas_equalTo(self).offset(-10);
        }];
    } else {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = [UIColor themeGray6].CGColor;
        self.layer.borderWidth = 0.5;
        _titleLabel.textColor = [UIColor themeGray3];
        _sugLabel.textColor = [UIColor themeGray4];
        [self.unValidLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(36);
            make.right.mas_equalTo(self).offset(-14);
        }];
    }
}

@end
