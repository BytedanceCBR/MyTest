//
//  FHUGCFollowManager.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/16.
//

#import "FHUGCConfig.h"
#import "FHHouseUGCAPI.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import "YYCache.h"
#import "TTAccount.h"
#import "TTAccount+Multicast.h"
#import "TTAccountManager.h"
#import "TTForumPostThreadStatusViewModel.h"
#import "FHEnvContext.h"
#import "TTBusinessManager+StringUtils.h"
#import "FHUtils.h"
#import "HMDTTMonitor.h"
#import "FHInterceptionManager.h"
#import "FHEnvContext.h"

//默认轮训间隔时间5分钟
#define defaultFocusTimerInterval 300
//默认的显示间隔
#define defaultFocusInterval 28800

#define lastRedPointShowKey @"lastRedPointShowKey"
#define lastUGCRedPointShowKey @"lastUGCRedPointShowKey"
#define lastCommunityRedPointShowKey @"lastCommunityRedPointShowKey"

static const NSString *kFHFollowListCacheKey = @"cache_follow_list_key";
static const NSString *kFHFollowListDataKey = @"key_follow_list_data";
// UGC config
static const NSString *kFHUGCConfigCacheKey = @"cache_ugc_config_key";
static const NSString *kFHUGCConfigDataKey = @"key_ugc_config_data";
// Publisher History
static const NSString *kFHUGCPublisherHistoryCacheKey = @"key_ugc_publisher_history_cache";
static const NSString *kFHUGCPublisherHistoryDataKey = @"key_ugc_publisher_history_Data";

// 圈子子数据统一内存数据缓存
@interface FHUGCSocialGroupData : NSObject

+ (instancetype)sharedInstance;
- (void)resetSocialGroupDataWith:(NSArray<FHUGCScialGroupDataModel> *)followList;// 重新设置缓存数据
- (void)updateSocialGroupDataWith:(FHUGCScialGroupDataModel *)model;// 内容更新
- (FHUGCScialGroupDataModel *)socialGroupData:(NSString *)social_group_id;

@end


@interface FHUGCConfig ()

@property (nonatomic, strong)   YYCache       *followListCache;
@property (nonatomic, strong)   YYCache       *ugcConfigCache;
@property (nonatomic, strong)   YYCache       *ugcPublisherHistoryCache;
@property (nonatomic, copy)     NSString      *followListDataKey;// 关注数据 用户相关 存储key
@property (nonatomic, strong)   NSTimer       *focusTimer;//关注是否有新内容的轮训timer
@property (nonatomic, assign)   NSTimeInterval focusTimerInterval;//轮训时间
@property (nonatomic, assign)   NSTimeInterval focusInterval;//间隔时间

@property (nonatomic, strong)   NSTimer       *ugcTimer;//邻里tab是否有新内容的轮训timer
@property (nonatomic, assign)   NSTimeInterval ugcTimerInterval;//轮训时间
@property (nonatomic, assign)   NSTimeInterval ugcInterval;//间隔时间

@property (nonatomic, strong)   NSTimer       *communityTimer;//圈子频道是否有新内容的轮训timer
@property (nonatomic, assign)   NSTimeInterval communityTimerInterval;//轮训时间
@property (nonatomic, assign)   NSTimeInterval communityInterval;//间隔时间

@property (nonatomic, assign)   NSInteger retryTimes;//重试次数

@end

@implementation FHUGCConfig

+ (instancetype)sharedInstance {
    static FHUGCConfig *_sharedInstance = nil;
    if (!_sharedInstance) {
        _sharedInstance = [[FHUGCConfig alloc] init];
    }
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [TTAccount addMulticastDelegate:self];
        _followListDataKey = [NSString stringWithFormat:@"%@_%@",kFHFollowListDataKey,[TTAccountManager userID]];
        
        _focusTimerInterval = defaultFocusTimerInterval;
        _focusInterval = defaultFocusInterval;
        _ugcTimerInterval = defaultFocusTimerInterval;
        _ugcInterval = defaultFocusInterval;
        _communityTimerInterval = defaultFocusTimerInterval;
        _communityInterval = defaultFocusInterval;
        // 加载本地
        [self loadFollowListData];
        [self loadLocalUgcConfigData];
        [self registerNoti];
    }
    return self;
}

- (void)registerNoti {
    // 发帖成功通知 数放在userinfo的：social_group_id
    //    static NSString *const kFHUGCPostSuccessNotification = @"k_fh_ugc_post_finish";
    // 删除帖子成功通知 数放在userinfo的：social_group_id
    //    static NSString *const kFHUGCDelPostNotification = @"k_fh_ugc_del_post_finish";
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postThreadSuccess:) name:kTTForumPostThreadSuccessNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delPostThreadSuccess:) name:kFHUGCDelPostNotification object:nil];
    
    //获取到did之后取消拦截
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRefreshed:) name:@"kFHTrackerDidRefreshDeviceId" object:nil];
}

