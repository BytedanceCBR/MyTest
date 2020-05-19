//
//  BDWebViewDetectBlankContent.h
//  BDWebKit
//
//  Created by 杨牧白 on 2020/3/13.
//

#import <Foundation/Foundation.h>
@import WebKit;

typedef NS_ENUM(NSInteger, BDDetectBlankStatus)
{
    eBDDetectBlankStatusImageError = 1,   //旧的检测接口，生成图片失败
    eBDDetectBlankStatusNewAPIError ,     //新的检测接口，API返回失败
    eBDDetectBlankUnsupportError,         //不支持检测，UI或WKiOS11以下 needOldSapshotDetect设置强制不检测，直接返回NO
    eBDDetectBlankStatusSuccess = 100,
};

NS_ASSUME_NONNULL_BEGIN

@interface BDWebViewBlankDetect : NSObject

/// WKWebView 白屏检测方案，效率更高（推荐）
/// @param wkWebview 被检测的WKWebView
/// @param block 返回检测结果
+ (void)detectBlankByNewSnapshotWithWKWebView:(WKWebView *)wkWebview CompleteBlock:(void(^)(BOOL isBlank, UIImage *image, NSError *error)) block;

/// 通用白屏检测方案
/// @param view 被检测的View
/// @param block 返回检测结果
+ (void)detectBlankByOldSnapshotWithView:(UIView *)view CompleteBlock:(void(^)(BOOL isBlank, UIImage *image, NSError *error)) block;
@end

NS_ASSUME_NONNULL_END
