//
//  FHDetailAdvisoryLoanCell.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/4/9.
//

#import "FHDetailAdvisoryLoanCell.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import <FHHouseBase/FHHouseContactDefines.h>
@interface FHDetailAdvisoryLoanCell()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, weak) UIImageView *backgroundImage;
@property (nonatomic, weak) UIImageView *titleImage;
@property (nonatomic, weak) UILabel *changeModify;
@property (nonatomic, weak) UIButton *changeModifyBtn;
@property (nonatomic, weak) UIImageView *rightArrow;
@property (nonatomic, weak) UILabel *submessageLab;
@property (nonatomic, weak) UIView *priceBacView;
@property (nonatomic, weak) UILabel *downPaymentsTitle;//最低首付title
@property (nonatomic, weak) UILabel *downPayments;
@property (nonatomic, weak) UILabel *monthlySupplyTitle;//月供title
@property (nonatomic, weak) UILabel *monthlySupply;
@property (nonatomic, weak) UIView *lineView;//中间分割线
@property (nonatomic, weak) UIButton *consultationBtn;
@end
@implementation FHDetailAdvisoryLoanCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailAdvisoryLoanModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailAdvisoryLoanModel *model = (FHDetailAdvisoryLoanModel *)data;
    self.shadowImage.image = model.shadowImage;
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    self.submessageLab.text = model.downPayment.text;
    self.downPayments.text = model.downPayment.minDownPayment;
    self.monthlySupply.text = model.downPayment.monthlyPayment;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shadowImage).offset(20);
        make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.bottom.mas_equalTo(self.shadowImage).offset(-20);
    }];
    [self.backgroundImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.containerView);
        make.height.mas_equalTo(([[UIScreen mainScreen] bounds].size.width -30)*161/345);
    }];
    [self.titleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(16);
        make.top.equalTo(self.containerView).offset(20);
        make.size.mas_equalTo(CGSizeMake(130, 20));
    }];
    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.containerView).offset(-16);
        make.centerY.equalTo(self.titleImage.mas_centerY);
    }];
    [self.changeModify mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.rightArrow.mas_left).offset(-5);
        make.centerY.equalTo(self.rightArrow.mas_centerY);
    }];
    [self.changeModifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.changeModify);
        make.right.equalTo(self.rightArrow);
    }];
    [self.submessageLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleImage.mas_bottom).offset(10);
        make.left.equalTo(self.titleImage);
        make.right.equalTo(self.rightArrow.mas_right);
    }];
    [self.priceBacView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleImage);
        make.right.equalTo(self.rightArrow.mas_right);
        make.top.equalTo(self.submessageLab.mas_bottom).offset(16);
        make.bottom.equalTo(self.containerView);
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.priceBacView.mas_centerX);
        make.top.equalTo(self.priceBacView).offset(18);
        make.size.mas_equalTo(CGSizeMake(1, 20));
    }];
    [self.downPayments mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.lineView.mas_centerY);
        make.right.equalTo(self.lineView.mas_left).offset(-20);
    }];
    [self.downPaymentsTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.lineView.mas_centerY);
        make.right.equalTo(self.downPayments.mas_left).offset(-8);
    }];
    [self.monthlySupplyTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.lineView.mas_centerY);
        make.left.equalTo(self.lineView.mas_right).offset(20);
    }];
    [self.monthlySupply mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.lineView.mas_centerY);
        make.left.equalTo(self.monthlySupplyTitle.mas_right).offset(8);
    }];
    [self.consultationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleImage);
        make.right.equalTo(self.rightArrow.mas_right);
        make.top.equalTo(self.downPaymentsTitle.mas_bottom).offset(25);
        make.height.mas_offset(40);
        make.bottom.equalTo(self.containerView).offset(-20);
    }];
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (UIImageView *)backgroundImage {
    if (!_backgroundImage) {
        UIImageView *backgroundImage = [[UIImageView alloc]init];
        backgroundImage.image = [UIImage imageNamed:@"advisory_loan_bac"];
        [self.containerView addSubview:backgroundImage];
        _backgroundImage = backgroundImage;
    }
    return  _backgroundImage;
}

- (UIImageView *)titleImage {
    if (!_titleImage) {
        UIImageView *titleImage = [[UIImageView alloc]init];
        titleImage.image = [UIImage imageNamed:@"advisory_loan_title"];
        [self.containerView addSubview:titleImage];
        _titleImage = titleImage;
    }
    return  _titleImage;
}

- (UIImageView *)rightArrow {
    if (!_rightArrow) {
        UIImage *img = ICON_FONT_IMG(16, @"\U0000e670", [UIColor themeGray3]); //@"detail_entrance_arrow"
        UIImageView *rightArrow = [[UIImageView alloc]initWithImage:img];
        [self.containerView addSubview:rightArrow];
        _rightArrow = rightArrow;
        
    }
    return _rightArrow;
}

- (UILabel *)changeModify
{
    if (!_changeModify) {
        UILabel *changeModify = [[UILabel alloc]init];
        changeModify.font = [UIFont themeFontRegular:12];
        changeModify.text = @"修改条件";
        changeModify.userInteractionEnabled = YES;
        changeModify.textColor = [UIColor colorWithHexStr:@"#9c6d43"];
        [self.containerView addSubview:changeModify];
        _changeModify = changeModify;
    }
    return _changeModify;
}

