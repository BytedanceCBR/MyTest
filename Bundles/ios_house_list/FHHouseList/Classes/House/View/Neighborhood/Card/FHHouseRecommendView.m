//
//  FHHouseRecommendView.m
//  FHHouseList
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHHouseRecommendView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHHouseRecommendViewModel.h"
#import "UIFont+House.h"

@interface FHHouseRecommendView()

@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UILabel *recommendLabel;
@property (nonatomic, strong) UIImageView *iconImageView;

@end

@implementation FHHouseRecommendView

+ (CGFloat)calculateViewHeight:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    FHHouseRecommendViewModel *recommendViewModel = (FHHouseRecommendViewModel *)viewModel;
    return [recommendViewModel showHeight];
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
    self.line = [[UIView alloc] init];
    self.line.backgroundColor = [UIColor themeGray7];
    [self addSubview:self.line];
    
    self.iconImageView = [[UIImageView alloc] init];
    [self addSubview:self.iconImageView];
    
    self.recommendLabel = [[UILabel alloc] init];
    self.recommendLabel.font = [UIFont themeFontRegular:10];
    self.recommendLabel.textColor = [UIColor themeGray1];
    [self addSubview:self.recommendLabel];
}

- (void)setupConstraints {
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.left.mas_equalTo(4);
        make.bottom.mas_equalTo(-28);
        make.height.mas_equalTo(1);
    }];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-4);
        make.left.mas_equalTo(0);
        make.height.width.mas_equalTo(20);
    }];
    [self.recommendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right);
        make.bottom.mas_equalTo(-9);
        make.height.mas_equalTo(10);
        make.right.mas_equalTo(0);
    }];
}

- (void)refreshOpacity:(CGFloat)opacity {
    if (!self.hidden) {
        self.recommendLabel.layer.opacity = opacity;
    }
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (!viewModel) {
        self.hidden = YES;
        return;
    }
    [super setViewModel:viewModel];
    FHHouseRecommendViewModel *recommendViewModel = (FHHouseRecommendViewModel *)viewModel;
    [self.iconImageView bd_setImageWithURL:[NSURL URLWithString:recommendViewModel.url]];
    self.recommendLabel.text = recommendViewModel.text;
    self.hidden = [recommendViewModel isHidden];
}

@end
