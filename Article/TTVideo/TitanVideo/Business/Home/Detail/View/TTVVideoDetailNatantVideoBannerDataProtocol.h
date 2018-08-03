//
//  TTVVideoDetailNatantVideoBannerDataProtocol.h
//  Article
//
//  Created by pei yun on 2017/5/26.
//
//

#ifndef TTVVideoDetailNatantVideoBannerDataProtocol_h
#define TTVVideoDetailNatantVideoBannerDataProtocol_h

#import "TTVPartnerVideo+TTVComputedProperties.h"

@protocol TTVVideoDetailNatantVideoBannerDataProtocol <NSObject>

@property (nonatomic, copy, readonly) NSString *iosOpenURL;

@property (nonatomic, copy, readonly) NSString *inBannerOpenImgURL;
@property (nonatomic, copy, readonly) NSString *inBannerDownloadImgURL;

@property (nonatomic, copy, readonly) NSString *belowBannerOpenImgURL;
@property (nonatomic, copy, readonly) NSString *belowBannerDownloadImgURL;

@property (nonatomic, copy) NSString *appName;

- (BOOL)inValid;
- (TTVVideoDetailBannerType)getTTVideoBannerType;

- (BOOL)installedApp;
- (void)jumpToAppstore;
- (void)jumpToOtherApp;
- (void)jumpToWebViewWithView:(UIView *)view;
@end

#endif /* TTVVideoDetailNatantVideoBannerDataProtocol_h */