- (void)deviceDidRefreshed:(NSNotification *)noti {
    [[FHInterceptionManager sharedInstance] breakInterception:kInterceptionUserFollows];
}

// 发帖成功通知
- (void)postThreadSuccess:(NSNotification *)noti {
    if (noti) {
        NSString *groupId = noti.userInfo[@"social_group_id"];
        if (groupId.length > 0) {
            NSArray *groupIDs = [groupId componentsSeparatedByString:@","];
            [groupIDs enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.length > 0) {
                    FHUGCScialGroupDataModel *data = [self socialGroupData:obj];
//                    [self updatePostSuccessScialGroupDataModel:data];
                    // 更新圈子数据
                    [self updateSocialGroupDataWith:data];
                }
            }];
        }
    }
}

// 删帖成功通知
- (void)delPostThreadSuccess:(NSNotification *)noti {
    NSString *groupId = noti.userInfo[@"social_group_id"];
    if (groupId.length > 0) {
        FHUGCScialGroupDataModel *data = [self socialGroupData:groupId];
//        [self updatePostDelSuccessScialGroupDataModel:data];
        // 更新圈子数据
        [self updateSocialGroupDataWith:data];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}
// 关注数据存储-start
- (YYCache *)followListCache
{
    if (!_followListCache) {
        _followListCache = [YYCache cacheWithName:kFHFollowListCacheKey];
    }
    return _followListCache;
}

- (void)saveFollowListData {
    if (self.followData) {
        NSDictionary *dic = [self.followData toDictionary];
        if (dic) {
            [self.followListCache setObject:dic forKey:self.followListDataKey];
        }
    }
}

- (void)loadFollowListData {
    NSDictionary *followListDic = [self.followListCache objectForKey:self.followListDataKey];
    if (followListDic && [followListDic isKindOfClass:[NSDictionary class]]) {
        NSError *err = nil;
        FHUGCModel * model = [[FHUGCModel alloc] initWithDictionary:followListDic error:&err];
        if (model) {
            self.followData = model;
        }
    } else {
        self.followData = [[FHUGCModel alloc] init];
        self.followData.data = [[FHUGCDataModel alloc] init];
    }
}
// 关注数据存储-end

- (void)loadConfigData {
    if([FHEnvContext isUGCOpen]){
        self.retryTimes = 0;
        [self loadFollowData];
    }else{
//        if(![FHEnvContext isNewDiscovery]){
            [self setFocusTimerState];
//        }
    }
    
//    if([FHEnvContext isNewDiscovery]){
//        [self setUGCTimerState];
//        [self setCommunityTimerState];
//    }
    
    [self loadUGCConfigData];
    [[TTForumPostThreadStatusViewModel sharedInstance_tt] checkCityPostData];
}

// App启动的时候需要加载
- (void)loadFollowData {
    __weak typeof(self) wself = self;
    [FHHouseUGCAPI requestFollowListByType:1 class:[FHUGCModel class] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if(error){
            wself.retryTimes++;
            if(wself.retryTimes < 5){
                [wself performSelector:@selector(loadFollowData) withObject:nil afterDelay:30];
            }else{
//                if(![FHEnvContext isNewDiscovery]){
                    [wself setFocusTimerState];
//                }
            }
            return;
        }
        
        if (model && [model isKindOfClass:[FHUGCModel class]]) {
            FHUGCModel *u_model = model;
            if([model.status integerValue] == 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    wself.followData = u_model;
                    if ([wself.followData.data.userFollowSocialGroups isKindOfClass:[NSArray class]]) {
                        [[FHUGCSocialGroupData sharedInstance] resetSocialGroupDataWith:self.followData.data.userFollowSocialGroups];
                    }
                    [wself updateFollowData];
//                    if(![FHEnvContext isNewDiscovery]){
                        [wself setFocusTimerState];
//                    }
                });
            }else{
                wself.retryTimes++;
                if(wself.retryTimes < 5){
                    [wself performSelector:@selector(loadFollowData) withObject:nil afterDelay:30];
                }else{
//                    if(![FHEnvContext isNewDiscovery]){
                        [wself setFocusTimerState];
//                    }
                }
            }
        }
    }];
}
// 关注
- (void)followSuccessWith:(FHUGCScialGroupDataModel *)social_group {
    // 关注成功
    if (social_group) {
        NSString *social_group_id = social_group.socialGroupId;
        if (social_group_id.length > 0) {
            NSMutableArray<FHUGCScialGroupDataModel> *sGroups = [NSMutableArray new];
            if (self.followData.data.userFollowSocialGroups.count > 0) {
                [sGroups addObjectsFromArray:self.followData.data.userFollowSocialGroups];
                __block FHUGCScialGroupDataModel * findData = nil;
                [sGroups enumerateObjectsUsingBlock:^(FHUGCScialGroupDataModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.socialGroupId isEqualToString:social_group_id]) {
                        findData = obj;
                        *stop = YES;
                    }
                }];
                if (findData) {
                    [sGroups removeObject:findData];
                }
                if (sGroups.count == 0) {
                    [sGroups addObject:social_group];
                } else {
                    [sGroups insertObject:social_group atIndex:0];
                }
            } else {
                [sGroups addObject:social_group];
            }
            self.followData.data.userFollowSocialGroups = sGroups;
            [self updateFollowData];
//            if(![FHEnvContext isNewDiscovery]){
                [self setFocusTimerState];
//            }
            [[FHUGCSocialGroupData sharedInstance] updateSocialGroupDataWith:social_group];
        }
    }
}
// 取消关注
- (void)cancelFollowSuccessWith:(NSString *)social_group_id {
    // 取消关注成功
    if (social_group_id.length > 0) {
        NSMutableArray<FHUGCScialGroupDataModel> *sGroups = [NSMutableArray new];
        if (self.followData.data.userFollowSocialGroups.count > 0) {
            [sGroups addObjectsFromArray:self.followData.data.userFollowSocialGroups];
            __block FHUGCScialGroupDataModel * findData = nil;
            [sGroups enumerateObjectsUsingBlock:^(FHUGCScialGroupDataModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.socialGroupId isEqualToString:social_group_id]) {
                    findData = obj;
                    *stop = YES;
                }
            }];
            if (findData) {
                [sGroups removeObject:findData];
                findData.hasFollow = @"0";
                NSString *followCountStr = findData.followerCount;
                NSInteger followCount = [findData.followerCount integerValue];
                followCount -= 1;
                if (followCount < 0) {
                    followCount = 0;
                }
                NSString *replaceFollowCountStr = [TTBusinessManager formatCommentCount:followCount];
                findData.followerCount = replaceFollowCountStr;
                [[FHUGCSocialGroupData sharedInstance] updateSocialGroupDataWith:findData];
            }
        }
        self.followData.data.userFollowSocialGroups = sGroups;
        [self updateFollowData];
