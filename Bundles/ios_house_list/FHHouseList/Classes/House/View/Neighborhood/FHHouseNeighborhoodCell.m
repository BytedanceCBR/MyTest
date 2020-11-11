//
//  FHHouseNeighborhoodCell.m
//  ABRInterface
//
//  Created by bytedance on 2020/11/9.
//

#import "FHHouseNeighborhoodCell.h"
#import "FHHouseNeighborhoodCardView.h"
#import "Masonry.h"
#import "FHHouseNeighborhoodCardViewModel.h"
#import "UIColor+Theme.h"

@interface FHHouseNeighborhoodCell ()
@property (nonatomic, strong) FHHouseNeighborhoodCardView *cardView;
@end

@implementation FHHouseNeighborhoodCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUI];
        [self setupConstraints];
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
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
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(0);
    }];
}

- (FHHouseNeighborhoodCardView *)cardView {
    if (!_cardView) {
        _cardView = [[FHHouseNeighborhoodCardView alloc] init];
        _cardView.layer.cornerRadius = 10;
        _cardView.layer.masksToBounds = YES;
        _cardView.backgroundColor = [UIColor whiteColor];
    }
    return _cardView;
}

- (void)cellWillShowAtIndexPath:(NSIndexPath *)indexPath {
    [super cellWillShowAtIndexPath:indexPath];
    if ([self.viewModel isKindOfClass:[FHHouseNeighborhoodCardViewModel class]]) {
        FHHouseNeighborhoodCardViewModel *cardViewModel = (FHHouseNeighborhoodCardViewModel *)self.viewModel;
        [cardViewModel showCardAtIndexPath:indexPath];
    }
}

- (void)cellDidClickAtIndexPath:(NSIndexPath *)indexPath {
    [super cellDidClickAtIndexPath:indexPath];
    if ([self.viewModel isKindOfClass:[FHHouseNeighborhoodCardViewModel class]]) {
        FHHouseNeighborhoodCardViewModel *cardViewModel = (FHHouseNeighborhoodCardViewModel *)self.viewModel;
        [cardViewModel clickCardAtIndexPath:indexPath];
    }
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
            return height + 15;
        }
    }
    
    return 0.0f;
}

@end
