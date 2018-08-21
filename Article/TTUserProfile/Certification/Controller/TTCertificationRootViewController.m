//
//  TTCertificationRootViewController.m
//  Article
//
//  Created by wangdi on 2017/5/16.
//
//

#import "TTCertificationRootViewController.h"
#import "TTCertificationBaseInfoViewController.h"
#import "TTCertificationConditionViewController.h"
#import "TTCertificationManager.h"
#import <TTAccountBusiness.h>
#import "TTAccountBindingViewController.h"
#import "TTOccupationalCertificationViewController.h"
#import "TTCertificationChooseIndustryViewController.h"
#import "TTCertificationSuccessViewController.h"
#import "TTCertificationFailureViewController.h"
#import "TTCertificationInReviewViewController.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "TTNavigationController.h"
#import "TTRoute.h"

#import "UIViewController+Refresh_ErrorHandler.h"
#import "TTThemedAlertController.h"
#import "TTIndicatorView.h"
#import "NetworkUtilities.h"
#import "TTBaseMacro.h"
#import "TTCertificationConfirmCertificationViewController.h"
#import "TTVerifyIconHelper.h"
#import "SSWebViewController.h"
#import "TTCertificationConst.h"
#import "TTUGCPermissionService.h"
#import "TTPostThreadViewController.h"
#import "TTCustomAnimationNavigationController.h"
#import <TTCategoryDefine.h>
#import "TTUGCDefine.h"
#import "TTCertificationConst.h"

@interface TTCertificationRootViewController ()
<
TTCertificationConditionViewControllerDelegate,
UIViewControllerErrorHandler,
TTAccountMulticastProtocol
>

@property (nonatomic, strong) NSMutableDictionary *router;
@property (nonatomic, strong) TTGetCertificationResponseModel *responeModel;
@property (nonatomic, strong) NSArray *editModels;
@property (nonatomic, strong) NSArray *occupationalEditModels;
@property (nonatomic, strong) TTCertificationEditModel *supplementEditModel;
@property (nonatomic, weak) UIViewController *currentVC;
@property (nonatomic, assign) BOOL isChooseIndustry;
@property (nonatomic, assign) BOOL hasValidateData;

@end

@implementation TTCertificationRootViewController


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[TTCertificationEditViewMetaDataManager sharedInstance] clearAllData];
    [TTAccount removeMulticastDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[TTCertificationEditViewMetaDataManager sharedInstance] updateModelHeight];
    [self themeChanged:nil];
    self.title = @"爱看认证";
    
    [TTAccount addMulticastDelegate:self];
    self.hasValidateData = NO;
    [self tt_startUpdate];
    [self loadInfoData];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoQuestionViewController:)
                                                 name:kCertificationPressQuestionsEntranceNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadPostNotification:) name:kTTForumPostThreadSuccessNotification object:nil];
}

- (BOOL)tt_hasValidateData
{
    return self.hasValidateData;
}

- (void)refreshData
{
    [self loadInfoData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.isChooseIndustry) {
        TTCertificationEditModel *editModel = [[TTCertificationEditViewMetaDataManager sharedInstance] editModelWithType:TTCertificationEditModelTypeIndustry];
        if(isEmptyString(editModel.content)) {
            [self updateIndustryInfoWithText:nil];
        }
    }
    self.isChooseIndustry = NO;
}

