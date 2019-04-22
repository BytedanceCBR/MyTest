//
//  SSDebugPingViewController.m
//  Article
//
//  Created by SunJiangting on 15-3-8.
//
//

#if INHOUSE

#import "SSDebugPingViewController.h"
#import "SSDebugViewController.h"
#import "SSPingServices.h"

@interface SSDebugPingViewController ()

@property(nonatomic, strong) UITextField        *textField;
@property(nonatomic, strong) STDebugTextView    *textView;
@property(nonatomic, strong) SSPingServices     *pingServices;

@end

@implementation SSDebugPingViewController

- (void)dealloc {
    [self.pingServices cancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Ping网络";
    if ([UIViewController instancesRespondToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout  = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.view.width - 100, 40)];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.placeholder = @"请输入IP地址或者域名";
    self.textField.text = @"www.toutiao.com";
    [self.view addSubview:self.textField];
    
    UIButton *goButton = [UIButton buttonWithType:UIButtonTypeCustom];
    goButton.frame = CGRectMake((self.textField.right) + 10, 10, 60, 40);
    [goButton setTitle:@"Ping" forState:UIControlStateNormal];
    [goButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [goButton addTarget:self action:@selector(_pingActionFired:) forControlEvents:UIControlEventTouchUpInside];
    goButton.tag = 10001;
    [self.view addSubview:goButton];
    
    self.textView = [[STDebugTextView alloc] initWithFrame:CGRectMake(0, (self.textField.bottom) + 10, self.view.width, self.view.height - (self.textField.bottom) - 20)];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.editable = NO;
    [self.view addSubview:self.textView];
}

- (void)_pingActionFired:(UIButton *)button {
//    [SimplePingHelper ping:self.textField.text target:self sel:@selector(_pingCallback:)];
    [self.textField resignFirstResponder];
    if (button.tag == 10001) {
        __weak SSDebugPingViewController *weakSelf = self;
        [button setTitle:@"Stop" forState:UIControlStateNormal];
        button.tag = 10002;
        self.pingServices = [SSPingServices startPingAddress:self.textField.text callbackHandler:^(SSPingItem *pingItem, NSArray *pingItems) {
            if (pingItem.status != SSPingStatusFinished) {
                [weakSelf.textView appendText:pingItem.description];
            } else {
                [weakSelf.textView appendText:[SSPingItem statisticsWithPingItems:pingItems]];
                [button setTitle:@"Ping" forState:UIControlStateNormal];
                button.tag = 10001;
                weakSelf.pingServices = nil;
            }
        }];
    } else {
        [self.pingServices cancel];
    }
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
#endif
