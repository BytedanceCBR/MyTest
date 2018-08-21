//
//  TTDetailWebViewRequestProcessorDelegate.h
//  Pods
//
//  Created by muhuai on 2017/4/27.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TTDetailWebviewContainerDefine.h"


@protocol TTDetailWebViewRequestProcessorDelegate <NSObject>

@optional

/**
 *  domReady 事件
 */
- (void)processRequestReceiveDomReady;


/**
 *  打开一个webview
 *
 *  @param url     webview的URL
 *  @param support 是否支持旋转
 */
- (void)processRequestOpenWebViewUseURL:(nullable NSURL *)url supportRotate:(BOOL)support;
/**
 *  显示一个提示的tip
 *
 *  @param tipMsg  需要提示的字符串
 */
- (void)processRequestShowTipMsg:(nullable NSString *)tipMsg;

/**
 *  显示一个提示及icon的tip
 *
 *  @param tipMsg  需要提示的字符串
 */
- (void)processRequestShowTipMsg:(nullable NSString *)tipMsg icon:(nullable UIImage *)image;

/**
 *  需要重新加载web类型内容
 *
 */
- (void)processRequestNeedLoadWebTypeContent;
/**
 *  在大图浏览页现实大图
 *
 *  @param index       从哪张图片开始浏览
 *  @param frameValue 图片在详情页上的位置（for animation, optional）
 */
- (void)processRequestShowImgInPhotoScrollViewAtIndex:(NSUInteger)index withFrameValue:(nullable NSValue *)frameValue;
/**
 *  执行JS
 *
 *  @param jsStr   待执行的JS
 */
- (void)processRequestStringByEvaluatingJavaScriptFromString:(nullable NSString *)jsStr;

/**
 *  显示用户主页
 *
 *  @param userID  用户ID
 */
- (void)processRequestShowUserProfileForUserID:(nullable NSString *)userID;

/**
 *  打开应用商店
 *
 *  @param actionURL 应用商店的URL
 *  @param appleID   应用商店的ID
 */
- (void)processRequestOpenAppStoreByActionURL:(nullable NSString *)actionURL itunesID:(nullable NSString *)appleID;
/**
 *  显示PGC主页
 *
 *  @param paramsDict 进入PGC主页所需的参数，如media ID
 */
- (void)processRequestShowPGCProfileWithParams:(nullable NSDictionary *)paramsDict;
/**
 *  显示搜索
 *
 *  @param query   查询词
 *  @param type    来源类型
 *  @param index   位置
 */
#warning ListDataHeader ListDataSearchFromType
- (void)processRequestShowSearchViewWithQuery:(nullable NSString *)query fromType:(NSInteger)type index:(NSUInteger)index;

/**
 *  修改article 的 imagemode
 *
 */
- (void)processRequestUpdateArticleImageMode:(nullable NSNumber*)mode;

@end
