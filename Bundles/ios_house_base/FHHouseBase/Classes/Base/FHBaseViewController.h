//
//  FHBaseViewController.h
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import <UIKit/UIKit.h>
#import "TTRoute.h"
#import "FHNavBarView.h"
#import "FHErrorView.h"

extern NSString *const TRACER_KEY ;
extern NSString *const VCTITLE_KEY ;

#define WRAP_WEAK(obj) wrap_weak(obj)
#define UNWRAP_WEAK(table)  unwrap_weak(table)

@protocol FHUITracerProtocol <NSObject>

-(NSString *)categoryName;

@end

NS_ASSUME_NONNULL_BEGIN

/*
 Route传参：TTRouteParamObj中的TTRouteUserInfo
 1、VCTITLE_KEY or "title":标题
 2、TRACER_KEY or "tracer":埋点数据
 */
@protocol TTRouteInitializeProtocol;
@class FHTracerModel;

@interface FHBaseViewController : UIViewController <FHUITracerProtocol>

@property(nonatomic , strong) NSMutableDictionary *tracerDict;
@property(nonatomic , strong) FHTracerModel *tracerModel;

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj;

/**
 * 添加导航栏，子类不调用当前方法，表示默认无导航栏
 * @param isDefault 一般传入YES
 */
- (void)setupDefaultNavBar:(BOOL)isDefault; // 子类不调用当前方法，表示默认无导航栏
/**
 * setupCustomNavBar isDefault为NO时支持自定义导航栏
 */
@property (nonatomic, strong) FHNavBarView *customNavBarView;

/**
 * 默认状态栏,UIStatusBarStyleDefault
 */
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/**
 * 默认是NO，加载完数据后记得赋值
 */
@property (nonatomic, assign) BOOL hasValidateData;


/**
 * 空页面，默认是NULL
 * 可以调用addDefaultEmptyViewWithEdgeInsets添加默认空页面
 * 也可以自己创建
 */
@property (nonatomic, strong) FHErrorView *emptyView;
/**
 * 添加默认空页面，默认隐藏
 * @param emptyEdgeInsets 默认是UIEdgeInsetsZero，显示位置是从导航栏底部开始，暂时支持top和bottom的Inset设置
 */
- (void)addDefaultEmptyViewWithEdgeInsets:(UIEdgeInsets)emptyEdgeInsets;
/**
 * 默认空页面时，点击重试调用，自己创建的空页面不回调此方法
 */
- (void)retryLoadData;
/**
 * 空页面重试按钮是否展示，默认是YES
 */
@property (nonatomic, assign) BOOL showenRetryButton;


/**
 * 开始加载中动画，子类调用
 */
- (void)startLoading;
/**
 * 结束加载中动画，给hasValidateData赋值时自动调用
 */
- (void)endLoading;

/**
 * 控制器返回
 */
- (void)goBack;

@end

NS_ASSUME_NONNULL_END
