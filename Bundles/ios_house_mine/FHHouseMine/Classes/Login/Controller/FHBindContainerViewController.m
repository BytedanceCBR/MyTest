//
//  FHBindContainerViewController.m
//  Pods
//
//  Created by bytedance on 2020/4/22.
//

#import "FHBindContainerViewController.h"
#import "FHLoginViewModel.h"
#import "FHLoginDefine.h"
#import "FHOneKeyBindingView.h"
#import "FHMobileBindingView.h"
#import "FHVerifyCodeInputView.h"

@interface FHBindContainerViewController ()

@property (nonatomic, weak) FHLoginViewModel *viewModel;

@property (nonatomic, assign) FHBindViewType viewType;

@property (nonatomic, weak) UITextField *textField;

@end

@implementation FHBindContainerViewController

- (void)dealloc {
    _viewModel = nil;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if (self = [super initWithRouteParamObj:paramObj]) {
        self.viewModel = paramObj.allParams[@"viewModel"];
        self.viewType = [paramObj.allParams[@"viewType"] integerValue];
//        self.viewType = FHLoginViewTypeVerify;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initNavbar];
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
    if (self.textField) {
        [self.textField becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.textField) {
        [self.textField resignFirstResponder];
    }
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        [self.view endEditing:YES];
    }
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateHighlighted];
    self.customNavBarView.seperatorLine.hidden = YES;
    [self.customNavBarView setLeftButtonBlock:^{
        //弹框提示，并且退出所有绑定页面
    }];
}

- (void)setupUI {
    switch (self.viewType) {
        case FHBindViewTypeOneKey: {
            FHOneKeyBindingView *onekeyBindView = [[FHOneKeyBindingView alloc] init];
            onekeyBindView.delegate = self.viewModel;
            [self.view addSubview:onekeyBindView];
            [onekeyBindView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (@available(iOS 11.0, *)) {
                    make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
                    make.bottom.mas_equalTo(self.mas_bottomLayoutGuide);
                } else {
                    make.top.mas_equalTo(64);
                    make.bottom.mas_equalTo(-20);
                }
                make.left.right.equalTo(self.view);
            }];
            [onekeyBindView updateOneKeyLoginWithPhone:self.viewModel.mobileNumber service:[self.viewModel serviceName] protocol:[self.viewModel protocolAttrTextByIsOneKeyLoginViewType:self.viewType]];
            break;
        }
        case FHBindViewTypeMobile: {
            FHMobileBindingView *mobileInputView = [[FHMobileBindingView alloc] init];
            mobileInputView.delegate = self.viewModel;
            [self.view addSubview:mobileInputView];
            [mobileInputView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (@available(iOS 11.0, *)) {
                    make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
                    make.bottom.mas_equalTo(self.mas_bottomLayoutGuide);
                } else {
                    make.top.mas_equalTo(64);
                    make.bottom.mas_equalTo(-20);
                }
                make.left.right.equalTo(self.view);
            }];
            self.textField = mobileInputView.mobileTextField;
            break;
        }
        case FHBindViewTypeVerify: {
            FHVerifyCodeInputView *verifyCodeInputView = [[FHVerifyCodeInputView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
            verifyCodeInputView.delegate = self.viewModel;
            verifyCodeInputView.isForBindMobile = YES;
            [self.view addSubview:verifyCodeInputView];
            [verifyCodeInputView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (@available(iOS 11.0, *)) {
                    make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
                    make.bottom.mas_equalTo(self.mas_bottomLayoutGuide);
                } else {
                    make.top.mas_equalTo(64);
                    make.bottom.mas_equalTo(-20);
                }
                make.left.right.equalTo(self.view);
            }];
            self.textField = verifyCodeInputView.textFieldArray.firstObject;
            [verifyCodeInputView updateMobileNumber:self.viewModel.mobileNumber];
            
            __weak FHVerifyCodeInputView * weakCodeView = verifyCodeInputView;
            [self.viewModel setUpdateTimeCountDownValue:^(NSInteger secondsValue) {
                [weakCodeView updateTimeCountDownValue:secondsValue];
            }];
            break;
        }
        default:
            break;
    }
}

@end
