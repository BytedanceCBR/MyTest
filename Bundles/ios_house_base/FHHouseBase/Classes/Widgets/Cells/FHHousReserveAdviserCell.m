//
//  FHHousReserveAdviserCell.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2020/6/1.
//

#import <Masonry/View+MASAdditions.h>
#import <FHCommonUI/UILabel+House.h>
#import "FHHousReserveAdviserCell.h"
#import "FHSearchHouseModel.h"
#import "FHDetailBaseModel.h"
#import <BDWebImage/BDWebImage.h>
#import "FHDetailAgentListCell.h"
#import "FHHousePhoneCallUtils.h"
#import "UIColor+Theme.h"
#import <FHHouseBase/FHCommonDefines.h>
#import <TTThemed/SSViewBase.h>
#import <TTThemed/UIColor+TTThemeExtension.h>
#import "UIImage+FIconFont.h"
#import "FHTextField.h"
#import "FHURLSettings.h"
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import "FHEnvContext.h"
#import "ToastManager.h"
#import "FHMainApi+Contact.h"
#import <FHHouseBase/FHUserInfoManager.h>
#import <FHHouseBase/NSObject+FHOptimize.h>
#import "SSCommonLogic.h"
#import "TTAccountLoginManager.h"
#import <TTAccountSDK/TTAccount.h>
#import <FHHouseBase/FHHouseFillFormHelper.h>

@interface FHHousReserveAdviserCell ()<UITextFieldDelegate>


@property(nonatomic, strong) UIView *containerView;

@property(nonatomic, strong) UIView *topInfoView;
@property(nonatomic, strong) UILabel *mainTitleLabel; //小区名称
@property(nonatomic, strong) UILabel *pricePerSqmLabel; //房源价格
@property(nonatomic, strong) UILabel *countOnSale; //在售套数
@property(nonatomic, strong) UIImageView *rightArrow;

@property(nonatomic, strong) UIImageView *bottomInfoView;
@property(nonatomic, strong) UILabel *tipNameLabel;
@property(nonatomic, strong) FHTextField *textField;
@property(nonatomic, strong) UIButton *subscribeBtn;
@property(nonatomic, strong) YYLabel *legalAnnouncement;

@property(nonatomic, strong) FHHouseReserveAdviserModel *modelData;
@property(nonatomic, strong) NSMutableDictionary *traceParams;
@property(nonatomic, strong) NSString *phoneNum;
@property(nonatomic, assign) CGFloat offsetY;

@end

@implementation FHHousReserveAdviserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        [self initNotification];
        [self setPhoneNumber];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return self;
}

- (void)updateHeightByIsFirst:(BOOL)isFirst {
    CGFloat top = 5;
    if (isFirst) {
        top = 10;
    }
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(top);
    }];
}

