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
    self.cardView.layer.cornerRadius = 10;
    self.cardView.layer.masksToBounds = YES;
    self.cardView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.cardView];
}

- (void)setupConstraints {
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(0);
    }];
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
