//
//  TTActivityShareSequenceManager.m
//  Article
//
//  Created by lishuangyang on 2017/8/25.
//
//

#import "TTActivityShareSequenceManager.h"
#import "TTWeChatShare.h"
#import "TTQQShare.h"
//#import "TTDingTalkShare.h"
#import "TTMessageCenter.h"

#define KShareActivitySequenceArray @"kShareActivitySequenceArray"
#define KShareServiceSequenceArray @"kShareServiceSequenceArray"

extern NSString * const TTActivityContentItemTypeWechat;
extern NSString * const TTActivityContentItemTypeWechatTimeLine;
extern NSString * const TTActivityContentItemTypeQQFriend;
extern NSString * const TTActivityContentItemTypeQQZone;
//extern NSString * const TTActivityContentItemTypeDingTalk;
extern NSString * const TTActivityContentItemTypeForwardWeitoutiao;


@implementation TTActivityShareSequenceManager

#pragma mark -
#pragma maek - old share pod
- (BOOL)instalAllShareActivitySequenceFirstActivity:(TTActivityType )activityType
{
   BOOL isSuccess = [self synchronizeShareActivitySequenceFirstActivity:activityType];
    if (isSuccess) {
        NSString *activityContentItemType = [[self class] activityStringTypeFromActivityType:activityType];
        [self synchronizeShareServiceSequenceFirstActivity:activityContentItemType];
        SAFECALL_MESSAGE(TTActivityShareSequenceChangedMessage,@selector(message_shareActivitySequenceChanged), message_shareActivitySequenceChanged);
    }
    return YES;
}

- (BOOL )synchronizeShareActivitySequenceFirstActivity:(TTActivityType )activityType
{
    NSArray *currentSequenceActivities = [self getOriginalSequnceActivities];
    NSMutableArray *nextSequenceAcitivites = [[NSMutableArray alloc] init];
    
    __block BOOL isfinishSequence = YES;
    if (activityType == TTActivityTypeWeitoutiao || activityType == TTActivityTypeWeixinShare || activityType == TTActivityTypeWeixinMoment ||
        activityType == TTActivityTypeQQZone || activityType == TTActivityTypeQQShare || activityType == TTActivityTypeDingTalk){
        [nextSequenceAcitivites addObject:@(activityType)];
        [currentSequenceActivities enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSNumber class] ]) {
                TTActivityType objType =[(NSNumber *)obj integerValue];
                if (objType != activityType) {
                    [nextSequenceAcitivites addObject:obj];
                }
            }else{
                *stop = YES;
                isfinishSequence = NO;
            }
        }];
        if (isfinishSequence) {
            [[NSUserDefaults standardUserDefaults] setObject:[nextSequenceAcitivites copy]forKey:KShareActivitySequenceArray];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return isfinishSequence;
}

- (NSArray *)getAllShareActivitySequence
{
    NSArray *activityArray = [self getOriginalSequnceActivities];
    NSMutableArray *avaliableSequenceArray = [[NSMutableArray alloc] initWithArray:activityArray];
    NSMutableArray *unAvaliableSequenceArray = [NSMutableArray array];
   
    [activityArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            TTActivityType objType = [obj integerValue];
            //微信好友
            if (objType == TTActivityTypeWeixinMoment) {
                if (![[TTWeChatShare sharedWeChatShare] isAvailable]) {
                    [avaliableSequenceArray removeObject:obj];
                    [unAvaliableSequenceArray addObject:obj];
                }
            }
            //微信好友
            if (objType == TTActivityTypeWeixinShare) {
                if (![[TTWeChatShare sharedWeChatShare] isAvailable]) {
                    [avaliableSequenceArray removeObject:obj];
                    [unAvaliableSequenceArray addObject:obj];
                }
                
            }
            if (objType == TTActivityTypeQQShare){
                if (![[TTQQShare sharedQQShare] isAvailable]) {
                    [avaliableSequenceArray removeObject:obj];
                    [unAvaliableSequenceArray addObject:obj];
                }
            }
            if (objType == TTActivityTypeQQZone) {
                if (![[TTQQShare sharedQQShare] isAvailable]){
                    [avaliableSequenceArray removeObject:obj];
                    [unAvaliableSequenceArray addObject:obj];
                }
            }
//            if (objType == TTActivityTypeDingTalk) {
//                if (![[TTDingTalkShare sharedDingTalkShare] isAvailable]) {
//                    [avaliableSequenceArray removeObject:obj];
//                    [unAvaliableSequenceArray addObject:obj];
//                }
//            }
        }
    }];
    
    NSMutableArray *currentSequenceArray = [[NSMutableArray alloc] initWithArray:avaliableSequenceArray];
    [currentSequenceArray addObjectsFromArray:unAvaliableSequenceArray];
    return [currentSequenceArray copy];
}

