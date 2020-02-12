//
//  TTTabbarLoadEpidemicSituatioManager.m
//  TTArticleBase
//
//  Created by liuyu on 2020/2/12.
//

#import "TTTabbarLoadEpidemicSituatioHelper.h"
#import "BDWebImageManager.h"
#import "FHEnvContext.h"

@implementation TTTabbarLoadEpidemicSituatioHelper
+ (void)requestEsituationImageWithImageUrl:(NSString *)url isNormal:(BOOL)isNormal{
    [[BDWebImageManager sharedManager] requestImage:[NSURL URLWithString:url] options:BDImageRequestHighPriority complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
        if (!error && image) {
            YYCache *epidemicSituationCache = [[FHEnvContext sharedInstance].generalBizConfig epidemicSituationCache];
            [epidemicSituationCache setObject:image forKey:isNormal?@"esituationNormalImage":@"esituationHighlightImage"];
        }
    }];
}

+ (void)downloadEpidemicSituationToCacheWithNormalUrl:(NSString *)normalStr highlighthUrl:(NSString *)highlightStr {
    [self requestEsituationImageWithImageUrl:normalStr isNormal:YES];
    [self requestEsituationImageWithImageUrl:highlightStr isNormal:NO];
}
@end
