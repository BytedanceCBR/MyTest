//
//  ArticleBadgeManager.m
//  Article
//
//  Created by Zhang Leonardo on 13-5-24.
//
//


#import "ArticleBadgeManager.h"
#import <TTAccountBusiness.h>
#import "SSUpdateListNotifyManager.h"
#import "FriendDataManager.h"
#import "SettingView.h"
#import "ExploreSubscribeDataListManager.h"
#import "TTCategoryDefine.h"
#import "TTFollowNotifyServer.h"
#import "TTDeviceHelper.h"
//#import "TTPLManager.h"
#import "TTSettingMineTabManager.h"
#import "TTBadgeTrackerHelper.h"
#import "TTRelationshipDefine.h"

#define fetchUpdateCountTimeInterval 180

#define subscribeHasNewUpdatesTimesInterval (3 * 3600)

#define vTag @"news"

@interface ArticleBadgeManager()
<
FriendDataManagerDelegate,
TTAccountMulticastProtocol
> {
    NSTimeInterval _latelyFetchTimeInterval;//最近一次获取的时间
}
@property(nonatomic, retain, readwrite)NSNumber * settingNewNumber;//设置更新的数字
@property(nonatomic, retain, readwrite)NSNumber * followNumber;//5.5我的关注更新数字
@property(nonatomic, strong, readwrite)NSNumber * messageNotificationNumber;//新版消息通知更新数字
@property(nonatomic, strong, readwrite)NSNumber * privateLetterUnreadNumber;//私信未读数
@property(nonatomic, retain, readwrite)NSNumber * subscribeHasNewUpdatesIndicator;

@property(nonatomic, retain)NSTimer * updateCountFetcheTimer;
@property(nonatomic, retain)FriendDataManager * friendManager;


@end

static ArticleBadgeManager * badgeManager;

@implementation ArticleBadgeManager

+ (ArticleBadgeManager *)shareManger
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        badgeManager = [[ArticleBadgeManager alloc] init];
    });
    return badgeManager;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
    
    [_updateCountFetcheTimer invalidate];
    self.followNumber = nil;
    self.updateCountFetcheTimer = nil;
    self.friendManager = nil;
    self.settingNewNumber = nil;
}


- (id)init
{
    self = [super init];
    if (self) {
        self.followNumber = @(0);
        self.settingNewNumber = @0;
        self.subscribeHasNewUpdatesIndicator = @NO;

    }
    return self;
}

- (void)refreshWithFollowNumber:(NSInteger)followNumber
{
    int originNum = [_followNumber intValue];
    if ( (originNum <= 0 && originNum != -1000) || (originNum == - 1000 && followNumber > 0) ){//magic number: -1000 表示有红点出现，但无具体数字
        self.followNumber = @(followNumber);
    }
    if (originNum != [_followNumber intValue]) {
        [self notify];
    }
}

- (void)clearFollowNumber
{
    BOOL needNotify = NO;
    if ([_followNumber integerValue] == -1000 || [_followNumber intValue] > 0){
        needNotify = YES;
    }
    self.followNumber = @(0);
    if (needNotify) {
        [self notify];
    }
}

- (void)startFetch
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - _latelyFetchTimeInterval < fetchUpdateCountTimeInterval - 10) {
        return;
    }
    _latelyFetchTimeInterval = now;
    
    [self p_commonStartFetch];
}

- (void)forceStartFetch{
    [self p_commonStartFetch];
}

- (void)p_commonStartFetch{
    //    [self startFetchMomentUpdate];
    [self addNotifycationObserver];
    
    self.settingNewNumber = @([SettingView settingNewPointBadgeNumber]);
    [_updateCountFetcheTimer invalidate];
    self.updateCountFetcheTimer = [NSTimer scheduledTimerWithTimeInterval:fetchUpdateCountTimeInterval target:self selector:@selector(fetchUpdateCountPolling) userInfo:nil repeats:YES];
    [self fetchUpdateCount];
    
}

- (void)fetchUpdateCount
{
    [self fetchUpdateCountPolling];

    //v6.2.x 去掉relation/counts信息轮询接口
}

