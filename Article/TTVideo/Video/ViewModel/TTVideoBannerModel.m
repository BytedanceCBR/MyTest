//
//  TTVideoBannerModel.m
//  Article
//
//  Created by 刘廷勇 on 16/4/20.
//
//

#import "TTVideoBannerModel.h"
#import "SSWebViewController.h"


@implementation TTVideoBannerModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper *)keyMapper
{
    NSDictionary *dict = @{@"ios_open_url"                  : @"openURL",
                           @"ios_download_url"              : @"downloadURL",
                           @"in_banner_open_img_url"        : @"inOpenImgURL",
                           @"in_banner_download_img_url"    : @"inDownloadImgURL",
                           @"below_banner_open_img_url"     : @"belowOpenImgURL",
                           @"below_banner_download_img_url" : @"belowDownloadImgURL",
                           @"h5_open_url"                   : @"h5OpenURL"};
    return [[JSONKeyMapper alloc] initWithDictionary:dict];
}

- (BOOL)inValid
{
    if (!isEmptyString(self.h5OpenURL)) {
        
        return (!isEmptyString(self.inOpenImgURL) && !isEmptyString(self.belowOpenImgURL));
    } else {
        return !isEmptyString(self.openURL) && !isEmptyString(self.downloadURL) && !isEmptyString(self.inOpenImgURL) && !isEmptyString(self.inDownloadImgURL) && !isEmptyString(self.belowOpenImgURL) && !isEmptyString(self.belowDownloadImgURL);
    }
}

- (TTVideoBannerType)getTTVideoBannerType {
    
    if (!isEmptyString(self.h5OpenURL)) {
        
        return TTVideoBannerTypeWebDetail;
    }
    
    if ([self installedApp]) {
        
        return TTVideoBannerTypeOpenApp;
    } else {
        
        return TTVideoBannerTypeDownloadApp;
    }
}

- (BOOL)installedApp
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.openURL]];
}

- (void)jumpToAppstore
{
    [self openURL:self.downloadURL];
}

- (void)jumpToOtherApp
{
    [self openURL:self.openURL];
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
