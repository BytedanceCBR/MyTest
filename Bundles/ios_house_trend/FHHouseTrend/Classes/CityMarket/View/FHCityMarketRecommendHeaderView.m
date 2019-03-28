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
@property (nonatomic, strong) UIView* sectionView;
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
    self.backgroundColor = [UIColor whiteColor];
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

    self.segment = [[UISegmentedControl alloc] initWithItems:nil];
    _segment.tintColor = [UIColor themeRed1];
    _segment.selectedSegmentIndex = 0;
    [self addSubview:_segment];
    [_segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(14);
        make.height.mas_equalTo(28);
    }];

    self.quetsionIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic-quesion-bg"]];
    [self addSubview:_quetsionIcon];
    [_quetsionIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.segment.mas_bottom).mas_offset(21);
        make.width.height.mas_equalTo(20);
    }];

    self.questionLabel = [[UILabel alloc] init];
    _questionLabel.font = [UIFont themeFontMedium:14];
    _questionLabel.textColor = [UIColor blackColor];
    [self addSubview:_questionLabel];
    [_questionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.quetsionIcon.mas_right).mas_equalTo(6);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.segment.mas_bottom).mas_offset(21);
        make.height.mas_equalTo(20);
    }];

    self.answerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic-answer-bg"]];
    [self addSubview:_answerIcon];
    [_answerIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.questionLabel.mas_bottom).mas_offset(6);
        make.width.height.mas_equalTo(20);
    }];

    self.answerLabel = [[UILabel alloc] init];
    _answerLabel.font = [UIFont themeFontRegular:14];
    _answerLabel.textColor = [UIColor themeGray1];
    [self addSubview:_answerLabel];
    [_answerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.answerIcon.mas_right).mas_offset(6);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.questionLabel.mas_bottom).mas_offset(6);
        make.height.mas_equalTo(20);
    }];
}

@end

