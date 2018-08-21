//
//  TTCertificationConfirmCertificationViewController.m
//  Article
//
//  Created by wangdi on 2017/8/31.
//
//

#import "TTCertificationConfirmCertificationViewController.h"
#import "SSJSBridgeWebView.h"
#import "TTCertificationOperationView.h"

@interface TTCertificationConfirmCertificationViewController ()

@property (nonatomic, strong) SSJSBridgeWebView *webView;
@property (nonatomic, copy) NSString *url;

@end

@implementation TTCertificationConfirmCertificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"爱看认证";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupSubveiw];
    [self themeChanged:nil];
}

- (instancetype)initWithRequestURL:(NSString *)url
{
    if(self =[super init]) {
        _url = url;
    }
    return self;
}

- (void)setupSubveiw
{
    [self.view addSubview:self.webView];
    [self loadRequest];
}

- (SSJSBridgeWebView *)webView
{
    if(!_webView) {
        CGFloat top = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;
        _webView = [[SSJSBridgeWebView alloc] init];
        _webView.disableThemedMask = YES;
        __weak typeof(self) weakSelf = self;
        [_webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse completion) {
            [weakSelf confirmCertification];
        } forMethodName:@"tt_confirm_request_bridge"];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _webView.left = 0;
        _webView.width = self.view.width;
        _webView.top = top;
        _webView.height = self.view.height - top;
    }
    return _webView;
}

- (void)themeChanged:(NSNotification *)notification
{
    if([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
        self.view.backgroundColor = [UIColor whiteColor];
    } else {
        self.view.backgroundColor = [UIColor colorWithHexString:@"#252525"];
    }

}

- (void)confirmCertification
{
    [TTTrackerWrapper eventV3:@"certificate_v_apply_confirm" params:nil];
    if(self.confirmCertificationClickBlock) {
        self.confirmCertificationClickBlock();
    }
}

- (void)dismissSelf
{
    [TTTrackerWrapper eventV3:@"certificate_v_apply_confirm" params:nil];
    [super dismissSelf];
}

- (void)loadRequest
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[TTStringHelper URLWithURLString:self.url]];
    [self.webView loadRequest:request appendBizParams:YES];
}

@end