- (void)initUI {

    self.contentView.clipsToBounds = NO;
    self.clipsToBounds = NO;

    _containerView = [[UIView alloc] init];
    _containerView.backgroundColor = [UIColor whiteColor];
    CALayer *layer = _containerView.layer;
    layer.cornerRadius = 10;
    layer.masksToBounds = YES;
    [self.contentView addSubview:_containerView];

    _topInfoView = [[UIView alloc] init];
    _topInfoView.userInteractionEnabled = NO;
    [self.containerView addSubview:_topInfoView];

    _mainTitleLabel = [[UILabel alloc] init];
    _mainTitleLabel.textAlignment = NSTextAlignmentLeft;
    _mainTitleLabel.textColor = [UIColor themeGray1];
    _mainTitleLabel.font = [UIFont themeFontSemibold:16];
    [self.topInfoView addSubview:_mainTitleLabel];

    _pricePerSqmLabel = [[UILabel alloc] init];
    _pricePerSqmLabel.textAlignment = NSTextAlignmentRight;
    _pricePerSqmLabel.textColor = [UIColor themeOrange1];
    _pricePerSqmLabel.font = [UIFont themeFontMedium:16];
    [self.topInfoView addSubview:_pricePerSqmLabel];

    _countOnSale = [[UILabel alloc] init];
    _countOnSale.textAlignment = NSTextAlignmentLeft;
    _countOnSale.textColor = [UIColor themeGray1];
    _countOnSale.font = [UIFont themeFontRegular:12];
    [self.topInfoView addSubview:_countOnSale];
    
    self.rightArrow = [[UIImageView alloc] initWithImage:ICON_FONT_IMG(10, @"\U0000e670", [UIColor themeGray6])];
    _rightArrow.hidden = YES;
    [self.topInfoView addSubview:_rightArrow];

    _bottomInfoView = [[UIImageView alloc] init];
    _bottomInfoView.userInteractionEnabled = YES;
    _bottomInfoView.image = [UIImage imageNamed:@"house_reserve_bg"];
    [self.containerView addSubview:_bottomInfoView];
    
    _tipNameLabel = [[UILabel alloc] init];
    _tipNameLabel.textAlignment = NSTextAlignmentLeft;
    _tipNameLabel.textColor = [UIColor colorWithHexString:@"a57d59"];
    _tipNameLabel.font = [UIFont themeFontSemibold:16];
    [self.bottomInfoView addSubview:_tipNameLabel];
    
    self.textField = [[FHTextField alloc] init];
    _textField.edgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    _textField.tintColor = [UIColor themeRed3];
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.font = [UIFont themeFontRegular:14];
    _textField.textColor = [UIColor themeGray1];
    _textField.layer.borderColor = [UIColor colorWithHexStr:@"#f9e7d5"].CGColor;
    _textField.layer.borderWidth  = 0.5;
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    _textField.placeholder = @"请输入手机号";
    _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入手机号" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexStr:@"#d9d9d9"]}];
    _textField.layer.cornerRadius = 16;
    _textField.layer.masksToBounds = YES;
    _textField.delegate = self;
    [self.bottomInfoView addSubview:_textField];
    
    self.subscribeBtn = [[UIButton alloc] init];
    [_subscribeBtn setTitle:@"免费预约" forState:UIControlStateNormal];
    [_subscribeBtn setTitleColor:[UIColor colorWithHexStr:@"#a57d59"] forState:UIControlStateNormal];
    _subscribeBtn.titleLabel.font = [UIFont themeFontSemibold:14];
    _subscribeBtn.layer.cornerRadius = 15;
    _subscribeBtn.layer.borderColor = [UIColor colorWithHexStr:@"#c8a572"].CGColor;
    _subscribeBtn.layer.borderWidth = 0.5;
    _subscribeBtn.enabled = NO;
    [_subscribeBtn addTarget:self action:@selector(subscribe) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomInfoView addSubview:_subscribeBtn];
    
    self.legalAnnouncement = [[YYLabel alloc] init];
    _legalAnnouncement.textColor = [UIColor colorWithHexStr:@"#cfb69b"];
    _legalAnnouncement.textAlignment = NSTextAlignmentLeft;
    _legalAnnouncement.lineBreakMode = NSLineBreakByWordWrapping;
    [self.bottomInfoView addSubview:_legalAnnouncement];
    
    [self.topInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(neighbourhoodInfoClick:)]];

    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(15);
        make.right.mas_equalTo(self.contentView).mas_offset(-15);
        make.top.mas_equalTo(self.contentView).offset(5);
        make.bottom.mas_equalTo(self.contentView).offset(-5);
    }];

    [self.topInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(73);
    }];

    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topInfoView).mas_offset(-10);
        make.left.mas_equalTo(self.topInfoView).offset(15);
        make.height.mas_equalTo(22);
        make.right.mas_lessThanOrEqualTo(self.pricePerSqmLabel.mas_left).offset(-10);
    }];

    [self.pricePerSqmLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.topInfoView.mas_right).offset(-15);
        make.centerY.mas_equalTo(self.topInfoView);
    }];

    [self.countOnSale mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mainTitleLabel);
        make.top.mas_equalTo(self.mainTitleLabel.mas_bottom).offset(2);
        make.height.mas_equalTo(17);
        make.right.mas_lessThanOrEqualTo(self.pricePerSqmLabel.mas_left).offset(-10);
    }];
    
    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.topInfoView.mas_right).offset(-15);
        make.centerY.mas_equalTo(self.topInfoView);
        make.width.mas_equalTo(18);
        make.height.mas_equalTo(18);
    }];

    [self.bottomInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topInfoView.mas_bottom);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.left.right.mas_equalTo(self.containerView);
    }];
    
    [self.tipNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bottomInfoView).offset(15);
        make.right.mas_equalTo(self.bottomInfoView).offset(-15);
        make.top.mas_equalTo(self.bottomInfoView).offset(16);
        make.height.mas_equalTo(22);
    }];
    
    [self.subscribeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipNameLabel.mas_bottom).offset(10);
        make.right.mas_equalTo(self.bottomInfoView).offset(-15);
        make.width.mas_equalTo(89);
        make.height.mas_equalTo(30);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.subscribeBtn);
        make.left.mas_equalTo(self.bottomInfoView).offset(15);
        make.right.mas_equalTo(self.subscribeBtn.mas_left).offset(-10);
        make.height.mas_equalTo(30);
    }];
    
    [self setLegalAnnouncement];
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShowNotifiction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHideNotifiction:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)setPhoneNumber {
    if ([SSCommonLogic isEnableVerifyFormAssociate]) {
        self.subscribeBtn.enabled = YES;
    } else {
        self.phoneNum = [FHUserInfoManager getPhoneNumberIfExist];
        [self showFullPhoneNum:NO];
    }
}

