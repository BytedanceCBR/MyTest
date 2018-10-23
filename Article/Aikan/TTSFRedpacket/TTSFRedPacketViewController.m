//
//  TTSFRedPacketViewController.m
//  he_uidemo
//
//  Created by chenjiesheng on 2017/11/29.
//  Copyright © 2017年 Bytedance. All rights reserved.
//

#import "TTSFRedPacketViewController.h"
#import "TTSFRedPacketView.h"
#import "TTSponsorModel.h"
#import <TTDialogDirector/TTDialogDirector.h>
#import <UIViewController+NavigationBarStyle.h>
#import <TTDialogDirector.h>
#import "TTSFBubbleTipManager.h"
#import "TTSFRedpacketManager.h"
#import "TTSFRedPacketViewModel.h"
#import "TTSFRedPacketStorage.h"
#import "TTSFActivityHelper.h"
#import <TTFollowManager.h>
#import "TTSFTracker.h"
@interface TTSFRedPacketViewController () <TTRedPacketBaseViewDelegate>

@property (nonatomic, strong)TTSFRedPacketView          *redPacketView;
@property (nonatomic, strong)TTSFRedpacketDetailView    *redPacketDetailView;
@property (nonatomic, assign)BOOL                        transitionAnimationDidFinished;
@property (nonatomic, strong)TTSFRedPacketViewModel     *viewModel;
@property (nonatomic, assign)BOOL                        disableTransition;
@property (nonatomic, copy)RPDetailDismissBlock          dismissBlock;
@property (nonatomic, assign) NSInteger preStatusBarStyle;

@end

@implementation TTSFRedPacketViewController

- (void)dealloc
{
    NSLog(@"self.class deallocated");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithViewModel:(TTSFRedPacketViewModel *)viewModel
{
    return [self initWithViewModel:viewModel disableTransition:NO dismissBlock:nil];
}

- (instancetype)initWithViewModel:(TTSFRedPacketViewModel *)viewModel
                disableTransition:(BOOL)disableTransition
                     dismissBlock:(RPDetailDismissBlock)dismissBlock
{
    self = [super init];
    if (self) {
        self.viewModel = viewModel;
        self.disableTransition = disableTransition;
        self.dismissBlock = dismissBlock;
        self.ttHideNavigationBar = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _preStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    self.redPacketDetailView = [TTSFRedpacketDetailView createDetailViewWithViewType:self.viewModel.viewType withFrame:self.view.bounds];
    self.redPacketDetailView.dismissBlock = self.dismissBlock;
    self.redPacketDetailView.hidden = !self.disableTransition;
    if (!self.disableTransition) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    [self.view addSubview:self.redPacketDetailView];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@(self.viewModel.sponsor.MID != nil) forKey:@"show_follow_button"];
    [dict setValue:self.viewModel.sponsor.mpName forKey:@"sponsor_mp_name"];
    [dict setValue:@"" forKey:@"redpack_id"];
    [dict setValue:@"" forKey:@"redpack_token"];
    
    // 设置红包封皮显示内容
    NSString *iconURL = nil;
    if (self.viewModel.viewType == TTSFRedPacketViewTypeTinyVideo) {
        iconURL = [self.viewModel.senderUserInfo tt_stringValueForKey:@"avatar_url"];
    } else {
        iconURL = self.viewModel.sponsor.icon;
    }
    [dict setValue:iconURL forKey:@"logo"];
    
    NSString *name = nil;
    if (self.viewModel.viewType == TTSFRedPacketViewTypeTinyVideo) {
        name = [self.viewModel.senderUserInfo tt_stringValueForKey:@"name"];
    } else {
        name = self.viewModel.sponsor.name;
    }
    [dict setValue:name forKey:@"name"];
    
    TTSFRedPacketParam *param = [TTSFRedPacketParam paramWithDict:[dict copy]];
    param.type = @(self.viewModel.viewType);
    self.redPacketView = [[TTSFRedPacketView alloc] initWithFrame:self.view.bounds param:param];
    self.redPacketView.hidden = YES;
    self.redPacketView.delegate = self;
    [self.view addSubview:self.redPacketView];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCloseRedPacketNotification) name:@"TTCloseRedPackertNotification" object:nil];
    
    // 从拆红包进来展示弹窗，从我的红包进入直接展示红包详情页
    if (self.disableTransition) {
        [self configRedPacketDetailView];
        [UIApplication sharedApplication].statusBarHidden = NO;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    }
}

