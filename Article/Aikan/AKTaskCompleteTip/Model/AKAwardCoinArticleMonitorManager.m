//
//  AKAwardCoinArticleMonitorManager.m
//  Article
//
//  Created by chenjiesheng on 2018/3/30.
//

#import "AKAwardCoinManager.h"
#import "AKTaskSettingHelper.h"
#import "AKAwardCoinArticleMonitorManager.h"

#define kAKEnableGetBonusDurationArticle               15

@interface AKAwardCoinArticleMonitorManager ()
//爱看检测是否需要弹出阅读金币
@property (nonatomic, assign) BOOL needCheckReadBonus;
@property (nonatomic, assign) BOOL readComplete;//阅读完毕
@property (nonatomic, strong, nullable) dispatch_source_t readBonusTimer;
@property (nonatomic, assign) BOOL timmerIsRunning;
@property (nonatomic, assign) NSInteger              readDuration;
@property (nonatomic, assign) NewsGoDetailFromSource fromSource;
@property (nonatomic, copy)   NSString *groupID;
@property (nonatomic, strong) NSDate    *startDate;
@end

@implementation AKAwardCoinArticleMonitorManager

static AKAwardCoinArticleMonitorManager *share_instance = nil;
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share_instance = [[AKAwardCoinArticleMonitorManager alloc] init];
    });
    return share_instance;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self ak_createCountDownTimer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)ak_createCountDownTimer
{
    if (!self.needCheckReadBonus) {
        return;
    }
    self.readBonusTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.readBonusTimer, DISPATCH_TIME_NOW, 1.f * NSEC_PER_SEC, 0);
    WeakSelf;
    dispatch_source_set_event_handler(self.readBonusTimer, ^{
        StrongSelf;
        [self readBonusTimerTrigged];
    });
    [self ak_resumeCountDownTimer];
}

- (void)ak_resumeCountDownTimer
{
    if (!self.needCheckReadBonus) {
        return;
    }
    if (!self.timmerIsRunning) {
        self.timmerIsRunning = YES;
        dispatch_resume(self.readBonusTimer);
    }
}

- (void)ak_suspendCountDownTimer
{
    if (!self.needCheckReadBonus) {
        return;
    }
    if (self.timmerIsRunning) {
        self.timmerIsRunning = NO;
        dispatch_suspend(self.readBonusTimer);
    }
}

- (void)ak_cancelCountDownTimer
{
    dispatch_source_cancel(self.readBonusTimer);
}

- (void)readBonusTimerTrigged
{
    if (!self.needCheckReadBonus) {
        return;
    }
    self.readDuration += 1;
    if (self.readDuration < kAKEnableGetBonusDurationArticle ||
        !self.readComplete){
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    if (self.fromSource == NewsGoDetailFromSourceAPNS ||
        self.fromSource == NewsGoDetailFromSourceAPNSInAppAlert) {
        [dict setValue:@"push" forKey:@"impression_type"];
    }
    NSString *groupID = self.groupID;
    self.needCheckReadBonus = NO;
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

#pragma notification

- (void)applicationEnterBackgroundNotification:(NSNotification *)notification
{
    if (self.needCheckReadBonus) {
        [self ak_suspendCountDownTimer];
    }
}

- (void)applicationEnterForegroundNotification:(NSNotification *)notification
{
    if (self.needCheckReadBonus) {
        [self ak_resumeCountDownTimer];
    }
}

#pragma public Method

- (void)ak_startMonitorIfNeedWithGroupID:(NSString *)groupID
                              fromSource:(NewsGoDetailFromSource)source
{
    self.groupID = groupID;
    self.fromSource = source;
    self.readComplete = NO;
    self.readDuration = 0;
    self.startDate = [[NSDate alloc] init];
    self.needCheckReadBonus =
    [[AKAwardCoinManager shareInstance] checkIfNeedMonitorWithGroupID:groupID] &&
    [AKTaskSettingHelper shareInstance].akBenefitEnable &&
    [TTAccount sharedAccount].isLogin;
    [self ak_createCountDownTimer];
}

+ (instancetype)ak_startMonitorIfNeedWithGroupID:(NSString *)groupID
                                      fromSource:(NewsGoDetailFromSource)source
{
    AKAwardCoinArticleMonitorManager *manager = [[AKAwardCoinArticleMonitorManager alloc] init];
    [manager ak_startMonitorIfNeedWithGroupID:groupID fromSource:source];
    return manager;
}

- (void)ak_readComplete
{
    self.readComplete = YES;
}

@end