- (void)setLegalAnnouncement {
    __weak typeof(self) weakSelf = self;
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:@"点击订阅即视为同意《个人信息保护声明》"];
    [attrText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(10, 8)];
    NSDictionary *attr = @{
            NSFontAttributeName: [UIFont themeFontRegular:10],
            NSForegroundColorAttributeName: [UIColor colorWithHexString:@"cfb69b"],
    };
    [attrText addAttributes:attr range:NSMakeRange(0, attrText.length)];
    [attrText yy_setTextHighlightRange:NSMakeRange(10, 8) color:[UIColor colorWithHexString:@"cfb69b"] backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        [weakSelf legalAnnouncementClick];
    }];

    self.legalAnnouncement.attributedText = attrText;
    
    [self.legalAnnouncement mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10);
        make.left.mas_equalTo(self.bottomInfoView).offset(15);
        make.right.mas_equalTo(self.bottomInfoView).offset(-15);
        make.height.mas_equalTo(14);
    }];
}

- (void)bindData:(FHHouseReserveAdviserModel *)model traceParams:(NSDictionary *)params {
    if (model) {
        self.modelData = model;
        self.traceParams = params.mutableCopy;

        [self.mainTitleLabel setText:model.targetName];
        [self.pricePerSqmLabel setText:model.areaPrice];
        if (model.districtAreaName.length > 0 && model.displayStatusInfo.length > 0) {
            self.countOnSale.text = [NSString stringWithFormat:@"%@/%@",model.districtAreaName,model.displayStatusInfo];
        }else if (model.districtAreaName.length > 0) {
            self.countOnSale.text = model.districtAreaName;
        }else if (model.displayStatusInfo.length > 0) {
            self.countOnSale.text = model.displayStatusInfo;
        }
        
        self.tipNameLabel.text = model.tipText;
        
        if([model.realtorType isEqualToString:@"4"]){
            //小区
            [self.pricePerSqmLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.rightArrow.mas_left).offset(-10);
                make.centerY.mas_equalTo(self.topInfoView);
            }];
            self.topInfoView.userInteractionEnabled = YES;
            self.rightArrow.hidden = NO;
        }else if([model.realtorType isEqualToString:@"5"]){
            //商圈
            [self.pricePerSqmLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.topInfoView.mas_right).offset(-15);
                make.centerY.mas_equalTo(self.topInfoView);
            }];
            self.topInfoView.userInteractionEnabled = NO;
            self.rightArrow.hidden = YES;
        }
        
        if(model.subscribeCache && model.targetId){
            model.isSubcribed = [model.subscribeCache[model.targetId] boolValue];
        }else{
            model.isSubcribed = NO;
        }
        
        if(model.isSubcribed){
            self.tipNameLabel.text = @"已为您预约顾问，稍后会和您联系";
            self.subscribeBtn.hidden = YES;
            self.textField.hidden = YES;
            self.legalAnnouncement.hidden = YES;
            [self.bottomInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(53);
            }];
            if ([SSCommonLogic isEnableVerifyFormAssociate]) {
                [self.tipNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.bottomInfoView).offset(15);
                    make.right.mas_equalTo(self.bottomInfoView).offset(-5);
                    make.height.mas_equalTo(20);
                    make.centerY.mas_equalTo(self.bottomInfoView);
                }];
            }
        }else{
            //新增实验
            self.tipNameLabel.text = model.tipText;
            if ([SSCommonLogic isEnableVerifyFormAssociate]) {
                self.tipNameLabel.font = [UIFont themeFontSemibold:14];
                self.tipNameLabel.text = @"高效找房，为您推荐专属顾问";
                
                self.subscribeBtn.hidden = NO;
                [self.subscribeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.subscribeBtn.layer.cornerRadius = 15;
//                _subscribeBtn.layer.borderColor = [UIColor colorWithHexStr:@"#c8a572"].CGColor;
                self.subscribeBtn.layer.borderWidth = 0;
                self.subscribeBtn.backgroundColor = [UIColor colorWithHexString:@"#d4b382"];
                self.textField.hidden = YES;
                self.legalAnnouncement.hidden = YES;
                
                [self.bottomInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(58);
                }];
                
                [self.subscribeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.bottomInfoView).mas_offset(-3);
                    make.right.mas_equalTo(self.bottomInfoView).offset(-15);
                    make.width.mas_equalTo(86);
                    make.height.mas_equalTo(30);
                }];
                
                [self.tipNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.bottomInfoView).offset(15);
                    make.right.mas_equalTo(self.subscribeBtn.mas_left).offset(0);
                    make.height.mas_equalTo(20);
                    make.centerY.mas_equalTo(self.subscribeBtn.mas_centerY);
                }];
            } else {
                self.subscribeBtn.hidden = NO;
                self.textField.hidden = NO;
                self.legalAnnouncement.hidden = NO;
                
                [self.bottomInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(118);
                }];
                
                [self.subscribeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.tipNameLabel.mas_bottom).offset(10);
                    make.right.mas_equalTo(self.bottomInfoView).offset(-15);
                    make.width.mas_equalTo(89);
                    make.height.mas_equalTo(30);
                }];
                
                [self.tipNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.bottomInfoView).offset(15);
                    make.right.mas_equalTo(self.bottomInfoView).offset(-15);
                    make.top.mas_equalTo(self.bottomInfoView).offset(16);
                    make.height.mas_equalTo(22);
                }];
            }
        }
    }
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[FHHouseReserveAdviserModel class]]) {
        FHHouseReserveAdviserModel *model = (FHHouseReserveAdviserModel *)data;
        [self bindData:model traceParams:model.tracerDict];
    }
}