- (NSMutableDictionary *)router
{
    if(!_router) {
        _router = [NSMutableDictionary dictionary];
        TTCertificationConditionViewController *condition = [[TTCertificationConditionViewController alloc] init];
        condition.delegate = self;
        _router[NSStringFromClass([TTCertificationConditionViewController class])] = condition;
        TTCertificationBaseInfoViewController *info = [[TTCertificationBaseInfoViewController alloc] init];
        __weak typeof(self) weakSelf = self;
        __weak typeof(info) weakInfo = info;
        info.opreationViewClickBlock = ^{
            TTOccupationalCertificationViewController *occupational = [[TTOccupationalCertificationViewController alloc] init];
            occupational.questionUrl = weakSelf.responeModel.data.faq_url;
            occupational.images = [weakInfo images];
            [weakSelf.navigationController pushViewController:occupational  animated:YES];
            occupational.occupationalEditModels = weakSelf.occupationalEditModels;
            occupational.supplementModel = weakSelf.supplementEditModel;
            occupational.authType = weakSelf.responeModel.data.user_auth_data.verify_type;
        };
        _router[NSStringFromClass([TTCertificationBaseInfoViewController class])] = info;
        
        TTOccupationalCertificationViewController *occupation = [[TTOccupationalCertificationViewController alloc] init];
        _router[NSStringFromClass([TTOccupationalCertificationViewController class])] = occupation;
        TTCertificationSuccessViewController *success = [[TTCertificationSuccessViewController alloc] init];
        success.operationViewClick = ^(BOOL isModify) {
            if(isModify) {
                [weakSelf setupModifyCertification];
            } else {
                [weakSelf setupCancelCertification];
            }
        };
        success.certificationGetVClick = ^{
            [weakSelf setupGetVCertification];
        };
        _router[NSStringFromClass([TTCertificationSuccessViewController class])] = success;
        TTCertificationFailureViewController *failure = [[TTCertificationFailureViewController alloc] init];
        _router[NSStringFromClass([TTCertificationFailureViewController class])] = failure;
        failure.operationViewClickBlock = ^{
            [TTTrackerWrapper eventV3:@"certificate_reapply" params:nil];
            weakSelf.responeModel.data.user_auth_data.status = @(0);
            [weakSelf setupSkip];
        };
        TTCertificationInReviewViewController *inReview = [[TTCertificationInReviewViewController alloc] init];
        _router[NSStringFromClass([TTCertificationInReviewViewController class])] = inReview;
    }
    return _router;
}

- (void)gotoQuestionViewController:(NSNotification *)notification {
    if (!isEmptyString(self.responeModel.data.faq_url)) {
        [SSWebViewController openWebViewForNSURL:[NSURL URLWithString:self.responeModel.data.faq_url] title:@"常见问题" navigationController:self.navigationController supportRotate:NO];
    }
}

- (NSArray *)editModels
{
    if(!_editModels) {
        TTCertificationEditModel *realNameModel = [[TTCertificationEditViewMetaDataManager sharedInstance] editModelWithType:TTCertificationEditModelTypeRealName];
        realNameModel.content = self.responeModel.data.user_auth_data.real_name;
        TTCertificationEditModel *idNameModel = [[TTCertificationEditViewMetaDataManager sharedInstance] editModelWithType:TTCertificationEditModelTypeIdNumber];
        idNameModel.content = self.responeModel.data.user_auth_data.id_number;
        TTCertificationEditModel *industryModel = [[TTCertificationEditViewMetaDataManager sharedInstance] editModelWithType:TTCertificationEditModelTypeIndustry];
        industryModel.content = self.responeModel.data.user_auth_data.auth_class_2;
        __weak typeof(self) weakSelf = self;
        industryModel.arrowBlock = ^{
            weakSelf.isChooseIndustry = YES;
            TTCertificationBaseInfoViewController *infoVC = weakSelf.router[NSStringFromClass([TTCertificationBaseInfoViewController class])];
            [infoVC.editView endEditing:YES];
            
            TTCertificationChooseIndustryViewController *chooseIndustry = [[TTCertificationChooseIndustryViewController alloc] init];
            chooseIndustry.chooseIndustryBlock = ^(NSString *text) {
                [weakSelf updateIndustryInfoWithText:text];
            };
            chooseIndustry.dataArray = weakSelf.responeModel.data.industry;
            [weakSelf.navigationController pushViewController:chooseIndustry animated:YES];
        };
        _editModels = @[realNameModel,idNameModel,industryModel];
        
    }
    return _editModels;
}


