//
//  TTActivitiesManager.m
//  TTActivityViewControllerDemo
//
//  Created by 延晋 张 on 16/6/1.
//
//

#import <objc/runtime.h>
#import "TTActivitiesManager.h"
#import "TTActivityProtocol.h"
#import "TTActivityContentItemProtocol.h"

@interface TTActivitiesManager ()

//只存储分享类型Activity 不存储分享内容activityContentItem
@property (nonatomic, strong) NSMutableArray *validActivitiesArray;

@end

@implementation TTActivitiesManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static TTActivitiesManager * sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        _validActivitiesArray = [NSMutableArray arrayWithArray:[self sharePodSupportActivities]];
    }
    return self;
}

- (void)addValidActivitiesFromArray:(NSArray *)activities
{
    for (id <TTActivityProtocol> activity in activities) {
        [self addValidActivity:activity];
    }
}

- (void)addValidActivity:(id <TTActivityProtocol>)activity
{
    BOOL hasThisClass = NO;
    for (id <TTActivityProtocol> activity_inArray in _validActivitiesArray) {
        if ([NSStringFromClass([activity class]) isEqualToString:NSStringFromClass([activity_inArray class])]) {
            hasThisClass = YES;
            break;
        }
    }
    //保证每种分享类型，只加一次
    if (!hasThisClass) {
        [_validActivitiesArray addObject:activity];
    }
}

- (NSMutableArray *)sharePodSupportActivities
{
    NSMutableArray *sharePodSupportActivities = [NSMutableArray array];
    for (NSString *activityNameString in [self allPodSupportActivitiesString]) {
        id activityObj = [[NSClassFromString(activityNameString) alloc] init];
        if (activityObj) {
            [sharePodSupportActivities addObject:activityObj];
        }
    }
    return sharePodSupportActivities;
}

- (NSArray *)allPodSupportActivitiesString
{
    return @[@"TTSinaWeiboActivity",
             @"TTWechatActivity",
             @"TTWechatTimelineActivity",
             @"TTZhiFuBaoActivity",
             @"TTSMSActivity",
             @"TTQQFriendActivity",
             @"TTQQZoneActivity",
             @"TTEmailActivity",
             @"TTSystemActivity",
             @"TTCopyActivity",
             @"TTDingTalkActivity"];
}

- (NSArray *)validActivitiesForContent:(NSArray *)contentArray
{
    NSMutableArray *activities = [NSMutableArray array];
    for (id object in contentArray) {
        if ([object isKindOfClass:[NSArray class]]) {
            [activities addObject:[self validActivitiesForContent:object]];
        } else if ([object conformsToProtocol:@protocol(TTActivityContentItemProtocol)]) {
            id <TTActivityContentItemProtocol> item = object;
            id <TTActivityProtocol> activity = [self getActivityByItem:item];
            if (activity) {
                [activities addObject:activity];
            }
        }
    }
    return [activities copy];
}

- (id <TTActivityProtocol>)getActivityByItem:(id <TTActivityContentItemProtocol>)item
{
    for (id <TTActivityProtocol> activity in _validActivitiesArray) {
        if ([[activity contentItemType] isEqualToString:item.contentItemType]) {
            activity.contentItem = item;
            return activity;
        }
    }
    return nil;
}

@end
