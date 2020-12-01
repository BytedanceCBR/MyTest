//
//  FHNewHouseDetailRelatedCell.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/9/9.
//

#import "FHNewHouseDetailRelatedCollectionCell.h"
#import <FHHouseBase/FHHouseBaseItemCell.h>
#import "FHDetailRelatedCourtModel.h"
#import <lottie-ios/Lottie/LOTAnimationView.h>
#import <YYText/YYLabel.h>
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHHouseNewCardView.h"
#import "FHHouseNewCardViewModel.h"
#import "FHCommonDefines.h"


@interface FHNewHouseDetailRelatedCollectionCell()

@property (nonatomic, strong) FHHouseNewCardView *cardView;

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UIView *line;

@end

@implementation FHNewHouseDetailRelatedCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHHouseListBaseItemModel class]]) {
        FHHouseListBaseItemModel *model = (FHHouseListBaseItemModel *)data;
        model.advantageDescription = nil;
        FHHouseNewCardViewModel *viewModel = [[FHHouseNewCardViewModel alloc] initWithModel:model];
        return CGSizeMake(width, [FHHouseNewCardView calculateViewHeight:viewModel] + 1);
    }
    return CGSizeZero;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)setupUI {
    self.backView = [[UIView alloc] init];
    [self.contentView addSubview:self.backView];
    self.backView.backgroundColor = [UIColor whiteColor];
    
    self.cardView = [[FHHouseNewCardView alloc] init];
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
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)refreshWithData:(id)data withLast:(BOOL) isLast {
    [self refreshWithData:data];
    self.line.hidden = isLast;
    CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH - 30, 114);
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
    self.currentData = data;
    if([data isKindOfClass:[FHHouseListBaseItemModel class]]) {
        FHHouseListBaseItemModel *model = (FHHouseListBaseItemModel *)data;
        model.advantageDescription = nil;
        FHHouseNewCardViewModel *viewModel = [[FHHouseNewCardViewModel alloc] initWithModel:model];
        self.cardView.viewModel = viewModel;
    }
}

- (NSString *)elementType {
    return @"related";
}

@end

@implementation FHNewHouseDetailTRelatedCollectionCellModel

@end