- (NSArray *)occupationalEditModels
{
    if(!_occupationalEditModels) {
        TTCertificationEditModel *unitModel = [[TTCertificationEditViewMetaDataManager sharedInstance] editModelWithType:TTCertificationEditModelTypeUnit];
        unitModel.content = self.responeModel.data.user_auth_data.company;
        
        TTCertificationEditModel *occupationalModel = [[TTCertificationEditViewMetaDataManager sharedInstance] editModelWithType:TTCertificationEditModelTypeOccupational];
        occupationalModel.content = self.responeModel.data.user_auth_data.profession;
        _occupationalEditModels = @[unitModel,occupationalModel];
    }
    return _occupationalEditModels;
}

- (TTCertificationEditModel *)supplementEditModel {
    if (!_supplementEditModel) {
        _supplementEditModel = [[TTCertificationEditViewMetaDataManager sharedInstance] editModelWithType:TTCertificationEditModelTypeSupplement];
        _supplementEditModel.content = self.responeModel.data.user_auth_data.extra.additional;
    }
    return _supplementEditModel;
}

- (void)loadInfoData
{
    [[TTCertificationManager sharedInstance] getCertificationInfoWithCompletion:^(NSError *error, TTGetCertificationResponseModel *responseModel) {
        if(!error) {
            if([responseModel isKindOfClass:[TTGetCertificationResponseModel class]]) {
                self.hasValidateData = YES;
                self.responeModel = responseModel;
                [self setupInfoData];
                [self tt_endUpdataData:NO error:error];
            } else {
                NSString *msg = @"加载失败，点击重新加载";
                [self tt_endUpdataData:NO error:error tip:msg tipTouchBlock:nil];
            }
        } else {
            NSString *msg = nil;
            if(TTNetworkConnected()) {
                msg = @"加载失败，点击重新加载";
                self.ttViewType = TTFullScreenErrorViewTypeLocationServiceDisabled;
            } else {
                msg = @"网络不给力，点击屏幕重试";
                self.ttViewType = TTFullScreenErrorViewTypeNetWorkError;
            }
            [self tt_endUpdataData:NO error:error tip:msg tipTouchBlock:nil];
        }
    }];
}

- (void)setupInfoData
{
    NSArray *array = nil;
    BOOL infoIsCompletion = [self checkInfoIsCompletion:&array];
    if(!infoIsCompletion) {
        TTCertificationConditionViewController *conditionVC = self.router[NSStringFromClass([TTCertificationConditionViewController class])];
        conditionVC.dataArray = array;
        [self changeControllerViewWithController:conditionVC];
    } else {
        [self setupSkip];
    }
}


- (void)setupGetVCertification
{
    if(self.responeModel.data.audit_info.can_modify_auth_info.integerValue == 0) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"本月已申请2次，请下个月再试" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:nil message:@"一个自然月内只可申请加v 2次，是否申请？" preferredType:TTThemedAlertControllerTypeAlert];
    __weak typeof(self) weakSelf = self;
    [alert addActionWithTitle:@"否" actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
    [alert addActionWithTitle:@"是" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        TTCertificationConfirmCertificationViewController *confirmCertification = [[TTCertificationConfirmCertificationViewController alloc] initWithRequestURL:self.responeModel.data.agreement_url];
        confirmCertification.confirmCertificationClickBlock = ^{
            [weakSelf setupConfirmCertification];
        };
        [self.navigationController pushViewController:confirmCertification animated:YES];
    }];
    [alert showFrom:self animated:YES];
}

- (void)setupConfirmCertification
{
    TTOccupationalCertificationViewController *occupationVC = [[TTOccupationalCertificationViewController alloc] init];
    occupationVC.isCertificationV = YES;
    [self.navigationController pushViewController:occupationVC animated:YES];
    for (NSInteger counter = 0; counter < self.occupationalEditModels.count; ++counter) {
        TTCertificationEditModel *editModel = self.occupationalEditModels[counter];
        if (counter == 0) {
            editModel.content = self.responeModel.data.user_auth_data.company;
        } else if (counter == 1) {
            editModel.content = self.responeModel.data.user_auth_data.profession;
        } else {
            break;
        }
    }
    occupationVC.supplementModel = self.supplementEditModel;
    occupationVC.occupationalEditModels = self.occupationalEditModels;
    occupationVC.authType = self.responeModel.data.user_auth_data.verify_type;
    occupationVC.isCertificationV = YES;
    [self clearData];
}

