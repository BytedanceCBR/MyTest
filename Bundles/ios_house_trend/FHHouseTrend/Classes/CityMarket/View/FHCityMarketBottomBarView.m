//
//  FHCityMarketBottomBarView.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/27.
//

#import "FHCityMarketBottomBarView.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
@interface FHCityMarketBottomBarItem ()

@end

@implementation FHCityMarketBottomBarItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layer.cornerRadius = 4;
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont themeFontRegular:16];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    }];
}

@end

@interface FHCityMarketBottomBarView ()
@end

@implementation FHCityMarketBottomBarView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)setBottomBarItems:(NSArray<UIControl*>*)items {
    if ([items count] == 1) {
        UIControl* control = items.firstObject;
        [self addSubview:control];
        [control mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.top.mas_equalTo(10);
            make.height.mas_equalTo(44);
        }];
    } else {
        [items enumerateObjectsUsingBlock:^(UIControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self addSubview:obj];
        }];
        [items mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:15 leadSpacing:20 tailSpacing:20];
        [items mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.height.mas_equalTo(44);
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
