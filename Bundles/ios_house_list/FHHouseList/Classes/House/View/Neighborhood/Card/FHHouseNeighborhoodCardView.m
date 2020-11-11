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
#import "FHHouseTitleAndTagView.h"
#import "FHHouseTitleAndTagViewModel.h"
#import "FHCommonDefines.h"

@interface FHHouseNeighborhoodCardView() 
@property (nonatomic, strong) FHHouseLeftImageView *leftImageView;
@property (nonatomic, strong) FHHouseTitleAndTagView *titleAndTagView;
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
    [self addSubview:self.titleAndTagView];
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
    
    [self.titleAndTagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView.mas_right).mas_offset(8);
        make.top.mas_equalTo(12);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(22);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView.mas_right).mas_offset(8);
        make.top.mas_equalTo(self.titleAndTagView.mas_bottom).mas_offset(2);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(22);
    }];
    
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView.mas_right).mas_offset(8);
        make.top.mas_equalTo(self.priceLabel.mas_bottom).mas_offset(2);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(18);
    }];
    
    [self.stateInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView.mas_right).mas_offset(8);
        make.top.mas_equalTo(self.subtitleLabel.mas_bottom).mas_offset(3);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(18);
    }];
}

- (void)refreshConstraints {
    CGFloat titleAndTagHeight = [FHHouseTitleAndTagView viewHeightWithViewModel:self.cardViewModel.titleAndTag];
    [self.titleAndTagView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(titleAndTagHeight);
    }];
}

- (FHHouseLeftImageView *)leftImageView {
    if (!_leftImageView) {
        _leftImageView = [FHHouseLeftImageView squareImageView];
    }
    return _leftImageView;
}

- (FHHouseTitleAndTagView *)titleAndTagView {
    if (!_titleAndTagView) {
        _titleAndTagView = [[FHHouseTitleAndTagView alloc] init];
    }
    return _titleAndTagView;
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
    self.titleAndTagView.viewModel = self.cardViewModel.titleAndTag;
    self.subtitleLabel.text = self.cardViewModel.subtitle;
    self.stateInfoLabel.text = self.cardViewModel.stateInfo;
    self.priceLabel.text = self.cardViewModel.price;
    
    [self refreshConstraints];
}

+ (CGFloat)calculateViewHeight:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseNeighborhoodCardViewModel.class]) return 0.0f;
    return 114.0f;
}

@end
