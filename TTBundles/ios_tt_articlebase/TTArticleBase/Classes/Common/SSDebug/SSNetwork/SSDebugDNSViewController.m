//
//  SSDebugDNSViewController.m
//  Article
//
//  Created by SunJiangting on 15-3-8.
//
//

#if INHOUSE

#import "SSDebugDNSViewController.h"
#import "SSDebugViewController.h"
#import "SSPingServices.h"
#import "MBProgressHUD.h"
#import "TTNetworkHelper.h"

@interface SSDebugDNSViewController ()

@property(nonatomic, strong) UITextField        *textField;
@property(nonatomic, strong) STDebugTextView    *textView;

@end

@implementation SSDebugDNSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"IP 信息";
    if ([UIViewController instancesRespondToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout  = UIRectEdgeNone;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.view.width - 100, 40)];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.placeholder = @"请输入域名";
    self.textField.text = @"www.toutiao.com";
    [self.view addSubview:self.textField];
    
    UIButton *goButton = [UIButton buttonWithType:UIButtonTypeCustom];
    goButton.frame = CGRectMake((self.textField.right) + 10, 10, 60, 40);
    [goButton setTitle:@"Get IP" forState:UIControlStateNormal];
    [goButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [goButton addTarget:self action:@selector(_pingActionFired:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goButton];
    
    self.textView = [[STDebugTextView alloc] initWithFrame:CGRectMake(0, (self.textField.bottom) + 10, self.view.width, self.view.height - (self.textField.bottom) - 20)];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.editable = NO;
    [self.view addSubview:self.textView];
}

- (void)_pingActionFired:(UIButton *)button {
    //    [SimplePingHelper ping:self.textField.text target:self sel:@selector(_pingCallback:)];
    [self.textField resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *IPAddress = [TTNetworkHelper addressOfHost:self.textField.text];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (IPAddress) {
                [self.textView appendText:IPAddress];
            } else {
                [self.textView appendText:@"未获取到IP地址，错无码%ld"];
            }
        });
    });
    
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
