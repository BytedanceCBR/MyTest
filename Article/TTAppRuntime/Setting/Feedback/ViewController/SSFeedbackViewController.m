//
//  SSFeedbackViewController.m
//  Article
//
//  Created by Zhang Leonardo on 13-1-6.
//
//

#import <QuartzCore/QuartzCore.h>
#import "SSFeedbackViewController.h"
#import "SSFeedbackContainerView.h"
//#import "SSControllerViewBase.h"
#import "SSFeedbackManager.h"
#import "SSNavigationBar.h"
#import "TTDeviceHelper.h"
#import "TTDebugRealMonitorManager.h"



@interface SSFeedbackViewController ()

@property(nonatomic, retain)SSFeedbackContainerView * feedbackContainerView;
@property (nonatomic,strong) TTRouteParamObj *paramObj;

@end

@implementation SSFeedbackViewController

- (void)dealloc
{
    self.feedbackContainerView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [SSFeedbackManager updateCurQuestionID:nil];
}

- (id)init
{
    return [self initWithRouteParamObj:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.feedbackContainerView.frame = [self frameForFeedbackView];
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super init];
    if (self) {
        
        self.paramObj = paramObj;
        
        NSString *questionID = [self.paramObj.allParams tt_stringValueForKey:@"question_id"];
        [SSFeedbackManager updateCurQuestionID:questionID];
        
        self.hidesBottomBarWhenPushed = YES;
        self.statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        
    }
    return self;
}

- (void)appDidEnterBackground
{
    [SSFeedbackManager setHasNewFeedback:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 修复iOS7下，photoScrollView 子视图初始化位置不正确的问题
    SSThemedView * baseView = [[SSThemedView alloc] initWithFrame:self.view.bounds];
    baseView.backgroundColorThemeKey = kColorBackground1;
    if ([TTDeviceHelper isPadDevice]) {
        baseView.backgroundColorThemeKey = kColorBackground4;
    }
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:baseView];
    
    CGRect feedbackViewRect = [self frameForFeedbackView];
    self.feedbackContainerView = [[SSFeedbackContainerView alloc] initWithFrame:feedbackViewRect];
    [self.view addSubview:_feedbackContainerView];
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:NSLocalizedString(@"意见反馈", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: [SSNavigationBar navigationBackButtonWithTarget:self action:@selector(back:)]];
    
    
    //统计事件
    [TTTracker eventV3:@"feedback_show" params:self.paramObj.allParams];
    [SSFeedbackManager shareInstance].trackerInfo = self.paramObj.allParams;
        
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   // LOG_ENTERSCREEN(kFeedBackMesageScreen);
    [_feedbackContainerView didAppear];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
   // LOG_LEAVESCREEN(kFeedBackMesageScreen);
    [_feedbackContainerView didDisappear];
    [SSFeedbackManager setHasNewFeedback:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_feedbackContainerView willDisappear];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_feedbackContainerView willAppear];
    [SSFeedbackManager setHasNewFeedback:NO];
}

- (CGRect)frameForFeedbackView
{
    CGRect rect = CGRectZero;
    rect.size.width = CGRectGetWidth(self.view.bounds);
    if ([TTDeviceHelper isPadDevice]) {
        rect = CGRectInset(self.view.bounds, [TTUIResponderHelper paddingForViewWidth:0], 0);

     }
    rect.origin.y = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;
    rect.size.height = CGRectGetHeight(self.view.bounds) - rect.origin.y;

    return rect;
}



#pragma mark -- life cycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark -- button target

- (void)back:(id)sender
{
    UIViewController *topController = [TTUIResponderHelper topViewControllerFor: self];
    if(topController.navigationController)
    {
        if ([topController.navigationController.viewControllers count] == 1) {
            [topController dismissViewControllerAnimated:YES completion:NULL];
        }
        else {
            [topController.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        [topController dismissViewControllerAnimated:YES completion:NULL];
    }
}


@end
