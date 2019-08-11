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

static const NSString *kFHFollowListCacheKey = @"cache_follow_list_key";
static const NSString *kFHFollowListDataKey = @"key_follow_list_data";
// UGC config
static const NSString *kFHUGCConfigCacheKey = @"cache_ugc_config_key";
static const NSString *kFHUGCConfigDataKey = @"key_ugc_config_data";

@interface FHUGCConfig ()

@property (nonatomic, strong)   YYCache       *followListCache;
@property (nonatomic, strong)   YYCache       *ugcConfigCache;
@property (nonatomic, copy)     NSString      *followListDataKey;// 关注数据 用户相关 存储key
@property (nonatomic, strong)   NSTimer       *focusTimer;//关注是否有新内容的轮训timer

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
        // 加载本地
        [self loadFollowListData];
        [self loadLocalUgcConfigData];
        [self registerNoti];
        [self initFocusTimer];
    }
    return self;
}

- (void)registerNoti {
    // 发帖成功通知 数放在userinfo的：social_group_id
    //    static NSString *const kFHUGCPostSuccessNotification = @"k_fh_ugc_post_finish";
    // 删除帖子成功通知 数放在userinfo的：social_group_id
    //    static NSString *const kFHUGCDelPostNotification = @"k_fh_ugc_del_post_finish";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postThreadSuccess:) name:kFHUGCPostSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delPostThreadSuccess:) name:kFHUGCDelPostNotification object:nil];
}

- (void)initFocusTimer {
    
}

// 发帖成功通知
- (void)postThreadSuccess:(NSNotification *)noti {
    if (noti) {
        NSString *groupId = noti.userInfo[@"social_group_id"];
        if (groupId.length > 0) {
            FHUGCScialGroupDataModel *data = [self socialGroupData:groupId];
            [self updatePostSuccessScialGroupDataModel:data];
        }
    }
}

// 删帖成功通知
- (void)delPostThreadSuccess:(NSNotification *)noti {
    NSString *groupId = noti.userInfo[@"social_group_id"];
    if (groupId.length > 0) {
        FHUGCScialGroupDataModel *data = [self socialGroupData:groupId];
        [self updatePostDelSuccessScialGroupDataModel:data];
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
    [self loadFollowData];
    [self loadUGCConfigData];
    [[TTForumPostThreadStatusViewModel sharedInstance_tt] checkCityPostData];
}

// App启动的时候需要加载
- (void)loadFollowData {
    __weak typeof(self) wself = self;
    [FHHouseUGCAPI requestFollowListByType:1 class:[FHUGCModel class] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if (model && [model isKindOfClass:[FHUGCModel class]]) {
            FHUGCModel *u_model = model;
            dispatch_async(dispatch_get_main_queue(), ^{
                wself.followData = u_model;
                [wself updateFollowData];
                [wself setFocusTimerState];
            });
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
            }
        }
        self.followData.data.userFollowSocialGroups = sGroups;
        [self updateFollowData];
    }
}

// 更新关注本地数据以及通知
- (void)updateFollowData {
    [self saveFollowListData];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCLoadFollowDataFinishedNotification object:nil];
}

- (void)setFocusTimerState {
    //关注列表有数据，才会触发小红点逻辑
    if([FHEnvContext isUGCOpen] && self.followList.count > 0){
        [self startTimer];
    }else{
        [self stopTimer];
    }
}

- (NSArray<FHUGCScialGroupDataModel> *)followList {
    return self.followData.data.userFollowSocialGroups;
}

- (FHUGCScialGroupDataModel *)socialGroupData:(NSString *)social_group_id {
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
                NSString *replaceFollowCountStr = [NSString stringWithFormat:@"%ld",followCount];
                NSString *countText = model.countText;
                // 替换第一个 关注数字
                NSRange range = [countText rangeOfString:followCountStr];
                // 有数据而且是起始位置的数据
                if (range.location == 0 && range.length > 0) {
                    countText = [countText stringByReplacingCharactersInRange:range withString:replaceFollowCountStr];
                    model.followerCount = replaceFollowCountStr;
                } else {
                    model.followerCount = followCountStr;
                }
                model.countText = countText;
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
                NSString *replaceFollowCountStr = [NSString stringWithFormat:@"%ld",followCount];
                NSString *countText = model.countText;
                // 替换第一个 关注数字
                NSRange range = [countText rangeOfString:followCountStr];
                if (range.location == 0 && range.length > 0) {
                    countText = [countText stringByReplacingCharactersInRange:range withString:replaceFollowCountStr];
                    model.followerCount = replaceFollowCountStr;
                } else {
                    model.followerCount = followCountStr;
                }
                model.countText = countText;
            }
        }
    }
}

// 发帖成功 更新帖子数 + 1
- (void)updatePostSuccessScialGroupDataModel:(FHUGCScialGroupDataModel *)model {
    if (model) {
        NSString *contentCountStr = model.contentCount;
        NSInteger contentCount = [model.contentCount integerValue];
        contentCount += 1;
        NSString *replaceContentCountStr = [NSString stringWithFormat:@"%ld",contentCount];
        NSString *countText = model.countText;
        // 替换第二个数字（热帖个数）
        NSRange range = [countText rangeOfString:contentCountStr options:NSBackwardsSearch];
        // 有数据而且不是起始位置的数据
        if (range.location > 0 && range.length > 0) {
            countText = [countText stringByReplacingCharactersInRange:range withString:replaceContentCountStr];
            model.contentCount = replaceContentCountStr;
        } else {
            model.contentCount = contentCountStr;
        }
        model.countText = countText;
    }
}

// 删帖成功 更新帖子数 - 1
- (void)updatePostDelSuccessScialGroupDataModel:(FHUGCScialGroupDataModel *)model {
    if (model) {
        NSString *contentCountStr = model.contentCount;
        NSInteger contentCount = [model.contentCount integerValue];
        contentCount -= 1;
        if (contentCount < 0) {
            contentCount = 0;
        }
        NSString *replaceContentCountStr = [NSString stringWithFormat:@"%ld",contentCount];
        NSString *countText = model.countText;
        // 替换第二个数字（热帖个数）
        NSRange range = [countText rangeOfString:contentCountStr options:NSBackwardsSearch];
        // 有数据而且不是起始位置的数据
        if (range.location > 0 && range.length > 0) {
            countText = [countText stringByReplacingCharactersInRange:range withString:replaceContentCountStr];
            model.contentCount = replaceContentCountStr;
        } else {
            model.contentCount = contentCountStr;
        }
        model.countText = countText;
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
                    } else {
                        // [[ToastManager manager] showToast:@"取消关注成功"];
                        // 取消关注成功
                        [self cancelFollowSuccessWith:social_group_id];
                    }
                    // 关注或者取消关注后 重新拉取 关注列表
                    isSuccess = YES;
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
            } else {
                // [[ToastManager manager] showToast:@"取消关注失败"];
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

//- (BOOL)ugcFocusHasNew {
//    return YES;
//}

- (void)startTimer {
    if(_focusTimer){
        [self stopTimer];
    }
    [self.focusTimer fire];
}

- (void)stopTimer {
    [_focusTimer invalidate];
    _focusTimer = nil;
}

- (NSTimer *)focusTimer {
    if(!_focusTimer){
        _focusTimer  =  [NSTimer timerWithTimeInterval:5 target:self selector:@selector(getHasNewForTimer) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_focusTimer forMode:NSRunLoopCommonModes];
    }
    return _focusTimer;
}

- (void)getHasNewForTimer {
    //每隔一段时候调用接口
    self.ugcFocusHasNew = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCFocusTabHasNewNotification object:nil];
}

@end
