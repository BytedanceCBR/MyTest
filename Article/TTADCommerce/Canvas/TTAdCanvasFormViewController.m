//
//  TTAdCanvasFormViewController.m
//  Article
//
//  Created by carl on 2017/11/12.
//

#import "TTAdCanvasFormViewController.h"

#import "TTDeviceHelper.h"
#import "TTKeyboardListener.h"
#import "UIView+Refresh_ErrorHandler.h"
#import <objc/runtime.h>

#define kLoadingViewSize CGSizeMake([TTDeviceUIUtils tt_newPadding:44], [TTDeviceUIUtils tt_newPadding:44])
#define kCancelButtonSize  CGSizeMake([TTDeviceUIUtils tt_newPadding:44], [TTDeviceUIUtils tt_newPadding:44])

@interface TTAdCanvasFormViewController () <YSWebViewDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) SSJSBridgeWebView *webview;
@property (nonatomic, strong) UITapGestureRecognizer *gesture;
@property (nonatomic, assign) TTAdApointFromSource fromSource;
@property (nonatomic, strong) SSThemedButton *cancelButton;
@property (nonatomic, strong) SSThemedImageView *cancelImageView;
@property (nonatomic, strong) TTAdLoadingView *loadingView;
@property (nonatomic, strong) TTAdRetryView *retryView;

@property (nonatomic, assign) BOOL keyBoardShow;
@property (nonatomic, assign) BOOL needCheckFail;
@end

@implementation TTAdCanvasFormViewController

- (void)dealloc {
     [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_webview removeDelegate:self];
    _webview.scrollView.delegate = nil;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.needCheckFail = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildupView];
    [self registerJSBridge];
    [self loadFormWebView];
}

- (void)viewDidAppear:(BOOL)animated {
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
}

- (void)buildupView {
    [self.view setTintColor:[UIColor clearColor]];
    [self.view addSubview:self.webview];
   
    if (@available(iOS 11.0, *)) {
        self.webview.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    self.webview.frame = [self frameforWebView];
   
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelTouched:)];
    [self.view addGestureRecognizer:gesture];
    self.gesture = gesture;
    
    [SSWebViewUtil registerUserAgent:YES];
    
    SSThemedButton *cancelButton = [[SSThemedButton alloc] init];
    [cancelButton setImage:[UIImage imageNamed:@"popup_newclose"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.webview.mas_right);
        make.top.equalTo(self.webview.mas_top);
        make.size.mas_equalTo(kCancelButtonSize);
    }];
    
    self.cancelButton = cancelButton;
    
    self.loadingView = [[TTAdLoadingView alloc] init];
    [self.view addSubview:self.loadingView];
    
    WeakSelf;
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        StrongSelf;
        make.center.equalTo(self.webview);
    }];
    self.loadingView.hidden = YES;
    
    self.retryView = [[TTAdRetryView alloc] initWithBlock:^{
        StrongSelf;
        self.retryView.hidden = YES;
        [self loadFormWebView];
    }];
    [self.view addSubview:self.retryView];
    
    [self.retryView mas_makeConstraints:^(MASConstraintMaker *make) {
        StrongSelf;
        make.center.equalTo(self.webview);
    }];
    self.retryView.hidden = YES;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
}

