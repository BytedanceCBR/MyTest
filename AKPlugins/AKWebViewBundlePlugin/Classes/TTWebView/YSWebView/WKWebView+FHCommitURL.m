//
//  WKWebView+FHCommitURL.m
//  AKWebViewBundlePlugin
//
//  Created by bytedance on 2020/12/29.
//

#import "WKWebView+FHCommitURL.h"
#import <objc/runtime.h>

@implementation WKWebView (FHCommitURL)

- (void)setFh_commitURL:(NSURL *)fh_commitURL {
    objc_setAssociatedObject(self, @selector(fh_commitURL), fh_commitURL, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSURL *)fh_commitURL {
    return objc_getAssociatedObject(self, _cmd);
}

@end
