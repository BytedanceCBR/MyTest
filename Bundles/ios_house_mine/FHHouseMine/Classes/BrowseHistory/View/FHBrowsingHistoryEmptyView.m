//
//  FHBrowsingHistoryEmptyView.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/13.
//

#import "FHBrowsingHistoryEmptyView.h"
#import "UIColor+Theme.h"
#import <FHCommonUI/UIFont+House.h>
#import "Masonry.h"
//#import "FHHouseType.h"


@interface FHBrowsingHistoryEmptyView()<FHBrowsingHistoryEmptyViewDelegate>

@property (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) UIButton *findHouseButton;

@end

@implementation FHBrowsingHistoryEmptyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self initConstraints];
    }
    return self;
}

- (void)setupUI
{
    self.emptyImageView = [[UIImageView alloc] init];
    self.emptyImageView.image = [UIImage imageNamed:@"group-9"];
    [self addSubview:_emptyImageView];
    
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.text = @"暂无浏览历史";
    self.emptyLabel.font = [UIFont themeFontRegular:14];
    self.emptyLabel.textColor = [UIColor themeGray3];
    [self.emptyLabel sizeToFit];
    [self addSubview:_emptyLabel];
    
    self.findHouseButton = [[UIButton alloc] init];
    self.findHouseButton.layer.cornerRadius = 22;
    self.findHouseButton.backgroundColor = [UIColor colorWithHexStr:@"#ff9629"];
    [self.findHouseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.findHouseButton setTitle:@"去挑好房" forState:UIControlStateNormal];
    [self.findHouseButton addTarget:self action:@selector(emptyClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_findHouseButton];
}

- (void)initConstraints
{
    [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.height.width.mas_equalTo(115);
        make.top.mas_equalTo(100);
    }];
    
    [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self.emptyImageView.mas_bottom).offset(10);
        make.height.mas_equalTo(20);
    }];
    
    [self.findHouseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self.emptyLabel).offset(50);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(120);
    }];
}

- (void)emptyClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickFindHouse:)]) {
        [self.delegate clickFindHouse:self.houseType];
    }
}

@end
