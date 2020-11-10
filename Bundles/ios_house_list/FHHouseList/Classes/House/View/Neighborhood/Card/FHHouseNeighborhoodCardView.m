//
//  FHHouseNeighborhoodCardView.m
//  ABRInterface
//
//  Created by bytedance on 2020/11/9.
//

#import "FHHouseNeighborhoodCardView.h"
#import "FHHouseLeftImageView.h"
#import "UIColor+Theme.h"
#import "FHHouseNeighborhoodCardViewModel.h"
#import "Masonry.h"

@interface FHHouseNeighborhoodCardView()
@property (nonatomic, strong) FHHouseLeftImageView *leftImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *stateInfoLabel;

@property (nonatomic, strong) FHHouseNeighborhoodCardViewModel *cardViewModel;
@end

@implementation FHHouseNeighborhoodCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.leftImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.subtitleLabel];
    [self addSubview:self.stateInfoLabel];
    [self addSubview:self.priceLabel];
}

- (void)setupConstraints {
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(15);
        make.width.height.mas_equalTo(84);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView.mas_right).mas_offset(8);
        make.top.mas_equalTo(12);
        make.right.mas_equalTo(15);
        make.height.mas_equalTo(22);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView.mas_right).mas_offset(8);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(2);
        make.right.mas_equalTo(15);
        make.height.mas_equalTo(22);
    }];
    
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView.mas_right).mas_offset(8);
        make.top.mas_equalTo(self.priceLabel.mas_bottom).mas_offset(2);
        make.right.mas_equalTo(15);
        make.height.mas_equalTo(18);
    }];
    
    [self.stateInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView.mas_right).mas_offset(8);
        make.top.mas_equalTo(self.subtitleLabel.mas_bottom).mas_offset(3);
        make.right.mas_equalTo(15);
        make.height.mas_equalTo(18);
    }];
}

- (FHHouseLeftImageView *)leftImageView {
    if (!_leftImageView) {
        _leftImageView = [FHHouseLeftImageView squareImageView];
    }
    return _leftImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont systemFontOfSize:12];
        _subtitleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _subtitleLabel.numberOfLines = 1;
        _subtitleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _subtitleLabel;
}

- (UILabel *)stateInfoLabel {
    if (!_stateInfoLabel) {
        _stateInfoLabel = [[UILabel alloc] init];
        _stateInfoLabel.font = [UIFont systemFontOfSize:12];
        _stateInfoLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _stateInfoLabel.numberOfLines = 1;
        _stateInfoLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _stateInfoLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
        _priceLabel.textColor = [UIColor colorWithHexString:@"#fe5500"];
        _priceLabel.numberOfLines = 1;
        _priceLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _priceLabel;
}

- (FHHouseNeighborhoodCardViewModel *)cardViewModel {
    if (![self.viewModel isKindOfClass:FHHouseNeighborhoodCardViewModel.class]) return nil;
    return (FHHouseNeighborhoodCardViewModel *)self.viewModel;
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    [self.leftImageView setImageModel:self.cardViewModel.leftImageModel];
    self.titleLabel.text = self.cardViewModel.title;
    self.subtitleLabel.text = self.cardViewModel.subtitle;
    self.stateInfoLabel.text = self.cardViewModel.stateInfo;
    self.priceLabel.text = self.cardViewModel.price;
}

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseNeighborhoodCardViewModel.class]) return 0.0f;
    return 114.0f;
}

@end