- (void)receiveCloseRedPacketNotification
{
    if (self.disableTransition) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [TTDialogDirector dequeueDialog:self.navigationController];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTSFReceivedRedPackageNotification object:self userInfo:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startRedPacketTransformAnimationIfNeed];
    
    if (self.viewModel.viewType == TTSFRedPacketViewTypeMahjongWinner) {
        [TTSFActivityHelper setSFMahjongRewardToastShown];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.redPacketDetailView stopVideoIfNeed];
    [UIApplication sharedApplication].statusBarStyle = _preStatusBarStyle;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.redPacketDetailView startVideoIfNeed];
    if (self.transitionAnimationDidFinished) {
        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    }
}

- (void)startRedPacketTransformAnimationIfNeed {
    if (self.disableTransition || !self.redPacketView.hidden) {
        return;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.redPacketView.hidden = NO;
    self.redPacketView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [CATransaction commit];
    
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.redPacketView.transform = CGAffineTransformMakeScale(1, 1);
                     }
                     completion:nil];
    
    [self.redPacketView playLottieView];
}

#pragma TTRedPacketBaseViewDelegate

- (void)redPacketDidClickCloseButton
{
    // 关闭红包封皮时记一下红包雨token（如果有）
    if (self.viewModel.viewType == TTSFRedPacketViewTypeRain) {
        [TTSFRedPacketStorage saveRedPacketToken:self.viewModel.token];
    } else if (self.viewModel.viewType == TTSFRedPacketViewTypePostTinyVideo) {
        [[TTSFRedpacketManager sharedManager] setHasShownPostTinyRedPacket];
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        self.redPacketView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.navigationController dismissViewControllerAnimated:NO completion:^{
            __strong typeof(self) strongSelf = self;
            if (strongSelf.dismissBlock) {
                strongSelf.dismissBlock();
            }
            [TTDialogDirector dequeueDialog:strongSelf.navigationController];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTTSFReceivedRedPackageNotification object:self userInfo:nil];
        }];
    }];
}

- (void)redPacketDidClickOpenRedPacketButton
{
    TTSFRedpacketManager *manager = [TTSFRedpacketManager sharedManager];
    void (^ShowRPDetailViewBlock)(void) = ^{
        [self.redPacketView stopLoadingAnimation];
        [self configRedPacketDetailView];
        [self.redPacketView startTransitionAnimation];
    };
    
    void (^ShowRPDetailViewFailBlock)(NSString *) = ^ (NSString *errorText) {
        [self.redPacketView stopLoadingAnimation];
        if (!isEmptyString(errorText)) {
            [self.redPacketView refreshWithExeptionTitle:errorText];
        }
    };
    
    [self.redPacketView startLoadingAnimation];
    
//     是否有效勾选了“同时关注”
    BOOL withConcern = self.redPacketView.followSelectedButton.selected && !self.redPacketView.followSelectedButton.hidden;
    
    // 拆红包
    if (self.viewModel.viewType == TTSFRedPacketViewTypeRain) {
        [manager unpackRainRedPacketWithToken:self.viewModel.token withConcern:withConcern completionBlock:^(NSString *token, NSInteger amount, TTSponsorModel *sponsor, NSDictionary *shareInfo, NSDictionary *userInfo) {
            self.viewModel.amount = [NSString stringWithFormat:@"%.2f",amount / 100.0];
            self.viewModel.sponsor = sponsor;
            self.viewModel.shareInfo = [shareInfo copy];
            self.viewModel.token = token;
            
            ShowRPDetailViewBlock();
        } failBlock:^(NSString *errorDesc) {
            ShowRPDetailViewFailBlock(errorDesc);
        }];
    } else if (self.viewModel.viewType == TTSFRedPacketViewTypePostTinyVideo) {
        [manager setHasShownPostTinyRedPacket];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ShowRPDetailViewBlock);
    } else if (self.viewModel.viewType == TTSFRedPacketViewTypeTinyVideo) {
        [manager unpackTinyPacketWithToken:self.viewModel.token completionBlock:^(NSString *token, NSInteger amount, TTSponsorModel *sponsor, NSDictionary *shareInfo, NSDictionary *userInfo) {
            self.viewModel.amount = [NSString stringWithFormat:@"%.2f",amount / 100.0];
            self.viewModel.sponsor = sponsor;
            self.viewModel.shareInfo = [shareInfo copy];
            self.viewModel.senderUserInfo = [userInfo copy];
            self.viewModel.token = token;

            ShowRPDetailViewBlock();
        } failBlock:^(NSString *errorDesc) {
            ShowRPDetailViewFailBlock(errorDesc);
        }];
    } else if (self.viewModel.viewType == TTSFRedPacketViewTypeInviteNewUser) {
        [manager unpackInviteNewUserPacketWithToken:self.viewModel.token completionBlock:^(NSString *token, NSInteger amount, TTSponsorModel *sponsor, NSDictionary *shareInfo, NSDictionary *userInfo) {
            self.viewModel.amount = [NSString stringWithFormat:@"%.2f",amount / 100.0];
            self.viewModel.sponsor = sponsor;
            self.viewModel.shareInfo = [shareInfo copy];
            self.viewModel.token = token;

            ShowRPDetailViewBlock();
        } failBlock:^(NSString *errorDesc) {
            ShowRPDetailViewFailBlock(errorDesc);
        }];
    } else if (self.viewModel.viewType == TTSFRedPacketViewTypeNewbee) {
        [manager unpackNewBeeRedPacketWithType:self.viewModel.newbeeType.integerValue token:self.viewModel.token invitorUserID:self.viewModel.invitorUserID completionBlock:^(NSString *token, NSInteger amount, TTSponsorModel *sponsor, NSDictionary *shareInfo, NSDictionary *userInfo) {
            self.viewModel.amount = [NSString stringWithFormat:@"%.2f",amount / 100.0];
            self.viewModel.sponsor = sponsor;
            self.viewModel.shareInfo = [shareInfo copy];
            self.viewModel.token = token;
            
            ShowRPDetailViewBlock();
        } failBlock:^(NSString *errorDesc) {
            ShowRPDetailViewFailBlock(errorDesc);
        }];
    } else if (self.viewModel.viewType == TTSFRedPacketViewTypeSunshine) {
        [manager unpackSunshineRedPacketWithToken:self.viewModel.token completionBlock:^(NSString *token, NSInteger amount, TTSponsorModel *sponsor, NSDictionary *shareInfo, NSDictionary *userInfo) {
            self.viewModel.amount = [NSString stringWithFormat:@"%.2f",amount / 100.0];
            self.viewModel.sponsor = sponsor;
            self.viewModel.shareInfo = [shareInfo copy];
            self.viewModel.token = token;
            
            ShowRPDetailViewBlock();
        } failBlock:^(NSString *errorDesc) {
            ShowRPDetailViewFailBlock(errorDesc);
        }];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ShowRPDetailViewBlock);
    }
    
