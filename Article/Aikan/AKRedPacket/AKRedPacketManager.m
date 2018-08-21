//
//  AKRedPacketManager.m
//  Article
//
//  Created by 冯靖君 on 2018/3/8.
//

#import "AKRedPacketManager.h"
#import "AKRedPacketViewController.h"
#import "AKHelper.h"
#import "AKNetworkManager.h"
#import "AKTaskSettingHelper.h"
#import <TTNavigationController.h>
#import <TTDialogDirector.h>

@implementation AKRedPacketManager

static AKRedPacketManager *_instance = nil;

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[AKRedPacketManager alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

#pragma mark - public

NSString * const kAKHasShownNewbeeRedPacketKey = @"kAKHasShownNewbeeRedPacketKey";
NSInteger const kAKNewbeeRedPacketTaskID = 6;
NSInteger const kAKNewbeeRedPacketShareInfoTaskID = 205;

- (void)applyNewbeeRedPacketIgnoreLocalFlag:(BOOL)ignore
{
    // 全局开关
    if (![[AKTaskSettingHelper shareInstance] akBenefitEnable]) {
        return;
    }
    
    // ignore表示必出红包封皮
    if ([self hasShownNewbeeRedPacket] && !ignore) {
        return;
    }
    
    [AKNetworkManager requestForJSONWithPath:@"task/luck_draw/" params:({
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@(kAKNewbeeRedPacketTaskID) forKey:@"task_id"];
        [params copy];
    }) method:@"GET" callback:^(NSInteger err_no, NSString *err_tips, NSDictionary *dataDict) {
        if (err_no == 0 && [dataDict isKindOfClass:[NSDictionary class]]) {
//            "amount": xxx,  // 金额; 单位:分，类型: int
//            "invite_apprentice_cash_amount":  xxx, // 邀请收徒金额; 类型: int
//            "invite_page_url":xxx, // 邀请好友落地页链接。
//            "task_status": 1：用户当天还未领取，2：用户当天已领取，当天不再展示，3，用户之后都不再展示了。
//            "confirm_url": xxx, // 用户领取时请求次url通知服务端。
            
            NSInteger status = [dataDict tt_intValueForKey:@"task_status"];
            if (status == 1) {
                // 展示红包封皮
                NSInteger defaultAmount = 100;
                NSInteger amount = [dataDict tt_intValueForKey:@"amount"];
                if (amount <= 0) {
                    amount = defaultAmount;
                }
                NSInteger withdrawMinAmount = [dataDict tt_intValueForKey:@"invite_apprentice_cash_amount"];
                NSInteger inviteBonusAmount = [dataDict tt_intValueForKey:@"invite_one_apprentice_cash_amount"];
                NSString *invitePageURL = [dataDict tt_stringValueForKey:@"earn_more_url"];
                [self showNewbeeRedPacketWithAmount:amount withdrawMinAmount:withdrawMinAmount inviteBonusAmount:inviteBonusAmount invitePageURL:invitePageURL shareInfo:nil];
//                [[AKShareManager sharedManager] startFetchShareInfoWithTaskID:kAKNewbeeRedPacketShareInfoTaskID completionBlock:^(NSDictionary *shareInfo) {
//                    [self showNewbeeRedPacketWithAmount:amount withdrawMinAmount:withdrawMinAmount inviteBonusAmount:inviteBonusAmount invitePageURL:invitePageURL shareInfo:shareInfo];
//                }];
                
                [self setHasShownNewbeeRedPacket];
            } else {
                // do nothing
            }
        }
    }];
}

- (void)showNewbeeRedPacketWithAmount:(NSInteger)amount
                    withdrawMinAmount:(NSInteger)withdrawMinAmount
                    inviteBonusAmount:(NSInteger)bonusAmount
                        invitePageURL:(NSString *)invitePageURL
                            shareInfo:(NSDictionary *)shareInfo
{
    AKRedpacketEnvViewModel *viewModel = [[AKRedpacketEnvViewModel alloc] initWithAmount:amount detailInfo:({
        NSMutableDictionary *detailInfo = [NSMutableDictionary dictionary];
        [detailInfo setValue:@(withdrawMinAmount) forKey:@"withdraw_min_amount"];
        [detailInfo setValue:@(bonusAmount) forKey:@"invite_bonus_amount"];
        [detailInfo setValue:invitePageURL forKey:@"invite_page_url"];
        [detailInfo copy];
    }) shareInfo:shareInfo];
    [self _showRedPacketWithViewModel:viewModel dismissBlock:nil];
}

- (BOOL)hasShownNewbeeRedPacket
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kAKHasShownNewbeeRedPacketKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:kAKHasShownNewbeeRedPacketKey];
    } else {
        return NO;
    }
}

- (void)setHasShownNewbeeRedPacket
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kAKHasShownNewbeeRedPacketKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSInteger const kAKNewbeeRpHasGotErrorNum = 1025;

- (void)notifyNewbeeRedPacketUserGotWithCompletion:(void (^)(BOOL shouldGot))completionBlock
{
    // 用户领取红包行为告知后端
    NSString *path = [NSString stringWithFormat:@"task/luck_draw_confirm/?task_id=%ld", kAKNewbeeRedPacketTaskID];
    [AKNetworkManager requestForJSONWithPath:path
                                      params:nil
                                      method:@"POST"
                                    callback:^(NSInteger err_no, NSString *err_tips, NSDictionary *dataDict) {
                                        if (err_no == 0) {
                                            LOGD(@"confirm api response succeeded");
                                            if (completionBlock) {
                                                completionBlock(YES);
                                            }
                                        } else if (err_no == kAKNewbeeRpHasGotErrorNum) {
                                            if (completionBlock) {
                                                completionBlock(NO);
                                            }
                                        } else {
                                            LOGD(@"do nothing");
                                        }
    }];
}

#pragma mark - private

- (void)_showRedPacketWithViewModel:(AKRedpacketEnvViewModel *)viewModel
                       dismissBlock:(RPDetailDismissBlock)dismissBlock
{
    AKRedPacketViewController *viewController = [[AKRedPacketViewController alloc] initWithViewModel:viewModel dismissBlock:dismissBlock];
    TTNavigationController *navController = [[TTNavigationController alloc] initWithRootViewController:viewController];
    navController.view.backgroundColor = [UIColor clearColor];
    navController.definesPresentationContext = YES;
    navController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    [TTDialogDirector enqueueShowDialog:navController withPriority:TTDialogPriorityHigh shouldShowMe:nil showMe:^(id  _Nonnull dialogInst) {
        [ak_top_vc() presentViewController:navController animated:NO completion:nil];
    } hideForcedlyMe:^(id  _Nonnull dialogInst) {
        [navController dismissViewControllerAnimated:NO completion:^{
            if (dismissBlock) {
                dismissBlock();
            }
            [TTDialogDirector dequeueDialog:navController];
            
//            [[NSNotificationCenter defaultCenter] postNotificationName:kTTSFReceivedRedPackageNotification object:self userInfo:nil];
        }];
    }];
}

@end