- (NSArray *)getOriginalSequnceActivities
{
    NSArray *activityArray = nil;
    if([[NSUserDefaults standardUserDefaults] objectForKey:KShareActivitySequenceArray]){
        activityArray = [[NSUserDefaults standardUserDefaults] objectForKey:KShareActivitySequenceArray];
    }else{
        activityArray = [self.class allNeedSequenceShareActivitys];
    }
    return activityArray;
}

+ (NSArray *)allNeedSequenceShareActivitys
{
    NSArray *exportShareActivities = @[@(TTActivityTypeWeixinMoment),
                                       @(TTActivityTypeWeixinShare),
                                       @(TTActivityTypeQQShare),
                                       @(TTActivityTypeQQZone),
                                       @(TTActivityTypeWeitoutiao),
                                       @(TTActivityTypeDingTalk)
                                       ];
    NSMutableArray *allShareContentActivities = [[NSMutableArray alloc] initWithArray:exportShareActivities];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:KShareActivitySequenceArray]){
        [[NSUserDefaults standardUserDefaults] setObject:[allShareContentActivities copy]forKey:KShareActivitySequenceArray];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return [allShareContentActivities copy];
}


#pragma mark -
#pragma maek - new share pod
- (NSArray *)getAllShareServiceSequence
{
    NSArray *activityArray = [self getOriginalSequenceShareServices];
    NSMutableArray *avaliableSequenceArray = [[NSMutableArray alloc] initWithArray:activityArray];
    NSMutableArray *unAvaliableSequenceArray = [NSMutableArray array];
    
    [activityArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *objType = obj;
            //微信好友
            if ([objType isEqualToString:TTActivityContentItemTypeWechatTimeLine]) {
                if (![[TTWeChatShare sharedWeChatShare] isAvailable]) {
                    [avaliableSequenceArray removeObject:obj];
                    [unAvaliableSequenceArray addObject:obj];
                }
            }
            //微信好友
            if ([objType isEqualToString:TTActivityContentItemTypeWechat]) {
                if (![[TTWeChatShare sharedWeChatShare] isAvailable]) {
                    [avaliableSequenceArray removeObject:obj];
                    [unAvaliableSequenceArray addObject:obj];
                }
                
            }
            if ([objType isEqualToString:TTActivityContentItemTypeQQFriend]){
                if (![[TTQQShare sharedQQShare] isAvailable]) {
                    [avaliableSequenceArray removeObject:obj];
                    [unAvaliableSequenceArray addObject:obj];
                }
            }
            if ([objType isEqualToString:TTActivityContentItemTypeQQZone]) {
                if (![[TTQQShare sharedQQShare] isAvailable]){
                    [avaliableSequenceArray removeObject:obj];
                    [unAvaliableSequenceArray addObject:obj];
                }
            }
//            if ([objType isEqualToString:TTActivityContentItemTypeDingTalk]) {
//                if (![[TTDingTalkShare sharedDingTalkShare] isAvailable]) {
//                    [avaliableSequenceArray removeObject:obj];
//                    [unAvaliableSequenceArray addObject:obj];
//                }
//            }
        }
    }];
    
    NSMutableArray *currentSequenceArray = [[NSMutableArray alloc] initWithArray:avaliableSequenceArray];
    [currentSequenceArray addObjectsFromArray:unAvaliableSequenceArray];
    return [currentSequenceArray copy];
}

- (NSArray *)getOriginalSequenceShareServices {
    NSArray *activityArray = nil;
    if([[NSUserDefaults standardUserDefaults] objectForKey:KShareServiceSequenceArray]){
        activityArray = [[NSUserDefaults standardUserDefaults] objectForKey:KShareServiceSequenceArray];
    }else{
        activityArray = [self.class allNeedSequenceShareServices];
    }
    return activityArray;
}

- (BOOL)instalAllShareServiceSequenceFirstActivity:(NSString *)activityType
{
    BOOL isSuccess = [self synchronizeShareServiceSequenceFirstActivity:activityType];
    if (isSuccess) {
        TTActivityType itemType = [[self class] activityTypeFromStringActivityType:activityType];
        [self synchronizeShareActivitySequenceFirstActivity:itemType];
        SAFECALL_MESSAGE(TTActivityShareSequenceChangedMessage,@selector(message_shareActivitySequenceChanged), message_shareActivitySequenceChanged);
    }
    return YES;
}

- (BOOL)synchronizeShareServiceSequenceFirstActivity:(NSString *)activityType
{
    NSArray *currentSequenceActivities = [self getOriginalSequenceShareServices];
    NSMutableArray *nextSequenceAcitivites = [[NSMutableArray alloc] init];
    
    __block BOOL isfinishSequence = YES;
    if ([activityType isEqualToString:TTActivityContentItemTypeForwardWeitoutiao] ||
        [activityType isEqualToString:TTActivityContentItemTypeWechatTimeLine] || [activityType isEqualToString:TTActivityContentItemTypeWechat] ||
        [activityType isEqualToString:TTActivityContentItemTypeQQZone] || [activityType isEqualToString:TTActivityContentItemTypeQQFriend]) {
        
        [nextSequenceAcitivites addObject:activityType];
        [currentSequenceActivities enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                NSString *objType =(NSString *)obj;
                if (![objType isEqualToString:activityType]) {
                    [nextSequenceAcitivites addObject:obj];
                }
            }else{
                *stop = YES;
                isfinishSequence = NO;
            }
        }];
        if (isfinishSequence) {
            [[NSUserDefaults standardUserDefaults] setObject:[nextSequenceAcitivites copy] forKey:KShareServiceSequenceArray];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return isfinishSequence;
}

