//
//  TTVPartnerVideo+TTVComputedProperties.h
//  Article
//
//  Created by pei yun on 2017/5/26.
//
//

#import <TTVideoService/VideoInformation.pbobjc.h>

typedef NS_ENUM(NSUInteger, TTVVideoDetailBannerType) {
    TTVVideoDetailBannerTypeOpenApp,
    TTVVideoDetailBannerTypeDownloadApp,
    TTVVideoDetailBannerTypeWebDetail,
};

@interface TTVPartnerVideo (TTVComputedProperties)

- (BOOL)inValid;
- (TTVVideoDetailBannerType)getTTVideoBannerType;

- (BOOL)installedApp;
- (void)jumpToAppstore;
- (void)jumpToWebViewWithView:(UIView *)view;
- (void)jumpToOtherApp;

@end

