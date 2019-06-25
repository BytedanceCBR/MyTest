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

static const NSString *kFHFollowListCacheKey = @"cache_follow_list_key";
static const NSString *kFHFollowListDataKey = @"key_follow_list_data";
// UGC config
static const NSString *kFHUGCConfigCacheKey = @"cache_ugc_config_key";
static const NSString *kFHUGCConfigDataKey = @"key_ugc_config_data";

@interface FHUGCConfig ()

@property (nonatomic, strong)   YYCache       *followListCache;
@property (nonatomic, strong)   YYCache       *ugcConfigCache;
@property (nonatomic, copy)     NSString       *followListDataKey;// 关注数据 用户相关 存储key

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
    }
    return self;
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
}

// App启动的时候需要加载
- (void)loadFollowData {
    [FHHouseUGCAPI requestFollowListByType:1 class:[FHUGCModel class] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if (model && [model isKindOfClass:[FHUGCModel class]]) {
            FHUGCModel *u_model = model;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.followData = u_model;
                [self updateFollowData];
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

// 关注 & 取消关注 follow ：YES为关注 NO为取消关注
- (void)followUGCBy:(NSString *)social_group_id isFollow:(BOOL)follow completion:(void (^ _Nullable)(BOOL isSuccess))completion {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        if (completion) {
            completion(NO);
        }
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

- (NSArray *)configLeadSuggest {
    return self.configData.data.leadSuggest;
}

- (NSArray *)configPermisson {
    return self.configData.data.permission;
}

@end