- (void)setupModifyCertification
{
    if(self.responeModel.data.audit_info.can_modify_auth_info.integerValue == 0) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"一个自然月内已修改2次，请下个月再试" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:nil message:@"一个自然月内只可修改2次，是否修改？" preferredType:TTThemedAlertControllerTypeAlert];
    [alert addActionWithTitle:@"否" actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
    [alert addActionWithTitle:@"是" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
        TTOccupationalCertificationViewController *occupationVC = [[TTOccupationalCertificationViewController alloc] init];
        occupationVC.questionUrl = self.responeModel.data.faq_url;
        [self.navigationController pushViewController:occupationVC animated:YES];
        occupationVC.occupationalEditModels = self.occupationalEditModels;
        occupationVC.supplementModel = self.supplementEditModel;
        if (![self.responeModel.data.user_auth_data.verify_type isEqualToString:KTTVerifyNoVVerifyType]) {
            occupationVC.authType = self.responeModel.data.user_auth_data.verify_type;
        }
        occupationVC.isModify = YES;
    }];
    [alert showFrom:self animated:YES];
}

- (void)setupCancelCertification
{
    if(!TTNetworkConnected()) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"网络异常" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        return;
    }
    UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self.view];
    nav.view.userInteractionEnabled = NO;
    TTIndicatorView *indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView indicatorText:@"正在加载..." indicatorImage:nil dismissHandler:nil];
    indicatorView.autoDismiss = NO;
    [indicatorView showFromParentView:self.view];
    [[TTCertificationManager sharedInstance] cancelCertificationWithCompletion:^(NSError *error, TTCancelCertificationResponseModel *responseModel) {
        nav.view.userInteractionEnabled = YES;
        [indicatorView dismissFromParentView];
        if(!error) {
            [self clearData];
            [self setupSkip];
        } else {
            NSString *desc = error.userInfo[@"description"];
            if(!isEmptyString(desc)) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:desc indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            }
            
            NSMutableDictionary *extra = [NSMutableDictionary dictionary];
            if(!isEmptyString(error.description)) {
                [extra setObject:error.description forKey:@"error_description"];
            }
            [extra setObject:@(error.code) forKey:@"error_code"];
            [[TTMonitor shareManager] trackService:@"certification_native_cancel" status:1 extra:extra];
        }
    }];
}

- (void)clearData
{
    self.editModels = nil;
    self.occupationalEditModels = nil;
    self.supplementEditModel = nil;
    self.responeModel.data.user_auth_data.status = nil;
    self.responeModel.data.user_auth_data.auth_class_2 = nil;
    self.responeModel.data.user_auth_data.uid = nil;
    self.responeModel.data.user_auth_data.id_number = nil;
    self.responeModel.data.user_auth_data.company = nil;
    self.responeModel.data.user_auth_data.profession = nil;
    self.responeModel.data.user_auth_data.real_name = nil;
    self.responeModel.data.user_auth_data.source = nil;
    self.responeModel.data.user_auth_data.extra = nil;
}

