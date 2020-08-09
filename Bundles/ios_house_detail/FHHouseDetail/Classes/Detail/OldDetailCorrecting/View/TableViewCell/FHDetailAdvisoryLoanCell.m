//
//  FHDetailAdvisoryLoanCell.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/4/9.
//

#import "FHDetailAdvisoryLoanCell.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import <FHHouseBase/FHHouseContactDefines.h>
#import "FHHouseFollowUpConfigModel.h"
#import "FHHouseFollowUpHelper.h"
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
//@property (nonatomic, weak) UILabel *downPaymentsTitle;//最低首付title
@property (nonatomic, weak) UILabel *downPayments;
//@property (nonatomic, weak) UILabel *monthlySupplyTitle;//月供title
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

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"loan_consult";
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
    self.downPayments.attributedText = [self returnAttributedStringWithTitle:@"最低首付  " info:model.downPayment.minDownPayment isdownPayments:YES];
    self.monthlySupply.attributedText = [self returnAttributedStringWithTitle:@"月供  " info:model.downPayment.monthlyPayment isdownPayments:NO];
}

- (NSMutableAttributedString *) returnAttributedStringWithTitle:(NSString *)title info:(NSString *)info isdownPayments:(BOOL)isdownPayments {
    NSString *titleStr = title;
    NSString *infoStr = info;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",titleStr,infoStr]];
    [attStr addAttribute:NSFontAttributeName value:[UIFont themeFontRegular:14] range:NSMakeRange(0, titleStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value: [UIColor themeGray3] range:NSMakeRange(0, titleStr.length)];
    [attStr addAttribute:NSFontAttributeName value:[UIFont themeFontSemibold:16] range:NSMakeRange(titleStr.length, attStr.length- titleStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value: [UIColor themeGray2] range:NSMakeRange(titleStr.length, attStr.length- titleStr.length)];
    [attStr addAttribute:NSBaselineOffsetAttributeName value:@(isdownPayments?-1.3:-1) range:NSMakeRange(titleStr.length, attStr.length- titleStr.length)];
    return attStr;
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
        make.right.equalTo(self.lineView.mas_left);
        make.left.equalTo(self.priceBacView);
    }];
    [self.monthlySupply mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.lineView.mas_centerY);
        make.left.equalTo(self.lineView.mas_right);
        make.right.equalTo(self.priceBacView);
    }];
    [self.consultationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleImage);
        make.right.equalTo(self.rightArrow.mas_right);
        make.top.equalTo(self.downPayments.mas_bottom).offset(25);
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
        UIImage *img = ICON_FONT_IMG(16, @"\U0000e670", [UIColor colorWithHexStr:@"a57d59"]); //@"detail_entrance_arrow"
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
        downPayments.textAlignment = NSTextAlignmentCenter;
        [self.containerView addSubview:downPayments];
        _downPayments = downPayments;
    }
    return _downPayments;
}

- (UILabel *)monthlySupply
{
    if (!_monthlySupply) {
        UILabel *monthlySupply = [[UILabel alloc]init];
        monthlySupply.font = [UIFont themeFontSemibold:16];
        monthlySupply.textColor = [UIColor themeGray2];
        monthlySupply.textAlignment = NSTextAlignmentCenter;
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
    NSString *openUrl = model.downPayment.openUrl;
    if (openUrl.length>0) {
//            NSURL *url = [NSURL URLWithString:openUrl];
            NSMutableDictionary *imExtra = @{}.mutableCopy;
            imExtra[@"from"] = @"app_oldhouse_mortgage";
            imExtra[@"source"] = @"app_oldhouse_mortgage";
            imExtra[@"source_from"] = @"loan";
            imExtra[@"realtor_position"] = @"loan";
            imExtra[@"im_open_url"] = openUrl;
//            imExtra[kFHClueEndpoint] = [NSString stringWithFormat:@"%ld",FHClueEndPointTypeC];
//            imExtra[kFHCluePage] = [NSString stringWithFormat:@"%ld",FHClueIMPageTypeCOldBudget];
            if(model.downPayment.associateInfo) {
                         imExtra[kFHAssociateInfo] = model.downPayment.associateInfo;
            }
            [model.contactModel onlineActionWithExtraDict:imExtra];
//        }
    }else {
        if ([model.contactModel respondsToSelector:@selector(fillFormActionWithParams:)]) {
            NSMutableDictionary *associateParamDict =  @{
                                       @"title":@"首付咨询",
                                       @"subtitle":@"订阅首付咨询，房源首付信息会及时发送到您的手机",
                                       @"position":@"loan",
                                       @"btn_title":@"提交"
            }.mutableCopy;
            associateParamDict[kFHAssociateInfo] = model.downPayment.associateInfo.reportFormInfo;
            NSMutableDictionary *reportParamsDict = [model.contactModel baseParams].mutableCopy;
            reportParamsDict[@"position"] = @"loan";
            associateParamDict[kFHReportParams] = reportParamsDict;
            
            [model.contactModel fillFormActionWithParams:associateParamDict];
        }
    }
  
}

- (void)tapCalculator:(UIButton *)sender {
    FHDetailAdvisoryLoanModel *model = (FHDetailAdvisoryLoanModel *)self.currentData;
    NSDictionary *userInfoDict = @{@"tracer":@{}};
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
    NSString *openUrl = model.downPayment.calculatorUrl;
    [self addGoDetailLog];
    if (openUrl.length > 0) {
        NSURL *url = [NSURL URLWithString:openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

- (void)addGoDetailLog
{
    FHDetailAdvisoryLoanModel *model = (FHDetailAdvisoryLoanModel *)self.currentData;
    //    1. event_type ：house_app2c_v2
    //    2. page_type（详情页类型）：rent_detail（租房详情页），old_detail（二手房详情页）
    //    3. card_type（房源展现时的卡片样式）：left_pic（左图）
    //    4. enter_from（详情页入口）：search_related_list（搜索结果推荐）
    //    5. element_from ：search_related
    //    6. rank
    //    7. origin_from
    //    8. origin_search_id
    //    9.log_pb
    NSMutableDictionary *params = @{}.mutableCopy;
    if (model.baseViewModel.detailTracerDic) {
        [params addEntriesFromDictionary:model.baseViewModel.detailTracerDic];
    }
    [params setValue:@"debit_calculator" forKey:@"page_type"];
    [params setValue:@"loan_consult" forKey:@"element_from"];
     [params setValue:@"old_detail" forKey:@"enter_from"];
    [FHUserTracker writeEvent:@"go_detail" params:params];
    
}
@end
@implementation FHDetailAdvisoryLoanModel


@end
