//
//  FHWebViewConfigProtocol.h
//  FHWebView
//
//  Created by 谢思铭 on 2019/5/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FHAppVersion)
{
    FHAppVersionC = 0,
    FHAppVersionB,
};

@protocol FHWebViewConfigProtocol <NSObject>

+ (FHAppVersion)appVersion;

+ (UIColor *)progressViewLineFillColor;

- (void)showEmptyView;

- (void)hideEmptyView;

@end

NS_ASSUME_NONNULL_END