//        if(![FHEnvContext isNewDiscovery]){
            [self setFocusTimerState];
//        }
    }
}

// 更新关注本地数据以及通知
- (void)updateFollowData {
    [self saveFollowListData];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCLoadFollowDataFinishedNotification object:nil];
}

- (void)setFocusTimerState {
    //触发小红点逻辑
    if([FHEnvContext isUGCOpen]){
        [self setFocusHasNewTimerInteralAndGetNewFirstTime];
    }else{
        [self stopTimer];
    }
}

- (void)setUGCTimerState {
    //触发小红点逻辑
    if([FHEnvContext isUGCOpen]){
        [self setUGCHasNewTimerInteralAndGetNewFirstTime];
    }else{
        [self stopUGCTimer];
    }
}

- (void)setCommunityTimerState {
    //触发小红点逻辑
    if([FHEnvContext isUGCOpen]){
        [self setCommunityHasNewTimerInteralAndGetNewFirstTime];
    }else{
        [self stopCommunityTimer];
    }
}

- (NSArray<FHUGCScialGroupDataModel> *)followList {
    return self.followData.data.userFollowSocialGroups;
}

- (FHUGCScialGroupDataModel *)socialGroupData:(NSString *)social_group_id {
    // 先去圈子专门内存中取（包含关注列表中的数据，优化后）
    FHUGCScialGroupDataModel * model = [[FHUGCSocialGroupData sharedInstance] socialGroupData:social_group_id];
    if (model) {
        return model;
    }
    // 关注列表中数据
    __block FHUGCScialGroupDataModel *groupData = nil;
    if (social_group_id.length > 0 && self.followData.data.userFollowSocialGroups.count > 0) {
        [self.followData.data.userFollowSocialGroups enumerateObjectsUsingBlock:^(FHUGCScialGroupDataModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.socialGroupId isEqualToString:social_group_id]) {
                groupData = obj;
                *stop = YES;
            }
        }];
    }
    return groupData;
}

