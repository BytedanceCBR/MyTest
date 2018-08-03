//
//  TTDetailWebviewGIFManager.h
//  Pods
//
//  Created by xushuangqing on 2017/8/7.
//
//

#import <Foundation/Foundation.h>
#import "FLAnimatedImageView.h"
#import "SSThemed.h"

@class TTDetailWebviewContainer, TTImageInfosModel, SSJSBridgeWebView;

@protocol TTDetailWebviewGIFManagerDelegate;

@interface TTDetailWebviewGIFManager : NSObject

@property (nonatomic, weak) id<TTDetailWebviewGIFManagerDelegate> delegate;/*预计为TTDetailWebviewContainer*/

+ (void)setDetailViewGifNativeEnabled:(BOOL)enabled;
+ (BOOL)isDetailViewGifNativeEnabled;

- (instancetype)initWithWebview:(SSJSBridgeWebView *)webview isInWindow:(BOOL)inWindow;

- (void)handleWebviewContainerDidDisappear;
- (void)handleWebviewContainerWillAppear;
- (void)handleContainerScrollViewScroll:(SSThemedScrollView *)containerScrollView inContainer:(TTDetailWebviewContainer *)container;

/*
 预计在
 - (void)p_webViewShowImageForModel:(TTImageInfosModel *)model
 imageIndex:(NSInteger)index
 imageType:(JSMetaInsertImageType)type
 中拦截将图片传给webview的事件
 */
- (BOOL)shouldUseNativeGIFPlayer:(TTImageInfosModel *)model imageIndex:(NSInteger)index;

- (void)resumeGifView:(UIView *)gifView;
- (void)pauseGifView:(UIView *)gifView;

@end

@protocol TTDetailWebviewGIFManagerDelegate <NSObject>

- (BOOL)gifManager:(TTDetailWebviewGIFManager *)gifManager isFrameInSight:(CGRect)frame;
- (void)gifManager:(TTDetailWebviewGIFManager *)gifManager gifViewDidMoveToSight:(UIView *)gifView;
- (void)gifManager:(TTDetailWebviewGIFManager *)gifManager gifViewDidRemovedFromSight:(UIView *)gifView;
- (void)gifManager:(TTDetailWebviewGIFManager *)gifManager gifView:(UIView *)gifView willUpdateFrame:(CGRect)newFrame;

@end
