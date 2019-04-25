//
//  TTRealnameAuthViewController.m
//  Article
//
//  Created by lizhuoli on 16/12/18.
//
//

#import "TTRealnameAuthViewController.h"
#import "TTRealnameAuthCardCameraViewController.h"
#import "TTRealnameAuthPersonCameraViewController.h"
#import "TTRealnameAuthViewModel.h"
#import "TTRealnameAuthContainerView.h"

#import "TTNavigationController.h"
#import "TTAuthorizeHintView.h"
#import "TTThemedAlertController.h"
#import "TTRealnameAuthMacro.h"

#import "TTRealnameAuthManager.h"

#import "TTIndicatorView.h"
#import "SSNavigationBar.h"
#import "NetworkUtilities.h"


@interface TTRealnameAuthViewController ()

@property (nonatomic, strong) TTRealnameAuthContainerView *containerView;
@property (nonatomic, strong) SSThemedImageView *indicator;
@property (nonatomic, strong) TTRealnameAuthViewModel *viewModel;

@property (nonatomic, assign) BOOL isRootVC;
@property (nonatomic, assign) NSTimeInterval enterTimeInterval;

@end

@implementation TTRealnameAuthViewController

-(void)dealloc
{
    if (_isRootVC) {
        NSTimeInterval endTimeInterval = [[NSDate date] timeIntervalSince1970];
        wrapperTrackEventWithCustomKeys(@"stay_tab", @"shiming", [NSString stringWithFormat:@"%.0f", (endTimeInterval - _enterTimeInterval) * 1000], nil, nil); // 埋点 一级的停留时间
    }
    LOGD(@"%@", @"TTRealnameAuthViewController dealloc");
}

#pragma mark - init Root View Controller
- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.viewModel = [TTRealnameAuthViewModel new];
        [self.viewModel setupRootVC:self];
        [self.viewModel loadInitialAuthStatus];
        // 整个流程进入时间戳
        self.enterTimeInterval = [[NSDate date] timeIntervalSince1970];
        self.isRootVC = YES;
    }
    
    return self;
}

- (instancetype)initWithViewModel:(TTRealnameAuthViewModel *)viewModel
{
    self = [super init];
    if (self) {
        _viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *barTitle = nil;
    switch (self.viewModel.model.state) {
        case TTRealnameAuthStateCardForegroundInfo:
        case TTRealnameAuthStateCardBackgroundInfo:
        case TTRealnameAuthStateCardSubmit:
            barTitle = @"身份认证";
            break;
        case TTRealnameAuthStatePersonAuth:
        case TTRealnameAuthStatePersonSubmit:
            barTitle = @"脸部识别";
            break;
        default:
            barTitle = @"实名认证";
            break;
    }
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle: NSLocalizedString(barTitle, nil)];
    
    if (!self.viewModel) {
        self.viewModel = [TTRealnameAuthViewModel new];
    }
    
    [self setupViewsWithModel:self.viewModel.model];
}

- (void)setupViewsWithModel:(TTRealnameAuthModel *)model
{
    if (self.viewModel.model.state == TTRealnameAuthStateAuthSucess || self.viewModel.model.state == TTRealnameAuthStateAuthed) { // 成功则显示完成，不允许dragToRoot
        self.ttDisableDragBack = YES;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight withTitle:@"完成" target:self action:@selector(finish:)]];
        //        for (UIViewController *vc in self.navigationController.viewControllers) {
        //            if (!vc.ttDragToRoot) { // ttDragToRoot指的是drag到导航栈上第一个未设置ttDragToRoot的VC上
        //                vc.ttDragToRoot = YES;
        //            }
        //        }
    }
    // 网络请求错误处理
    if (self.viewModel.rootVC == self) { // 只有root VC会处理网络错误的情况
        if (!self.viewModel.model.authStatus || self.viewModel.model.authStatusError) {
            if (!TTNetworkConnected()) { // 网络未连接
                self.ttViewType = TTFullScreenErrorViewTypeNetWorkError; // 网络未连接为default页
                [self tt_endUpdataData:NO error:[NSError errorWithDomain:kTTRealnameAuthErrorDomain code:-1 userInfo:nil]];
            } else {
                [self tt_startUpdate]; // 等待Auth接口返回值
            }
        }
    }
    
    self.containerView = [TTRealnameAuthContainerView new];
    [self.view addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.containerView.delegate = self;
    [self.containerView setupContainerViewWithModel:model];
}

