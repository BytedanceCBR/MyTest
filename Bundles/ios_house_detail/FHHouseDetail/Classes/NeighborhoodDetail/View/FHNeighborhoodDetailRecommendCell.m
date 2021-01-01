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

@interface FHNeighborhoodDetailRecommendCell()

@property (nonatomic, strong) FHHouseSecondCardView *cardView;

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
    
    self.cardView = [[FHHouseSecondCardView alloc] initWithLeftMargin:12 rightMargin:12];
    [self.contentView addSubview:self.cardView];
    
    self.cardView.backgroundColor = [UIColor clearColor];
    
    self.line = [[UIView alloc] init];
    self.line.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:self.line];
}

- (void)setupConstraints {
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.right.mas_equalTo(-12);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)refreshWithData:(id)data withLast:(BOOL)isLast {
    [self refreshWithData:data];
    self.line.hidden = isLast;
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
