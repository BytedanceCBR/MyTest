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
@property (nonatomic, strong) UIView *backView;

@end

@implementation FHHouseNeighborhoodCell

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
    
    self.backView = [[UIView alloc] init];
    self.backView.layer.cornerRadius = 10;
    self.backView.layer.masksToBounds = YES;
    self.backView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.backView];
    
    [self.contentView addSubview:self.cardView];
}

- (void)setupConstraints {
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-5);
        make.top.mas_equalTo(5);
    }];
    
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
        _cardView.backgroundColor = [UIColor clearColor];
    }
    return _cardView;
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    if ([viewModel isKindOfClass:[FHHouseNeighborhoodCardViewModel class]]) {
        self.cardView.viewModel = (FHHouseNeighborhoodCardViewModel *)viewModel;
        [self.cardView refreshOpacityWithData:viewModel];
        FHHouseNeighborhoodCardViewModel *neighborhoodViewModel = (FHHouseNeighborhoodCardViewModel *)viewModel;
        __weak typeof(self) wSelf = self;
        neighborhoodViewModel.opacityDidChange = ^{
            [wSelf.cardView refreshOpacityWithData:wSelf.viewModel];
        };
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

#pragma  mark - FHHouseCardTouchAnimationProtocol

- (void)shrinkWithAnimation {
    [UIView animateWithDuration:FHHouseCardTouchAnimateTime animations:^{
        self.cardView.transform = CGAffineTransformMakeScale(FHHouseCardShrinkRate, FHHouseCardShrinkRate);
    }];
}

- (void)restoreWithAnimation {
    [UIView animateWithDuration:FHHouseCardTouchAnimateTime animations:^{
        self.cardView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

@end
