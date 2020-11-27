//
//  FHBrowsingHistorySecondCell.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/11/6.
//

#import "FHBrowsingHistorySecondCell.h"
#import "FHBrowsingHistorySecondCardView.h"
#import "FHHouseSecondCardViewModel.h"
#import "Masonry.h"
#import "UIColor+Theme.h"

@interface FHBrowsingHistorySecondCell()

@property (nonatomic, strong) FHBrowsingHistorySecondCardView *cardView;

@end

@implementation FHBrowsingHistorySecondCell

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
    self.cardView = [[FHBrowsingHistorySecondCardView alloc] init];
    self.cardView.layer.cornerRadius = 10;
    self.cardView.layer.masksToBounds = YES;
    self.cardView.backgroundColor = [UIColor whiteColor];
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

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    if ([viewModel isKindOfClass:[FHHouseSecondCardViewModel class]]) {
        self.cardView.viewModel = viewModel;
    }
}

+ (CGFloat)calculateViewHeight:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if ([viewModel isKindOfClass:[FHHouseSecondCardViewModel class]]) {
        return [FHHouseSecondCardView calculateViewHeight:viewModel];
    }
    return 0.0f;
}

@end