- (void)updateScialGroupDataModel:(FHUGCScialGroupDataModel *)model byFollowed:(BOOL)followed {
    if (model) {
        // 替换关注人数 XX关注XX热帖
        BOOL currentFollowed = [model.hasFollow boolValue];
        if (followed) {
            // 看是否 + 1
            if (!currentFollowed) {
                model.hasFollow = @"1";
                NSString *followCountStr = model.followerCount;
                NSInteger followCount = [model.followerCount integerValue];
                followCount += 1;
                NSString *replaceFollowCountStr = [TTBusinessManager formatCommentCount:followCount];
                model.followerCount = replaceFollowCountStr;
            }
        } else {
            // 看是否 - 1
            if (currentFollowed) {
                model.hasFollow = @"0";
                NSString *followCountStr = model.followerCount;
                NSInteger followCount = [model.followerCount integerValue];
                followCount -= 1;
                if (followCount < 0) {
                    followCount = 0;
                }
                NSString *replaceFollowCountStr = [TTBusinessManager formatCommentCount:followCount];
                model.followerCount = replaceFollowCountStr;
            }
        }
    }
}

//// 发帖成功 更新帖子数 + 1
//- (void)updatePostSuccessScialGroupDataModel:(FHUGCScialGroupDataModel *)model {
//    if (model) {
//        NSString *contentCountStr = model.contentCount;
//        NSInteger contentCount = [model.contentCount integerValue];
//        contentCount += 1;
//        NSString *replaceContentCountStr = [TTBusinessManager formatCommentCount:contentCount];
//        NSString *countText = model.countText;
//        // 替换第二个数字（热帖个数）
//        NSRange range = [countText rangeOfString:contentCountStr options:NSBackwardsSearch];
//        // 有数据而且不是起始位置的数据
//        if (range.location >= 0 && range.length > 0) {
//            countText = [countText stringByReplacingCharactersInRange:range withString:replaceContentCountStr];
//            model.contentCount = replaceContentCountStr;
//        } else {
//            model.contentCount = contentCountStr;
//        }
//        model.countText = countText;
//    }
//}

//// 删帖成功 更新帖子数 - 1
//- (void)updatePostDelSuccessScialGroupDataModel:(FHUGCScialGroupDataModel *)model {
//    if (model) {
//        NSString *contentCountStr = model.contentCount;
//        NSInteger contentCount = [model.contentCount integerValue];
//        contentCount -= 1;
//        if (contentCount < 0) {
//            contentCount = 0;
//        }
//        NSString *replaceContentCountStr = [TTBusinessManager formatCommentCount:contentCount];
//        NSString *countText = model.countText;
//        // 替换第二个数字（热帖个数）
//        NSRange range = [countText rangeOfString:contentCountStr options:NSBackwardsSearch];
//        // 有数据而且不是起始位置的数据
//        if (range.location >= 0 && range.length > 0) {
//            countText = [countText stringByReplacingCharactersInRange:range withString:replaceContentCountStr];
//            model.contentCount = replaceContentCountStr;
//        } else {
//            model.contentCount = contentCountStr;
//        }
//        model.countText = countText;
//    }
//}

- (void)updateSocialGroupDataWith:(FHUGCScialGroupDataModel *)model {
    [[FHUGCSocialGroupData sharedInstance] updateSocialGroupDataWith:model];
    // 通知 附近 可能感兴趣的圈子 帖子数变化
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHUGCSicialGroupDataChangeKey" object:nil];
    // 我关注的列表数据修改
    NSString *social_group_id = model.socialGroupId;
    __block FHUGCScialGroupDataModel *socialData = nil;
    if (social_group_id.length > 0 && self.followData.data.userFollowSocialGroups.count > 0) {
        [self.followData.data.userFollowSocialGroups enumerateObjectsUsingBlock:^(FHUGCScialGroupDataModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.socialGroupId isEqualToString:social_group_id]) {
                socialData = obj;
                *stop = YES;
            }
        }];
    }
    // 找到
    if (socialData) {
        socialData.countText = model.countText;
        socialData.hasFollow = model.hasFollow;
        socialData.followerCount = model.followerCount;
        socialData.contentCount = model.contentCount;
    }
}

