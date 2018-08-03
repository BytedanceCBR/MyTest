//
//  TTVideoBannerModel.h
//  Article
//
//  Created by 刘廷勇 on 16/4/20.
//
//

#import <JSONModel/JSONModel.h>

typedef NS_ENUM(NSUInteger, TTVideoBannerType) {
    TTVideoBannerTypeOpenApp,
    TTVideoBannerTypeDownloadApp,
    TTVideoBannerTypeWebDetail,
};

@interface TTVideoBannerModel : JSONModel

@property (nonatomic, copy) NSString *openURL;
@property (nonatomic, copy) NSString *downloadURL;

@property (nonatomic, copy) NSString *inOpenImgURL;
@property (nonatomic, copy) NSString *inDownloadImgURL;

@property (nonatomic, copy) NSString *belowOpenImgURL;
@property (nonatomic, copy) NSString *belowDownloadImgURL;

@property (nonatomic, copy) NSString *appName;

@property (nonatomic, copy) NSString *h5OpenURL;

- (BOOL)inValid;

- (TTVideoBannerType)getTTVideoBannerType;

- (BOOL)installedApp;
- (void)jumpToAppstore;
- (void)jumpToOtherApp;
- (void)jumpToWebViewWithView:(UIView *)view;

@end
