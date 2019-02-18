//
//  FHLoginViewController.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/2/14.
//

#import "FHLoginViewController.h"
#import "FHLoginView.h"
#import "FHLoginViewModel.h"

@interface FHLoginViewController ()

@property(nonatomic, strong) FHLoginViewModel *viewModel;
@property(nonatomic ,strong) FHLoginView *loginView;

@end

@implementation FHLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        if([change[@"new"] boolValue]){
            [self.view endEditing:YES];
            self.viewModel.isHideKeyBoard = NO;
        }else{
            self.viewModel.isHideKeyBoard = YES;
        }
    }
}

@end