- (void)setupSkip
{
    BOOL hasShownFail = [[NSUserDefaults standardUserDefaults] boolForKey:kCertificaitonHasBeenRejectedKey];
    if(self.responeModel.data.user_auth_data.status.integerValue == 1 || self.responeModel.data.user_auth_data.status.integerValue == 5) { //审核中
        TTCertificationInReviewViewController *inReviewVC = self.router[NSStringFromClass([TTCertificationInReviewViewController class])];
        [self changeControllerViewWithController:inReviewVC];
        inReviewVC.timeLabel.text = self.responeModel.data.auditing_show_info;
        inReviewVC.descLabel.text = @"申请提交成功，审核中";
        if (self.responeModel.data.user_auth_data.status.integerValue == 1 ) {
            inReviewVC.iconView.imageName = @"Information_passing";
        } else {
            inReviewVC.iconView.imageName = @"v_Information_passing";//申请V
        }
    } else if(self.responeModel.data.user_auth_data.status.integerValue == 2) { //审核成功
        if(self.responeModel.data.audit_info.is_auditing.integerValue == 1) {//用户修改认证后的审核中
            TTCertificationInReviewViewController *inReviewVC = self.router[NSStringFromClass([TTCertificationInReviewViewController class])];
            [self changeControllerViewWithController:inReviewVC];
            inReviewVC.timeLabel.text = self.responeModel.data.auditing_show_info;
            inReviewVC.descLabel.text = @"申请提交成功，审核中";
            inReviewVC.iconView.imageName = @"v_Information_passing";
        } else {
            TTCertificationSuccessViewController *successVC = self.router[NSStringFromClass([TTCertificationSuccessViewController class])];
            NSMutableString *string = [NSMutableString string];
            if(!isEmptyString(self.responeModel.data.user_auth_data.company)) {
                [string appendString:self.responeModel.data.user_auth_data.company];
            }
            if(!isEmptyString(self.responeModel.data.user_auth_data.profession)) {
                if (!isEmptyString(string)) {
                    [string appendString:self.responeModel.data.user_auth_data.profession];
                } else {
                    [string appendString:self.responeModel.data.user_auth_data.profession];
                }
            }
            [self changeControllerViewWithController:successVC];
            successVC.occupationalText = string;
            successVC.authType = self.responeModel.data.user_auth_data.verify_type;
            if([self.responeModel.data.user_auth_data.verify_type isEqualToString:KTTVerifyNoVVerifyType]) {
                successVC.isCertificationV = NO;
                successVC.certificationText = @"当前为爱看认证用户";
            } else {
                successVC.isCertificationV = YES;
                successVC.certificationText = @"当前为加V认证用户";
            }
            successVC.certificationResultText = @"认证预览";
            successVC.certificationTipText = self.responeModel.data.upgrade_vtag;
        }
    } else if(self.responeModel.data.user_auth_data.status.integerValue == 3 && !hasShownFail) { //审核失败
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCertificaitonHasBeenRejectedKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        TTCertificationFailureViewController *failureVC = self.router[NSStringFromClass([TTCertificationFailureViewController class])];
        [self changeControllerViewWithController:failureVC];
        failureVC.descLabel.text = @"审核不通过";
        failureVC.iconView.imageName = @"Information_notpass";
        if(!isEmptyString(self.responeModel.data.user_auth_data.extra.reason)) {
            failureVC.timeLabel.text = [NSString stringWithFormat:@"原因:%@",self.responeModel.data.user_auth_data.extra.reason];
            failureVC.timeLabel.height = [TTDeviceUIUtils tt_newPadding:17];
        } else {
            failureVC.timeLabel.text = nil;
            failureVC.timeLabel.height = 0;
        }
        failureVC.emailText = self.responeModel.data.audit_not_pass_info;
    } else if(self.responeModel.data.user_auth_data.status.integerValue == 0 || hasShownFail) { //未申请
        if(self.responeModel.data.is_pgc.integerValue == 1) { //是头条号，直接跳过第一步
            TTOccupationalCertificationViewController *occupationVC = self.router[NSStringFromClass([TTOccupationalCertificationViewController class])];
            [self changeControllerViewWithController:occupationVC];
            occupationVC.occupationalEditModels = self.occupationalEditModels;
            occupationVC.supplementModel = self.supplementEditModel;
            occupationVC.authType = self.responeModel.data.user_auth_data.verify_type;
        } else { //不是头条号,跳到第一步
            TTCertificationBaseInfoViewController *infoVC = self.router[NSStringFromClass([TTCertificationBaseInfoViewController class])];
            [self changeControllerViewWithController:infoVC];
            infoVC.editModels = self.editModels;
        }
    }
    
    [self setupBackGesture];
}

