//
//  TTPLManager.m
//  Article
//
//  Created by 杨心雨 on 2017/1/18.
//
//

#import "TTPLManager.h"
#import "TTIMMsgExt.h"
#import "TTIMSDKService.h"
#import "TTIMChatCenterViewModel.h"
#import "ArticleMessageManager.h"
#import <TTAccountBusiness.h>
#import "TTSettingMineTabManager.h"
#import "TTIMManager.h"
#import "TTBlockManager.h"
#import "TTUserServices.h"
#import "TTUserData.h"


NSString * const kPrivateLetterGetUnreadNumberFinishNofication = @"kPrivateLetterGetUnreadNumberFinishNofication";

@interface TTPLManager () <TTIMMsgExt, TTAccountMulticastProtocol>
@property (nonatomic, strong) NSMutableDictionary *drafts;
@property (nonatomic, assign) BOOL hadInitIMService;
@property (nonatomic, assign) BOOL isIMServiceEnable;
@end


@implementation TTPLManager

+ (instancetype)sharedManager {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TTPLManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _hasShowTip = [[NSUserDefaults standardUserDefaults] boolForKey:@"TTIMChatHasShowNoticeView"];
        _needShowTip = NO;
        _unreadNumber = 0;
        _hadInitIMService = NO;
        _isIMServiceEnable = [SSCommonLogic isIMServerEnable];
        
        [TTAccount addMulticastDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveBlockUnblockedNotification:) name:kHasBlockedUnblockedUserNotification object:nil];
        
        if ([TTAccountManager isLogin]) {
            [self setupIMService];
        }
    }
    return self;
}

- (void)dealloc
{
    [[TTIMSDKService sharedInstance] unRegisterSession:@"" listener:self.chatCenterViewModel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (void)setupIMService
{
    if (![SSCommonLogic isIMServerEnable]) return;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.chatCenterViewModel = [TTIMChatCenterViewModel new];
        [[TTIMSDKService sharedInstance] registerSession:@"" listener:self.chatCenterViewModel];
    });
    
    [[TTIMManager sharedManager] loginIMService];
    self.hadInitIMService = YES;
    [self refreshChatCenterModel];
}

- (void)logoutIMService
{
    [[TTIMManager sharedManager] logoutIMService];
    self.hadInitIMService = NO;
    
    [self clearAllData];
}

- (void)resetIMServerEnabled:(BOOL)enable
{
    if (![TTAccountManager isLogin] || self.isIMServiceEnable == enable) return;
    
    self.isIMServiceEnable = enable;
    
    if (enable) {
        if (!self.hadInitIMService) {
            [self setupIMService];
        }
    } else {
        if (self.hadInitIMService) {
            [self logoutIMService];
        }
    }
    
    [[TTPLManager sharedManager] refreshUnreadNumber];
    [[TTSettingMineTabManager sharedInstance_tt] refreshPrivateLetterEntry:enable];
}

- (void)removeUnreadNumberWithSessionName:(NSString *)sessionName
{
    if (isEmptyString(sessionName)) return;
    
    [self refreshUnreadNumber];
}

- (void)refreshChatCenterModel
{
    WeakSelf;
    [self.chatCenterViewModel fetchChatCenterSessionsWithResultHandler:^(NSDictionary *sessions) {
        StrongSelf;
        [self refreshUnreadNumber];
    }];
}

- (void)refreshUnreadNumber
{
    __block NSUInteger total = 0;
    if ([SSCommonLogic isIMServerEnable] && [TTAccountManager isLogin]) {
        [self.chatCenterViewModel.sessionsDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, TTIMChatCenterModel *_Nonnull chatCenterModel, BOOL * _Nonnull stop) {
            total += chatCenterModel.unreadCount;
        }];
    }
    self.unreadNumber = total;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPrivateLetterGetUnreadNumberFinishNofication object:nil];
    });
}

- (void)setHasShowTip
{
    if (_hasShowTip != YES) {
        _hasShowTip = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TTIMChatHasShowNoticeView"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


#pragma mark - TTAccountMulticastProtocol

- (void)onAccountLogout
{
    [self logoutIMService];
}

- (void)onAccountSessionExpired:(NSError *)error
{
    [self logoutIMService];
}

/*
// TODO: 确认下是否需要这个回调
- (void)onAccountGetUserInfo
{
    [self refreshChatCenterModel];
}
 */

- (void)onAccountLogin
{
    [self setupIMService];
}

#pragma mark Block & Unblock
- (void)didReceiveBlockUnblockedNotification:(NSNotification *)notification {
    NSString *userID = [notification.userInfo valueForKey:kBlockedUnblockedUserIDKey];
    NSNumber *isBlocking = [notification.userInfo valueForKey:kIsBlockingKey];
    if (isEmptyString(userID)) {
        return;
    }
    
    //服了……TTUserData维护了一套本地持久化，不和其他位置的拉黑同步，需要Hack处理
    TTUserData *userData = [TTUserData objectForPrimaryKey:userID];
    if (userData) {
        userData.isBlocking = isBlocking;
        [userData save];
    }
}

#pragma mark Private

- (void)setUnreadNumber:(NSUInteger)unreadNumber
{
    if (![SSCommonLogic isIMServerEnable]) {
        unreadNumber = 0;
    }
    if (_unreadNumber != unreadNumber) {
        _unreadNumber = unreadNumber;
    }
}

- (BOOL)needShowTip
{
    if (!_hasShowTip && _needShowTip) {
        return YES;
    }
    return NO;
}

- (void)clearAllData
{
    self.unreadNumber = 0;
    [self.chatCenterViewModel.sessionsDict removeAllObjects];
    [self refreshUnreadNumber];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"TTIMDraftDic"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSMutableDictionary *)drafts
{
    if (_drafts == nil) {
        NSDictionary *draftDic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"TTIMDraftDic"];
        if (draftDic == nil) {
            draftDic = [[NSDictionary alloc] init];
        }
        _drafts = [[NSMutableDictionary alloc] initWithDictionary:draftDic];
    }
    return _drafts;
}

- (void)setDraft:(NSString *)draft withSessionId:(NSString *)sessionId
{
    [self.drafts setValue:draft forKey:sessionId];
    [[NSUserDefaults standardUserDefaults] setValue:self.drafts forKey:@"TTIMDraftDic"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getDraftWithSessionId:(NSString *)sessionId
{
    return [self.drafts tt_stringValueForKey:sessionId];
}

@end