// 关注前先登录 逻辑
- (void)followUGCBy:(NSString *)social_group_id isFollow:(BOOL)follow enterFrom:(NSString *)enter_from enterType:(NSString *)enter_type completion:(void (^ _Nullable)(BOOL isSuccess))completion {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        if (completion) {
            completion(NO);
        }
        return;
    }
    // 登录 或者 是取消关注(取关可以不登录)
    if ([TTAccountManager isLogin] || !follow) {
        [self followUGCBy:social_group_id isFollow:follow completion:completion];
    } else {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        if (enter_from.length <= 0) {
            enter_from = @"be_null";
        }
        if (enter_type.length <= 0) {
            enter_type = @"be_null";
        }
        [params setObject:enter_from forKey:@"enter_from"];
        [params setObject:enter_type forKey:@"enter_type"];
        // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
        [params setObject:@(YES) forKey:@"need_pop_vc"];
        params[@"from_ugc"] = @(YES);
        __weak typeof(self) wSelf = self;
        [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                // 登录成功
                if ([TTAccountManager isLogin]) {
                    [wSelf followUGCBy:social_group_id isFollow:follow completion:completion];
                } else {
                    if (completion) {
                        completion(NO);
                    }
                }
            } else {
                if (completion) {
                    completion(NO);
                }
            }
        }];
    }
}


// 关注 & 取消关注 follow ：YES为关注 NO为取消关注
- (void)followUGCBy:(NSString *)social_group_id isFollow:(BOOL)follow completion:(void (^ _Nullable)(BOOL isSuccess))completion {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        if (completion) {
            completion(NO);
        }
        return;
    }
    // 服务端可能返回 “0”
    if (social_group_id.length <= 1) {
        return;
    }
    NSInteger action = 1;
    if (follow) {
        action = 1;
    } else {
        action = 0;
    }
    [FHHouseUGCAPI requestFollow:social_group_id action:action completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if (model && error == nil) {
            // 请求成功
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL isSuccess = NO;
                if ([model.status isEqualToString:@"0"]) {
                    if (follow) {
                        // [[ToastManager manager] showToast:@"关注成功"];
                        // 关注成功
                        FHUGCFollowModel *tModel = model;
                        if ([tModel isKindOfClass:[FHUGCFollowModel class]]) {
                            [self followSuccessWith:tModel.data];
                        }
                        [[HMDTTMonitor defaultManager] hmdTrackService:@"follow_community" metric:nil category:@{@"status":@(0)} extra:nil];
                    } else {
                        // [[ToastManager manager] showToast:@"取消关注成功"];
                        // 取消关注成功
                        [self cancelFollowSuccessWith:social_group_id];
                        [[HMDTTMonitor defaultManager] hmdTrackService:@"unfollow_community" metric:nil category:@{@"status":@(0)} extra:nil];
                    }
                    // 关注或者取消关注后 重新拉取 关注列表
                    isSuccess = YES;
                } else if([model.status isEqualToString:@"1"]) {
                    // 管理员 - 禁止取消关注 - toast 提示
                    if ([model.message isKindOfClass:[NSString class]] && model.message.length > 0) {
                        NSString *messageStr = model.message;
                        [[ToastManager manager] showToast:messageStr];
                    }
                } else {
                    // 其他直接显示message
                    if ([model.message isKindOfClass:[NSString class]] && model.message.length > 0) {
                        NSString *messageStr = model.message;
                        [[ToastManager manager] showToast:messageStr];
                    }
                }
                if (completion) {
                    completion(isSuccess);
                }
                NSMutableDictionary *dict = [NSMutableDictionary new];
                dict[@"social_group_id"] = social_group_id;
                NSInteger act = 0;
                if (isSuccess) {
                    act = action;
                } else {
                    act = (action == 1) ? 0 : 1;
                }
                dict[@"followStatus"] = @(act);// 关注结果：0 未关注 1 已关注
                [dict setValue:model.status forKey:@"status"];
                [dict setValue:model.message forKey:@"message"];
                // 发送通知
                [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCFollowNotification object:nil userInfo:dict];
            });
        } else {
            if (follow) {
                // [[ToastManager manager] showToast:@"关注失败"];
                [[HMDTTMonitor defaultManager] hmdTrackService:@"follow_community" metric:nil category:@{@"status":@(2)} extra:nil];
            } else {
                // [[ToastManager manager] showToast:@"取消关注失败"];
                [[HMDTTMonitor defaultManager] hmdTrackService:@"unfollow_community" metric:nil category:@{@"status":@(2)} extra:nil];
            }
            if (completion) {
                completion(NO);
            }
        }
    }];
  
}

#pragma mark - TTAccountMulticaastProtocol

// 帐号切换
- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    //切换账号时记录的时间清零，重新显示小红点
    [FHUtils setContent:@(0) forKey:lastRedPointShowKey];
    [self loadUGCConfigData];
    
    if ([TTAccountManager isLogin]) {
        self.followListDataKey = [NSString stringWithFormat:@"%@_%@",kFHFollowListDataKey,[TTAccountManager userID]];
    } else {
        self.followListDataKey = [NSString stringWithFormat:@"%@_",kFHFollowListDataKey];
    }
    // 切换账号 加载数据
    [self loadFollowListData];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCLoadFollowDataFinishedNotification object:nil];
    // 重新加载
    [self loadFollowData];
    
