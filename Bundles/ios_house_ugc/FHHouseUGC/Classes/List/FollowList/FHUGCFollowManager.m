//
//  FHUGCFollowManager.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/16.
//

#import "FHUGCFollowManager.h"
#import "FHHouseUGCAPI.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import "YYCache.h"

static const NSString *kFHFollowListCacheKey = @"cache_follow_list_key";
static const NSString *kFHFollowListDataKey = @"key_follow_list_data";

@interface FHUGCFollowManager ()

@property (nonatomic, strong)   YYCache       *followListCache;

@end

@implementation FHUGCFollowManager

+ (instancetype)sharedInstance {
    static FHUGCFollowManager *_sharedInstance = nil;
    if (!_sharedInstance) {
        _sharedInstance = [[FHUGCFollowManager alloc] init];
    }
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 加载本地
        [self loadData];
    }
    return self;
}

- (YYCache *)followListCache
{
    if (!_followListCache) {
        _followListCache = [YYCache cacheWithName:kFHFollowListCacheKey];
    }
    return _followListCache;
}

- (void)saveData {
    if (self.followData) {
        NSDictionary *dic = [self.followData toDictionary];
        if (dic) {
            [self.followListCache setObject:dic forKey:kFHFollowListDataKey];
        }
    }
}

- (void)loadData {
    NSDictionary *followListDic = [self.followListCache objectForKey:kFHFollowListDataKey];
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
    [self saveData];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCLoadFollowDataFinishedNotification object:nil];
}

- (NSArray<FHUGCScialGroupDataModel> *)followList {
    return self.followData.data.userFollowSocialGroups;
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

@end
