//
//  FHCityMarketHeaderPropertyBar.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/21.
//

#import "FHCityMarketHeaderPropertyBar.h"
#import "FHCityMarketHeaderPropertyItemView.h"
#import <Masonry.h>
@implementation FHCityMarketHeaderPropertyBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initBarStyle];
    }
    return self;
}

-(void)initBarStyle {
    self.backgroundColor = [UIColor whiteColor];
//    self.clipsToBounds = NO;
    self.layer.cornerRadius = 4;
    self.layer.shadowRadius = 4;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.06;
    self.layer.shadowOffset = CGSizeMake(0, 2);
}

-(void)setPropertyItem:(NSArray<FHCityMarketHeaderPropertyItemView*>*)items {
    //清除掉所有的子视图
    [[self subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];

    [items enumerateObjectsUsingBlock:^(FHCityMarketHeaderPropertyItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addSubview:obj];
    }];

    if ([items count] > 1) {
        [items mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:2 leadSpacing:0 tailSpacing:0];
    }

    [items mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
    }];
}

@end
