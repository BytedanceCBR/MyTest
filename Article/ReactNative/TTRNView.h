//
//  TTRNView.h
//  Article
//
//  Created by Chen Hong on 16/7/13.
//
//

#import <UIKit/UIKit.h>

static NSString * _Nonnull const kTTRNViewCancelTouchesNotification = @"kTTRNViewCancelTouchesNotification";

typedef NS_ENUM(NSInteger, TTRNViewSizeFlexibility) {
    TTRNViewSizeFlexibilityNone = 0,
    TTRNViewSizeFlexibilityWidth,
    TTRNViewSizeFlexibilityHeight,
    TTRNViewSizeFlexibilityWidthAndHeight,
};

typedef void (^TTRNFatalHandler)(void);

@protocol TTRNViewDelegate <NSObject>

@optional
- (void)rootViewDidChangeIntrinsicSize:(CGSize)size;

//如果业务需要自己建立jsbundle路径,需实现此方法
- (NSURL* _Nullable)RNBundleUrl;

- (NSURL* _Nullable)fallbackSourceURL;

@end

@class TTRNBridge;
@class RCTRootView;
@interface TTRNView : UIView

@property(nonatomic, readonly, nullable) RCTRootView *rootView;
@property(nonatomic, weak, nullable) id<TTRNViewDelegate> delegate;


/**
 *  RNView关联的bridgeModule
 *
 *  @return bridgeModule;
 */
- (TTRNBridge * _Nullable)bridgeModule;

/**
 *  加载内置在应用里的jsBundle
 *
 *  @param moduleName        组件名称
 *  @param initialProperties 初始props
 */
- (void)loadModule:(NSString * _Nonnull)moduleName
 initialProperties:(NSDictionary * _Nullable)initialProperties;

/**
 *  从网络下载jsBundle.zip，解压后使用缓存的jsBundle
 *
 *  @param bundleUrl         zip包地址
 *  @param moduleName        组件名称
 *  @param initialProperties 初始props
 */
//- (void)loadRNViewWithBundleUrl:(NSString * _Nonnull)bundleUrl
//                     moduleName:(NSString * _Nonnull)moduleName
//              initialProperties:(NSDictionary * _Nullable)initialProperties;

/**
 *  更新rootView的props
 *
 *  @param props 静态属性
 */
- (void)updateProperties:(NSDictionary * _Nullable)props;

//- (void)reload;

- (void)refreshSize;

- (void)removeRootViewSuviews;

/**
 *  设置加载view
 *
 *  @param loadingView
 */
- (void)setLoadingView:(UIView * _Nullable)loadingView;

/**
 *  设置rootView的sizeFlexibility
 *
 *  @param sizeFlexibility
 */
- (void)setSizeFlexibility:(TTRNViewSizeFlexibility)sizeFlexibility;

- (void)setFatalHandler:(TTRNFatalHandler _Nullable)handler;

@end

