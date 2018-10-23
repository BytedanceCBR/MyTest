//
//  TTLiveWebViewVC.m
//  TTLive
//
//  Created by matrixzk on 4/18/16.
//
//

#import "TTLiveWebViewVC.h"

#import "SSJSBridgeWebView.h"

//#import "TTLiveManager.h"
#import "TTLiveMainViewController.h"
#import "TTLiveTabCategoryItem.h"
#import "TTFoldableLayoutDefinitaions.h"
#import "SSWebViewContainer.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeManager.h"

@interface TTLiveWebViewVC () <YSWebViewDelegate, TTFoldableLayoutItemDelegate>
@property (nonatomic, strong) TTLiveTabCategoryItem *channelModel;
@property (nonatomic, strong) SSWebViewContainer *webViewContainer;

@end

@implementation TTLiveWebViewVC
{
    __weak TTLiveMainViewController *_chatroom;
}

//- (void)dealloc
//{
////    LOGD(@">>>>>>> TTLiveWebViewVC dealloc !!!");
//}

- (instancetype)initWithDataSourceModel:(id)model chatroom:(TTLiveMainViewController *)chatroom
{
    self = [super init];
    if (self) {
        if ([model isKindOfClass:[TTLiveTabCategoryItem class]]) {
            _channelModel = (TTLiveTabCategoryItem *)model;
        }
        _chatroom = chatroom;
    }
    return self;
}

- (void)loadView
{
    _webViewContainer = [[SSWebViewContainer alloc] initWithFrame:CGRectZero];
    _webViewContainer.ssWebView.scrollView.contentInset = [_chatroom edgeInsetsOfContentWebScrollView];
    [_webViewContainer.ssWebView addDelegate:self];
    _webViewContainer.ssWebView.scrollView.scrollsToTop = NO;
    _webViewContainer.ssWebView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    _webViewContainer.ssWebView.opaque = NO;
    self.view = _webViewContainer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.webViewContainer.ssWebView.scrollView.scrollsToTop = YES;
    
    [self reloadWebViewIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.webViewContainer.ssWebView.scrollView.scrollsToTop = NO;
}

- (void)reloadWebViewIfNeeded
{
    if (_webViewContainer.ssWebView.request.URL) {
        return;
    }
    
    NSString *URLStr = [NSString stringWithFormat:@"%@%@", _channelModel.categoryUrl, [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight ? @"#night" : @""];
    [_webViewContainer loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLStr]]];
}

- (void)resetWebViewOpaque
{
    // 解决夜间模式初次进入时闪现白色背景色的问题。初始化时置为NO，加载完成置为YES，避免渲染性能问题。
    if (!_webViewContainer.ssWebView.opaque) {
        _webViewContainer.ssWebView.opaque = YES;
    }
}

#pragma mark - YSWebViewDelegate Method

- (void)webViewDidFinishLoad:(YSWebView *)webView
{
    [self resetWebViewOpaque];
}

- (void)webView:(YSWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self resetWebViewOpaque];
}

#pragma mark - TTFoldableLayoutItemDelegate Methods

- (UIScrollView *)tt_foldableDirvenScrollView
{
    return self.webViewContainer.ssWebView.scrollView;
}

@end
