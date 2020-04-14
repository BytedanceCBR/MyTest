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

@end

@implementation FHLoginContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initNavbar];
    [self setupUI];
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
        }
            break;
        case FHLoginViewTypeVerify:
        {
            FHVerifyCodeInputView *verifyCodeInputView = [[FHVerifyCodeInputView alloc] init];
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
        }
            break;
        default:
            break;
    }
}

@end