//    if([FHEnvContext isNewDiscovery]){
//        [self setUGCTimerState];
//        [self setCommunityTimerState];
//    }
}


#pragma mark - UGC Config Ref

- (void)loadUGCConfigData {
    __weak typeof(self) wself = self;
    [FHHouseUGCAPI requestUGCConfig:[FHUGCConfigModel class] completion:^(id<FHBaseModelProtocol> _Nonnull model, NSError * _Nonnull error) {
        if(!error){
            wself.configData = (FHUGCConfigModel *)model;
            [wself saveLocalUgcConfigData];
        }
    }];
}


- (YYCache *)ugcConfigCache
{
    if (!_ugcConfigCache) {
        _ugcConfigCache = [YYCache cacheWithName:kFHUGCConfigCacheKey];
    }
    return _ugcConfigCache;
}

- (void)loadLocalUgcConfigData {
    // 参考上面
    // kFHUGCConfigDataKey
    NSDictionary *configDic = [self.ugcConfigCache objectForKey:kFHUGCConfigDataKey];
    if (configDic && [configDic isKindOfClass:[NSDictionary class]]) {
        NSError *err = nil;
        FHUGCConfigModel * model = [[FHUGCConfigModel alloc] initWithDictionary:configDic error:&err];
        if (model) {
            self.configData = model;
        }
    }
}

- (void)saveLocalUgcConfigData {
    // 参考上面
    // kFHUGCConfigDataKey
    if (self.configData) {
        NSDictionary *dic = [self.configData toDictionary];
        if (dic) {
            [self.ugcConfigCache setObject:dic forKey:kFHUGCConfigDataKey];
        }
    }
}

- (NSArray *)secondTabLeadSuggest {
    NSString* suggest = nil;
    for (FHUGCConfigDataLeadSuggestModel *suggestModel in self.configData.data.leadSuggest) {
        if([suggestModel.kind isEqualToString:@"neighborhood"]){
            suggest = suggestModel.hint;
            break;
        }
    }
    return suggest;
}

- (NSArray *)searchLeadSuggest {
    NSString* suggest = nil;
    for (FHUGCConfigDataLeadSuggestModel *suggestModel in self.configData.data.leadSuggest) {
        if([suggestModel.kind isEqualToString:@"search"]){
            suggest = suggestModel.hint;
            break;
        }
    }
    return suggest;
}

- (NSArray *)ugcDetailLeadSuggest {
    NSString* suggest = nil;
    for (FHUGCConfigDataLeadSuggestModel *suggestModel in self.configData.data.leadSuggest) {
        if([suggestModel.kind isEqualToString:@"subsribe"]){
            suggest = suggestModel.hint;
            break;
        }
    }
    return suggest;
}

- (NSArray *)operationConfig {
    return self.configData.data.permission;
}

- (void)startTimer {
    if(_focusTimer){
        [self stopTimer];
    }
    [self.focusTimer fire];
}

- (void)startUGCTimer {
    if(_ugcTimer){
        [self stopUGCTimer];
    }
    [self.ugcTimer fire];
}

- (void)startCommunityTimer {
    if(_communityTimer){
        [self stopCommunityTimer];
    }
    [self.communityTimer fire];
}

- (void)stopTimer {
    [_focusTimer invalidate];
    _focusTimer = nil;
}

- (void)stopUGCTimer {
    [_ugcTimer invalidate];
    _ugcTimer = nil;
}

- (void)stopCommunityTimer {
    [_communityTimer invalidate];
    _communityTimer = nil;
}

- (NSTimer *)focusTimer {
    if(!_focusTimer){
        _focusTimer  =  [NSTimer timerWithTimeInterval:self.focusTimerInterval target:self selector:@selector(getHasNewForTimer) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:_focusTimer forMode:NSRunLoopCommonModes];
    }
    return _focusTimer;
}

- (NSTimer *)ugcTimer {
    if(!_ugcTimer){
        _ugcTimer  =  [NSTimer timerWithTimeInterval:self.ugcTimerInterval target:self selector:@selector(getUGCHasNewForTimer) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:_ugcTimer forMode:NSRunLoopCommonModes];
    }
    return _ugcTimer;
}

- (NSTimer *)communityTimer {
    if(!_communityTimer){
        _communityTimer  =  [NSTimer timerWithTimeInterval:self.communityTimerInterval target:self selector:@selector(getCommunityHasNewForTimer) userInfo:nil repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:_communityTimer forMode:NSRunLoopCommonModes];
    }
    return _communityTimer;
}

