//
//  SpringLoginViewController.m
//  FHHouseHome
//
//  Created by 谢思铭 on 2019/12/16.
//

#import "SpringLoginViewController.h"
#import "SpringLoginView.h"
#import "SpringLoginViewModel.h"
#import "FHTracerModel.h"
#import "FHUserTracker.h"
#import "TTAccountLoginManager.h"
#import "TTAccountManager.h"
#import "ToastManager.h"

@interface SpringLoginViewController ()<TTRouteInitializeProtocol>

@property(nonatomic, strong) SpringLoginViewModel *viewModel;
@property(nonatomic ,strong) SpringLoginView *loginView;
@property (nonatomic, strong)     TTAcountFLoginDelegate       *loginDelegate;
@property (nonatomic, assign)   BOOL       needPopVC;
@property (nonatomic, assign)   BOOL       isFromUGC;
@property (nonatomic, assign)   BOOL       present;
@property (nonatomic, assign)   BOOL       isFromMineTab;

@end

@implementation SpringLoginViewController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary *params = paramObj.allParams;
        self.needPopVC = YES;
        self.tracerModel = [[FHTracerModel alloc] init];
        self.tracerModel.enterFrom = params[@"enter_from"];
        self.tracerModel.enterType = params[@"enter_type"];
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
    [self initView];
    [self initConstraints];
    [self initViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear];
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisappear];
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"手机快捷登录";
    self.customNavBarView.title.hidden = YES;
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateHighlighted];
}

- (void)initView {
    self.loginView = [[SpringLoginView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_loginView];
}

- (void)initConstraints {
    [self.loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
        } else {
            make.top.mas_equalTo(64);
        }
        make.left.right.bottom.equalTo(self.view);
    }];
}

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

- (void)initViewModel {
    self.viewModel = [[SpringLoginViewModel alloc] initWithView:self.loginView controller:self];
    self.viewModel.needPopVC = self.needPopVC;
    self.viewModel.present = self.present;
    self.viewModel.isNeedCheckUGCAdUser = self.isFromMineTab;
    self.viewModel.loginDelegate = self.loginDelegate;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        if([change[@"new"] boolValue]){
            [self.view endEditing:YES];
            self.viewModel.isHideKeyBoard = NO;
        }else{
            if(!self.viewModel.noDismissVC){
                self.viewModel.isHideKeyBoard = YES;
            }
        }
    }
}

@end
