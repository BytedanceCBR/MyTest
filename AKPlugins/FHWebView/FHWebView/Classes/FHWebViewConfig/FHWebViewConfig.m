//
//  FHWebViewConfig.m
//  FHWebView
//
//  Created by 谢思铭 on 2019/5/15.
//

#import "FHWebViewConfig.h"
#import "UIColor+Theme.h"

@implementation FHWebViewConfig

+ (instancetype)sharedInstance {
    static FHWebViewConfig *_sharedInstance = nil;
    if (!_sharedInstance){
        _sharedInstance = [[FHWebViewConfig alloc] init];
    }
    return _sharedInstance;
}

+ (UIColor *)progressViewLineFillColor {
    return [UIColor themeRed1];
}

+ (FHAppVersion)appVersion {
    return FHAppVersionC;
}

- (void)showEmptyView:(UIView *)view {
    
}

- (void)hideEmptyView {
    
}

- (void)showLoading:(UIView *)view {
    
}

- (void)hideLoading {
    
}

+ (UILabel *)defaultTitleView {
    return nil;
}

@end