- (void)setupBackGesture
{
    TTCertificationBaseInfoViewController *infoVC = self.router[NSStringFromClass([TTCertificationBaseInfoViewController class])];
    TTOccupationalCertificationViewController *occupationVC = self.router[NSStringFromClass([TTOccupationalCertificationViewController class])];
    if(self.currentVC == infoVC || self.currentVC == occupationVC) {
        self.ttDisableDragBack = YES;
    } else {
        self.ttDisableDragBack = NO;
    }
}

- (void)updateIndustryInfoWithText:(NSString *)text
{
    TTCertificationEditModel *editModel = nil;
    for(TTCertificationEditModel *model in self.editModels) {
        if(model.type == TTCertificationEditModelTypeIndustry) {
            editModel = model;
            break;
        }
    }
    editModel.content = text;
    TTCertificationBaseInfoViewController *infoVC = self.router[NSStringFromClass([TTCertificationBaseInfoViewController class])];
    [infoVC.editView updateEidtModel:editModel];
}

- (void)changeControllerViewWithController:(UIViewController *)controller
{
    [self.currentVC.view removeFromSuperview];
    [self.view insertSubview:controller.view atIndex:0];
    controller.view.frame = self.view.bounds;
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.currentVC = controller;
}

- (BOOL)checkInfoIsCompletion:(NSArray *__autoreleasing *)array
{
    BOOL isCompletion = YES;
    TTCertificationConditionModel *iconModel = [[TTCertificationConditionModel alloc] init];
    iconModel.type = TTCertificationConditionTypeIcon;
    iconModel.iconName = @"authentication_avatar_icon";
    iconModel.titleText = @"有清晰的头像";
    iconModel.regexText = @"请更换头像";
    
    TTCertificationConditionModel *userNameModel = [[TTCertificationConditionModel alloc] init];
    userNameModel.iconName = @"authentication_username_icon";
    userNameModel.type = TTCertificationConditionTypeUserName;
    userNameModel.titleText = @"合法的用户名";
    userNameModel.regexText = @"请修改用户名";

    TTCertificationConditionModel *phoneModel = [[TTCertificationConditionModel alloc] init];
    phoneModel.type = TTCertificationConditionTypeBindPhone;
    phoneModel.iconName = @"authentication_bindphone_icon";
    phoneModel.titleText = @"绑定手机";
    phoneModel.regexText = @"先绑定有效手机号";
    
    TTCertificationConditionModel *weitoutiaoModel = [[TTCertificationConditionModel alloc] init];
    weitoutiaoModel.type = TTCertificationConditionTypeWeitoutiao;
    weitoutiaoModel.iconName = @"authentication_wtoutiao_icon";
    weitoutiaoModel.titleText = @"发布过微头条内容";
    weitoutiaoModel.regexText = @"最少发布1条微头条";
    
    TTCertificationConditionModel *fanCountModel = [[TTCertificationConditionModel alloc] init];
    fanCountModel.type = TTCertificationConditionTypeAvailableFanCount;
    fanCountModel.iconName = @"certification_fan_count";
    NSInteger needCount = self.responeModel.data.need_fans.integerValue > 0 ? self.responeModel.data.need_fans.integerValue : 10;
    fanCountModel.titleText = [NSString stringWithFormat:@"粉丝数≥%zd人",needCount];
    if(![self isVUser]) {
        *array = @[iconModel,userNameModel,phoneModel,weitoutiaoModel,fanCountModel];
    } else {
        *array = @[iconModel,userNameModel,phoneModel,weitoutiaoModel];
    }
    
    if([self isMatchWithText:[TTAccountManager avatarURLString] regexText:kIconRegex]) {
        isCompletion = NO;
        iconModel.isCompletion = NO;
    } else {
        iconModel.isCompletion = YES;
    }
    if([self isMatchWithText:[TTAccountManager userName] regexText:kUserNameRegex]) {
        isCompletion = NO;
        userNameModel.isCompletion = NO;
    } else {
        userNameModel.isCompletion = YES;
    }
    if(isEmptyString([TTAccountManager currentUser].mobile)) {
        isCompletion = NO;
        phoneModel.isCompletion = NO;
    } else {
        phoneModel.isCompletion = YES;
    }
    if (self.responeModel.data.has_post_ugc.boolValue) {
        weitoutiaoModel.isCompletion = YES;
    } else {
        isCompletion = NO;
        weitoutiaoModel.isCompletion = NO;
    }
    if(![self isVUser]) {
        NSInteger defaultNeedCount = self.responeModel.data.need_fans.integerValue > 0 ? self.responeModel.data.need_fans.integerValue : 10;
        NSInteger needFanCount = defaultNeedCount - self.responeModel.data.fans_count.integerValue;
        if(needFanCount > 0) {
            isCompletion = NO;
            fanCountModel.isCompletion = NO;
            fanCountModel.regexText = [NSString stringWithFormat:@"还需粉丝%zd人",needFanCount];
        } else {
            fanCountModel.isCompletion = YES;
        }
    }
    return isCompletion;
}

