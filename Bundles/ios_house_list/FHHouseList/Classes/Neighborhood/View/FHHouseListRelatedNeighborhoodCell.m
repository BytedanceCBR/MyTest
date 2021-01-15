//
//  FHHouseListRelatedNeighborhoodCell.m
//  FHHouseList
//
//  Created by xubinbin on 2021/1/8.
//

#import "FHHouseListRelatedNeighborhoodCell.h"
#import "FHHouseNeighborhoodCardView.h"
#import "Masonry.h"
#import "FHHouseNeighborhoodCardViewModel.h"
#import "UIColor+Theme.h"

@interface FHHouseListRelatedNeighborhoodCell()

@property (nonatomic, strong) FHHouseNeighborhoodCardView *cardView;

@end

@implementation FHHouseListRelatedNeighborhoodCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUI];
        [self setupConstraints];
        self.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    }
    return self;
}

- (void)setupUI {
    [self.contentView addSubview:self.cardView];
}

- (void)setupConstraints {
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(5);
        make.bottom.mas_equalTo(-5);
    }];
}

- (FHHouseNeighborhoodCardView *)cardView {
    if (!_cardView) {
        _cardView = [[FHHouseNeighborhoodCardView alloc] init];
        _cardView.backgroundColor = [UIColor whiteColor];
        _cardView.layer.cornerRadius = 10;
        _cardView.layer.masksToBounds = YES;
    }
    return _cardView;
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    if ([viewModel isKindOfClass:[FHHouseNeighborhoodCardViewModel class]]) {
        self.cardView.viewModel = (FHHouseNeighborhoodCardViewModel *)viewModel;
    }
}

+ (CGFloat)calculateViewHeight:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if ([viewModel isKindOfClass:[FHHouseNeighborhoodCardViewModel class]]) {
        CGFloat height = [FHHouseNeighborhoodCardView calculateViewHeight:(FHHouseNeighborhoodCardViewModel *)viewModel];
        if (height > 0.01) {
            return height + 10;
        }
    }
    return 0.0f;
}

@end
