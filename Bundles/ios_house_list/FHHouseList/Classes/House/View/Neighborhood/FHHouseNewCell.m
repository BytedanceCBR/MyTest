//
//  FHHouseNewCell.m
//  FHHouseList
//
//  Created by xubinbin on 2020/12/2.
//

#import "FHHouseNewCell.h"
#import "FHHouseNewCardView.h"
#import "FHHouseNewCardViewModel.h"
#import "Masonry.h"
#import "UIColor+Theme.h"

@interface FHHouseNewCell()

@property (nonatomic, strong) FHHouseNewCardView *cardView;

@end

@implementation FHHouseNewCell

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
    self.cardView = [[FHHouseNewCardView alloc] init];
    self.cardView.layer.cornerRadius = 10;
    self.cardView.layer.masksToBounds = YES;
    self.cardView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.cardView];
}

- (void)setupConstraints {
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-5);
        make.height.mas_equalTo(0);
    }];
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    if ([viewModel isKindOfClass:[FHHouseNewCardViewModel class]]) {
        self.cardView.viewModel = viewModel;
        [self.cardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([FHHouseNewCardView calculateViewHeight:viewModel]);
        }];
    }
}

+ (CGFloat)calculateViewHeight:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if ([viewModel isKindOfClass:[FHHouseNewCardViewModel class]]) {
        FHHouseNewCardViewModel *newViewModel = (FHHouseNewCardViewModel *)viewModel;
        CGFloat topMargin = 0;
        if ([newViewModel.model isKindOfClass:[FHSearchHouseItemModel class]]) {
            topMargin = ((FHSearchHouseItemModel *)newViewModel.model).topMargin;
        }
        return [FHHouseNewCardView calculateViewHeight:viewModel] + 5 + topMargin;
    }
    return 0.0f;
}

- (void)cellWillShowAtIndexPath:(NSIndexPath *)indexPath {
    [super cellWillShowAtIndexPath:indexPath];
    if ([self.viewModel isKindOfClass:[FHHouseNewCardViewModel class]]) {
        FHHouseNewCardViewModel *cardViewModel = (FHHouseNewCardViewModel *)self.viewModel;
        [cardViewModel showCardAtIndexPath:indexPath];
    }
}

- (void)cellDidClickAtIndexPath:(NSIndexPath *)indexPath {
    [super cellDidClickAtIndexPath:indexPath];
    if ([self.viewModel isKindOfClass:[FHHouseNewCardViewModel class]]) {
        FHHouseNewCardViewModel *cardViewModel = (FHHouseNewCardViewModel *)self.viewModel;
        [cardViewModel clickCardAtIndexPath:indexPath];
    }
}

@end