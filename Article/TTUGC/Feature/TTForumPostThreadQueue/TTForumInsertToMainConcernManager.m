//
//  TTForumInsertToMainConcernManager.m
//  Article
//
//  Created by 徐霜晴 on 16/11/2.
//
//

#import "TTForumInsertToMainConcernManager.h"
#import "TTUGCDefine.h"
#import <TTAccountBusiness.h>
#import "TTVideoDetailViewController.h"
#import "TTForumPostThreadTask.h"
#import "TTArticleCategoryManager.h"
#import "ExploreMomentDefine.h"
#import "TTTabBarProvider.h"
#import "TSVShortVideoOriginalData.h"
#import "TTTabBarProvider.h"

static NSString * const kUserDefaultKeyThreadsNeedInsertToMainConcern = @"kUserDefaultKeyThreadsNeedInsertToMainConcern";

static NSString *const kUserDefaultKeyThreadsNeedInsertToFollowConcern = @"kUserDefaultKeyThreadsNeedInsertToFollowConcern";

static NSString * const kUserDefaultKeyThreadsNeedInsertToWeitoutiao = @"kUserDefaultKeyThreadsNeedInsertToWeitoutiao";

@interface TTForumInsertToMainConcernManager ()
<
TTAccountMulticastProtocol
>

@property (nonatomic, strong) NSArray *concernIDArray;

@property (nonatomic, strong) NSDictionary *concernKeyDic;

@end

@implementation TTForumInsertToMainConcernManager

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.concernIDArray = [NSArray arrayWithObjects:kTTMainConcernID,KTTFollowPageConcernID,kTTWeitoutiaoConcernID,nil];
        self.concernKeyDic = [NSDictionary dictionaryWithObjectsAndKeys:kUserDefaultKeyThreadsNeedInsertToMainConcern,kTTMainConcernID,kUserDefaultKeyThreadsNeedInsertToFollowConcern,KTTFollowPageConcernID,kUserDefaultKeyThreadsNeedInsertToWeitoutiao,kTTWeitoutiaoConcernID, nil];
        
        [self registerNotifications];
        
        if (![TTTabBarProvider isWeitoutiaoOnTabBar]) {
            [self clearThreadNeedsInsertToPageWithConcernID:kTTWeitoutiaoConcernID];
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postThreadSuccessNotification:) name:kTTForumPostThreadSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteThreadNotification:) name:kTTForumDeleteThreadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteVideoNotification:) name:TTVideoDetailViewControllerDeleteVideoArticle object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMomentThreadNotification:) name:kDeleteMomentNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteShortVideoNotitifation:) name:kTSVShortVideoDeleteNotification object:nil];
    
    [TTAccount addMulticastDelegate:self];
}

#pragma mark - NSUserDefaults

#pragma mark - 通用方法

- (NSArray *)getThreadsNeedInsertToPageWithConcernID:(NSString *)concernID{
    
    if (isEmptyString(concernID)) {
        return nil;
    }
    
    NSString *keyString = [self.concernKeyDic objectForKey:concernID];
    
    if (!isEmptyString(keyString)) {
        NSArray *threads = nil;
        NSData *threadsData = [[NSUserDefaults standardUserDefaults] dataForKey:keyString];
        if (!threadsData) {
            threads = [[NSArray alloc] init];
            return threads;
        }
        threads = [NSKeyedUnarchiver unarchiveObjectWithData:threadsData];
        return threads;
    }
    
    return nil;
    
}

- (void)clearThreadNeedsInsertToPageWithConcernID:(NSString *)concernID{
    if (isEmptyString(concernID)) {
        return;
    }
    
    NSString *keyString = [self.concernKeyDic objectForKey:concernID];
    if (isEmptyString(keyString)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyString];
}

- (void)saveThreadsNeedInsertToPage:(NSArray *)threads WithConcernID:(NSString *)concernID{
    
    if (isEmptyString(concernID)) {
        return;
    }
    
    NSString *keyString = [self.concernKeyDic objectForKey:concernID];
    if (isEmptyString(keyString)) {
        return;
    }
    
    NSData *threadsData = [NSKeyedArchiver archivedDataWithRootObject:threads];
    if (threadsData) {
        [[NSUserDefaults standardUserDefaults] setObject:threadsData forKey:keyString];
    }
}

#pragma mark - Handle Notifications

// 发帖成功
- (void)postThreadSuccessNotification:(NSNotification *)notification {
    
    TTForumPostThreadTask *task = notification.object;
    NSDictionary *dict = notification.userInfo;
    NSString *concernID = [dict valueForKey:kTTForumPostThreadConcernID];
    if (isEmptyString(concernID) || (![concernID isEqualToString:kTTMainConcernID] && ![concernID isEqualToString:KTTFollowPageConcernID] && (![concernID isEqualToString:kTTWeitoutiaoConcernID]))) {
        return;
    }
    
    // 一个有点trick的方案
    // 由于ExploreMixedListBaseView会重用，所以有可能当微头条/视频发送成功时，当前没有ExploreMixedListBaseView的对象与帖子的concernID一致
    // 所以做一个兜底方案
    // 即将插入推荐页的微头条/视频，将持久化到NSUserDefaults
    
    // 生成帖子的muDic，等待下次刷新推荐频道时插入
    NSMutableDictionary *muDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [muDict setValue:concernID forKey:@"concernID"];
    if (isEmptyString(task.categoryID)) {
        [muDict setValue:@"" forKey:@"categoryID"];
    }else {
        [muDict setValue:task.categoryID forKey:@"categoryID"];
    }
    [muDict setValue:@(ExploreOrderedDataListTypeCategory) forKey:@"listType"];
    [muDict setValue:@(ExploreOrderedDataListLocationCategory) forKey:@"listLocation"];
    
    if (![concernID isEqualToString:kTTWeitoutiaoConcernID] || ([concernID isEqualToString:kTTWeitoutiaoConcernID] && [TTTabBarProvider isWeitoutiaoOnTabBar])) {

        BOOL isRepost = [dict tt_boolValueForKey:kFRPostThreadIsRepost];
        if (!isRepost) {
            NSMutableArray *threads = [[NSMutableArray alloc] initWithArray:[self getThreadsNeedInsertToPageWithConcernID:concernID]];
            [threads addObject:muDict];
            [self saveThreadsNeedInsertToPage:threads WithConcernID:concernID];
        }
    }

}

