//
//  FHRNDebugViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/27.
//

#import "FHRNDebugViewController.h"

#import "TTRNKitBridgeModule.h"
#import "TTRNKitHelper.h"
#import "TTRNKitMacro.h"
#import "TTRNKit.h"
#import <TTBaseLib/TTDeviceHelper.h>
#import <React/RCTRootView.h>
#import <React/RCTBridge.h>

@interface FHRNDebugViewController ()
@property (nonatomic, strong) UITextField *textField,*moduleField;
@property (nonatomic, strong) UIViewController<FHRNDebugViewControllerProtocol> *contentViewController;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) UILabel *address;
@property (nonatomic, assign) BOOL origNavigationBarHidden;
@end

@implementation FHRNDebugViewController
@synthesize manager = _manager;

- (instancetype)initWithContentViewController:(UIViewController<FHRNDebugViewControllerProtocol> *)contentViewController initModuleParams:(NSDictionary *)initModuleParams{
    if (self = [super initWithParams:nil viewWrapper:nil]){
        _contentViewController = contentViewController;
        _params = initModuleParams;
        _origNavigationBarHidden = [contentViewController.navigationController isNavigationBarHidden];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"debug";
    
    _textField = [[UITextField alloc] init];
    _textField.borderStyle = UITextBorderStyleLine;
    _textField.placeholder = @"ip地址";
    _textField.text = @"127.0.0.1:8081";
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    CGRect textFieldFrame = CGRectMake(15, 40 + ([TTDeviceHelper isIPhoneXDevice] ? 88 : 64), [UIScreen mainScreen].bounds.size.width - 30, 40);
    _textField.frame = textFieldFrame;
    [self.view addSubview:_textField];
    
    _address = [[UILabel alloc] init];
    _address.numberOfLines = 0;
    _address.frame = CGRectMake(15, textFieldFrame.origin.y + textFieldFrame.size.height + 20, [UIScreen mainScreen].bounds.size.width - 30, 100);
    [self.view addSubview:_address];
    
    _address.text = [NSString stringWithFormat:@"http://%@/index.bundle?platform=ios",_textField.text];
    
    _moduleField = [[UITextField alloc] init];
    _moduleField.borderStyle = UITextBorderStyleLine;
    _moduleField.placeholder = @"module name";
    _moduleField.text = @"FHRNAgentDetailModule";
    _moduleField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _moduleField.frame = CGRectMake(15, _address.frame.origin.y + _address.frame.size.height + 20, [UIScreen mainScreen].bounds.size.width - 30, 40);
    [self.view addSubview:_moduleField];
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(15, _moduleField.frame.origin.y + _moduleField.frame.size.height,  [UIScreen mainScreen].bounds.size.width - 30, 40);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(onConfirm:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:_origNavigationBarHidden animated:NO];
}

#pragma mark - 远程调试
- (void)onConfirm:(id)sender{
    if (![TTRNKitHelper isEmptyString:_textField.text] && ![TTRNKitHelper isEmptyString:_moduleField.text]){
        [self loadJSbundleAndShowWithIp:nil port:nil moduleName:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ip地址或module为空" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:NO completion:nil];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)loadJSbundleAndShowWithIp:(NSString *)host
                             port:(NSString *)port
                       moduleName:(NSString *)moduleName {
    NSString *hostFormat = @"http://%@/index.bundle?platform=ios";
    NSURL *jsCodeLocation;
    if (host.length && port.length) {
        jsCodeLocation = [NSURL URLWithString:
                          [NSString stringWithFormat:hostFormat,
                           [NSString stringWithFormat:@"%@:%@", host, port]]];
    } else {
        jsCodeLocation = [NSURL URLWithString:[NSString stringWithFormat:hostFormat, _textField.text]];
    }
    NSMutableDictionary *initParams = [NSMutableDictionary dictionaryWithDictionary:_params];
    initParams[RNModuleName] = moduleName ?: _moduleField.text;
    TTRNKitViewWrapper *wrapper = [[TTRNKitViewWrapper alloc] init];
    [self.manager registerObserver:wrapper];
    if (!self.contentViewController) {
        self.contentViewController = [[TTRNKitBaseViewController alloc] initWithParams:@{RNHideBar:@(1)} viewWrapper:wrapper];
    }
    if ([self.contentViewController respondsToSelector:@selector(addViewWrapper:)]) {
        [self.contentViewController addViewWrapper:wrapper];
    } else {
        [self.contentViewController setView:wrapper];
    }
    UIViewController *contentVC = self.contentViewController;
    [self createRNView:initParams bundleURL:jsCodeLocation inWrapper:wrapper];
    [self.navigationController pushViewController:contentVC animated:YES];
    [contentVC.navigationController setNavigationBarHidden:YES animated:NO];
    [contentVC.navigationItem setHidesBackButton:YES];
    
}

- (void)createRNView:(NSDictionary *)initParams bundleURL:(NSURL *)jsCodeLocation inWrapper:(TTRNKitViewWrapper *)wrapper {
    [wrapper reloadDataForDebugWith:initParams
                          bundleURL:jsCodeLocation
                         moduleName:initParams[RNModuleName] ?: @""];
}

- (void)textFieldDidChange:(id)sender {
    _address.text = [NSString stringWithFormat:@"http://%@/index.bundle?platform=ios",_textField.text];
}
@end