- (UILabel *)submessageLab
{
    if (!_submessageLab) {
        UILabel *submessageLab = [[UILabel alloc]init];
        submessageLab.font = [UIFont themeFontRegular:10];
        submessageLab.textColor = [[UIColor colorWithHexStr:@"#9c6d43"]colorWithAlphaComponent:0.62];
        [self.containerView addSubview:submessageLab];
        _submessageLab = submessageLab;
    }
    return _submessageLab;
}

- (UIView *)priceBacView
{
    if (!_priceBacView) {
        UIView *priceBacView = [[UIView alloc] init];
        priceBacView.backgroundColor = [UIColor whiteColor];
        priceBacView.layer.cornerRadius = 10;
        priceBacView.layer.masksToBounds = YES;
        [self.containerView addSubview:priceBacView];
        _priceBacView = priceBacView;
    }
    return _priceBacView;
}

- (UIView *)lineView
{
    if (!_lineView) {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor themeGray6];
        [self.contentView addSubview:lineView];
        _lineView = lineView;
    }
    return _lineView;
}

- (UILabel *)downPayments
{
    if (!_downPayments) {
        UILabel *downPayments = [[UILabel alloc]init];
        downPayments.font = [UIFont themeFontSemibold:16];
        downPayments.textColor = [UIColor themeGray2];
        [self.containerView addSubview:downPayments];
        _downPayments = downPayments;
    }
    return _downPayments;
}

- (UILabel *)downPaymentsTitle
{
    if (!_downPaymentsTitle) {
        UILabel *downPaymentsTitle = [[UILabel alloc]init];
        downPaymentsTitle.font = [UIFont themeFontRegular:14];
        downPaymentsTitle.text = @"最低首付";
        downPaymentsTitle.textColor = [UIColor themeGray3];
        [self.containerView addSubview:downPaymentsTitle];
        _downPaymentsTitle = downPaymentsTitle;
    }
    return _downPaymentsTitle;
}

- (UILabel *)monthlySupplyTitle
{
    if (!_monthlySupplyTitle) {
        UILabel *monthlySupplyTitle = [[UILabel alloc]init];
        monthlySupplyTitle.font = [UIFont themeFontRegular:14];
        monthlySupplyTitle.textColor = [UIColor themeGray3];
        monthlySupplyTitle.text = @"月供";
        [self.containerView addSubview:monthlySupplyTitle];
        _monthlySupplyTitle = monthlySupplyTitle;
    }
    return _monthlySupplyTitle;
}

- (UILabel *)monthlySupply
{
    if (!_monthlySupply) {
        UILabel *monthlySupply = [[UILabel alloc]init];
        monthlySupply.font = [UIFont themeFontSemibold:16];
        monthlySupply.textColor = [UIColor themeGray2];
        [self.containerView addSubview:monthlySupply];
        _monthlySupply = monthlySupply;
    }
    return _monthlySupply;
}

- (UIButton *)consultationBtn {
    if (!_consultationBtn) {
        UIButton *consultationBtn = [[UIButton alloc]init];
        consultationBtn.layer.cornerRadius = 20;
        consultationBtn.layer.masksToBounds = YES;
        [consultationBtn setTitle:@"咨询经纪人该房源首付" forState:UIControlStateNormal];
        consultationBtn.titleLabel.font = [UIFont themeFontMedium:16];
        [consultationBtn setTitleColor:[UIColor themeOrange4] forState:UIControlStateNormal];
        [consultationBtn addTarget:self action:@selector(tapConsultation:) forControlEvents:UIControlEventTouchDown];
        [consultationBtn setBackgroundColor:[UIColor colorWithHexStr:@"#fff8ef"]];
        [self.containerView addSubview:consultationBtn];
        _consultationBtn = consultationBtn;
    }
    return _consultationBtn;
}

- (UIButton *)changeModifyBtn {
    if (!_changeModifyBtn) {
        UIButton *changeModifyBtn = [[UIButton alloc]init];
        [changeModifyBtn addTarget:self action:@selector(tapCalculator:) forControlEvents:UIControlEventTouchDown];
        [self.containerView addSubview:changeModifyBtn];
        _changeModifyBtn = changeModifyBtn;
    }
    return _changeModifyBtn;
}

- (void)tapConsultation:(UIButton *)sender {
    FHDetailAdvisoryLoanModel *model = (FHDetailAdvisoryLoanModel *)self.currentData;
    if (model.contactModel.contactPhone.phone.length<0) {
        if ([model.contactModel respondsToSelector:@selector(fillFormActionWithExtraDict:)]) {
            NSDictionary *infoDic =  @{kFHCluePage:@(FHClueFormPageTypeCOldHouseShoufu),
                                       @"title":@"首付咨询",
                                       @"subtitle":@"订阅首付咨询，房源首付信息会及时发送到您的手机",
                                       @"position":@"loan",
            };
            [model.contactModel fillFormActionWithExtraDict:infoDic];
        }
    }else {
        NSDictionary *userInfoDict = @{@"tracer":@{}};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
        NSString *openUrl = model.downPayment.openUrl;
        if (openUrl.length > 0) {
            NSURL *url = [NSURL URLWithString:openUrl];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

- (void)tapCalculator:(UIButton *)sender {
        FHDetailAdvisoryLoanModel *model = (FHDetailAdvisoryLoanModel *)self.currentData;
        NSDictionary *userInfoDict = @{@"tracer":@{}};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
        NSString *openUrl = model.downPayment.calculatorUrl;
        if (openUrl.length > 0) {
            NSURL *url = [NSURL URLWithString:openUrl];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
}
@end
@implementation FHDetailAdvisoryLoanModel


@end