- (void)closeViewController {
    self.view.backgroundColor = [UIColor clearColor];
    [self.webview endEditing:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:TTAdAppointAlertViewCloseKey object:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)cancelTouched:(id)sender {
    [self closeViewController];
    [self completeWithType:TTAdApointCompleteTypeCloseForm];
}

- (void)completeWithType:(TTAdApointCompleteType)type {
 // TODO Reason
}

- (void)loadFormWebView {
    NSURL *url = [NSURL URLWithString:self.model.formUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    [self.webview loadRequest:request];
}

#pragma mark -- webview delegate

- (BOOL)webView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType {
    if(!TTNetworkConnected()) {
        [self.loadingView stopAnimating];
        self.loadingView.hidden = YES;
        self.retryView.hidden = NO;
        [self.retryView netWorkFail];
        return NO;
    }
    if (self.needCheckFail) {
        NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:self];
        if (connection) {
            self.loadingView.hidden = NO;
            [self.loadingView startAnimating];
            return NO;
        }
    }
    return YES;
}

- (void)evaluateJavaScriptIfNeeded {
    if (![self.model isKindOfClass:[TTAdAppointAlertScriptModel class]]) {
        return;
    }
    if (![self.model.javascriptString isKindOfClass:[NSString class]]) {
        return;
    }
    [self.webview evaluateJavaScriptFromString:self.model.javascriptString completionBlock:^(NSString * _Nullable result, NSError * _Nullable error) {
        
    }];
}

- (void)webViewDidFinishLoad:(YSWebView *)webView {
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
    [self evaluateJavaScriptIfNeeded];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger status = [httpResponse statusCode];
        
        BOOL shuldLoadWeb = YES;
        if (status >= 400) {
            shuldLoadWeb = NO;
            self.needCheckFail = YES;
            [self.loadingView stopAnimating];
            self.loadingView.hidden = YES;
            self.retryView.hidden = NO;
        } else {
            shuldLoadWeb = YES;
        }
        [connection cancel];
        if (shuldLoadWeb) {
            self.needCheckFail = NO;
            [self loadFormWebView];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
    self.retryView.hidden = NO;
    [connection cancel];
}

#pragma mark -

- (CGRect)frameforWebView {
    CGFloat height = CGRectGetHeight(self.view.frame);
    CGFloat webviewWidth = CGRectGetWidth(self.view.frame);
    UIEdgeInsets safeInset = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeInset = self.view.safeAreaInsets;
    }
    CGFloat webviewHeight = height;
    if (self.model.formWidth.doubleValue >= FLT_EPSILON) {
        webviewHeight = webviewWidth * self.model.formHeight.doubleValue / self.model.formWidth.doubleValue + safeInset.bottom;
        webviewHeight = MIN(height, webviewHeight);
    }
    CGFloat y = height  - webviewHeight;
    return CGRectMake(0, y, webviewWidth, webviewHeight);
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    self.webview.frame = [self frameforWebView];
}

#pragma mark  keyboard observer

- (void)keyboardWillShow:(NSNotification *)notification {
    self.keyBoardShow = YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    CGFloat keyboardHeight = [TTKeyboardListener sharedInstance].keyboardHeight;
    CGRect webviewFrame = [self frameforWebView];
    webviewFrame.origin.y = MAX(0, webviewFrame.origin.y - keyboardHeight);
    webviewFrame.size.height = MIN(CGRectGetHeight(self.view.bounds), CGRectGetHeight(webviewFrame) + keyboardHeight);
    self.webview.frame = webviewFrame;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.keyBoardShow = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    self.webview.frame = [self frameforWebView];
    [UIView commitAnimations];
}

- (void)registerJSBridge {
    __weak typeof(self) wself = self;
    [self.webview.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        __strong typeof(self) sself = wself;
        NSNumber *cid = [NSNumber numberWithLongLong:[sself.model.ad_id longLongValue]];
        NSString *adLogExtra = sself.model.log_extra;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:cid forKey:@"cid"];
        [params setValue:adLogExtra forKey:@"log_extra"];
        if (callback) {
            callback(TTRJSBMsgSuccess, params);
        }
    } forMethodName:@"adInfo"];
    
    [self.webview.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        StrongSelf;
        TTAdApointCompleteType submit_result =([result[@"submit_result"] boolValue] == 1)?TTAdApointCompleteTypeSubmitSuccess:TTAdApointCompleteTypeSubmitFail;
        [self closeViewController];
        if (submit_result == TTAdApointCompleteTypeSubmitSuccess) {
            [self completeWithType:submit_result];
        } else if (submit_result == TTAdApointCompleteTypeSubmitFail) {
            [self completeWithType:submit_result];
        }
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"formDialogClose"];
}

- (SSJSBridgeWebView *)webview {
    if (!_webview) {
        SSJSBridgeWebView *webview = [[SSJSBridgeWebView alloc] initWithFrame:CGRectZero disableWKWebView:YES ignoreGlobalSwitchKey:YES];
        webview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        webview.scrollView.showsVerticalScrollIndicator = NO;
        webview.scrollView.delegate = self;
        [webview addDelegate:self];
        _webview = webview;
    }
    return _webview;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation TTAdAppointAlertScriptModel
@end
