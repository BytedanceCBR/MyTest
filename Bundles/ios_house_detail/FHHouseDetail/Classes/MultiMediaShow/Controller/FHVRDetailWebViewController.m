//
//  FHVRDetailWebViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/9/27.
//

#import "FHVRDetailWebViewController.h"
#import "BDImageView.h"
#import <TTUIWidget/UIView+Refresh_ErrorHandler.h>
#import "FHCommonDefines.h"
#import <TTBaseLib/TTUIResponderHelper.h>
#import "UIViewController+NavigationBarStyle.h"

@interface FHVRDetailWebViewController ()<TTRouteInitializeProtocol>
@property(nonatomic,strong)BDImageView *maskLoadingView;
@property(nonatomic, retain)SSWebViewContainer * webContainer;
@property(nonatomic, strong)NSURL * requestURL;
@property(nonatomic, assign)BOOL isNeedRemoveMask;

@end

@implementation FHVRDetailWebViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    if (self) {

        NSDictionary *params = paramObj.allParams;
        
        self.webContainer = [[SSWebViewContainer alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, SCREEN_HEIGHT) baseCondition:@{@"use_wk":@(YES)}];
        [_webContainer.ssWebView addDelegate:self];
        [_webContainer hiddenProgressView:YES];
        if (@available(iOS 11.0 , *)) {
            _webContainer.ssWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _webContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _webContainer.ssWebView.opaque = NO;
        _webContainer.ssWebView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
        _webContainer.disableConnectCheck = YES;
        _webContainer.disableEndRefresh = NO;
                
        
        __weak __typeof(self) weakSelf = self;
        [_webContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse completion) {
            weakSelf.isNeedRemoveMask = YES;
           [weakSelf.webContainer tt_endUpdataData];
           [weakSelf.maskLoadingView removeFromSuperview];
            weakSelf.ttDisableDragBack = YES;
        } forMethodName:@"closeLoading"];
        
        
        NSString * urlStr = nil;
        if ([params.allKeys containsObject:@"url"]) {
            urlStr = [params objectForKey:@"url"];
        }
        self.requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        [_webContainer.ssWebView loadRequest:self.requestURL];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:_webContainer];

    // Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:YES];
    
    
    if (self.isNeedRemoveMask) {
        [_webContainer tt_endUpdataData];
        [self.maskLoadingView removeFromSuperview];
    }else
    {
        if (!_maskLoadingView) {
            UIImage *imageData = [UIImage imageNamed:@"fh_vr_loading"];
            _maskLoadingView = [BDImageView new];
            [_maskLoadingView setImage:imageData];
            [_maskLoadingView setFrame:self.view.frame];
            _maskLoadingView.contentMode = UIViewContentModeScaleAspectFill;
            [_maskLoadingView setBackgroundColor:[UIColor redColor]];
            [self.view addSubview:_maskLoadingView];
            [self.view bringSubviewToFront:_maskLoadingView];
        }
    }

    
    [_webContainer.ssWebView ttr_fireEvent:@"show" data:nil];
    [_webContainer.ssWebView ttr_fireEvent:@"preload_open" data:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_webContainer.ssWebView ttr_fireEvent:@"hide" data:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
