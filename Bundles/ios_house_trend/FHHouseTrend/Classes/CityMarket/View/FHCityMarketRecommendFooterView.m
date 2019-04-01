//
//  FHCityMarketRecommendFooterView.m
//  FHHouseTrend
//
//  Created by leo on 2019/4/1.
//

#import "FHCityMarketRecommendFooterView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>

@interface FHCityMarketRecommendFooterView ()
@property (nonatomic, strong) UIImageView* arrawView;
@end

@implementation FHCityMarketRecommendFooterView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    self.textLabel = [[UILabel alloc] init];
    _textLabel.font = [UIFont themeFontRegular:16];
    _textLabel.textColor = [UIColor colorWithHexString:@"333333"];
    [self addSubview:_textLabel];
    [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.centerX.mas_equalTo(self).mas_offset(-7);
        make.centerY.mas_equalTo(self);
    }];

    self.arrawView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon-detail"]];
    [self addSubview:_arrawView];
    [_arrawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.textLabel.mas_right);
        make.centerY.mas_equalTo(self);
        make.width.height.mas_equalTo(14);
    }];

    self.clickBtn = [[UIButton alloc] init];
    [self addSubview:_clickBtn];
    [_clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}


@end
