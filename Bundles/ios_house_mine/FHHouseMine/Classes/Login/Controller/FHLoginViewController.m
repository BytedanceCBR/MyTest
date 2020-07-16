//
//  FHLoginViewController.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/2/14.
//

#import "FHLoginViewController.h"
#import "FHLoginView.h"
#import "FHOneKeyLoginView.h"
#import "FHMobileInputView.h"
#import "FHDouYinLoginView.h"
#import "FHLoginViewModel.h"
#import "FHTracerModel.h"
#import "FHUserTracker.h"
#import "TTAccountLoginManager.h"
#import "TTAccountManager.h"
#import "ToastManager.h"

@interface FHLoginViewController ()<TTRouteInitializeProtocol>

@property (nonatomic, strong) FHLoginViewModel *viewModel;
@property (nonatomic ,strong) FHOneKeyLoginView *onekeyLoginView;
@property (nonatomic, strong) FHMobileInputView *mobileInputView;
@property (nonatomic, strong) FHDouYinLoginView *douyinLoginView;
@property (nonatomic, weak) UIView *currentShowView;
@property (nonatomic, strong)     TTAcountFLoginDelegate       *loginDelegate;
@property (nonatomic, assign)   BOOL       needPopVC;
@property (nonatomic, assign)   BOOL       isFromUGC;
@property (nonatomic, assign)   BOOL       present;
@property (nonatomic, assign)   BOOL       isFromMineTab;
@property (nonatomic, weak) UITextField *textField;
@end

@implementation FHLoginViewController

- (void)dealloc
{
    if (self.isFromUGC) {
        // UGC过来的，关闭登录页面后需要同步关注状态
        if (![TTAccountManager isLogin]) {
            if (self.loginDelegate.completeAlert) {
                self.loginDelegate.completeAlert(TTAccountAlertCompletionEventTypeCancel,nil);
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (![TTAccountManager isLogin]) {
                [[ToastManager manager] showToast:@"需要先登录才能进行操作哦"];
            }
        });
    }
}

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        //登录相关埋点均使用的tracerDict
        NSDictionary *params = paramObj.allParams;
        self.needPopVC = YES;
        if (params[@"enter_from"]) {
            self.tracerModel.enterFrom = params[@"enter_from"];
            self.tracerDict[@"enter_from"] = params[@"enter_from"];
        }
        if (params[@"enter_type"]) {
            self.tracerModel.enterType = params[@"enter_type"];
            if (!self.tracerDict[@"enter_method"]) {
                self.tracerDict[@"enter_method"] = params[@"enter_type"];
            }
        }
        if ([params[@"isCheckUGCADUser"] isKindOfClass:[NSNumber class]]) {
            self.isFromMineTab = [params[@"isCheckUGCADUser"] boolValue];
        }else
        {
            self.isFromMineTab = NO;
        }
        if (params[@"delegate"]) {
            NSHashTable *delegate = params[@"delegate"];
            self.loginDelegate = delegate.anyObject;
        }
        // 有部分需求是登录成功之后要跳转其他页面，so，不需要pop当前登录页面，可以延时0.7s之后移除当前页面
        if (params[@"need_pop_vc"]) {
            self.needPopVC = [params[@"need_pop_vc"] boolValue];
        }
        self.isFromUGC = NO;
        if (params[@"from_ugc"]) {
            self.isFromUGC = [params[@"from_ugc"] boolValue];
        }
        
        if (params[@"present"]) {
            self.present = [params[@"present"] boolValue];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initNavbar];
    [self initViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
    if (self.textField && !self.textField.isFirstResponder) {
        [self.textField becomeFirstResponder];
    }
    [self.viewModel viewWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.textField) {
        [self.textField resignFirstResponder];
    }
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        [self.view endEditing:YES];
    }
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"douyin_login_close"] forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"douyin_login_close"] forState:UIControlStateHighlighted];
//    self.customNavBarView.backgroundColor = [UIColor clearColor];
//    self.customNavBarView.seperatorLine.hidden = YES;
    [self.customNavBarView cleanStyle:YES];
    [self.customNavBarView setNaviBarTransparent:YES];
    __weak typeof(self) weakSelf = self;
    [self.customNavBarView setLeftButtonBlock:^{
        [weakSelf cancelLoginAction];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHLoginViewControllerCancelLoginActionNotification" object:nil];
    }];
}

- (void)cancelLoginAction {
    if (self.viewModel && [self.viewModel respondsToSelector:@selector(loginCancelAction)]) {
        [self.viewModel performSelector:@selector(loginCancelAction)];
    }
}