- (void)updateViewsWithModel:(TTRealnameAuthModel *)model
{
    if (!self.containerView) {
        [self setupViewsWithModel:model];
    }
    
    switch (model.state) {
        case TTRealnameAuthStateCardForegroundInfo: // 照片更新三种状态
        case TTRealnameAuthStateCardBackgroundInfo: {
            [self.containerView updateContainerViewWithModel:model];
        }
            break;
        case TTRealnameAuthStateCardSubmit: { // 身份证反面提交结果
            [self stopIndicator];
            if (self.viewModel.model.backgroundError) { // 反面错误
                NSString *bgErrorInfo = model.backgroundError.userInfo[@"reason"];
                if (!isEmptyString(bgErrorInfo)) { // 反面错误信息（非空）
                    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:bgErrorInfo message:nil preferredType:TTThemedAlertControllerTypeAlert];
                    [alert addActionWithTitle:NSLocalizedString(@"重新拍摄", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
                    [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
                } else { // 反面识别失败（为空）
                    TTAuthorizeHintView *hintView = [[TTAuthorizeHintView alloc] initAuthorizeHintWithImageName:@"IDcard_defect" title:@"身份信息提取失败" message:@"请重新拍摄身份证正反面并上传" confirmBtnTitle:@"重新拍摄" animated:YES reversed:YES completed:^(TTAuthorizeHintCompleteType type) {
                        if (type == TTAuthorizeHintCompleteTypeDone) {
                            wrapperTrackEvent(@"shiming", @"idretake2"); //第二级入口重拍：(提取失败重新拍摄那个）
                            model.state = TTRealnameAuthStateNotAuth;
                            [self.viewModel setupModel:model withSender:self];
                            [self.navigationController popToViewController:self.viewModel.rootVC animated:YES];
                        }
                    }];
                    [hintView show];
                }
            } else { // 反面成功，正面也成功，继续走流程
                UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self];
                [self.viewModel setupModel:model withSender:self];
                TTRealnameAuthViewController *vc = [[TTRealnameAuthViewController alloc] initWithViewModel:self.viewModel];
                
                [nav pushViewController:vc animated:YES];
            }
        }
            break;
        case TTRealnameAuthStatePersonSubmit: {
            if (self.indicator) { // 从Submitting转换，人像提交失败
                [self stopIndicator];
                if (self.viewModel.model.editInfoFlag) { // 如果有修改身份证和姓名信息，优先提示
                    NSString *errorInfo = self.viewModel.model.submitError.userInfo[@"reason"];
                    errorInfo = isEmptyString(errorInfo) ? @"身份证修改信息上传失败，请重新提交" : errorInfo;
                    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:errorInfo message:nil preferredType:TTThemedAlertControllerTypeAlert];
                    [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
                    [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
                } else {
                    // 人像图上传失败
                    NSString *errorInfo = self.viewModel.model.personError.userInfo[@"reason"];
                    errorInfo = isEmptyString(errorInfo) ? @"人像照上传失败" : errorInfo;
                    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:errorInfo message:nil preferredType:TTThemedAlertControllerTypeAlert];
                    [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
                    [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
                }
            } else { // 重拍人像状态
                [self.containerView updateContainerViewWithModel:model];
            }
        }
            break;
        case TTRealnameAuthStateAuthSucess: { // 人像提交成功，流程结束
            TTRealnameAuthViewController *vc = [[TTRealnameAuthViewController alloc] initWithViewModel:self.viewModel];
            UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self];
            [nav pushViewController:vc animated:YES];
        }
            break;
        case TTRealnameAuthStateNotAuth: { // 点重拍回到首页重新开始流程，避免重复构造
            [self.containerView setupContainerViewWithModel:model];
        }
            break;
        case TTRealnameAuthStateInit: { // 初始化错误，弹出错误页面
            self.ttTargetView = self.containerView;
            self.ttViewType = TTFullScreenErrorViewTypeNetWorkError;
            [self tt_endUpdataData:NO error:[NSError errorWithDomain:kTTRealnameAuthErrorDomain code:1 userInfo:nil]];
        }
            break;
            
        default:
            break;
    }
}

- (void)startButtonTouched:(UIButton *)sender
{
    TTRealnameAuthModel *model = [TTRealnameAuthModel modelWithState:sender.tag];
    switch (sender.tag) {
        case TTRealnameAuthStateNotAuth: { // 回到最开始重新走流程
            [self.viewModel setupModel:model withSender:self];
            
            UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self];
            [nav popToViewController:[self.viewModel rootVC] animated:YES];
        }
            break;
        case TTRealnameAuthStateCardForegroundCamera: {
            //第二级入口点击开始拍照
            wrapperTrackEvent(@"shiming", @"idphoto2");
            [self.viewModel setupModel:model withSender:self];
            TTRealnameAuthCardCameraViewController *vc = [[TTRealnameAuthCardCameraViewController alloc] initWithViewModel:self.viewModel];
            
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
        case TTRealnameAuthStateCardBackgroundCamera: {
            [self.viewModel setupModel:model withSender:self];
            TTRealnameAuthCardCameraViewController *vc = [[TTRealnameAuthCardCameraViewController alloc] initWithViewModel:self.viewModel];
            
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
        case TTRealnameAuthStateCardSubmit: {
            NSString *fgErrorInfo = self.viewModel.model.foregroundError.userInfo[@"reason"];
            
            if (!isEmptyString(self.viewModel.model.name) && !isEmptyString(self.viewModel.model.IDNum) && !self.viewModel.model.foregroundError && !self.viewModel.model.backgroundError) { // 所有流程正常，继续
                [self.viewModel setupModel:model withSender:self];
                TTRealnameAuthViewController *vc = [[TTRealnameAuthViewController alloc] initWithViewModel:self.viewModel];
                
                [self.navigationController pushViewController:vc animated:YES];
                return;
            }
            
            if (!TTNetworkConnected()) {
                [self showToastWithMsg:kTTRealnameAuthErrorNetworkMsg];
                return;
            }
            
            if (!isEmptyString(fgErrorInfo)) { // 正面照上传成功，响应错误（身份证已注册）
                TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:fgErrorInfo message:nil preferredType:TTThemedAlertControllerTypeAlert];
                [alert addActionWithTitle:NSLocalizedString(@"重新拍摄", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                    model.state = TTRealnameAuthStateNotAuth;
                    [self.viewModel setupModel:model withSender:self];
                    [self.navigationController popToViewController:self.viewModel.rootVC animated:YES];
                }];
                [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
                
            } else if (!self.viewModel.model.foregroundError && self.viewModel.model.backgroundError) { // 背面照上传失败（优先处理正面照）
                [self startIndicatorInButton:sender];
                TTRealnameAuthModel *model = [TTRealnameAuthModel modelWithState:TTRealnameAuthStateCardSubmit];
                [self.viewModel setupModel:model withSender:self];
                
            } else { // 正面照片上传失败或者提取失败
                TTAuthorizeHintView *hintView = [[TTAuthorizeHintView alloc] initAuthorizeHintWithImageName:@"IDcard_defect" title:@"身份信息提取失败" message:@"请重新拍摄身份证正反面并上传" confirmBtnTitle:@"重新拍摄" animated:YES reversed:YES completed:^(TTAuthorizeHintCompleteType type) {
                    if (type == TTAuthorizeHintCompleteTypeDone) {
                        wrapperTrackEvent(@"shiming", @"idretake2"); //第二级入口重拍：(提取失败重新拍摄那个）
                        model.state = TTRealnameAuthStateNotAuth;
                        [self.viewModel setupModel:model withSender:self];
                        [self.navigationController popToViewController:self.viewModel.rootVC animated:YES];
                    }
                }];
                [hintView show];
            }
        }
            break;
        case TTRealnameAuthStateCardSubmitting: {
            NSString *name = self.containerView.submitView.name;
            NSString *IDNum = self.containerView.submitView.IDNum;
            
            if (!isEmptyString(name) && !(isEmptyString(IDNum))) {
                //第二级入口点击确认并提交
                wrapperTrackEvent(@"shiming", @"idconfirm2");
                model.name = name;
                model.IDNum = IDNum;
                [self.viewModel setupModel:model withSender:self];
                TTRealnameAuthViewController *vc = [[TTRealnameAuthViewController alloc] initWithViewModel:self.viewModel];
                
                UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self];
                [nav pushViewController:vc animated:YES];
            } else {
                TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"请补全您的身份信息" message:nil preferredType:TTThemedAlertControllerTypeAlert];
                [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
                [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
            }
        }
            break;
        case TTRealnameAuthStatePersonCamera: {
            //第二级入口点击实名的开始识别
            wrapperTrackEvent(@"shiming", @"facerecog2");
            [self.viewModel setupModel:model withSender:self];
            TTRealnameAuthPersonCameraViewController *vc = [[TTRealnameAuthPersonCameraViewController alloc] initWithViewModel:self.viewModel];
            
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
        case TTRealnameAuthStatePersonSubmitting: {
            //第二级入口点击最后一步确认并提交
            wrapperTrackEvent(@"shiming", @"faceconfirm2");
            if (!TTNetworkConnected()) {
                [self showToastWithMsg:kTTRealnameAuthErrorNetworkMsg];
                return;
            }
            [self startIndicatorInButton:sender];
            [self.viewModel setupModel:model withSender:self];
        }
            break;
        default:
            break;
    }
}

- (void)retakeButtonTouched:(UIButton *)sender
{
    TTRealnameAuthModel *model = [TTRealnameAuthModel modelWithState:sender.tag];
    model.dismissFlag = YES;
    switch (sender.tag) {
        case TTRealnameAuthStateCardForegroundCamera: {
            [self.viewModel setupModel:model withSender:self];
            TTRealnameAuthCardCameraViewController *vc = [[TTRealnameAuthCardCameraViewController alloc] initWithViewModel:self.viewModel];
            
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
        case TTRealnameAuthStateCardBackgroundCamera: {
            [self.viewModel setupModel:model withSender:self];
            TTRealnameAuthCardCameraViewController *vc = [[TTRealnameAuthCardCameraViewController alloc] initWithViewModel:self.viewModel];
            
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
        case TTRealnameAuthStatePersonAuth: {
            [self.viewModel setupModel:model withSender:self];
            UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self];
            [nav popViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)showToastWithMsg:(NSString *)msg
{
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:nil autoDismiss:YES dismissHandler:nil];
}

- (void)stopIndicator
{
    if (self.indicator) {
        [self.indicator stopAnimating];
        [self.indicator removeFromSuperview];
        self.indicator = nil;
    }
}



- (void)runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)startAnimatingForView:(UIView *)view
{
    [view.layer removeAllAnimations];
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.duration = 1.0f;
    rotateAnimation.repeatCount = HUGE_VAL;
    rotateAnimation.toValue = @(M_PI * 2);
    [view.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
}

- (void)stopAnimatingForView:(UIView *)view
{
    [view.layer removeAllAnimations];
    [view removeFromSuperview];
    view = nil;
}

- (void)startIndicatorInButton:(UIButton *)button
{
    if (self.indicator) {
        [self stopAnimatingForView:self.indicator];
    }
    
    self.indicator = [[SSThemedImageView alloc] initWithImage:[UIImage themedImageNamed:@"toast_keywords_refresh"]];
    CGFloat halfButtonHeight = button.bounds.size.height / 2;
    CGFloat buttonWidth = button.bounds.size.width;
    CGPoint center = CGPointMake((buttonWidth - button.titleLabel.width) / 2 - self.indicator.width, halfButtonHeight);
    self.indicator.center = center;
    [button addSubview:self.indicator];
    [self startAnimatingForView:self.indicator];
}

- (BOOL)authInfoLegalWithName:(NSString *)name {
    if (!isEmptyString(name)) {
        NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[\\u4e00-\\u9fa5]{1,7}"];
        if ([nameTest evaluateWithObject:name]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)authInfoLegalWithIDNum:(NSString *)IDNum
{
    if (!isEmptyString(IDNum)) {
        NSPredicate *IDNumTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"(^\\d{15}$)|(^\\d{18}$)|(^\\d{17}(\\d|X|x)$)"];
        if ([IDNumTest evaluateWithObject:IDNum]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - TTUserProfileInputViewDelegate delegate
- (void)cancelButtonClicked:(TTUserProfileInputView *)view
{
    
}
- (void)confirmButtonClicked:(TTUserProfileInputView *)view
{
    switch (view.tag) {
        case TTRealnameAuthSubmitTextName: {
            if ([self authInfoLegalWithName:view.textView.text]) {
                self.containerView.submitView.name = view.textView.text;
                if (![view.textView.text isEqualToString:self.viewModel.model.name]) {
                    self.viewModel.model.editInfoFlag = YES;
                }
                self.viewModel.model.name = self.containerView.submitView.name;
            } else {
                TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"姓名必须为中文" message:nil preferredType:TTThemedAlertControllerTypeAlert];
                [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
                [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
            }
        }
            break;
        case TTRealnameAuthSubmitTextIDNum: {
            if ([self authInfoLegalWithIDNum:view.textView.text]) {
                self.containerView.submitView.IDNum = view.textView.text;
                if (![view.textView.text isEqualToString:self.viewModel.model.IDNum]) {
                    self.viewModel.model.editInfoFlag = YES;
                }
                self.viewModel.model.IDNum = self.containerView.submitView.IDNum;
            } else {
                TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"证件号必须为15位或18位身份证号" message:nil preferredType:TTThemedAlertControllerTypeAlert];
                [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
                [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
            }
        }
            break;
        default:
            break;
    }
}

- (void)finishButtonTouched:(id)sender
{
    NSTimeInterval endTimeInterval = [[NSDate date] timeIntervalSince1970];
    wrapperTrackEventWithCustomKeys(@"stay_tab", @"shiming", [NSString stringWithFormat:@"%.0f", (endTimeInterval - self.enterTimeInterval)], nil, nil); // 埋点 一级的停留时间
    TTNavigationController *nav = (TTNavigationController *)[TTUIResponderHelper topNavigationControllerFor:self];
    [nav popToRootViewControllerAnimated:YES];
}

#pragma mark - TTNavigationViewController delegate
- (void)finish:(id)sender
{
    TTNavigationController *nav = (TTNavigationController *)[TTUIResponderHelper topNavigationControllerFor:self];
    [nav popToRootViewControllerAnimated:YES];
}

#pragma mark - UIViewControllerErrorHandler delegate
- (void)refreshData
{
    [self.viewModel loadInitialAuthStatus];
}

- (BOOL)tt_hasValidateData
{
    if (self.viewModel.rootVC == self) {
        return self.viewModel.model.state != TTRealnameAuthStateInit;
    }
    
    return YES;
}

@end
