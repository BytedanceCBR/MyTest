//
//  FHHouseNewCardView.m
//  FHHouseList
//
//  Created by xubinbin on 2020/11/27.
//

#import "FHHouseNewCardView.h"
#import "FHHouseLeftImageView.h"
#import "UIColor+Theme.h"
#import "Masonry.h"
#import "FHCommonDefines.h"
#import "FHHouseRecommendView.h"
#import "UIFont+House.h"
#import "YYLabel.h"
#import "FHHouseRecommendViewModel.h"
#import "UILabel+BTDAdditions.h"
#import "FHSingleImageInfoCellModel.h"
#import <lottie-ios/Lottie/LOTAnimationView.h>
#import "FHHouseNewCardViewModel.h"
#import <BDWebImage/UIImageView+BDWebImage.h>

@interface FHHouseNewCardView()

@property (nonatomic, strong) FHHouseLeftImageView *leftImageView;
@property (nonatomic, strong) UILabel *mainTitleLabel;
@property (nonatomic, strong) UILabel *propertyTagLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) YYLabel *tagLabel;
@property (nonatomic, strong) FHHouseRecommendView *recommendView;
@property (nonatomic, strong) LOTAnimationView *vrLoadingView;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UIImageView *tagImage;

@end

@implementation FHHouseNewCardView

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
    
    self.mainTitleLabel = [[UILabel alloc]init];
    self.mainTitleLabel.font = [UIFont themeFontSemibold:16];
    self.mainTitleLabel.textColor = [UIColor themeGray1];
    [self addSubview:self.mainTitleLabel];
    
    self.propertyTagLabel = [[UILabel alloc] init];
    self.propertyTagLabel.font = [UIFont themeFontRegular:10];
    self.propertyTagLabel.layer.cornerRadius = 2;
    self.propertyTagLabel.textAlignment = NSTextAlignmentCenter;
    self.propertyTagLabel.layer.borderWidth = 0.5;
    [self addSubview:self.propertyTagLabel];
    
    self.priceLabel = [[UILabel alloc]init];
    self.priceLabel.textColor = [UIColor themeOrange1];
    self.priceLabel.font = [UIFont themeFontSemibold:16];
    [self addSubview:self.priceLabel];
    
    self.subTitleLabel = [[UILabel alloc]init];
    self.subTitleLabel.font = [UIFont themeFontRegular:12];
    self.subTitleLabel.textColor = [UIColor themeGray1];
    [self addSubview:self.subTitleLabel];
    
    self.tagLabel = [[YYLabel alloc]init];
    self.tagLabel.numberOfLines = 0;
    self.tagLabel.font = [UIFont themeFontRegular:10];
    self.tagLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:self.tagLabel];
    
    self.recommendView = [[FHHouseRecommendView alloc] init];
    [self addSubview:self.recommendView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"VRImageLoading" ofType:@"json"];
    self.vrLoadingView = [LOTAnimationView animationWithFilePath:path];
    self.vrLoadingView.loopAnimation = YES;
    [self addSubview:self.vrLoadingView];
    
    self.videoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_image"]];
    [self addSubview:self.videoImageView];
    
    self.tagImage = [[UIImageView alloc] init];
    [self addSubview:self.tagImage];
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
    
    [self.videoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.vrLoadingView);
    }];
    
    [self.tagImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self.leftImageView);
        make.width.mas_equalTo(26);
        make.height.mas_equalTo(16);
    }];
    
    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12);
        make.left.mas_equalTo(self.leftImageView.mas_right).offset(8);
        make.right.mas_lessThanOrEqualTo(self.propertyTagLabel.mas_left).offset(1);
        make.height.mas_equalTo(22);
    }];
    
    [self.propertyTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(15);
        make.height.mas_equalTo(16);
        make.width.mas_equalTo(0);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainTitleLabel);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(22);
        make.top.mas_equalTo(self.mainTitleLabel.mas_bottom).offset(1);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainTitleLabel);
        make.top.mas_equalTo(self.priceLabel.mas_bottom).offset(2);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(18);
    }];
    
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(self.mainTitleLabel).offset(-2);
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(18);
    }];
    
    [self.recommendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tagLabel.mas_bottom);
        make.right.mas_equalTo(self.priceLabel);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(self.priceLabel).offset(-4);
    }];
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    FHHouseNewCardViewModel *newViewModel = (FHHouseNewCardViewModel *)viewModel;
    [self.leftImageView setImageModel:newViewModel.leftImageModel];
    if (newViewModel.tagImageModel) {
        self.tagImage.hidden = NO;
        [self.tagImage bd_setImageWithURL:[NSURL URLWithString:newViewModel.tagImageModel.url]];
    } else {
        self.tagImage.hidden = YES;
    }
    self.mainTitleLabel.text = newViewModel.title;
    self.priceLabel.text = newViewModel.price;
    self.subTitleLabel.text = newViewModel.subtitle;
    self.tagLabel.attributedText = [FHSingleImageInfoCellModel tagsStringWithTagList:newViewModel.tagList withInset:UIEdgeInsetsMake(-2, -4, -2, -4) withMaxWidth:[UIScreen mainScreen].bounds.size.width - 152];
    self.vrLoadingView.hidden = !newViewModel.hasVr;
    if (!self.vrLoadingView.hidden) {
        [self.vrLoadingView play];
    }
    self.videoImageView.hidden = !newViewModel.hasVideo;
    self.recommendView.hidden = newViewModel.recommendViewModel.isHidden;
    self.recommendView.viewModel = newViewModel.recommendViewModel;
    if (newViewModel.propertyText.length > 0) {
        self.propertyTagLabel.text = newViewModel.propertyText;
        self.propertyTagLabel.layer.borderColor = [UIColor colorWithHexStr:newViewModel.propertyBorderColor].CGColor;
        CGFloat width = [self.propertyTagLabel btd_widthWithHeight:16] + 6;
        [self.propertyTagLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
        }];
    } else {
        [self.propertyTagLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
    }
}

+ (CGFloat)calculateViewHeight:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseNewCardViewModel.class]) return 0.0f;
    FHHouseNewCardViewModel *newViewModel = (FHHouseNewCardViewModel *)viewModel;
    return 114 + newViewModel.recommendViewModel.showNewHouseHeight;
}

@end