- (void)fetchUpdateCountPolling
{
//    static int times = -1;
//    ++times;
//    if (times % (subscribeHasNewUpdatesTimesInterval / fetchUpdateCountTimeInterval) == 0)
//    {
//        [[ExploreSubscribeDataListManager shareManager] fetchHasNewUpdatesIndicator];
//    }
    
    if (![TTAccountManager isLogin]) {
        return;
    }
    
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    [condition setValue:vTag forKey:kStartGetUpdateCountTag];
    if ([TTDeviceHelper isPadDevice]) {
        [[SSUpdateListNotifyManager shareInstance] startGetUpdateCount:condition];
        
        NSMutableDictionary * userUpdateCondition = [NSMutableDictionary dictionaryWithCapacity:10];
        [userUpdateCondition setValue:vTag forKey:kStartGetUpdateCountTag];
        [SSUpdateListNotifyManager shareInstance];
    }
    
    if (_friendManager == nil) {
        self.friendManager = [[FriendDataManager alloc] init];
        _friendManager.delegate = self;
    }
}

- (void)addNotifycationObserver
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [TTAccount addMulticastDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingViewBadgeMayChanged:) name:kSettingViewWillDisappearNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRelationViewHasGetSuggestFriendCountNotification:) name:kRelationViewSuggestUserViewShowedNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePrivateLetterBadgeChangeNotification:) name:kPrivateLetterGetUnreadNumberFinishNofication object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    });

}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    switch (reasonType) {
        case TTAccountStatusChangedReasonTypeLogout:
        case TTAccountStatusChangedReasonTypeSessionExpiration: {
            //退出登录后 把关注数清空
            self.followNumber = @0;
            
            [self notify];

        }
            break;
        case TTAccountStatusChangedReasonTypeAutoSyncLogin:
        case TTAccountStatusChangedReasonTypeFindPasswordLogin:
        case TTAccountStatusChangedReasonTypePasswordLogin:
        case TTAccountStatusChangedReasonTypeSMSCodeLogin:
        case TTAccountStatusChangedReasonTypeEmailLogin:
        case TTAccountStatusChangedReasonTypeTokenLogin:
        case TTAccountStatusChangedReasonTypeSessionKeyLogin:
        case TTAccountStatusChangedReasonTypeAuthPlatformLogin: {
            [self forceStartFetch];
        }
            break;
    }
}

#pragma mark -- Notification target

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    
}

//- (void)receivePrivateLetterBadgeChangeNotification:(NSNotification *)notification
//{
//    NSUInteger originNum = self.privateLetterUnreadNumber.unsignedIntegerValue;
//    self.privateLetterUnreadNumber = @([[TTPLManager sharedManager] unreadNumber]);
//    if (originNum != self.privateLetterUnreadNumber.unsignedIntegerValue) {
//        [self notify];
//        [[TTSettingMineTabManager sharedInstance_tt] reloadSectionsIfNeeded];
//    }
//}

- (void)handleRelationViewHasGetSuggestFriendCountNotification:(NSNotification *)notification
{
    [self notify];
}

- (void)settingViewBadgeMayChanged:(NSNotification *)notification
{
    NSInteger settingUpdateNumber = [SettingView settingNewPointBadgeNumber];
    
    self.settingNewNumber = @(settingUpdateNumber);
    [self notify];
}

- (void)clearSubscribeHasNewUpdatesIndicator
{
    BOOL needNotify = [self.subscribeHasNewUpdatesIndicator boolValue];
    self.subscribeHasNewUpdatesIndicator = @NO;
    if (needNotify)
    {
        [self notify];
        NSDictionary * userInfo = @{@"categoryID" : kTTSubscribeCategoryID, @"showBadge" : @(NO)};
        [self notifyCategoryBadgeChange:userInfo];
    }
}

- (void)notify
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kArticleBadgeManagerRefreshedNotification object:nil];
    });
}

- (void)notifyCategoryBadgeChange:(NSDictionary *)userInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kCategoryBadgeChangeNotification object:nil userInfo:userInfo];
    });
}

@end
