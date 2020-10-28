//
//  FHHouseNewBillboardItemView.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/10/27.
//

#import "FHHouseNewBillboardItemView.h"
#import "Masonry.h"
#import "FHSearchHouseModel.h"
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "UIColor+Theme.h"
#import "FHHouseNewBillboardItemViewModel.h"

static UIEdgeInsets const Insets = {12, 20, 12, 20};

@interface FHHouseNewBillboardItemView()
@property (nonatomic, strong) UIButton *containerView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) FHHouseNewBillboardItemViewModel *itemViewModel;
@end

@implementation FHHouseNewBillboardItemView

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (!viewModel || ![viewModel isKindOfClass:FHHouseNewBillboardItemViewModel.class] || ![viewModel isValid]) return 0.0f;
    return 68.0f;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupConstraints];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.iconImageView];
    [self.containerView addSubview:self.titleLabel];
    [self.containerView addSubview:self.subtitleLabel];
    [self.containerView addSubview:self.detailLabel];
    [self.containerView addSubview:self.lineView];
}

- (void)setupConstraints {
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(Insets.left);
        make.centerY.equalTo(self);
        make.width.height.mas_equalTo(32);
    }];
    
    [self.detailLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.detailLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-Insets.right);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(22);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right).mas_offset(10);
        make.right.mas_equalTo(self.detailLabel.mas_left).mas_offset(-10);
        make.top.mas_equalTo(self).mas_offset(Insets.top);
        make.height.mas_equalTo(22);
    }];
    
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(4);
        make.height.mas_equalTo(18);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(Insets.left);
        make.right.mas_equalTo(-Insets.right);
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}

- (UIButton *)containerView {
    if (!_containerView) {
        _containerView = [[UIButton alloc] init];
        [_containerView addTarget:self action:@selector(onItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _containerView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.backgroundColor = [UIColor lightGrayColor];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        _titleLabel.textColor = [UIColor colorWithHexStr:@"#333333"];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        _subtitleLabel.textColor = [UIColor colorWithHexStr:@"#999999"];
        _subtitleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _subtitleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        _detailLabel.textColor = [UIColor colorWithHexStr:@"#fe5500"];
        _detailLabel.textAlignment = NSTextAlignmentRight;
    }
    return _detailLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithHexStr:@"#e8e8e8"];
    }
    return _lineView;
}

- (FHHouseNewBillboardItemViewModel *)itemViewModel {
    return (FHHouseNewBillboardItemViewModel *)self.viewModel;
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    [self refreshUI];
}

- (void)refreshUI {
    self.titleLabel.text = self.itemViewModel.title;
    self.subtitleLabel.text = self.itemViewModel.subtitle;
    self.detailLabel.text = self.itemViewModel.detail;
    if (self.itemViewModel.img.url.length) {
        [self.iconImageView bd_setImageWithURL:[NSURL URLWithString:self.itemViewModel.img.url]];
    }
    self.lineView.hidden = self.itemViewModel.isLastItem;
}

- (void)onItemClicked:(id)sender {
    if ([self.itemViewModel respondsToSelector:@selector(onClickView)]) {
        [self.itemViewModel onClickView];
    }
}
@end
