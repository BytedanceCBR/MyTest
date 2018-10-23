//
//  AKAwardCoinTipManager.m
//  Article
//
//  Created by chenjiesheng on 2018/3/12.
//

#import "AKNetworkManager.h"
#import "ArticleURLSetting.h"
#import "AKAwardCoinManager.h"
#import "AKTaskSettingHelper.h"
#import "TTInterfaceTipManager.h"

#import <TTPersistence.h>
@interface AKAwardCoinManager()

@property (nonatomic, strong)NSMutableDictionary                *historyDict;
@property (nonatomic, strong)TTPersistence                      *persistence;
@end
@implementation AKAwardCoinManager

static AKAwardCoinManager *shareInstance = nil;
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[AKAwardCoinManager alloc] init];
    });
    return shareInstance;
}

+ (void)showAwardCoinTipInView:(UIView *)view
                       tipType:(AKAwardCoinTipType)tipType
                       coinNum:(NSInteger)coinNum
                         title:(NSString *)title
{
    if ([AKTaskSettingHelper shareInstance].isEnableShowCoinTip) {
        AKAwardCoinTipModel *model = [[AKAwardCoinTipModel alloc] init];
        model.title = title;
        model.coinNum = coinNum;
        model.tipType = tipType;
        model.useCustomBackView = view != nil;
        model.customBackView = view;
        [TTInterfaceTipManager appendTipWithModel:model];
    }
}

+ (void)showAwardCoinTipInView:(UIView *)view tipType:(AKAwardCoinTipType)tipType
{
    [self showAwardCoinTipInView:view tipType:tipType coinNum:10 title:nil];
}

+ (void)requestReadBounsWithGroupID:(NSString *)groupID
                     withExtraParam:(NSDictionary *)extParam
                         completion:(void (^)(NSInteger, NSString *,NSDictionary *))completion
{
    if (isEmptyString(groupID)) {
        if (completion) {
            completion(999,@"groupID is nil",nil);
        }
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
    [dict setValue:groupID forKey:@"group_id"];
    if ([extParam isKindOfClass:[NSDictionary class]] && extParam.count > 0) {
        [dict addEntriesFromDictionary:extParam];
    }
    [AKNetworkManager requestForJSONWithPath:@"task/get_read_bonus/" params:dict method:@"GET" callback:^(NSInteger err_no, NSString *err_tips, NSDictionary *dataDict) {
        if (completion) {
            completion(err_no,err_tips,dataDict);
        }
    }];
}

+ (void)requestShareBounsWithGroup:(NSString *)groupID
                          fromPush:(BOOL)fromPush
                        completion:(void (^)(NSString *, NSInteger))completion
{
    if (isEmptyString(groupID) || ![TTAccount sharedAccount].isLogin) {
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:groupID forKey:@"group_id"];
    if (fromPush) {
        [dict setValue:@"push" forKey:@"impression_type"];
    }
    [AKNetworkManager requestForJSONWithPath:@"task/get_share_bonus/" params:dict method:@"GET" callback:^(NSInteger err_no, NSString *err_tips, NSDictionary *dataDict) {
        if (isEmptyString(err_tips) && [dataDict isKindOfClass:[NSDictionary class]]) {
            NSString *content = [dataDict tt_stringValueForKey:@"content"];
            NSInteger num = [dataDict tt_integerValueForKey:@"score_amount"];
            if (completion) {
                completion(content,num);
            }
        } else {
            if (completion) {
                completion(nil,0);
            }
        }
    }];
}

+ (BOOL)isShareTypeWithActivityType:(TTActivityType)type
{
    switch (type) {
        case TTActivityTypeWeixinShare:
        case TTActivityTypeWeixinMoment:
        case TTActivityTypeQQShare:
        case TTActivityTypeQQWeibo:
        case TTActivityTypeSystem:
        case TTActivityTypeMessage:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}

- (BOOL)checkIfNeedMonitorWithGroupID:(NSString *)groupID
{
    return ![self.historyDict tt_boolValueForKey:groupID];
}

- (void)setHadReadWithGroupID:(NSString *)groupID
{
    [self.historyDict setObject:@YES forKey:groupID];
    [self.persistence setObject:self.historyDict forKey:@"history"];
    [self.persistence save];
}

#pragma Getter

- (NSMutableDictionary *)historyDict
{
    if (_historyDict == nil) {
        _historyDict = [NSMutableDictionary dictionary];
        NSDictionary *dict = [self.persistence objectForKey:@"history"];
        if (dict.count > 0) {
            [_historyDict addEntriesFromDictionary:dict];
        }
    }
    return _historyDict;
}

- (TTPersistence *)persistence
{
    if (_persistence == nil) {
        _persistence = [TTPersistence persistenceWithName:@"ak_award_coin_history"];
    }
    return _persistence;
}
@end