- (void)setFocusHasNewTimerInteralAndGetNewFirstTime {
    //每隔一段时候调用接口
    __weak typeof(self) wself = self;
    [FHHouseUGCAPI refreshFeedTips:@"f_ugc_follow" beHotTime:self.behotTime completion:^(bool hasNew, NSTimeInterval interval, NSTimeInterval cacheDuration, NSError * _Nonnull error) {
        if(!error && hasNew){
            self.ugcFocusHasNew = YES;
        }else{
            self.ugcFocusHasNew = NO;
        }
        
        if(self.ugcFocusHasNew){
            self.ugcFocusHasNew = [self isCanShowRedPoint];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCFocusTabHasNewNotification object:nil];
        
        if(interval > 0){
            self.focusTimerInterval = interval;
        }
        if(cacheDuration > 0){
            self.focusInterval = cacheDuration;
        }
        [self startTimer];
    }];
}

- (void)setUGCHasNewTimerInteralAndGetNewFirstTime {
    //每隔一段时候调用接口
    __weak typeof(self) wself = self;
    [FHHouseUGCAPI refreshFeedTips:@"f_news_recommend" beHotTime:self.behotTime completion:^(bool hasNew, NSTimeInterval interval, NSTimeInterval cacheDuration, NSError * _Nonnull error) {
        if(!error && hasNew){
            self.ugcHasNew = YES;
        }else{
            self.ugcHasNew = NO;
        }
        
        if(self.ugcHasNew){
            self.ugcHasNew = [self isCanShowUGCRedPoint];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCRecomendTabHasNewNotification object:nil];
        
        if(interval > 0){
            self.ugcTimerInterval = interval;
        }
        if(cacheDuration > 0){
            self.ugcInterval = cacheDuration;
        }
        [self startUGCTimer];
    }];
}

- (void)setCommunityHasNewTimerInteralAndGetNewFirstTime {
    //每隔一段时候调用接口
    __weak typeof(self) wself = self;
    [FHHouseUGCAPI refreshFeedTips:@"f_ugc_neighbor" beHotTime:self.behotTime completion:^(bool hasNew, NSTimeInterval interval, NSTimeInterval cacheDuration, NSError * _Nonnull error) {
        if(!error && hasNew){
            self.ugcCommunityHasNew = YES;
        }else{
            self.ugcCommunityHasNew = NO;
        }
        
        if(self.ugcCommunityHasNew){
            self.ugcCommunityHasNew = [self isCanShowCommunityRedPoint];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCCommunityTabHasNewNotification object:nil];
        
        if(interval > 0){
            self.communityTimerInterval = interval;
        }
        if(cacheDuration > 0){
            self.communityInterval = cacheDuration;
        }
        [self startCommunityTimer];
    }];
}

- (void)getHasNewForTimer {
    //每隔一段时候调用接口
    __weak typeof(self) wself = self;
    [FHHouseUGCAPI refreshFeedTips:@"f_ugc_follow" beHotTime:self.behotTime completion:^(bool hasNew, NSTimeInterval interval, NSTimeInterval cacheDuration, NSError * _Nonnull error) {
        if(!error && hasNew && [self isCanShowRedPoint]){
            self.ugcFocusHasNew = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCFocusTabHasNewNotification object:nil];
        }
    }];
}

- (void)getUGCHasNewForTimer {
    //每隔一段时候调用接口
    __weak typeof(self) wself = self;
    [FHHouseUGCAPI refreshFeedTips:@"f_news_recommend" beHotTime:self.behotTime completion:^(bool hasNew, NSTimeInterval interval, NSTimeInterval cacheDuration, NSError * _Nonnull error) {
        if(!error && hasNew && [self isCanShowUGCRedPoint]){
            self.ugcHasNew = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCRecomendTabHasNewNotification object:nil];
        }
    }];
}

- (void)getCommunityHasNewForTimer {
    //每隔一段时候调用接口
    __weak typeof(self) wself = self;
    [FHHouseUGCAPI refreshFeedTips:@"f_ugc_neighbor" beHotTime:self.behotTime completion:^(bool hasNew, NSTimeInterval interval, NSTimeInterval cacheDuration, NSError * _Nonnull error) {
        if(!error && hasNew && [self isCanShowCommunityRedPoint]){
            self.ugcCommunityHasNew = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCCommunityTabHasNewNotification object:nil];
        }
    }];
}

