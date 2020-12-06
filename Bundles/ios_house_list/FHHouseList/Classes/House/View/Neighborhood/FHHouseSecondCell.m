//
//  FHHouseSecondCell.m
//  FHHouseList
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHHouseSecondCell.h"
#import "FHHouseSecondCardView.h"
#import "FHHouseSecondCardViewModel.h"
#import "Masonry.h"
#import "UIColor+Theme.h"

@interface FHHouseSecondCell()

@property (nonatomic, strong) FHHouseSecondCardView *cardView;

@end

@implementation FHHouseSecondCell

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
    self.cardView = [[FHHouseSecondCardView alloc] init];
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
    if ([viewModel isKindOfClass:[FHHouseSecondCardViewModel class]]) {
        self.cardView.viewModel = viewModel;
        [self.cardView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([FHHouseSecondCardView calculateViewHeight:viewModel]);
        }];
    }
}

+ (CGFloat)calculateViewHeight:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if ([viewModel isKindOfClass:[FHHouseSecondCardViewModel class]]) {
        FHHouseSecondCardViewModel *secondViewModel = (FHHouseSecondCardViewModel *)viewModel;
        CGFloat topMargin = 0;
        if ([secondViewModel.model isKindOfClass:[FHSearchHouseItemModel class]]) {
            topMargin = ((FHSearchHouseItemModel *)secondViewModel.model).topMargin;
        }
        return [FHHouseSecondCardView calculateViewHeight:viewModel] + 5 + topMargin;
    }
    return 0.0f;
}

@end
