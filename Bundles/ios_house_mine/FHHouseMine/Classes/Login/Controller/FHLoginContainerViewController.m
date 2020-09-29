//
//  FHLoginContainerViewController.m
//  Pods
//
//  Created by bytedance on 2020/4/14.
//

#import "FHLoginContainerViewController.h"
#import "FHLoginViewModel.h"
#import "FHLoginDefine.h"
#import "FHOneKeyLoginView.h"
#import "FHVerifyCodeInputView.h"
#import "FHMobileInputView.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import <FHHouseBase/FHTracerModel.h>

@interface FHLoginContainerViewController ()

@property (nonatomic, weak) FHLoginViewModel *viewModel;

@property (nonatomic, assign) FHLoginViewType viewType;

@property (nonatomic, weak) UITextField *textField;

@end

@implementation FHLoginContainerViewController

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
    [self setupNavbar];
//    [self setupDefaultNavBar:YES];
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
    if (self.textField) {
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        [self.view endEditing:YES];
    }
}

- (void)setupNavbar {
    [self setupDefaultNavBar:NO];
    [self.customNavBarView cleanStyle:YES];
    [self.customNavBarView setNaviBarTransparent:YES];
}

- (void)setupUI {
    
    NSString *login_suggest_method = @"";
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    switch (self.viewType) {
        case FHLoginViewTypeOneKey: {
            tracerDict[@"carrier_one_click_show"] = @(1);
            FHOneKeyLoginView *onekeyLoginView = [[FHOneKeyLoginView alloc] init];
            onekeyLoginView.delegate = self.viewModel;
            [self.view addSubview:onekeyLoginView];
            [onekeyLoginView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (@available(iOS 11.0, *)) {
                    make.top.mas_equalTo(self.mas_topLayoutGuide).offset(0);
                    make.bottom.mas_equalTo(self.mas_bottomLayoutGuide);
                } else {
                    make.top.mas_equalTo(24);
                    make.bottom.mas_equalTo(-20);
                }
                make.left.right.equalTo(self.view);
            }];
            [onekeyLoginView updateOneKeyLoginWithPhone:self.viewModel.mobileNumber service:[self.viewModel.class serviceName] protocol:[self.viewModel protocolAttrTextByIsOneKeyLoginViewType:self.viewType] showDouyinIcon:[self.viewModel shouldShowDouyinIcon]];
            if ([self.viewModel shouldShowDouyinIcon]) {
                tracerDict[@"douyin_is_show"] = @(1);
                if (@available(iOS 13.0, *)) {
                    tracerDict[@"apple_is_show"] = @(1);
                }
            }
            break;
        }
        case FHLoginViewTypeMobile: {
            tracerDict[@"phone_show"] = @(1);
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
            self.textField = mobileInputView.mobileTextField;
            [mobileInputView updateProtocol:[self.viewModel protocolAttrTextByIsOneKeyLoginViewType:self.viewType] showDouyinIcon:[self.viewModel shouldShowDouyinIcon]];
            if ([self.viewModel shouldShowDouyinIcon]) {
                tracerDict[@"douyin_is_show"] = @(1);
                if (@available(iOS 13.0, *)) {
                    tracerDict[@"apple_is_show"] = @(1);
                }
            }
            break;
        }
        case FHLoginViewTypeVerify: {
            tracerDict[@"phone_sms_show"] = @(1);
            FHVerifyCodeInputView *verifyCodeInputView = [[FHVerifyCodeInputView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
            verifyCodeInputView.isForBindMobile = NO;
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
            self.textField = verifyCodeInputView.textFieldArray.firstObject;
            [verifyCodeInputView updateMobileNumber:self.viewModel.mobileNumber];
            __weak FHVerifyCodeInputView * weakCodeView = verifyCodeInputView;
            [self.viewModel setUpdateTimeCountDownValue:^(NSInteger secondsValue) {
                [weakCodeView updateTimeCountDownValue:secondsValue];
            }];
            [self.viewModel setClearVerifyCodeWhenError:^{
                [weakCodeView clearTextFieldText];
            }];
            break;
        }
        default:
            break;
    }
    
    [FHLoginTrackHelper loginShow:tracerDict];
}

@end
