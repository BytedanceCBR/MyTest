//
//  TTTabbarLoadEpidemicSituatioManager.m
//  TTArticleBase
//
//  Created by liuyu on 2020/2/12.
//

#import "TTTabbarLoadEpidemicSituatioHelper.h"
#import "BDWebImageManager.h"
#import "FHEnvContext.h"
#import "TTTabBarManager.h"
#import "TTTabBarItem.h"
#import "TTArticleTabBarController.h"

@implementation TTTabbarLoadEpidemicSituatioHelper
+ (void)requestEsituationImageWithImageUrl:(NSString *)url isNormal:(BOOL)isNormal{
    [[BDWebImageManager sharedManager] requestImage:[NSURL URLWithString:url] options:BDImageRequestHighPriority complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
        YYCache *epidemicSituationCache = [[FHEnvContext sharedInstance].generalBizConfig epidemicSituationCache];
        if (!error && image) {
            [epidemicSituationCache setObject:image forKey:isNormal?@"esituationNormalImage":@"esituationHighlightImage"];
        }else {
            [epidemicSituationCache setObject:nil forKey:isNormal?@"esituationNormalImage":@"esituationHighlightImage"];
        }
    }];
}

+ (void)downloadEpidemicSituationToCacheWithNormalUrl:(NSString *)normalStr highlighthUrl:(NSString *)highlightStr {
    [self requestEsituationImageWithImageUrl:normalStr isNormal:YES];
    [self requestEsituationImageWithImageUrl:highlightStr isNormal:NO];
}

+ (void)checkConfigEpidemicSituatiData:(FHConfigCenterTabModel *)opTab {
     YYCache *epidemicSituationCache = [[FHEnvContext sharedInstance].generalBizConfig epidemicSituationCache];
    FHConfigCenterTabModel *cacheTab = [epidemicSituationCache objectForKey:@"tab_cache"];
    opTab = [self placeholderModel:opTab];
    cacheTab = [self placeholderModel:cacheTab];
    if (![opTab.tabId isEqualToString:cacheTab.tabId]) {
        NSMutableArray *items = [[TTTabBarManager sharedTTTabBarManager].tabItems mutableCopy];
        [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TTTabBarItem *item = obj;
            if ([item.identifier isEqualToString:kFHouseHouseEpidemicSituationTabKey]) {
                item.freezed = YES;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                          TTArticleTabBarController *rootVC = (TTArticleTabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
                      [rootVC updateTabBarControllerWithAutoJump:YES];
              });
        }];
        if (opTab.title.length>4) {
            opTab.title = [opTab.title substringToIndex:4];
        }
        opTab.isShow = false;
        [epidemicSituationCache setObject:opTab forKey:@"tab_cache"];
        [self downloadEpidemicSituationToCacheWithNormalUrl:opTab.staticImage.url highlighthUrl:opTab.activationimage.url];
    }
}

+ (FHConfigCenterTabModel *)placeholderModel:(FHConfigCenterTabModel *)currentModel {
    if (currentModel == nil) {
        currentModel = [[FHConfigCenterTabModel alloc]init];
        currentModel.tabId = @"";
        currentModel.enable = false;
        currentModel.isShow = false;
        currentModel.openUrl = @"";
        currentModel.logPb = @"";
        currentModel.staticImage = @{};
        currentModel.activationimage = @{};
    }
    return currentModel;
}

@end