+ (CGFloat)heightForData:(id)data
{
    if ([data isKindOfClass:[FHHouseReserveAdviserModel class]]) {
        FHHouseReserveAdviserModel *model = (FHHouseReserveAdviserModel *)data;
        if ([SSCommonLogic isEnableVerifyFormAssociate] || model.isSubcribed) {
            return 126;
        }
    }
    
    return 211;
}

- (void)subscribe {
    if ([SSCommonLogic isEnableVerifyFormAssociate]) {
        __weak typeof(self) weakSelf = self;
        FHAssociateFormReportModel *formReportModel = [[FHAssociateFormReportModel alloc] init];
        formReportModel.associateInfo = self.modelData.associateInfo.reportFormInfo;
        NSMutableDictionary *tracerDic = self.modelData.tracerDict.mutableCopy;
        tracerDic[@"enter_type"] = @"click_subscribe";
        if([self.modelData.realtorType isEqualToString:@"4"]){
            //小区
            tracerDic[@"position"] = @"neighborhood_expert_card";
        } else if ([self.modelData.realtorType isEqualToString:@"5"]){
            //商圈
            tracerDic[@"position"] = @"area_expert_card";
        }
        
        formReportModel.reportParams = tracerDic.copy;
        formReportModel.houseType = FHHouseTypeNeighborhood;
        formReportModel.title = @"免费预约";
        formReportModel.btnTitle = @"立即预约";
        formReportModel.subtitle = @"预约后，我们将为您匹配专业的找房顾问，提供优质的咨询服务。";
        formReportModel.topViewController = self.modelData.belongsVC;
        [FHHouseFillFormHelper fillFormActionWithAssociateReportModel:formReportModel completion:^{
            if(weakSelf.modelData.subscribeCache && weakSelf.modelData.targetId){
                weakSelf.modelData.subscribeCache[weakSelf.modelData.targetId] = @(YES);
            }
            [weakSelf subscribeSuccess];
        }];
        return;
    }
    NSString *phoneNum = self.phoneNum;
    if (phoneNum.length == 11 && [phoneNum hasPrefix:@"1"] && [FHUserInfoManager checkPureIntFormatted:phoneNum]) {
        NSMutableDictionary *tracerDic = self.modelData.tracerDict.mutableCopy;
        tracerDic[@"position"] = @"card";
        tracerDic[kFHAssociateInfo] = self.modelData.associateInfo.reportFormInfo;
        [FHUserTracker writeEvent:@"click_confirm" params:tracerDic];
        [self subscribeFormRequest:phoneNum];
    }else {
        [[ToastManager manager] showToast:@"手机格式错误"];
        self.textField.textColor = [UIColor themeOrange1];
    }
}

