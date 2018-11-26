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

@interface FHWebviewViewController ()<TTRouteInitializeProtocol>

@property(nonatomic , strong) FHWebviewViewModel *viewModel;

@end

@implementation FHWebviewViewController

-(void)initNavbar
{
    UIBarButtonItem *backItem = [self defaultBackItemWithTarget:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UILabel *label = [self defaultTitleView];
    label.text = @"测试页面";
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
    
    [self initNavbar];
    self.viewModel = [[FHWebviewViewModel alloc] initWithViewController:self];
    [self.viewModel registerJSBridge:self.webview.ttr_staticPlugin];
    
//    __weak typeof(self) wself = self;
//    self.viewModel.identifyFinishBlock = ^(NSDictionary *info) {
//        if (wself.identifyDoneFinishBlock) {
//            wself.identifyDoneFinishBlock();
//        }
//        [wself.navigationController popViewControllerAnimated:YES];
//    };
    

    
    NSURL *u = [NSURL URLWithString:self.url];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:u];
    [self.webview ttr_loadRequest:request];
    
    
   
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

@end