- (BOOL)isVUser
{
    return [self.responeModel.data.user_auth_data.verify_type isEqualToString:kTTVerifyVerifyType] || [self.responeModel.data.user_auth_data.verify_type isEqualToString:kTTVerifyStarVerifyType] || [self.responeModel.data.user_auth_data.verify_type isEqualToString:KTTVerifyBlueVerifyType];
}

- (BOOL)isMatchWithText:(NSString *)text regexText:(NSString *)regexText
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexText];
    return [pred evaluateWithObject:text];
}

#pragma mark - TTAccountMulticastProtocal

- (void)onAccountUserProfileChanged:(NSDictionary *)changedFields error:(NSError *)error
{
    BOOL bUserName   = [[changedFields objectForKey:@(TTAccountUserProfileTypeUserName)] boolValue];
    BOOL bUserAvatar = [[changedFields objectForKey:@(TTAccountUserProfileTypeUserAvatar)] boolValue];
    BOOL bMobile = [[changedFields objectForKey:@(TTAccountUserProfileTypeUserPhone)] boolValue];
    
    if (bUserName) {
        [self userNameChangeNotification];
    }
    
    if (bUserAvatar) {
        [self userAvatarChangeNotification];
    }
    
    if (bMobile) {
        [self phoneNumberChangeNotification];
    }
}

- (void)userNameChangeNotification
{
    if(![self.currentVC isKindOfClass:[TTCertificationConditionViewController class]]) return;
    NSArray *array = nil;
    BOOL isCompletion = [self checkInfoIsCompletion:&array];
    if(isCompletion) {
        [self setupSkip];
    } else {
        TTCertificationConditionViewController *conditionVC = self.router[NSStringFromClass([TTCertificationConditionViewController class])];
        conditionVC.dataArray = array;
    }
}

- (void)userAvatarChangeNotification
{
    if(![self.currentVC isKindOfClass:[TTCertificationConditionViewController class]]) return;
    NSArray *array = nil;
    BOOL isCompletion = [self checkInfoIsCompletion:&array];
    if(isCompletion) {
        [self setupSkip];
    } else {
        TTCertificationConditionViewController *conditionVC = self.router[NSStringFromClass([TTCertificationConditionViewController class])];
        if(self.currentVC != conditionVC) return;
        conditionVC.dataArray = array;
    }
}

- (void)phoneNumberChangeNotification
{
    if(![self.currentVC isKindOfClass:[TTCertificationConditionViewController class]]) return;
    NSArray *array = nil;
    BOOL isCompletion = [self checkInfoIsCompletion:&array];
    if(isCompletion) {
        [self setupSkip];
    } else {
        TTCertificationConditionViewController *conditionVC = self.router[NSStringFromClass([TTCertificationConditionViewController class])];
        if(self.currentVC != conditionVC) return;
        conditionVC.dataArray = array;
    }
}

