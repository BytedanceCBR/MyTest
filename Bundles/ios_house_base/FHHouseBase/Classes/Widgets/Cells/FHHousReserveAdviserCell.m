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
#import "FHExtendHotAreaButton.h"
#import "FHShadowView.h"
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

extern NSString *const kFHPhoneNumberCacheKey;

@interface FHHousReserveAdviserCell ()<UITextFieldDelegate>


@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) FHShadowView *shadowView;

@property(nonatomic, strong) UIView *topInfoView;
@property(nonatomic, strong) UILabel *mainTitleLabel; //小区名称
@property(nonatomic, strong) UILabel *pricePerSqmLabel; //房源价格
@property(nonatomic, strong) UILabel *countOnSale; //在售套数

@property(nonatomic, strong) UIImageView *bottomInfoView;
@property(nonatomic, strong) UILabel *tipNameLabel;
@property(nonatomic, strong) FHTextField *textField;
@property(nonatomic, strong) UIButton *subscribeBtn;
@property(nonatomic, strong) YYLabel *legalAnnouncement;

@property(nonatomic, strong) FHHouseReserveAdviserModel *modelData;
@property(nonatomic, strong) NSMutableDictionary *traceParams;
@property(nonatomic, strong) NSString *phoneNum;

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

- (void)initUI {

    self.contentView.clipsToBounds = NO;
    self.clipsToBounds = NO;

    _shadowView = [[FHShadowView alloc] initWithFrame:CGRectZero];
    [_shadowView setCornerRadius:10];
    [_shadowView setShadowColor:[UIColor colorWithRed:110.f/255.f green:110.f/255.f blue:110.f/255.f alpha:1]];
    [_shadowView setShadowOffset:CGSizeMake(0, 2)];
    [self.contentView addSubview:_shadowView];

    _containerView = [[UIView alloc] init];
    CALayer *layer = _containerView.layer;
    layer.cornerRadius = 10;
    layer.masksToBounds = YES;
    layer.borderColor =  [UIColor colorWithHexString:@"#e8e8e8"].CGColor;
    layer.borderWidth = 0.5f;
    [self.contentView addSubview:_containerView];

    _topInfoView = [[UIView alloc] init];
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

    _bottomInfoView = [[UIImageView alloc] init];
    _bottomInfoView.userInteractionEnabled = YES;
    _bottomInfoView.image = [UIImage imageNamed:@"house_reserve_bg"];
//    _bottomInfoView.contentMode = UIViewContentModeScaleAspectFill;
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

    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(15);
        make.right.mas_equalTo(self.contentView).mas_offset(-15);
        make.top.mas_equalTo(self.contentView).offset(10);
        make.bottom.mas_equalTo(self.contentView).offset(-10);
    }];

    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];

    [self.topInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(73);
    }];

    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topInfoView).offset(16);
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

    [self.bottomInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topInfoView.mas_bottom);
        make.height.mas_equalTo(118);
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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)setPhoneNumber {
    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    id phoneCache = [sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
    id loginPhoneCache = [sendPhoneNumberCache objectForKey:kFHPLoginhoneNumberCacheKey];
    
    NSString *phoneNum = nil;
    if ([phoneCache isKindOfClass:[NSString class]]) {
        NSString *cacheNum = (NSString *)phoneCache;
        if (cacheNum.length > 0) {
            phoneNum = cacheNum;
        }
    }else if ([loginPhoneCache isKindOfClass:[NSString class]]) {
        NSString *cacheNum = (NSString *)loginPhoneCache;
        if (cacheNum.length > 0) {
            phoneNum = cacheNum;
        }
    }
    self.phoneNum = phoneNum;
    [self showFullPhoneNum:NO];
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
        
        self.subscribeBtn.hidden = model.isSubcribed;
        self.textField.hidden = model.isSubcribed;
        self.legalAnnouncement.hidden = model.isSubcribed;
        
        if(model.isSubcribed){
            self.tipNameLabel.text = @"已为您预约顾问，稍后会和您联系";
            [self.bottomInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(53);
            }];
        }else{
            self.tipNameLabel.text = model.tipText;
            [self.bottomInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(118);
            }];
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
        return model.isSubcribed ? 146 : 211;
    }
    
    return 211;
}

