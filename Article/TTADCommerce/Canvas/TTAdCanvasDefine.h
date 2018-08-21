//
//  TTAdCanvasDefine.h
//  Article
//
//  Created by carl on 2017/5/21.
//
//

#import <Foundation/Foundation.h>

extern NSString *const kTTCanvasSourceImageModel;
extern NSString *const kTTCanvasSourceImageInfo;
extern NSString *const kTTCanvasSourceImageFrame;
extern NSString *const kTTCanvasProjectModel;
extern NSString *const kTTCanvasFeedData;
extern NSErrorDomain kTTAdCanvasErrorDomain;

extern NSString * const kCanvasDetailPage;
extern NSString * const kTTAdCanvasReatModule;
extern NSString * const kTTAdCanvasStyle;

#define startAnimationDuration 0.32
#define sourceImageViewTag 1001
#define toImageViewTag 1002

static CGFloat const kNavigationBarHeight = 44.0f;

@class TTAdCanvasTracker;
@class TTAdCanvasViewModel;
@protocol TTAdCanvasVCDelegate;

typedef NS_ENUM(NSInteger, TTAdCanvasMIME) {
    TTAdCanvasMIMEUnknow = 0,
    TTAdCanvasMIMEText,
    TTAdCanvasMIMEPic,
    TTAdCanvasMIMEGroupPic,
    TTAdCanvasMIMEFullPic,
    TTAdCanvasMIMEVideo,
    TTAdCanvasMIMELive,
    TTAdCanvasMIMEButton
};

/**
 沉浸式页面打开策略 控制
 */
typedef NS_ENUM(NSInteger, TTAdCanvasOpenStrategy) {
    TTAdCanvasOpenStrategyImmediately = 1,  // 不检查资源预加载情况(layout 还是需要的) 立即打开
    TTAdCanvasOpenStrategyFirstScreen = 2,  // 已经预加载首屏资源 must_url
    TTAdCanvasOpenStrategyAllResource = 3   // 已经预加载所有资源
};

/**
 页面打开动画形式
 */
typedef NS_ENUM(NSInteger, TTAdCanvasOpenAnimation) {
    TTAdCanvasOpenAnimationPush = 0,    // 系统默认动画
    TTAdCanvasOpenAnimationMoveUp = 1,  // 普通视图动画
    TTAdCanvasOpenAnimationScale = 2    // 全景大图 打开模式
};

/**
 采用具体详情页类型
 */
typedef NS_ENUM(NSInteger, TTAdCanvasDetailViewStyle) {
    TTAdCnavasDetailViewStyleRN = 0,        // 采用RN 详情页
    TTAdCnavasDetailViewStyleNative = 1,    // Native 直接解析 layout file
    TTAdCnavasDetailViewStyleWeb = 2,       // article_url web 打开
    TTAdCnavasDetailViewStyleNone = -1      // bug
};

@protocol TTAdCanvasVCDelegate <NSObject>

- (void)canvasVCShowEndAnimation:(CGRect)sourceFrame sourceImageModel:(TTImageInfosModel *)souceImageInfo toFrame:(CGRect)toFrame toImageModel:(TTImageInfosModel *)toImageInfoModel complete:(void(^)(BOOL))completion;

@end

@protocol TTAdCanvasViewController
@property (nonatomic, strong) TTAdCanvasTracker *tracker;
@property (nonatomic, weak) id<TTAdCanvasVCDelegate> delegate;
@property (nonatomic, strong) TTAdCanvasViewModel *viewModel;

- (void)reloadState:(TTAdCanvasViewModel *)viewModel;
@end

typedef NS_ENUM(NSInteger, TTAdCnavasOpenErrorCode) {
    TTAdCnavasOpenErrorCodeLayout = 1,
    TTAdCnavasOpenErrorCodeImage,
    TTAdCnavasOpenErrorCodeNotfound,
    TTAdCnavasOpenErrorCodeNotSupport,
    TTAdCnavasOpenErrorCodeFatal
};
