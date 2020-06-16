//
//  FHFindHouseHelperCell.m
//  AKCommentPlugin
//
//  Created by wangxinyu on 2020/6/16.
//

#import "FHFindHouseHelperCell.h"
#import "UIColor+Theme.h"
#import "Masonry.h"

@interface FHFindHouseHelperCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UIView *leftSeparator;
@property (nonatomic, strong) UIView *rightSeparator;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIButton *confirmButton;

@end

@implementation FHFindHouseHelperCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
    }
    
    return self;
}

- (void)initViews {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    _topLabel = [[UILabel alloc] init];
    _topLabel.text = @"没有找到相关房源，换个条件试试吧";
    _topLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    _topLabel.textColor = [UIColor themeGray3];
    _topLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_topLabel];
    [_topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.centerX.equalTo(self.contentView);
    }];
    
    _leftSeparator = [[UIView alloc] init];
    _leftSeparator.backgroundColor = [UIColor colorWithHexStr:@"d8d8d8"];
    [self.contentView addSubview:_leftSeparator];
    [_leftSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 1));
        make.left.mas_equalTo(15);
        make.centerY.equalTo(self.topLabel.mas_centerY);
    }];
    
    _rightSeparator = [[UIView alloc] init];
    _rightSeparator.backgroundColor = [UIColor colorWithHexStr:@"d8d8d8"];
    [self.contentView addSubview:_rightSeparator];
    [_rightSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 1));
        make.right.mas_equalTo(-15);
        make.centerY.equalTo(self.topLabel.mas_centerY);
    }];
    
    _containerView = [[UIView alloc] init];
    _containerView.backgroundColor = [UIColor themeWhite];
    _containerView.layer.cornerRadius = 10;
    _containerView.layer.borderWidth = 0.5;
    _containerView.layer.borderColor = [UIColor themeGray6].CGColor;
    _containerView.layer.shadowColor = [UIColor themeBlack].CGColor;
    _containerView.layer.shadowOpacity = 0.1;
    _containerView.layer.shadowOffset = CGSizeMake(0, 4);
    _containerView.layer.shadowRadius = 3;
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60);
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapAction:)];
    [_containerView addGestureRecognizer:tap];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"坐享定制找房服务";
    _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
    _titleLabel.textColor = [UIColor themeGray1];
    [self.containerView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(15);
        make.top.equalTo(self.containerView).offset(16);
    }];
    
    _subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel.text = @"即刻查看专属好房";
    _subTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    _subTitleLabel.textColor = [UIColor themeGray3];
    [self.containerView addSubview:_subTitleLabel];
    [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(15);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(2);
    }];
    
    _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmButton.layer.cornerRadius = 4;
    _confirmButton.layer.borderWidth = 0.5;
    _confirmButton.layer.borderColor = [UIColor themeOrange1].CGColor;
    [_confirmButton setTitle:@"帮我找房" forState:UIControlStateNormal];
    [_confirmButton setBackgroundColor:[UIColor whiteColor]];
    [_confirmButton setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
    [_confirmButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:12]];
    _confirmButton.userInteractionEnabled = NO;
    [self.containerView addSubview:_confirmButton];
    [_confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.containerView);
        make.right.mas_equalTo(-15);
        make.size.mas_equalTo(CGSizeMake(64, 28));
    }];
}

#pragma mark - Action

- (void)cellTapAction:(UITapGestureRecognizer *)sender {
    if (self.cellTapAction) {
        self.cellTapAction();
    }
}

@end