- (void)subscribe {
//    NSString *phoneNum = self.phoneNum;
//    if (phoneNum.length == 11 && [phoneNum hasPrefix:@"1"] && [self isPureInt:phoneNum]) {
//
//        FHDetailHouseSubscribeCorrectingModel *model = (FHDetailHouseSubscribeCorrectingModel *)self.currentData;
//        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
//        tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
//        tracerDic[@"position"] = @"card";
//        tracerDic[@"growth_deepevent"] = @(1);
//        tracerDic[kFHAssociateInfo] = model.associateInfo.reportFormInfo;
//        [FHUserTracker writeEvent:@"click_confirm" params:tracerDic];
//
//        [self subscribeFormRequest:self.phoneNum];
//    }else {
//        [[ToastManager manager] showToast:@"手机格式错误"];
//        self.textField.textColor = [UIColor themeOrange1];
//    }
    
    [self subscribeSuccess];
}

- (void)subscribeSuccess {
    self.modelData.isSubcribed = YES;
    [self.modelData.tableView beginUpdates];
    
    self.subscribeBtn.hidden = YES;
    self.textField.hidden = YES;
    self.legalAnnouncement.hidden = YES;
    self.tipNameLabel.text = @"已为您预约顾问，稍后会和您联系";
    [self.bottomInfoView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(53);
    }];
    
    [self setNeedsUpdateConstraints];
    
    [self.modelData.tableView endUpdates];
//    [self.modelData.tableView reloadData];
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

- (void)legalAnnouncementClick{
    NSString *privateUrlStr = [NSString stringWithFormat:@"%@/f100/client/user_privacy&title=个人信息保护声明&hide_more=1",[FHURLSettings baseURL]];
    NSString *urlStr = [privateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://webview?url=%@",urlStr]];
    [[TTRoute sharedRoute]openURLByPushViewController:url];
}

- (void)showFullPhoneNum:(BOOL)isShow {
    if (self.phoneNum.length > 0) {
        if(isShow){
            self.textField.text = self.phoneNum;
        }else{
            // 显示 151*****010
            NSString *tempPhone = self.phoneNum;
            if (self.phoneNum.length == 11 && [self.phoneNum hasPrefix:@"1"] && [self isPureInt:self.phoneNum]) {
                tempPhone = [NSString stringWithFormat:@"%@*****%@",[self.phoneNum substringToIndex:3],[self.phoneNum substringFromIndex:7]];
            }
            self.textField.text = tempPhone;
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
    }
}

- (void)subscribeFormRequest:(NSString *)phoneNum {
//    __weak typeof(self)wself = self;
//    if (![TTReachability isNetworkConnected]) {
//        [[ToastManager manager] showToast:@"网络异常"];
//        return;
//    }
//    NSString *houseId = self.houseId;
//    NSString *from = @"app_oldhouse_subscription";
//
//    [FHMainApi requestCallReportByHouseId:houseId phone:phoneNum from:nil cluePage:nil clueEndpoint:nil targetType:nil reportAssociate:subscribeModel.associateInfo.reportFormInfo agencyList:nil completion:^(FHDetailResponseModel * _Nullable model, NSError * _Nullable error) {
//
//        if (model.status.integerValue == 0 && !error) {
//            FHDetailOldModel * model = (FHDetailOldModel *)self.detailData;
//            NSString *toast =@"提交成功，经纪人将尽快与您联系";
//            if (model.data.subscriptionToast && model.data.subscriptionToast.length > 0) {
//                toast = model.data.subscriptionToast;
//            }
//            [[ToastManager manager] showToast:toast];
//            YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
//            [sendPhoneNumberCache setObject:phoneNum forKey:kFHPhoneNumberCacheKey];
//
//            YYCache *subscribeHouseCache = [[FHEnvContext sharedInstance].generalBizConfig subscribeHouseCache];
//            [subscribeHouseCache setObject:@"1" forKey:wself.houseId];
//
//            [wself.items removeObject:subscribeModel];
//            [wself reloadData];
//        }else {
//            [[ToastManager manager] showToast:[NSString stringWithFormat:@"提交失败 %@",model.message]];
//        }
//    }];
//    // 静默关注功能
//    NSMutableDictionary *params = @{}.mutableCopy;
//    if (self.detailTracerDic) {
//        [params addEntriesFromDictionary:self.detailTracerDic];
//    }
//    FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:params error:nil];
//    configModel.houseType = self.houseType;
//    configModel.followId = self.houseId;
//    configModel.actionType = self.houseType;
//
//    [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:configModel];
}

#pragma mark -- UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
//    tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
//    tracerDic[@"position"] = @"card";
//    tracerDic[@"growth_deepevent"] = @(1);
//    [FHUserTracker writeEvent:@"inform_show" params:tracerDic];
    
    [self showFullPhoneNum:YES];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
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

@end
