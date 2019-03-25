//
//  FHCityMarketRecommendHeaderView.m
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import "FHCityMarketRecommendHeaderView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>

@interface FHCityMarketRecommendHeaderView ()
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIView* sectionView;
@property (nonatomic, strong) UILabel* questionLabel;
@property (nonatomic, strong) UILabel* answerLabel;
@property (nonatomic, strong) UIImageView* quetsionIcon;
@property (nonatomic, strong) UIImageView* answerIcon;
@end

@implementation FHCityMarketRecommendHeaderView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = [UIFont themeFontSemibold:18];
    [self addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(25);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(30);
    }];
    _titleLabel.text = @"特色二手房";
    NSArray *arr = [[NSArray alloc]initWithObjects:@"降价房", @"值得买", @"抢手房", nil];

    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:arr];
    segment.tintColor = [UIColor themeRed1];
    segment.selectedSegmentIndex = 0;
    [self addSubview:segment];
    [segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(14);
        make.height.mas_equalTo(28);
    }];

    self.questionLabel = [[UILabel alloc] init];
    _questionLabel.font = [UIFont themeFontMedium:14];
    _questionLabel.textColor = [UIColor blackColor];
    [self addSubview:_questionLabel];
    [_questionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(segment.mas_bottom).mas_offset(21);
        make.height.mas_equalTo(20);
    }];
}

@end

