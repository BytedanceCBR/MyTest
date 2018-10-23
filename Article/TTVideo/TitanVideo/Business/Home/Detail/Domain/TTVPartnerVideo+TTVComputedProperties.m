//
//  TTVPartnerVideo+TTVComputedProperties.m
//  Article
//
//  Created by pei yun on 2017/5/26.
//
//

#import "TTVPartnerVideo+TTVComputedProperties.h"
#import "SSWebViewController.h"
#import "TTUIResponderHelper.h"

@implementation TTVPartnerVideo (TTVComputedProperties)

- (BOOL)inValid
{
    if (!isEmptyString(self.h5OpenURL)) {
        return (!isEmptyString(self.inBannerOpenImgURL) && !isEmptyString(self.belowBannerOpenImgURL));
    } else {
        return !isEmptyString(self.iosOpenURL) && !isEmptyString(self.iosDownloadURL) && !isEmptyString(self.inBannerOpenImgURL) && !isEmptyString(self.inBannerDownloadImgURL) && !isEmptyString(self.belowBannerOpenImgURL) && !isEmptyString(self.belowBannerDownloadImgURL);
    }
}

- (TTVVideoDetailBannerType)getTTVideoBannerType {
    
    if (!isEmptyString(self.h5OpenURL)) {
        
        return TTVVideoDetailBannerTypeWebDetail;
    }
    
    if ([self installedApp]) {
        
        return TTVVideoDetailBannerTypeOpenApp;
    } else {
        
        return TTVVideoDetailBannerTypeDownloadApp;
    }
}

- (BOOL)installedApp
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.iosOpenURL]];
}

- (void)jumpToAppstore
{
    [self openURL:self.iosDownloadURL];
}

- (void)jumpToOtherApp
{
    [self openURL:self.iosOpenURL];
}

- (void)jumpToWebViewWithView:(UIView *)view {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", self.h5OpenURL]];
    
    if (url) {
        ssOpenWebView(url, url.host, [TTUIResponderHelper topNavigationControllerFor:view], NO, nil);
    }
}

- (BOOL)openURL:(NSString *)url
{
    NSURL *openURL = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:openURL]) {
        return [[UIApplication sharedApplication] openURL:openURL];
    }
    return NO;
}

@end
