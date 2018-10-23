//
//  TSVVideoShareManager.m
//  HTSVideoPlay
//
//  Created by dingjinlu on 2017/11/30.
//

#import "TSVVideoShareManager.h"
#import "TTShareManager.h"
#import "TTWechatTimelineContentItem.h"
#import "TTWechatContentItem.h"
#import "TTQQFriendContentItem.h"
#import "TTQQZoneContentItem.h"
#import "TTFavouriteContentItem.h"
#import "TTReportContentItem.h"
#import "TTDislikeContentItem.h"
//#import "TTSystemContentItem.h"
//#import "TTCopyContentItem.h"
//#import "TTSaveVideoContentItem.h"
#import "TTForwardWeitoutiaoContentItem.h"
//#import "TTDingTalkContentItem.h"

#define KShareServiceSequenceArray @"kShareServiceSequenceArray"

@implementation TSVVideoShareManager

+ (NSArray<id<TTActivityContentItemProtocol>> *)synchronizeUserDefaultsWithItemArray:(NSArray *)array
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:KShareServiceSequenceArray]) {
        NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:[array count]];
        
        NSArray *localArray = [[NSUserDefaults standardUserDefaults] objectForKey:KShareServiceSequenceArray];
        [localArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *activityType = obj;
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                id<TTActivityContentItemProtocol> item = obj;
                if ([[item contentItemType] isEqualToString:activityType]) {
                    [itemArray addObject:item];
                }
            }];
        }];
        return itemArray;
    } else {
        return array;
    }
}

+ (void)synchronizeUserDefaultsWithAvtivityType:(NSString *)activityType
{
    NSArray *currentSequenceActivities = [self getOriginalSequenceShareServices];
    NSMutableArray *nextSequenceAcitivites = [[NSMutableArray alloc] init];
    
    __block BOOL isfinishSequence = YES;
    if ([[[self class] allNeedSequenceShareServices] containsObject:activityType]) {
        
        [nextSequenceAcitivites addObject:activityType];
        [currentSequenceActivities enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                NSString *objType =(NSString *)obj;
                if (![objType isEqualToString:activityType]) {
                    [nextSequenceAcitivites addObject:obj];
                }
            } else {
                *stop = YES;
                isfinishSequence = NO;
            }
        }];
        if (isfinishSequence) {
            [[NSUserDefaults standardUserDefaults] setObject:[nextSequenceAcitivites copy] forKey:KShareServiceSequenceArray];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

+ (NSArray *)getOriginalSequenceShareServices
{
    NSArray *activityArray = nil;
    if([[NSUserDefaults standardUserDefaults] objectForKey:KShareServiceSequenceArray]){
        activityArray = [[NSUserDefaults standardUserDefaults] objectForKey:KShareServiceSequenceArray];
    }else{
        activityArray = [self allNeedSequenceShareServices];
    }
    return activityArray;
}

+ (NSArray *)allNeedSequenceShareServices
{
    NSArray *exportShareActivities = @[TTActivityContentItemTypeWechatTimeLine,
                                       TTActivityContentItemTypeWechat,
                                       TTActivityContentItemTypeForwardWeitoutiao,
                                       TTActivityContentItemTypeQQFriend,
                                       TTActivityContentItemTypeQQZone,
                                       ];
    NSMutableArray *allShareContentActivities = [[NSMutableArray alloc] initWithArray:exportShareActivities];
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:KShareServiceSequenceArray]){
        [[NSUserDefaults standardUserDefaults] setObject:[allShareContentActivities copy] forKey:KShareServiceSequenceArray];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return [allShareContentActivities copy];
}

@end

