//
//  FHNeighborhoodDetailRecommendCell.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/10/14.
//

#import "FHNeighborhoodDetailRecommendCell.h"
#import "FHHouseSecondCardView.h"
#import "FHHouseSecondCardViewModel.h"
#import "Masonry.h"
#import "UIColor+Theme.h"

#import "FHHouseSearchSecondHouseCell.h"
#import "FHCommonDefines.h"
#import <YYText/YYLabel.h>
#import <lottie-ios/Lottie/LOTAnimationView.h>
#import "Masonry.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "UIButton+TTAdditions.h"
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "UILabel+BTDAdditions.h"
#import "FHSingleImageInfoCellModel.h"

@interface FHNeighborhoodDetailRecommendCell()

@property (nonatomic, strong) FHHouseSecondCardView *cardView;

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UIView *line;

@end

@implementation FHNeighborhoodDetailRecommendCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if ([data isKindOfClass:[FHHouseSecondCardViewModel class]]) {
        FHHouseSecondCardViewModel *viewModel = (FHHouseSecondCardViewModel *)data;
        CGFloat height = [FHHouseSecondCardView calculateViewHeight:viewModel] + 1;
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
        [self setupConstraints];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = [UIColor themeGray7];
    
    self.backView = [[UIView alloc] init];
    self.backView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.backView];
    
    self.cardView = [[FHHouseSecondCardView alloc] initWithLeftMargin:12 rightMargin:12];
    [self.contentView addSubview:self.cardView];
    
    self.line = [[UIView alloc] init];
    self.line.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:self.line];
}

- (void)setupConstraints {
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.right.mas_equalTo(-12);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)refreshWithData:(id)data withLast:(BOOL)isLast {
    [self refreshWithData:data];
    self.line.hidden = isLast;
}

- (void)refreshIndexCorner:(BOOL)isFirst andLast:(BOOL)isLast {
    CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH - 18, 114);
    if (isLast) {
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(15, 15)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = frame;
        maskLayer.path = maskPath.CGPath;
        self.backView.layer.mask = maskLayer;
    } else {
        self.backView.layer.mask = nil;
    }
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[FHHouseSecondCardViewModel class]]) {
        self.cardView.viewModel = data;
    }
}

-(NSString *)elementType {
    return  @"search_related";
}

@end

@implementation FHNeighborhoodDetailRecommendCellModel

@end
