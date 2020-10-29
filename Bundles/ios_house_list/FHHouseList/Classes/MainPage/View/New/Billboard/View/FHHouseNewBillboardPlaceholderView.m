//
//  FHHouseNewBillboardPlaceholderView.m
//  FHHouseList
//
//  Created by bytedance on 2020/10/28.
//

#import "FHHouseNewBillboardPlaceholderView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"

#define PlaceholderColor [UIColor colorWithHexStr:@"#f5f5f5"];

@interface FHHouseNewBillboardPlaceholderItemView : UIView
@property (nonatomic, strong) UIView *iconView;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIView *subtitleView;
@property (nonatomic, strong) UIView *detailView;

+ (CGFloat)viewHeight;

@end


@implementation FHHouseNewBillboardPlaceholderItemView

+ (CGFloat)viewHeight {
    return 68.0f;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)setupUI {
    
    self.iconView = [[UIView alloc] init];
    self.iconView.backgroundColor = PlaceholderColor;
    [self addSubview:self.iconView];
    
    self.titleView = [[UIView alloc] init];
    self.titleView.backgroundColor = PlaceholderColor;
    [self addSubview:self.titleView];
    
    self.subtitleView = [[UIView alloc] init];
    self.subtitleView.backgroundColor = PlaceholderColor;
    [self addSubview:self.subtitleView];
    
    self.detailView = [[UIView alloc] init];
    self.detailView.backgroundColor = PlaceholderColor;
    [self addSubview:self.detailView];
}

- (void)setupConstraints {
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.equalTo(self);
        make.width.height.mas_equalTo(32);
    }];
    
    [self.detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.centerY.equalTo(self);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(18);
    }];
    
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconView.mas_right).mas_offset(10);
        make.right.mas_equalTo(self.detailView.mas_left).mas_offset(-33);
        make.top.equalTo(self.iconView);
        make.height.mas_equalTo(14);
    }];
    
    [self.subtitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleView);
        make.right.mas_equalTo(self.titleView.mas_right).mas_offset(-60);
        make.top.mas_equalTo(self.titleView.mas_bottom).mas_offset(4);
        make.height.mas_equalTo(14);
    }];
}

@end


static UIEdgeInsets const Insets = {10, 20, 10, 20};
static CGFloat const TitleHeight = 25;
static CGFloat const TitleWidth = 90;

@interface FHHouseNewBillboardPlaceholderView()
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) FHHouseNewBillboardPlaceholderItemView *itemView;
@end

@implementation FHHouseNewBillboardPlaceholderView

+ (CGFloat)viewHeight {
    return Insets.top + TitleHeight + [FHHouseNewBillboardPlaceholderItemView viewHeight] + Insets.bottom;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)setupUI {
    self.titleView = [[UIView alloc] init];
    self.titleView.backgroundColor = PlaceholderColor;
    [self addSubview:self.titleView];
    
    self.itemView = [[FHHouseNewBillboardPlaceholderItemView alloc] init];
    [self addSubview:self.itemView];
}

- (void)setupConstraints {
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(Insets.left);
        make.top.mas_equalTo(Insets.top);
        make.width.mas_equalTo(TitleWidth);
        make.height.mas_equalTo(TitleHeight);
    }];
    
    [self.itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(Insets.left);
        make.right.mas_equalTo(-Insets.right);
        make.top.mas_equalTo(self.titleView.mas_bottom);
        make.height.mas_equalTo([FHHouseNewBillboardPlaceholderItemView viewHeight]);
    }];
}


@end