- (BOOL)isCanShowRedPoint {
    //显示时候记录时间
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSNumber *last = [FHUtils contentForKey:lastRedPointShowKey];
    NSTimeInterval lastTime = last.doubleValue;
    
    if(lastTime > 0 && (currentTime - lastTime) <= self.focusInterval){
        return NO;
    }
    
    return YES;
}

- (void)recordHideRedPointTime {
    //显示时候记录时间
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    [FHUtils setContent:@(currentTime) forKey:lastRedPointShowKey];
}

- (BOOL)isCanShowUGCRedPoint {
    //显示时候记录时间
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSNumber *last = [FHUtils contentForKey:lastUGCRedPointShowKey];
    NSTimeInterval lastTime = last.doubleValue;
    
    if(lastTime > 0 && (currentTime - lastTime) <= self.ugcInterval){
        return NO;
    }
    
    return YES;
}

- (void)recordHideUGCRedPointTime {
    //显示时候记录时间
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    [FHUtils setContent:@(currentTime) forKey:lastUGCRedPointShowKey];
}

- (BOOL)isCanShowCommunityRedPoint {
    //显示时候记录时间
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSNumber *last = [FHUtils contentForKey:lastCommunityRedPointShowKey];
    NSTimeInterval lastTime = last.doubleValue;
    
    if(lastTime > 0 && (currentTime - lastTime) <= self.communityInterval){
        return NO;
    }
    
    return YES;
}

- (void)recordHideCommunityRedPointTime {
    //显示时候记录时间
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    [FHUtils setContent:@(currentTime) forKey:lastCommunityRedPointShowKey];
}

#pragma mark - Publisher Hisgtory

- (YYCache *)ugcPublisherHistoryCache {
    if(!_ugcPublisherHistoryCache) {
        _ugcPublisherHistoryCache = [YYCache cacheWithName:kFHUGCPublisherHistoryCacheKey];
    }
    return _ugcPublisherHistoryCache;
}

- (FHPostUGCSelectedGroupHistory *)loadPublisherHistoryData {
    NSDictionary *historyDict = [self.ugcPublisherHistoryCache objectForKey:kFHUGCPublisherHistoryDataKey];
    if (historyDict && [historyDict isKindOfClass:[NSDictionary class]]) {
        NSError *err = nil;
        FHPostUGCSelectedGroupHistory * model = [[FHPostUGCSelectedGroupHistory alloc] initWithDictionary:historyDict error:&err];
        if (model) {
            return model;
        }
    }
    return nil;
}

- (void)savePublisherHistoryDataWithModel: (FHPostUGCSelectedGroupHistory *)model {
    if (model) {
        NSDictionary *historyDict = [model toDictionary];
        if (historyDict) {
            [self.ugcPublisherHistoryCache setObject:historyDict forKey:kFHUGCPublisherHistoryDataKey];
        }
    }
}
@end


// FHUGCSocialGroupData
@interface FHUGCSocialGroupData ()

// 包含关注列表数据
@property (nonatomic, strong)   NSMutableDictionary       *groupDataDic;

@end

@implementation FHUGCSocialGroupData

+ (instancetype)sharedInstance {
    static FHUGCSocialGroupData *_sharedInstance = nil;
    if (!_sharedInstance) {
        _sharedInstance = [[FHUGCSocialGroupData alloc] init];
    }
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _groupDataDic = [NSMutableDictionary new];
    }
    return self;
}

- (void)resetSocialGroupDataWith:(NSArray<FHUGCScialGroupDataModel> *)followList {
    [_groupDataDic removeAllObjects];
    if ([followList isKindOfClass:[NSArray class]]) {
        [followList enumerateObjectsUsingBlock:^(FHUGCScialGroupDataModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.socialGroupId.length > 0) {
                [_groupDataDic setObject:obj forKey:obj.socialGroupId];
            }
        }];
    }
}

- (void)updateSocialGroupDataWith:(FHUGCScialGroupDataModel *)model {
    if (model && model.socialGroupId.length > 0) {
        FHUGCScialGroupDataModel *socialData = [self.groupDataDic objectForKey:model.socialGroupId];
        if (socialData) {
            socialData.countText = model.countText;
            socialData.hasFollow = model.hasFollow;
            socialData.followerCount = model.followerCount;
            socialData.contentCount = model.contentCount;
            socialData.permission = model.permission;
        } else {
            [_groupDataDic setObject:model forKey:model.socialGroupId];
        }
    }
}

- (FHUGCScialGroupDataModel *)socialGroupData:(NSString *)social_group_id {
    if (social_group_id.length > 0) {
        return [self.groupDataDic objectForKey:social_group_id];
    }
    return nil;
}
@end
