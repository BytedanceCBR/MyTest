//
//  FHWebviewController.m
//  Article
//
//  Created by 张元科 on 2018/11/26.
//

#import "FHWebviewViewController.h"
#import "FHWebviewViewModel.h"
#import <TTRJSBForwarding.h>
#import <TTRStaticPlugin.h>
#import "UIViewController+NavbarItem.h"
#import "TTRoute.h"
#import "TTRWebViewProgressView.h"
#import "SSNavigationBar.h"

@interface FHWebviewViewController ()<TTRouteInitializeProtocol>

@property(nonatomic , strong) FHWebviewViewModel *viewModel;

@end

@implementation FHWebviewViewController

-(void)initNavbar
{
//    UIImage *img = [UIImage imageNamed:@"icon-return"];
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backButton setImage:img forState:UIControlStateNormal];
//    [backButton setImage:img forState:UIControlStateHighlighted];
//    backButton.frame = CGRectMake(0, 0, 44, 44);
//    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
//    UIImage *image = [UIImage imageNamed:@"icon-return"];
//    if (target == nil) {
//        target = self;
//    }
//    if (selector == nil) {
//        selector = @selector(_defaultBackAction);
//    }
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:[SSNavigationBar navigationBackButtonWithTarget:self action:@selector(backAction)]];
    
//    UIBarButtonItem *backItem = [self defaultBackItemWithTarget:self action:@selector(backAction)];
//    backItem.image = img;
    self.navigationItem.leftBarButtonItem = backItem;
    
    UILabel *label = [self defaultTitleView];
    label.text = @"123Title";
    [label sizeToFit];

    self.navigationItem.titleView = label;
}

-(void)backAction
{
    if ([self.webview ttr_canGoBack]) {
        [self.webview ttr_goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super init];
    if (self) {
        TTRouteUserInfo *userInfo = paramObj.userInfo;
        NSString *url = [userInfo.allInfo objectForKey:@"url"];
        NSString *title = [userInfo.allInfo objectForKey:@"title"];
        UILabel *label = self.navigationItem.titleView;
        label.text = title;
        
        NSString *houseId = [userInfo.allInfo objectForKey:@"house_id"];
        
        NSArray *history = [userInfo.allInfo objectForKey:@"history"];
        
        

//        self.url = @"https://www.baidu.com";
        self.url = url;
        self.dic = [NSMutableDictionary dictionary];
        
        [self.dic setObject:@{@"history":history} forKey:@"data"];
        [self.dic setObject:houseId forKey:@"house_id"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (@available(iOS 11.0 , *)) {
        self.webview.ttr_scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        UIEdgeInsets inset = UIEdgeInsetsZero;
        inset.bottom = [[UIApplication sharedApplication] keyWindow].safeAreaInsets.bottom;
        self.webview.ttr_scrollView.contentInset = inset;
    }
    
    self.webview.frame = CGRectMake(0, 44.f + self.view.tt_safeAreaInsets.top, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height - (44.f + self.view.tt_safeAreaInsets.top));
//    if #available(iOS 11.0, *) {
//        tableView.contentInsetAdjustmentBehavior = .never
//    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initNavbar];
    self.viewModel = [[FHWebviewViewModel alloc] initWithViewController:self];
    [self.viewModel registerJSBridge:self.webview.ttr_staticPlugin];

    
    NSURL *u = [NSURL URLWithString:self.url];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:u];
    [self.webview ttr_loadRequest:request];
    
//    TTRWebViewProgressView *progressView = self.progressView;
    
    
   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //    NSData *jdata = [NSJSONSerialization dataWithJSONObject:data options:kNilOptions error:nil];
    NSString *json = [self.dic JSONRepresentation];
    NSLog(@"%@",json);
    //    wself.liveDetectResult = data[@"data"];
    
//    NSString *js = [NSString stringWithFormat:@"requestPageData(%@)",json];
//    
//    [self.webview ttr_evaluateJavaScript:js completionHandler:^(id result, NSError *error) {
//        
//    }];
}

#pragma mark - TTRWebViewDelegate


@end
