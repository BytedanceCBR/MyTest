//
//  FHLoginViewController.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/2/14.
//

#import "FHLoginViewController.h"
#import "FHLoginView.h"
#import "FHLoginViewModel.h"
#import "FHTracerModel.h"
#import "FHUserTracker.h"
#import "TTAccountLoginManager.h"

@interface FHLoginViewController ()<TTRouteInitializeProtocol>

@property(nonatomic, strong) FHLoginViewModel *viewModel;
@property(nonatomic ,strong) FHLoginView *loginView;
@property (nonatomic, strong)     TTAcountFLoginDelegate       *loginDelegate;
@property (nonatomic, assign)   BOOL       needPopVC;

@end

@implementation FHLoginViewController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary *params = paramObj.allParams;
        self.needPopVC = YES;
        self.tracerModel = [[FHTracerModel alloc] init];
        self.tracerModel.enterFrom = params[@"enter_from"];
        self.tracerModel.enterType = params[@"enter_type"];
        if (params[@"delegate"]) {
            NSHashTable *delegate = params[@"delegate"];
            self.loginDelegate = delegate.anyObject;
        }
        // 有部分需求是登录成功之后要跳转其他页面，so，不需要pop当前登录页面，可以延时0.7s之后移除当前页面
        if (params[@"need_pop_vc"]) {
            self.needPopVC = [params[@"need_pop_vc"] boolValue];
        }
        [self addEnterCategoryLog];
    }
    return self;
}

- (void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = [self.tracerModel logDict];
    TRACK_EVENT(@"login_page", tracerDict);
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
    self.loginView = [[FHLoginView alloc] initWithFrame:self.view.bounds];
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

- (void)initViewModel {
    self.viewModel = [[FHLoginViewModel alloc] initWithView:self.loginView controller:self];
    self.viewModel.needPopVC = self.needPopVC;
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