- (void)threadPostNotification:(NSNotification *)notification
{

    if (![[notification.userInfo tt_stringValueForKey:kTTForumPostThreadConcernID] isEqualToString:kTTWeitoutiaoConcernID]) {
        return;
    }
    
    if(![self.currentVC isKindOfClass:[TTCertificationConditionViewController class]]) return;
    self.responeModel.data.has_post_ugc = @(YES);
    NSArray *array = nil;
    BOOL isCompletion = [self checkInfoIsCompletion:&array];
    if(isCompletion) {
        [self setupSkip];
    } else {
        TTCertificationConditionViewController *conditionVC = self.router[NSStringFromClass([TTCertificationConditionViewController class])];
        conditionVC.dataArray = array;
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    if([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
        self.view.backgroundColor = [UIColor whiteColor];
    } else {
        self.view.backgroundColor = [UIColor colorWithHexString:@"#252525"];
    }
}

- (void)dismissSelf
{
    if(![self needShowAlert]) {
        [super dismissSelf];
    }
}

- (BOOL)needShowAlert
{
    BOOL needAlert = NO;
    if([self.currentVC isKindOfClass:[TTCertificationBaseInfoViewController class]]) {
        TTCertificationBaseInfoViewController *infoVC = self.router[NSStringFromClass([TTCertificationBaseInfoViewController class])];
        if([infoVC hasEditInfo]) {
            needAlert = YES;
        }
    } else if([self.currentVC isKindOfClass:[TTOccupationalCertificationViewController class]]) {
        TTOccupationalCertificationViewController *occupationalVC = self.router[NSStringFromClass([TTOccupationalCertificationViewController class])];
        if([occupationalVC hasEditInfo]) {
            needAlert = YES;
        }
    }
    
    if(needAlert) {
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否退出当前流程?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        //        alert.tag = 100;
        //        [alert show];
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:nil message:@"是否退出当前流程?" preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:@"否" actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [alert addActionWithTitle:@"是" actionType:TTThemedAlertActionTypeNormal  actionBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert showFrom:self animated:YES];
    }
    return needAlert;
}

#pragma mark - TTCertificationConditionViewController 代理
- (void)didSelectedWithType:(TTCertificationConditionType)type
{
    if(type == TTCertificationConditionTypeIcon || type == TTCertificationConditionTypeUserName) {
        NSURL *url = [NSURL URLWithString:@"sslocal://account_manager?"];
        [[TTRoute sharedRoute] openURLByPushViewController:url];
    } else if (type == TTCertificationConditionTypeWeitoutiao) {
        NSUInteger postEditStatus = [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) postUGCShowEtStatus];
        NSString * postHint = [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) postUGCHint];
        NSMutableDictionary * baseConditionParams = [NSMutableDictionary dictionary];
        [baseConditionParams setValue:@(postEditStatus) forKey:@"show_et_status"];
        [baseConditionParams setValue:postHint forKey:@"post_content_hint"];
        [baseConditionParams setValue:kTTWeitoutiaoCategoryID forKey:@"category_id"];
        [baseConditionParams setValue:kTTWeitoutiaoConcernID forKey:@"cid"];
        [baseConditionParams setValue:@(1) forKey:@"refer"];
        [baseConditionParams setValue:@"weitoutiao_tab_publisher" forKey:@"source"];
        [baseConditionParams setValue:@"weitoutiao_publisher" forKey:@"enter_type"];
        [baseConditionParams setValue:@(YES) forKey:@"notification_certification"];
        [baseConditionParams setValue:[TTAccountManager mediaID] forKey:@"mid"];
        TTPostThreadViewController *postThreadVC = [[TTPostThreadViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(baseConditionParams.copy)];
        TTCustomAnimationNavigationController *nav = [[TTCustomAnimationNavigationController alloc] initWithRootViewController:postThreadVC animationStyle:TTCustomAnimationStyleUGCPostEntrance];
        nav.ttDefaultNavBarStyle = @"White";
        
        [[TTUIResponderHelper topmostViewController] presentViewController:nav
                                                                  animated:YES
                                                                completion:nil];
    } else if (type == TTCertificationConditionTypeAvailableFanCount) {
        return;
    } else {
        TTAccountBindingViewController *vc = [[TTAccountBindingViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
