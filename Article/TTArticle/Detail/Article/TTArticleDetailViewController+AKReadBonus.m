//
//  TTArticleDetailViewController+AKReadBonus.m
//  Article
//
//  Created by chenjiesheng on 2018/3/12.
//

#define kAKEnableGetBonusDurationArticle               15

#import "AKAwardCoinManager.h"
#import "AKTaskSettingHelper.h"
#import "TTArticleDetailViewController+AKReadBonus.h"

@implementation TTArticleDetailViewController (AKReadBonus)

- (void)ak_createCountDownTimer
{
    if (!self.detailModel.needCheckReadBonus) {
        return;
    }
    self.detailModel.readBonusTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.detailModel.readBonusTimer, DISPATCH_TIME_NOW, 1.f * NSEC_PER_SEC, 0);
    WeakSelf;
    dispatch_source_set_event_handler(self.detailModel.readBonusTimer, ^{
        StrongSelf;
        [self readBonusTimerTrigged];
    });
    [self ak_resumeCountDownTimer];
}

- (void)ak_resumeCountDownTimer
{
    if (!self.detailModel.needCheckReadBonus) {
        return;
    }
    if (!self.detailModel.timmerIsRunning) {
        self.detailModel.timmerIsRunning = YES;
        dispatch_resume(self.detailModel.readBonusTimer);
    }
}

- (void)ak_suspendCountDownTimer
{
    if (!self.detailModel.needCheckReadBonus) {
        return;
    }
    if (self.detailModel.timmerIsRunning) {
        self.detailModel.timmerIsRunning = NO;
        dispatch_suspend(self.detailModel.readBonusTimer);
    }
}

- (void)ak_cancelCountDownTimer
{
    dispatch_source_cancel(self.detailModel.readBonusTimer);
}

- (void)readBonusTimerTrigged
{
    if (!self.detailModel.needCheckReadBonus) {
        return;
    }
    float duration = [self.detailModel.sharedDetailManager currentStayDuration] / 1000;
    if (duration < kAKEnableGetBonusDurationArticle ||
        !self.detailModel.readComplete){
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    if (self.detailModel.fromSource == NewsGoDetailFromSourceAPNS ||
        self.detailModel.fromSource == NewsGoDetailFromSourceAPNSInAppAlert) {
        [dict setValue:@"push" forKey:@"impression_type"];
    }
    NSString *groupID = self.detailModel.article.groupModel.groupID;
    self.detailModel.needCheckReadBonus = NO;
    [AKAwardCoinManager requestReadBounsWithGroupID:groupID withExtraParam:dict completion:^(NSInteger err_no, NSString * err_tip, NSDictionary * dict) {
        if (err_no == 0 && [dict isKindOfClass:[NSDictionary class]]) {
            NSString *content = [dict tt_stringValueForKey:@"content"];
            NSInteger coinNum = [dict tt_integerValueForKey:@"score_amount"];
            [AKAwardCoinManager showAwardCoinTipInView:nil tipType:AKAwardCoinTipTypeArticle coinNum:coinNum title:content];
            [[AKAwardCoinManager shareInstance] setHadReadWithGroupID:groupID];
            [self ak_cancelCountDownTimer];
        }
    }];
}

- (void)ak_readComplete
{
    self.detailModel.readComplete = YES;
}

- (void)ak_checkNeedReadBonus
{
    self.detailModel.needCheckReadBonus =
    [[AKAwardCoinManager shareInstance] checkIfNeedMonitorWithGroupID:self.detailModel.article.groupModel.groupID] &&
    [AKTaskSettingHelper shareInstance].akBenefitEnable &&
    [TTAccount sharedAccount].isLogin;
}
@end