+ (NSArray *)allNeedSequenceShareServices
{
    NSArray *exportShareActivities = @[TTActivityContentItemTypeWechatTimeLine,
                                       TTActivityContentItemTypeWechat,
                                       TTActivityContentItemTypeQQFriend,
                                       TTActivityContentItemTypeQQZone,
                                       TTActivityContentItemTypeForwardWeitoutiao
                                       ];
    NSMutableArray *allShareContentActivities = [[NSMutableArray alloc] initWithArray:exportShareActivities];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:KShareServiceSequenceArray]){
        [[NSUserDefaults standardUserDefaults] setObject:[allShareContentActivities copy] forKey:KShareServiceSequenceArray];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return [allShareContentActivities copy];
}

+ (NSString *)activityStringTypeFromActivityType:(TTActivityType)itemType
{
    if (itemType == TTActivityTypeWeixinShare){
        return TTActivityContentItemTypeWechat;
    }else if (itemType == TTActivityTypeWeixinMoment){
        return TTActivityContentItemTypeWechatTimeLine;
    }else if (itemType == TTActivityTypeQQZone){
        return TTActivityContentItemTypeQQZone;
    }else if (itemType == TTActivityTypeQQShare){
        return TTActivityContentItemTypeQQFriend;
    }
//    else if (itemType == TTActivityTypeDingTalk){
//        return TTActivityContentItemTypeDingTalk;
//    }
    else if (itemType == TTActivityTypeWeitoutiao){
        return TTActivityContentItemTypeForwardWeitoutiao;
    }
    return nil;
}

+ (TTActivityType)activityTypeFromStringActivityType:(NSString *)activityTypeString
{
    if ([activityTypeString isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
        return TTActivityTypeWeixinMoment;
    }else if ([activityTypeString isEqualToString:TTActivityContentItemTypeWechat]){
        return TTActivityTypeWeixinShare;
    }else if ([activityTypeString isEqualToString:TTActivityContentItemTypeQQFriend]){
        return TTActivityTypeQQShare;
    }else if ([activityTypeString isEqualToString:TTActivityContentItemTypeQQZone]){
        return TTActivityTypeQQZone;
    }
//    else if ([activityTypeString isEqualToString:TTActivityContentItemTypeDingTalk]){
//        return TTActivityTypeDingTalk;
//    }
    else if ([activityTypeString isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]){
        return TTActivityTypeWeitoutiao;
    }
    return TTActivityTypeNone;
}

+ (TTVActivityShareErrorCode)shareErrorCodeFromItemErrorCode:(NSError *)itemError WithActivity:(id<TTActivityProtocol>)activity
{
    if (itemError) {
        if ([activity.contentItemType isEqualToString:TTActivityContentItemTypeQQFriend] || [activity.contentItemType isEqualToString:TTActivityContentItemTypeQQZone]){
            switch (itemError.code) {
                case kTTQQShareErrorTypeNotInstalled:
                    return TTVActivityShareErrorNotInstalled;
                    break;
                case kTTQQShareErrorTypeNotSupportAPI:
                    return TTVActivityShareErrorUnavaliable;
                    break;
                default:
                    return TTVActivityShareErrorFailed;
                    break;
            }
        }
        else if ([activity.contentItemType isEqualToString:TTActivityContentItemTypeWechat] || [activity.contentItemType isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
            switch (itemError.code) {
                case kTTWeChatShareErrorTypeNotInstalled:
                    return TTVActivityShareErrorNotInstalled;
                    break;
                case kTTWeChatShareErrorTypeNotSupportAPI:
                    return TTVActivityShareErrorUnavaliable;
                    break;
                default:
                    return TTVActivityShareErrorFailed;
                    break;
            }
        }
//        else if ([activity.contentItemType isEqualToString:TTActivityContentItemTypeDingTalk]){
//            switch (itemError.code) {
//                case kTTDingTalkShareErrorTypeNotInstalled:
//                    return TTVActivityShareErrorNotInstalled;
//                    break;
//                case kTTDingTalkShareErrorTypeNotSupportAPI:
//                    return TTVActivityShareErrorUnavaliable;
//                    break;
//                default:
//                    return TTVActivityShareErrorFailed;
//                    break;
//            }
//        }
        
    }
    return TTVActivityShareSuccess;
}
@end
