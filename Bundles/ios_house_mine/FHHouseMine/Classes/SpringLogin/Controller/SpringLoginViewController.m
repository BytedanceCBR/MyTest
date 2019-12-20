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
#import <FHIntroduceManager.h>

@interface SpringLoginViewController ()<TTRouteInitializeProtocol>

@property(nonatomic, strong) SpringLoginViewModel *viewModel;
@property(nonatomic ,strong) SpringLoginView *loginView;
@property (nonatomic, strong)     TTAcountFLoginDelegate       *loginDelegate;
@property (nonatomic, assign)   BOOL       needPopVC;
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
    self.view.backgroundColor = [UIColor clearColor];
    [self initView];
    [self initConstraints];
    [self initViewModel];
    
    if([FHIntroduceManager sharedInstance].isShowing){
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
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

- (void)initView {
    self.loginView = [[SpringLoginView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_loginView];
}

- (void)initConstraints {
    [self.loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
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
