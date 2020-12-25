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
        make.top.mas_equalTo(5);
    }];
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    if ([viewModel isKindOfClass:[FHHouseNewCardViewModel class]]) {
        self.cardView.viewModel = viewModel;
        [self.cardView refreshOpacityWithData:viewModel];
        FHHouseNewCardViewModel *newViewModel = (FHHouseNewCardViewModel *)viewModel;
        __weak typeof(self) wSelf = self;
        newViewModel.opacityDidChange = ^{
            [wSelf.cardView refreshOpacityWithData:wSelf.viewModel];
        };
    }
}

- (void)cellWillEnterForground {
    [self.cardView resumeVRIcon];
}

+ (CGFloat)calculateViewHeight:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if ([viewModel isKindOfClass:[FHHouseNewCardViewModel class]]) {
        return [FHHouseNewCardView calculateViewHeight:viewModel] + 10;
    }
    return 0.0f;
}

@end
