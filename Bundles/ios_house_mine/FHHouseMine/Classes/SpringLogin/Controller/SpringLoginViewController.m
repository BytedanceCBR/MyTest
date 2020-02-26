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
#import "FHIntroduceManager.h"
#import "UIViewController+Track.h"
#import "FHMinisdkManager.h"

@interface SpringLoginViewController ()<TTRouteInitializeProtocol,TTUIViewControllerTrackProtocol>

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
        
        if(params[@"enter_from"]){
            self.tracerDict[@"enter_from"] = params[@"enter_from"];
        }
        
        self.tracerDict[@"enter_type"] = @"be_null";
        
        self.tracerDict[@"page_type"] = @"festival_version_1";
        
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
    self.ttTrackStayEnable = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor clearColor];
    [self initView];
    [self initConstraints];
    [self initViewModel];
    
    [FHMinisdkManager sharedInstance].isShowing = YES;
    
    if([FHIntroduceManager sharedInstance].isShowing){
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    
    [self addEnterCategoryLog];
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
    
    [self addStayPageLog];
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
    self.viewModel.isNeedCheckUGCAdUser = YES;
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

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self addStayPageLog];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
    
    [self.loginView startAnimation];
}

#pragma mark - 埋点

- (void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = [self.tracerDict mutableCopy];
    tracerDict[@"login_type"] = @"other_login";

    TRACK_EVENT(@"login_page", tracerDict);
}

-(void)addStayPageLog {
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    TRACK_EVENT(@"stay_page", tracerDict);
    
    [self tt_resetStayTime];
}

@end
