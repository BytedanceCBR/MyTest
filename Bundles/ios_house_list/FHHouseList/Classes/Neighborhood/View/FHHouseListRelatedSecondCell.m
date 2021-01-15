//
//  FHHouseListRelatedSecondCell.m
//  FHHouseList
//
//  Created by xubinbin on 2021/1/8.
//

#import "FHHouseListRelatedSecondCell.h"
#import "FHHouseSecondCardView.h"
#import "FHHouseSecondCardViewModel.h"
#import "Masonry.h"
#import "UIColor+Theme.h"

@interface FHHouseListRelatedSecondCell()

@property (nonatomic, strong) FHHouseSecondCardView *cardView;

@end

@implementation FHHouseListRelatedSecondCell

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
    self.cardView.backgroundColor = [UIColor whiteColor];
    self.cardView.layer.cornerRadius = 10;
    self.cardView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.cardView];
}

- (void)setupConstraints {
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-5);
        make.top.mas_equalTo(5);
    }];
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    if ([viewModel isKindOfClass:[FHHouseSecondCardViewModel class]]) {
        self.cardView.viewModel = viewModel;
    }
}

+ (CGFloat)calculateViewHeight:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if ([viewModel isKindOfClass:[FHHouseSecondCardViewModel class]]) {
        return [FHHouseSecondCardView calculateViewHeight:viewModel] + 10;
    }
    return 0.0f;
}

@end
