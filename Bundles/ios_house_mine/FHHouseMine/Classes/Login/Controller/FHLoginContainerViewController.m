//
//  FHLoginContainerViewController.m
//  Pods
//
//  Created by bytedance on 2020/4/14.
//

#import "FHLoginContainerViewController.h"
#import "FHOneKeyLoginView.h"
#import "FHVerifyCodeInputView.h"
#import "FHMobileInputView.h"

@interface FHLoginContainerViewController ()

@property (nonatomic, weak) FHLoginViewModel *viewModel;

@property (nonatomic, assign) FHLoginViewType viewType;


@property (nonatomic, weak) FHMobileInputView *mobileInputView;

@end

@implementation FHLoginContainerViewController

- (void)dealloc {
    _viewModel = nil;
    [_mobileInputView endEditing:YES];
    _mobileInputView.delegate = nil;
    NSLog(@"FHLoginContainerViewController dealloc");
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.mobileInputView) {
        [self.mobileInputView.mobileTextField becomeFirstResponder];
    }
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateHighlighted];
}

- (void)setupUI {
    switch (self.viewType) {
        case FHLoginViewTypeOneKey:
        {
            FHOneKeyLoginView *onekeyLoginView = [[FHOneKeyLoginView alloc] init];
            onekeyLoginView.delegate = self.viewModel;
            [self.view addSubview:onekeyLoginView];
            [onekeyLoginView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (@available(iOS 11.0, *)) {
                    make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
                    make.bottom.mas_equalTo(self.mas_bottomLayoutGuide);
                } else {
                    make.top.mas_equalTo(64);
                    make.bottom.mas_equalTo(-20);
                }
                make.left.right.equalTo(self.view);
            }];
        }
            break;
        case FHLoginViewTypeMobile:
        {
            FHMobileInputView *mobileInputView = [[FHMobileInputView alloc] init];
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
            self.mobileInputView = mobileInputView;
        }
            break;
        case FHLoginViewTypeVerify:
        {
            FHVerifyCodeInputView *verifyCodeInputView = [[FHVerifyCodeInputView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
            verifyCodeInputView.delegate = self.viewModel;
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
            [verifyCodeInputView updateMobileNumber:self.viewModel.mobileNumber];
            
            __weak FHVerifyCodeInputView * weakCodeView = verifyCodeInputView;
            [self.viewModel setUpdateTimeCountDownValue:^(NSInteger secondsValue) {
                [weakCodeView updateTimeCountDownValue:secondsValue];
            }];
            
        }
            break;
        default:
            break;
    }
}

@end
