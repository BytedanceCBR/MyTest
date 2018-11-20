//
//  FHHomeFeedHeaderView.m
//  Article
//
//  Created by 谢飞 on 2018/11/20.
//

#import "FHHomeFeedHeaderView.h"
#import <FHHouseRent.h>
#import "FHHomeBannerView.h"
#import "FHHomeCityTrendView.h"

@interface FHHomeFeedHeaderView ()
@property (nonatomic, strong) FHRowsView* rowsView;
@property (nonatomic, strong) FHHomeBannerView* bannerView;
@property (nonatomic, strong) FHHomeCityTrendView* trendView;
@end

@implementation FHHomeFeedHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rowsView = [FHRowsView new];
        self.bannerView = [FHHomeBannerView new];
        self.trendView = [FHHomeCityTrendView new];
        
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews
{
    [self addSubview:self.rowsView];
    
    [self.rowsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.equalTo(self);
        make.height.mas_equalTo(100);
    }];
    self.rowsView.backgroundColor = [UIColor redColor];
    
    [self addSubview:self.bannerView];
    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.rowsView.mas_bottom);
        make.right.left.equalTo(self);
        make.height.mas_equalTo(100);
    }];
    self.bannerView.backgroundColor = [UIColor purpleColor];

    
    [self addSubview:self.trendView];
    [self.trendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bannerView.mas_bottom);
        make.right.left.equalTo(self);
        make.height.mas_equalTo(100);
    }];
    self.trendView.backgroundColor = [UIColor blueColor];
}

- (void)setHomeModel:(FHHomeModel *)homeModel
{
    _homeModel = homeModel;
    
    
    
    
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
