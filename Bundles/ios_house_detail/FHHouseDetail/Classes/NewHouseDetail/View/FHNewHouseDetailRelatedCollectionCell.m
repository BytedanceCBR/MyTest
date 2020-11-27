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

@interface FHNewHouseDetailRelatedCollectionCell()

@property (nonatomic, strong) FHHouseNewCardView *cardView;

@property (nonatomic, strong) UIView *line;

@end

@implementation FHNewHouseDetailRelatedCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHHouseListBaseItemModel class]]) {
        FHHouseNewCardViewModel *viewModel = [[FHHouseNewCardViewModel alloc] initWithModel:data];
        return CGSizeMake(width, [FHHouseNewCardView calculateViewHeight:viewModel]);
    }
    return CGSizeZero;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupConstraints];
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    }
    return self;
}

- (void)setupUI {
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
}

- (void)refreshWithData:(id)data {
    self.currentData = data;
    if([data isKindOfClass:[FHHouseListBaseItemModel class]]) {
        FHHouseNewCardViewModel *viewModel = [[FHHouseNewCardViewModel alloc] initWithModel:data];
        self.cardView.viewModel = viewModel;
    }
}

- (NSString *)elementType {
    return @"related";
}

@end

@implementation FHNewHouseDetailTRelatedCollectionCellModel

@end
