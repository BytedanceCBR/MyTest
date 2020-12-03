//
//  FHHouseSecondCardView.m
//  FHHouseList
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHHouseSecondCardView.h"
#import "FHHouseLeftImageView.h"
#import "UIColor+Theme.h"
#import "FHHouseSecondCardViewModel.h"
#import "Masonry.h"
#import "FHHouseTitleAndTagView.h"
#import "FHHouseTitleAndTagViewModel.h"
#import "FHCommonDefines.h"
#import "FHHouseRecommendView.h"
#import "UIFont+House.h"
#import "YYLabel.h"
#import "FHHouseRecommendViewModel.h"
#import "UILabel+BTDAdditions.h"
#import "FHSingleImageInfoCellModel.h"
#import <lottie-ios/Lottie/LOTAnimationView.h>

@interface FHHouseSecondCardView()

@property (nonatomic, strong) FHHouseLeftImageView *leftImageView;
@property (nonatomic, strong) FHHouseTitleAndTagView *titleAndTagView;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) YYLabel *tagLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *pricePerSqmLabel;
@property (nonatomic, strong) FHHouseRecommendView *recommendView;
@property (nonatomic, strong) LOTAnimationView *vrLoadingView;


@end

@implementation FHHouseSecondCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)setupUI {
    self.leftImageView = [FHHouseLeftImageView squareImageView];
    [self addSubview:self.leftImageView];
    
    self.titleAndTagView = [[FHHouseTitleAndTagView alloc] init];
    [self addSubview:self.titleAndTagView];
    
    self.subTitleLabel = [[UILabel alloc] init];
    self.subTitleLabel.font = [UIFont themeFontRegular:12];
    self.subTitleLabel.textColor = [UIColor themeGray1];
    [self addSubview:self.subTitleLabel];
    
    self.tagLabel = [[YYLabel alloc]init];
    self.tagLabel.numberOfLines = 0;
    self.tagLabel.font = [UIFont themeFontRegular:10];
    self.tagLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:self.tagLabel];
    
    self.priceLabel = [[UILabel alloc] init];
    self.priceLabel.font = [UIFont themeFontSemibold:16];
    self.priceLabel.textColor = [UIColor themeRed4];
    [self addSubview:self.priceLabel];
    
    self.pricePerSqmLabel = [[UILabel alloc]init];
    self.pricePerSqmLabel.font = [UIFont themeFontRegular:12];
    self.pricePerSqmLabel.textColor = [UIColor themeGray3];
    [self addSubview:self.pricePerSqmLabel];
    
    self.recommendView = [[FHHouseRecommendView alloc] init];
    [self addSubview:self.recommendView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"VRImageLoading" ofType:@"json"];
    self.vrLoadingView = [LOTAnimationView animationWithFilePath:path];
    self.vrLoadingView.loopAnimation = YES;
    [self addSubview:self.vrLoadingView];
}

- (void)setupConstraints {
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(15);
        make.width.height.mas_equalTo(84);
    }];
    
    [self.vrLoadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView).offset(8);
        make.bottom.mas_equalTo(self.leftImageView).offset(-8);
        make.width.height.mas_equalTo(16);
    }];
    
    [self.titleAndTagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView.mas_right).offset(8);
        make.top.mas_equalTo(12);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(22);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.titleAndTagView);
        make.height.mas_equalTo(18);
        make.top.mas_equalTo(self.titleAndTagView.mas_bottom).offset(3);
    }];
    
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleAndTagView.mas_left).offset(-2);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(18);
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom).offset(4);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tagLabel.mas_bottom).offset(4);
        make.left.mas_equalTo(self.titleAndTagView.mas_left);
        make.height.mas_equalTo(22);
    }];
    
    [self.pricePerSqmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.priceLabel.mas_top).offset(4);
        make.left.mas_equalTo(self.priceLabel.mas_right).offset(4);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.priceLabel);
    }];
    [self.recommendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.priceLabel.mas_bottom);
        make.left.right.mas_equalTo(self.titleAndTagView);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    FHHouseSecondCardViewModel *secondViewModel = (FHHouseSecondCardViewModel *)self.viewModel;
    [self.leftImageView setImageModel:secondViewModel.leftImageModel];
    self.titleAndTagView.viewModel = secondViewModel.titleAndTag;
    CGFloat titleHeight = [FHHouseTitleAndTagView viewHeightWithViewModel:secondViewModel.titleAndTag];
    [self.titleAndTagView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(titleHeight);
    }];
    self.subTitleLabel.text = secondViewModel.subtitle;
    self.tagLabel.attributedText = [FHSingleImageInfoCellModel tagsStringWithTagList:secondViewModel.tagList withInset:UIEdgeInsetsMake(-2, -4, -2, -4) withMaxWidth:[UIScreen mainScreen].bounds.size.width - 152];
    self.priceLabel.text = secondViewModel.price;
    CGFloat width = [self.priceLabel btd_widthWithHeight:22];
    [self.priceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
    }];
    self.pricePerSqmLabel.text = secondViewModel.pricePerSqm;
    self.recommendView.hidden = secondViewModel.recommendViewModel.isHidden;
    self.recommendView.viewModel = secondViewModel.recommendViewModel;
    self.vrLoadingView.hidden = !secondViewModel.hasVr;
    if (!self.vrLoadingView.hidden) {
        [self.vrLoadingView play];
    }
}

+ (CGFloat)calculateViewHeight:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseSecondCardViewModel.class]) return 0.0f;
    FHHouseSecondCardViewModel *secondViewModel = (FHHouseSecondCardViewModel *)viewModel;
    CGFloat titleHeight = [FHHouseTitleAndTagView viewHeightWithViewModel:secondViewModel.titleAndTag];
    return titleHeight + 92 + secondViewModel.recommendViewModel.showSecondHouseHeight;
}

@end
