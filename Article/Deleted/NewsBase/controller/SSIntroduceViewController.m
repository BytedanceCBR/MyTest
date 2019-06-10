//
//  SSIntroduceViewController.m
//  Article
//
//  Created by Dianwei on 13-1-28.
//
//

#import "SSIntroduceViewController.h"
#import "UIViewController+NavigationBarStyle.h"
#import "ArticleAddressBridger.h"
#import "TTNavigationController.h"
#import "NewsBaseDelegate.h"
#import "TTDeviceHelper.h"
#import "TTProjectLogicManager.h"
@import ObjectiveC;

@interface SSIntroduceViewController ()
@end

@implementation SSIntroduceViewController

- (void)dealloc
{
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.view.backgroundColor = [UIColor clearColor];
        
   
        self.authorityView = [[NewAuthorityView alloc] initWithFrame:self.view.bounds type:AuthorityViewIntroduce];
        _authorityView.umengEventName = @"guide";
        _authorityView.showLoginIndicator = YES;
        _authorityView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_authorityView];
        
        
        // for the strange behavior below ios 4.3
        if (![SSCommonLogic shouldUseOptimisedLaunch]) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }
        
        self.ttHideNavigationBar = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_authorityView didDisappear];
    [[TTGuideDispatchManager sharedInstance_tt] removeGuideViewItem:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_authorityView didAppear];
}

- (void) setCompletion:(ArticleMobilePiplineCompletion)completion {
    _authorityView.completion = completion;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_authorityView willAppear];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if([TTDeviceHelper isPadDevice])
    {
        return  UIInterfaceOrientationMaskAll;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if([TTDeviceHelper isPadDevice])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark -- TTGuideProtocol Method

- (BOOL)shouldDisplay:(id)context {
    return YES;
}

- (void)showWithContext:(__kindof NewsBaseDelegate *)context {
    if ([context isKindOfClass:[NewsBaseDelegate class]]) {
        NSString * className = TTLogicString(@"IntroduceViewController", @"SSIntroduceViewController");
        Class cls = NSClassFromString(className);
        if (!cls) {
            cls = [SSIntroduceViewController class];
        }
        self.completion = ^(ArticleLoginState state) {
            [[ArticleAddressBridger sharedBridger] setPresentingController:[TTUIResponderHelper topViewControllerFor:context]];
            [[ArticleAddressBridger sharedBridger] tryShowGetAddressBookAlertWithMobileLoginState:state];
        };
        /// 这里这么写是因为 登录逻辑中包含页面之间的push。
        TTNavigationController * navigationController = [[TTNavigationController alloc] initWithRootViewController:self];
        navigationController.ttDefaultNavBarStyle = @"White";
        [context.appTopNavigationController presentViewController:navigationController animated:NO completion:nil];
    }
}

- (id)context {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setContext:(id)context {
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