- (void)deleteMomentThreadNotification:(NSNotification *)notification{
    
    if (!notification || !notification.userInfo) {
        return;
    }
    long long threadID = [[notification.userInfo objectForKey:@"id"] longLongValue];
    
    WeakSelf;
    [self.concernIDArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        StrongSelf;
        if (obj && [obj isKindOfClass:[NSString class]]) {
            NSString *concernID = (NSString *)obj;
            [self deleteThreadWithConcernID:concernID WithThreadID:threadID];
        }
    }];
    
}

//删除帖子
- (void)deleteThreadNotification:(NSNotification *)notification {
    
    long long threadID = [notification.userInfo tt_longlongValueForKey:kTTForumThreadID];
    WeakSelf;
    [self.concernIDArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        StrongSelf;
        if (obj && [obj isKindOfClass:[NSString class]]) {
            NSString *concernID = (NSString *)obj;
            [self deleteThreadWithConcernID:concernID WithThreadID:threadID];
        }
    }];

}

- (void)deleteThreadWithConcernID:(NSString *)concernID WithThreadID:(long long)threaID{
    
    if (isEmptyString(concernID)) {
        return;
    }
    
    if (![concernID isEqualToString:kTTWeitoutiaoConcernID] || ([concernID isEqualToString:kTTWeitoutiaoConcernID] && [TTTabBarProvider isWeitoutiaoOnTabBar])) {
        NSMutableArray *threadsAndVideos = [[NSMutableArray alloc] initWithArray:[self getThreadsNeedInsertToPageWithConcernID:concernID]];
        
        __block NSDictionary *matchedDict = nil;
        [threadsAndVideos enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
            long long uniqueID = [dict tt_longlongValueForKey:@"uniqueID"];
            if (uniqueID == threaID) {
                matchedDict = dict;
            }
        }];
        
        if (matchedDict) {
            [threadsAndVideos removeObject:matchedDict];
        }
        [self saveThreadsNeedInsertToPage:threadsAndVideos WithConcernID:concernID];
        
    }
}

//删除视频
- (void)deleteVideoNotification:(NSNotification *)notification {
    long long groupID = [notification.userInfo tt_longlongValueForKey:@"uniqueID"];
    WeakSelf;
    [self.concernIDArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        StrongSelf;
        if (obj && [obj isKindOfClass:[NSString class]]) {
            NSString *concernID = (NSString *)obj;
            [self deleteVideoOrShortVideoWithConcernID:concernID WithGroupID:groupID];
        }
    }];
}

- (void)deleteShortVideoNotitifation:(NSNotification *)notification {
    long long groupID = [notification.userInfo tt_longlongValueForKey:kTSVShortVideoDeleteUserInfoKeyGroupID];
    WeakSelf;
    [self.concernIDArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        StrongSelf;
        if (obj && [obj isKindOfClass:[NSString class]]) {
            NSString *concernID = (NSString *)obj;
            [self deleteVideoOrShortVideoWithConcernID:concernID WithGroupID:groupID];
        }
    }];
}

- (void)deleteVideoOrShortVideoWithConcernID:(NSString *)concernID WithGroupID:(long long)groupID{
    if (isEmptyString(concernID)) {
        return;
    }
    
    if (![concernID isEqualToString:kTTWeitoutiaoConcernID] || ([concernID isEqualToString:kTTWeitoutiaoConcernID] && [TTTabBarProvider isWeitoutiaoOnTabBar])) {
        NSMutableArray *threadsAndVideos = [[NSMutableArray alloc] initWithArray:[self getThreadsNeedInsertToPageWithConcernID:concernID]];
        __block NSDictionary *matchedDict = nil;
        [threadsAndVideos enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
            long long uniqueID = [dict tt_longlongValueForKey:@"uniqueID"];
            if (uniqueID == groupID) {
                matchedDict = dict;
            }
        }];
        if (matchedDict) {
            [threadsAndVideos removeObject:matchedDict];
        }
        [self saveThreadsNeedInsertToPage:threadsAndVideos WithConcernID:concernID];
    }
}

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    WeakSelf;
    [self.concernIDArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        StrongSelf;
        if (obj && [obj isKindOfClass:[NSString class]]) {
            NSString *concernID = (NSString *)obj;
            [self clearThreadNeedsInsertToPageWithConcernID:concernID];
        }
    }];
}

@end