//    // 关注赞助商头条号（红包雨在拆接口中处理）
    if (withConcern && self.viewModel.viewType != TTSFRedPacketViewTypeRain && !isEmptyString(self.viewModel.sponsor.MID.stringValue)) {
        [[TTSFRedpacketManager sharedManager] followRedPacketPGCAccountWithMID:self.viewModel.sponsor.MID.stringValue];
    }
}

- (void)sendMoneyGetTrack
{
    TTSFRedpacketManager *manager = [TTSFRedpacketManager sharedManager];
    [TTSFTracker event:@"money_get" eventType:[manager trackEventTypeWithRpViewType:self.viewModel.viewType newbeeType:self.viewModel.newbeeType.integerValue] params:({
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:self.viewModel.amount forKey:@"amount"];
        [dict setValue:self.viewModel.batch forKey:@"section_timestamp"];
        [dict setValue:self.viewModel.sponsor.ID forKey:@"sponsor_id"];
        [dict setValue:self.viewModel.token forKey:@"red_env_token"];
        
        NSString *inviteType = nil;
        if (self.viewModel.viewType == TTSFRedPacketViewTypeInviteNewUser) {
            inviteType = @"old_user";
        } else if (self.viewModel.viewType == TTSFRedPacketViewTypeNewbee) {
            inviteType = @"new_user";
        }
        
        [dict setValue:inviteType forKey:@"invite_type"];
        
        [dict copy];
    })];
}

- (void)redPacketWillStartTransitionAnimation {
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    
    self.redPacketDetailView.hidden = NO;
    self.redPacketDetailView.navBar.hidden = YES;
    self.redPacketDetailView.curveView.hidden = YES;
    self.redPacketDetailView.curveBackView.hidden = YES;
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
    self.redPacketDetailView.curveBackView.hidden = NO;
    [self.redPacketView removeFromSuperview];
    [self.redPacketDetailView redPacketDidFinishTransitionAnimation];
    self.transitionAnimationDidFinished = YES;
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)configRedPacketDetailView
{
    TTSFRedpacketDetailViewModel *detailViewModel = [[TTSFRedpacketDetailViewModel alloc] init];
    detailViewModel.userName = self.viewModel.sponsor.name;
    detailViewModel.money = self.viewModel.amount;
    detailViewModel.sponsor = self.viewModel.sponsor;
    detailViewModel.shareInfo = [self.viewModel.shareInfo copy];
    detailViewModel.senderUserInfo = [self.viewModel.senderUserInfo copy];
    
    [self.redPacketDetailView configWithViewModel:detailViewModel];
    
    [self sendMoneyGetTrack];
}

@end
