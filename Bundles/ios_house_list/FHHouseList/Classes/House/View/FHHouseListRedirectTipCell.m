//
//  FHHouseListRedirectTipCell.m
//  FHHouseList
//
//  Created by 张静 on 2019/12/10.
//

#import "FHHouseListRedirectTipCell.h"
#import <FHHouseBase/FHShadowView.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>
#import "FHSearchHouseModel.h"
#import <TTBaseLib/UIViewAdditions.h>

@interface FHHouseListRedirectTipCell ()

@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) FHShadowView *shadowView;
@property(nonatomic,strong)UILabel *leftLabel;
@property(nonatomic,strong)UIButton *rightBtn;

@end

@implementation FHHouseListRedirectTipCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    
    return self;
}

- (FHShadowView *)shadowView
{
    if (!_shadowView) {
        _shadowView = [[FHShadowView alloc] initWithFrame:CGRectZero];
        [_shadowView setCornerRadius:10];
        [_shadowView setShadowColor:[UIColor colorWithRed:110.f/255.f green:110.f/255.f blue:110.f/255.f alpha:1]];
        [_shadowView setShadowOffset:CGSizeMake(0, 2)];
    }
    return _shadowView;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        CALayer *layer = _containerView.layer;
        layer.cornerRadius = 10;
        layer.masksToBounds = YES;
        layer.borderColor =  [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
        layer.borderWidth = 0.5f;
    }
    return _containerView;
}

- (void)setupUI
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.contentView addSubview:self.shadowView];
    [self.contentView addSubview:self.containerView];
  
    [self.containerView addSubview:self.leftLabel];
    [self.containerView addSubview:self.rightBtn];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(10);
        make.bottom.mas_equalTo(-10);
    }];
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.containerView);
        make.left.mas_equalTo(12);
        make.right.mas_equalTo(self.rightBtn.mas_left).mas_offset(-5);
    }];
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.containerView);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(28);
    }];
    [self.rightBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.rightBtn addTarget:self action:@selector(rightBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)refreshWithData:(id)data
{
    self.currentData = data;
    if ([data isKindOfClass:[FHSearchHouseDataRedirectTipsModel class]]) {
        FHSearchHouseDataRedirectTipsModel *model = (FHSearchHouseDataRedirectTipsModel *)data;
        self.leftLabel.text = model.text;
        [self.rightBtn setTitle:model.text2 forState:UIControlStateNormal];
        [self.rightBtn sizeToFit];
        CGFloat btnWidth = self.rightBtn.width + 32;
        [self.rightBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(btnWidth);
        }];
    }
}

+ (CGFloat)heightForData:(id)data
{
    return 80;
}

- (void)rightBtnDidClick:(UIButton *)btn
{
    if ([self.currentData isKindOfClass:[FHSearchHouseDataRedirectTipsModel class]]) {
        FHSearchHouseDataRedirectTipsModel *model = (FHSearchHouseDataRedirectTipsModel *)self.currentData;
        if (model.clickRightBlock) {
            model.clickRightBlock(model.openUrl);
        }
    }
}

- (UILabel *)leftLabel
{
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc]init];
        _leftLabel.textColor = [UIColor themeGray1];
        _leftLabel.font = [UIFont themeFontRegular:14];
    }
    return _leftLabel;
}

- (UIButton *)rightBtn
{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightBtn setTitle:@"切换城市" forState:UIControlStateNormal];
        [_rightBtn setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
        _rightBtn.titleLabel.font = [UIFont themeFontRegular:12];
        _rightBtn.layer.borderColor = [UIColor themeOrange1].CGColor;
        _rightBtn.layer.borderWidth = 0.5;
        _rightBtn.layer.cornerRadius = 4;
    }
    return _rightBtn;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