- (void)subscribeSuccess {
    self.modelData.isSubcribed = YES;
    [self.modelData.tableView beginUpdates];
    
    self.subscribeBtn.hidden = YES;
    self.textField.hidden = YES;
    self.legalAnnouncement.hidden = YES;
    self.tipNameLabel.text = @"已为您预约顾问，稍后会和您联系";
    if ([SSCommonLogic isEnableVerifyFormAssociate]) {
        [self.tipNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.bottomInfoView).offset(15);
            make.right.mas_equalTo(self.bottomInfoView).offset(0);
            make.height.mas_equalTo(20);
            make.centerY.mas_equalTo(self.bottomInfoView);
        }];
        
        [self.bottomInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(58);
        }];

    } else {
        [self.bottomInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(53);
        }];
    }
    
    [self setNeedsUpdateConstraints];
    
    [self.modelData.tableView endUpdates];
}

- (void)legalAnnouncementClick{
    [self.modelData.belongsVC.view endEditing:YES];
    NSString *privateUrlStr = [NSString stringWithFormat:@"%@/f100/client/user_privacy&title=个人信息保护声明&hide_more=1",[FHURLSettings baseURL]];
    NSString *urlStr = [privateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://webview?url=%@",urlStr]];
    [[TTRoute sharedRoute]openURLByPushViewController:url];
}

- (void)showFullPhoneNum:(BOOL)isShow {
    if(isShow){
        __weak typeof(self) weakSelf = self;
        [self executeOnce:^{
            weakSelf.textField.text = @"";
        } token:FHExecuteOnceUniqueTokenForCurrentContext];
    }else{
        self.textField.text = [FHUserInfoManager formatMaskPhoneNumber:self.phoneNum];
    }
    if (self.textField.text.length > 0) {
        self.subscribeBtn.enabled = YES;
        [self.subscribeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.subscribeBtn.backgroundColor = [UIColor colorWithHexStr:@"#c8a572"];
    }else {
        self.subscribeBtn.enabled = NO;
        [self.subscribeBtn setTitleColor:[UIColor colorWithHexStr:@"#a57d59"] forState:UIControlStateNormal];
        self.subscribeBtn.backgroundColor = [UIColor whiteColor];
    }
}

- (void)subscribeFormRequest:(NSString *)phoneNum {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }

    __weak typeof(self) wself = self;
    [FHMainApi requestCallReportByHouseId:nil phone:phoneNum from:nil cluePage:nil clueEndpoint:nil targetType:nil reportAssociate:self.modelData.associateInfo.reportFormInfo agencyList:nil extraInfo:nil completion:^(FHDetailFillFormResponseModel * _Nullable model, NSError * _Nullable error) {

        if (model.status.integerValue == 0 && !error) {
            if(wself.modelData.subscribeCache && wself.modelData.targetId){
                wself.modelData.subscribeCache[wself.modelData.targetId] = @(YES);
            }
            NSString *toast = @"已为您预约顾问，稍后将会和您联系";
            [[ToastManager manager] showToast:toast];
            [wself subscribeSuccess];
            [FHUserInfoManager savePhoneNumber:phoneNum];
        }else {
            [[ToastManager manager] showToast:[NSString stringWithFormat:@"%@%@",model.message.length ? @"" : @"提交失败 ", model.message]];
        }
    }];
}

#pragma mark -- UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self showFullPhoneNum:YES];
    if(self.textFieldShouldBegin){
        self.textFieldShouldBegin();
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if(self.textFieldDidEnd){
        self.textFieldDidEnd();
    }
}

- (void)textFieldDidChange:(NSNotification *)notification {
    if (!self.textField.isFirstResponder) {
        return;
    }
    if (self.textField.text.length > 11) {
        self.textField.text = [self.textField.text substringToIndex:11];
    }
    
    self.textField.textColor = [UIColor themeGray1];
    self.phoneNum = self.textField.text;
    
    if (self.textField.text.length > 0) {
        self.subscribeBtn.enabled = YES;
        [self.subscribeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.subscribeBtn.backgroundColor = [UIColor colorWithHexStr:@"#c8a572"];
    }else {
        self.subscribeBtn.enabled = NO;
        [self.subscribeBtn setTitleColor:[UIColor colorWithHexStr:@"#a57d59"] forState:UIControlStateNormal];
        self.subscribeBtn.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - 键盘通知
- (void)keyboardWillShowNotifiction:(NSNotification *)notification {
    if (!self.textField.isFirstResponder) {
        return;
    }
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGRect frame = [self convertRect:self.bounds toView:nil];
    CGFloat y = [UIScreen mainScreen].bounds.size.height - frame.origin.y - frame.size.height - height;
    self.offsetY = y;
    
    if(y < 0){
        [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions)[curve integerValue] animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            CGPoint point = self.modelData.tableView.contentOffset;
            point.y -= y;
            self.modelData.tableView.contentOffset = point;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)keyboardWillHideNotifiction:(NSNotification *)notification {
    self.offsetY = 0;
    if(self.modelData.tableView.contentOffset.y + self.modelData.tableView.frame.size.height > self.modelData.tableView.contentSize.height){
        //剩余不满一屏幕
        NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions)[curve integerValue] animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            CGPoint point = self.modelData.tableView.contentOffset;
            point.y = (self.modelData.tableView.contentSize.height - self.modelData.tableView.frame.size.height);
            self.modelData.tableView.contentOffset = point;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)neighbourhoodInfoClick:(id)neighbourhoodInfoClick {
    if (self.modelData) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@", self.modelData.targetId]];

        NSMutableDictionary *tracerDict = @{}.mutableCopy;
        if (self.traceParams) {
            [tracerDict addEntriesFromDictionary:self.traceParams];
        }
        tracerDict[@"element_from"] = self.traceParams[@"realtor_position"];
        tracerDict[@"enter_from"] = self.traceParams[@"page_type"];
        tracerDict[@"page_type"] = nil;
        NSMutableDictionary *dict = @{@"house_type": @(FHHouseTypeNeighborhood), @"tracer": tracerDict}.mutableCopy;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

@end
