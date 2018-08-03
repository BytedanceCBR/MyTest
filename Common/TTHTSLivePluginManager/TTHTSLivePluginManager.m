//
//  TTHTSLivePluginManager.m
//  Article
//
//  Created by 冯靖君 on 16/7/25.
//
//  火山插件的主端管理类，和插件进行数据交互

#import "TTHTSLivePluginManager.h"
#import "TTFirstConcernManager.h"
#import "ArticleCategoryManager.h"
#import "LiveRoomViewController.h"
#import "TTModuleBridge.h"
#import "SSTracker.h"

#define kHTSLiveCategoryID    @"hotsoon"
#define kHTSLiveCategoryName  @"火山直播"
#define kHTSLiveCategoryIndex 3

@implementation TTHTSLivePluginManager

//+ (void)load
//{
//    [[TTModuleBridge sharedInstance_tt] registerAction:kLiveRoomIsHTSLiveCategoryPrioritizedKey withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
//        return @([self _liveRoomViewControllerIsHTSLiveCategoryPrioritized]);
//    }];
//    [[TTModuleBridge sharedInstance_tt] registerAction:kLiveRoomShowFirstConcernAlertKey withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
//        [self _liveRoomViewControllerShowFirstConcernAlertIfNeeded];
//        return nil;
//    }];
//    [[TTModuleBridge sharedInstance_tt] registerAction:kLiveRoomWillAddCategoryKey withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
//        [self _liveRoomViewControllerWillAddHTSLiveCategory];
//        return nil;
//    }];
//    [[TTModuleBridge sharedInstance_tt] registerAction:kLiveRoomCancelAddCategoryKey withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
//        [self _liveRoomViewControllerDidCancelAddHTSLiveCategory];
//        return nil;
//    }];
//}

//- (void)dealloc
//{
//    [TTHTSLivePluginManager destorySharedInstance_tt];
//}

#pragma mark - private

+ (BOOL)_liveRoomViewControllerIsHTSLiveCategoryPrioritized
{
    // 火山频道未添加或位于频道列表排序后50%时
    NSArray <TTCategory *> *categories = [[ArticleCategoryManager sharedManager] subScribedCategories];
    NSInteger maxIndex = MAX((categories.count - 1)/2 + 1, 0);
    for (TTCategory * category in categories) {
        if ([self _isHTSLiveCategory:category] && category.orderIndex < maxIndex) {
            return YES;
        }
    }
    return NO;
}

+ (void)_liveRoomViewControllerShowFirstConcernAlertIfNeeded
{
    if (![TTFirstConcernManager firstTimeGuideEnabled]) {
        return;
    }
    TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
    [manager showFirstConcernAlertViewWithDismissBlock:nil];
}

+ (void)_liveRoomViewControllerWillAddHTSLiveCategory
{
    ArticleCategoryManager *manager = [ArticleCategoryManager sharedManager];
    TTCategory *htsLiveCategory = nil;
    BOOL shouldAdd = [self _hasHTSLiveCategory] ? NO : YES;
    NSArray <TTCategory *> *categories = [self _hasHTSLiveCategory] ? [manager subScribedCategories] : [manager unsubscribeCategories];
    for (TTCategory * category in categories) {
        if ([self _isHTSLiveCategory:category]) {
            htsLiveCategory = category;
            break;
        }
    }
    
    if (!htsLiveCategory) {
        htsLiveCategory = [self insertHotsoonCategoryModel];
    }
    
    if (shouldAdd) {
        [manager subscribe:htsLiveCategory];
        manager.lastAddedCategory = htsLiveCategory;
    }
    
    [manager changeSubscribe:htsLiveCategory toOrderIndex:kHTSLiveCategoryIndex];
    [manager saveWithNotify:NO];
    [manager startGetCategory];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAritlceCategoryGotFinishedNotification object:nil];
    
    ssTrackEvent(@"hotsoon", @"category_add");
}

+ (void)_liveRoomViewControllerDidCancelAddHTSLiveCategory
{
    ssTrackEvent(@"hotsoon", @"category_reject");
}

+ (BOOL)_isHTSLiveCategory:(TTCategory *)category
{
    return [category.categoryID isEqualToString:kHTSLiveCategoryID];
}

+ (BOOL)_hasHTSLiveCategory
{
    NSArray <TTCategory *> *categories = [[ArticleCategoryManager sharedManager] subScribedCategories];
    for (TTCategory * category in categories) {
        if ([self _isHTSLiveCategory:category]) {
            return YES;
        }
    }
    return NO;
}

+ (TTCategory *)insertHotsoonCategoryModel {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:kHTSLiveCategoryID forKey:@"category"];
    [dict setValue:@(kHTSLiveCategoryIndex) forKey:@"order_index"];
    [dict setValue:kHTSLiveCategoryName forKey:@"name"];
    [dict setValue:@(4) forKey:@"type"];
    [dict setValue:@"" forKey:@"web_url"];
    [dict setValue:@(0) forKey:@"flags"];
    
    return [ArticleCategoryManager insertCategoryWithDictionary:dict];
}

@end
