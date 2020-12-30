//
//  WKWebView+FHCommitURL.h
//  AKWebViewBundlePlugin
//
//  Created by bytedance on 2020/12/29.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (FHCommitURL)

@property (nonatomic, copy) NSURL *fh_commitURL;

@end

NS_ASSUME_NONNULL_END