- (void)initViewModel {
    __weak typeof(self) weakSelf = self;
    self.viewModel = [[FHLoginViewModel alloc] initWithController:self];
    self.viewModel.needPopVC = self.needPopVC;
    self.viewModel.present = self.present;
    self.viewModel.isNeedCheckUGCAdUser = self.isFromMineTab;
    self.viewModel.loginDelegate = self.loginDelegate;
    [self.viewModel setLoginViewViewTypeChanged:^(FHLoginViewType type) {
        [weakSelf configureSubviewWithType:type];
    }];
    [self.viewModel startLoadData];
}

- (void)configureSubviewWithType:(FHLoginViewType )type {
    
    switch (type) {
        case FHLoginViewTypeOneKey:
        {
            if (self.currentShowView && self.currentShowView == self.onekeyLoginView) {
                return;
            }
            [self.currentShowView removeFromSuperview];
            if (!self.onekeyLoginView) {
                self.onekeyLoginView = [[FHOneKeyLoginView alloc] init];
                self.onekeyLoginView.delegate = self.viewModel;
            }
            [self.view addSubview:self.onekeyLoginView];
            [self.onekeyLoginView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (@available(iOS 11.0, *)) {
                    make.top.mas_equalTo(self.mas_topLayoutGuide).offset(0);
                    make.bottom.mas_equalTo(self.mas_bottomLayoutGuide);
                } else {
                    make.top.mas_equalTo(24);
                    make.bottom.mas_equalTo(-20);
                }
                make.left.right.equalTo(self.view);
            }];
            self.currentShowView = self.onekeyLoginView;
            [self.onekeyLoginView updateOneKeyLoginWithPhone:self.viewModel.mobileNumber service:[self.viewModel serviceName] protocol:[self.viewModel protocolAttrTextByIsOneKeyLoginViewType:type] showDouyinIcon:[self.viewModel shouldShowDouyinIcon]];
        }
            break;
        case FHLoginViewTypeMobile:
        {
            if (self.currentShowView && self.currentShowView == self.mobileInputView) {
                return;
            }
            [self.currentShowView removeFromSuperview];
            if (!self.mobileInputView) {
                self.mobileInputView = [[FHMobileInputView alloc] init];
                self.mobileInputView.delegate = self.viewModel;
            }
            [self.view addSubview:self.mobileInputView];
            [self.mobileInputView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (@available(iOS 11.0, *)) {
                    make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
                    make.bottom.mas_equalTo(self.mas_bottomLayoutGuide);
                } else {
                    make.top.mas_equalTo(64);
                    make.bottom.mas_equalTo(-20);
                }
                make.left.right.equalTo(self.view);
            }];
            self.currentShowView = self.mobileInputView;
            self.textField = self.mobileInputView.mobileTextField;
            [self.mobileInputView updateProtocol:[self.viewModel protocolAttrTextByIsOneKeyLoginViewType:type] showDouyinIcon:[self.viewModel shouldShowDouyinIcon]];
            [self.textField becomeFirstResponder];
        }
            break;
        case FHLoginViewTypeDouYin:
        {
            if (self.currentShowView && self.currentShowView == self.douyinLoginView) {
                return;
            }
            [self.currentShowView removeFromSuperview];
            if (!self.douyinLoginView) {
                self.douyinLoginView = [[FHDouYinLoginView alloc] init];
                self.douyinLoginView.delegate = self.viewModel;
            }
            [self.view addSubview:self.douyinLoginView];
            [self.douyinLoginView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (@available(iOS 11.0, *)) {
                    make.top.mas_equalTo(self.mas_topLayoutGuide);
                    make.bottom.mas_equalTo(self.mas_bottomLayoutGuide);
                } else {
                    make.top.mas_equalTo(24);
                    make.bottom.mas_equalTo(-20);
                }
                make.left.right.equalTo(self.view);
            }];
            self.currentShowView = self.douyinLoginView;
            [self.douyinLoginView updateProtocol:[self.viewModel protocolAttrTextByIsOneKeyLoginViewType:type]];
        }
            break;
        default:
            break;
    }
    [self.view bringSubviewToFront:self.customNavBarView];
}


- (void)supportCarrierLogin:(void (^)(BOOL))completion {
    if (!completion) {
        return;
    }
    if ([FHLoginSharedModel sharedModel].hasRequestedApis) {
        completion([FHLoginSharedModel sharedModel].isOneKeyLogin);
    } else {
        [[FHLoginSharedModel sharedModel] loadOneKayAndDouyinConfigs:^{
            completion([FHLoginSharedModel sharedModel].isOneKeyLogin);
        }];
    }
}

- (void)showHalfLogin:(UIViewController *)vc {
    self.present = YES;
    [[ToastManager manager] showToast:@"展示半屏登录"];
}
@end
