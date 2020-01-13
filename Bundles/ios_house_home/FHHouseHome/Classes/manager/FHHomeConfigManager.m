//
//  FHHomeConfigManager.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeConfigManager.h"
#import "TTRoute.h"
#import <TTArticleCategoryManager.h>
#import "FHEnvContext.h"
#import "TTNetworkManager.h"

#define kFHHomeHouseMixedCategoryID   @"f_house_news" // 推荐频道

@interface FHHomeConfigManager()

@property(nonatomic , strong) id fhHomeBridge;

@end

@implementation FHHomeConfigManager

+(instancetype)sharedInstance
{
    static FHHomeConfigManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FHHomeConfigManager alloc] init];
    });
    return manager;
}

- (void)openCategoryFeedStart
{
    NSString * categoryStartName = nil;

    if ([[[FHHomeConfigManager sharedInstance] fhHomeBridgeInstance] respondsToSelector:@selector(feedStartCategoryName)]) {
        categoryStartName = [[self fhHomeBridgeInstance] feedStartCategoryName];
    }
    if ([categoryStartName isEqualToString:@"f_find_house"] && [[[TTArticleCategoryManager sharedManager] allCategories] containsObject:[TTArticleCategoryManager categoryModelByCategoryID:@"f_find_house"]]) {
        if ([[[FHHomeConfigManager sharedInstance] fhHomeBridgeInstance] respondsToSelector:@selector(currentSelectCategoryName)]) {
            self.isNeedTriggerPullDownUpdateFowFindHouse = YES;
        }
    }else
    {
        if ([categoryStartName isEqualToString:[TTArticleCategoryManager currentSelectedCategoryID]]) {
            self.isNeedTriggerPullDownUpdate = NO;
        }else
        {
            self.isNeedTriggerPullDownUpdate = YES;
        }
    }
    
    if (categoryStartName == nil) {
        BOOL isHasFindHouseCategory = [[[TTArticleCategoryManager sharedManager] allCategories] containsObject:[TTArticleCategoryManager categoryModelByCategoryID:kNIHFindHouseCategoryID]];
        if (isHasFindHouseCategory) {
            categoryStartName = kNIHFindHouseCategoryID;
        }else
        {
            categoryStartName = kNIHFeedHouseMixedCategoryID;
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *openUrl = [NSString stringWithFormat:@"snssdk1370://category_feed?category=%@",categoryStartName];
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:openUrl] userInfo:nil];
        });
    });
}

- (id<FHHomeBridgeProtocol>)fhHomeBridgeInstance
{
    if (!_fhHomeBridge) {
        Class classBridge = NSClassFromString(@"FHHomeBridgeImp");
        if (classBridge) {
            _fhHomeBridge = [[classBridge alloc] init];
        }
    }
    return _fhHomeBridge;
}

@end
