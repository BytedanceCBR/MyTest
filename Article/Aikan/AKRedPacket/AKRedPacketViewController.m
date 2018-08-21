//
//  AKRedPacketViewController.m
//  Article
//
//  Created by 冯靖君 on 2018/3/8.
//

#import "AKRedPacketViewController.h"
#import <UIViewController+NavigationBarStyle.h>
#import <TTDialogDirector.h>
#import "AKRedPacketManager.h"

@interface AKRedPacketViewController () <AKRedPacketBaseViewDelegate>

@property (nonatomic, strong) AKRedpacketEnvBaseView *redPacketEnvView;
@property (nonatomic, strong) AKRedPacketDetailBaseView *redPacketDetailView;
@property (nonatomic, strong) AKRedpacketEnvViewModel *viewModel;
@property (nonatomic, copy) RPDetailDismissBlock dismissBlock;
@property (nonatomic, assign) BOOL transitionAnimationDidFinished;
@property (nonatomic, assign) NSInteger preStatusBarStyle;

@end

@implementation AKRedPacketViewController

- (void)dealloc
{
    NSLog(@"self.class deallocated");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithViewModel:(AKRedpacketEnvViewModel *)viewModel
                     dismissBlock:(RPDetailDismissBlock)dismissBlock
{
    self = [super init];
    if (self) {
        self.viewModel = viewModel;
        self.dismissBlock = dismissBlock;
        self.ttHideNavigationBar = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _preStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    self.redPacketDetailView = [[AKRedPacketDetailBaseView alloc] initWithFrame:self.view.bounds];
    self.redPacketDetailView.dismissBlock = self.dismissBlock;
    self.redPacketDetailView.hidden = YES;
    self.navigationItem.leftBarButtonItem = nil;
    [self.view addSubview:self.redPacketDetailView];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"" forKey:@"redpack_id"];
    [dict setValue:@"" forKey:@"redpack_token"];
    
    // 显示红包封皮
    self.redPacketEnvView = [[AKRedpacketEnvBaseView alloc] initWithFrame:self.view.bounds viewModel:self.viewModel];
    self.redPacketEnvView.hidden = YES;
    self.redPacketEnvView.delegate = self;
    [self.view addSubview:self.redPacketEnvView];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCloseRedPacketNotification) name:@"TTCloseRedPackertNotification" object:nil];
}

- (void)receiveCloseRedPacketNotification
{
    [TTDialogDirector dequeueDialog:self.navigationController];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kTTSFReceivedRedPackageNotification object:self userInfo:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startRedPacketTransformAnimationIfNeed];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = _preStatusBarStyle;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.transitionAnimationDidFinished) {
        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    }
}

- (void)startRedPacketTransformAnimationIfNeed {
    if (!self.redPacketEnvView.hidden) {
        return;
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.redPacketEnvView.hidden = NO;
    self.redPacketEnvView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [CATransaction commit];
    
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.redPacketEnvView.transform = CGAffineTransformMakeScale(1, 1);
                     }
                     completion:nil];
}

#pragma TTRedPacketBaseViewDelegate

- (void)redPacketDidClickCloseButton
{
    [UIView animateWithDuration:0.1 animations:^{
        self.redPacketEnvView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.navigationController dismissViewControllerAnimated:NO completion:^{
            __strong typeof(self) strongSelf = self;
            if (strongSelf.dismissBlock) {
                strongSelf.dismissBlock();
            }
            [TTDialogDirector dequeueDialog:strongSelf.navigationController];
//            [[NSNotificationCenter defaultCenter] postNotificationName:kTTSFReceivedRedPackageNotification object:self userInfo:nil];
        }];
    }];
}

- (void)redPacketDidClickOpenRedPacketButton
{
    void (^ShowRPDetailViewBlock)(void) = ^{
//        [self.redPacketEnvView stopLoadingAnimation];
        [self configRedPacketDetailView];
        [self.redPacketEnvView startTransitionAnimation];
    };
    
//    [self.redPacketEnvView startLoadingAnimation];
    
    // 直接进入红包详情页
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ShowRPDetailViewBlock);
}

- (void)redPacketWillStartTransitionAnimation {
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    
    self.redPacketDetailView.hidden = NO;
    self.redPacketDetailView.navBar.hidden = YES;
    self.redPacketDetailView.curveView.hidden = YES;
//    self.redPacketDetailView.curveBackView.hidden = YES;
}

- (void)redPacketDidStartTransitionAnimation {
    CABasicAnimation *transformAnimation = [CABasicAnimation animation];
    transformAnimation.keyPath = @"transform.scale";
    transformAnimation.fromValue = @0.5f;
    transformAnimation.toValue = @1.f;
    transformAnimation.duration = 0.7;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.14 :1 :0.34 :1];
    [self.redPacketDetailView.contentView.layer addAnimation:transformAnimation forKey:nil];
}

- (void)redPacketDidFinishTransitionAnimation {
    self.redPacketDetailView.navBar.hidden = NO;
//    self.redPacketDetailView.curveBackView.hidden = NO;
    [self.redPacketEnvView removeFromSuperview];
//    [self.redPacketDetailView redPacketDidFinishTransitionAnimation];
    self.transitionAnimationDidFinished = YES;
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)configRedPacketDetailView
{
    AKRedPacketDetailBaseViewModel *detailViewModel = [[AKRedPacketDetailBaseViewModel alloc] init];
    detailViewModel.amount = self.viewModel.amount;
    detailViewModel.withdrawMinAmount = [self.viewModel.customDetailInfo tt_integerValueForKey:@"withdraw_min_amount"];
    detailViewModel.inviteBonusAmount = [self.viewModel.customDetailInfo tt_integerValueForKey:@"invite_bonus_amount"];
    detailViewModel.openURL = [self.viewModel.customDetailInfo tt_stringValueForKey:@"invite_page_url"];
    detailViewModel.shareInfo = [self.viewModel.shareInfo copy];
    
    [self.redPacketDetailView configWithViewModel:detailViewModel];
}

@end
