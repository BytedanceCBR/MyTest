//
//  FHBaseViewController.h
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import <UIKit/UIKit.h>
#import <TTRoute/TTRoute.h>
#import "FHNavBarView.h"
#import "FHErrorView.h"

extern NSString *const TRACER_KEY ;
extern NSString *const VCTITLE_KEY ;

#define WRAP_WEAK(obj) wrap_weak(obj)
#define UNWRAP_WEAK(table)  unwrap_weak(table)

@protocol FHUITracerProtocol <NSObject>

-(NSString *)categoryName;

@end

// 页面间数据传递协议
@protocol FHHouseBaseDataProtocel <NSObject>

- (void)callBackDataInfo:(NSDictionary *)info;

@end

NS_ASSUME_NONNULL_BEGIN

/*
 Route传参：TTRouteParamObj中的TTRouteUserInfo
 1、VCTITLE_KEY or "title":标题
 2、TRACER_KEY or "tracer":埋点数据
 */
@protocol TTRouteInitializeProtocol;
@class FHTracerModel;

@interface FHBaseViewController : UIViewController <FHUITracerProtocol,TTRouteInitializeProtocol>

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
 * 默认是NO，正在加载数据
 */
@property (nonatomic, assign) BOOL isLoadingData;

/**
 * 默认是YES，是否重设statusBar的状态。默认每次新进一个vc都需要设置，但是针对子vc需要和父vc行为一致，这时候需要设置这个字段来控制
 */
@property (nonatomic, assign) BOOL isResetStatusBar;


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
 * 添加默认空页面，全屏,忽略导航栏
 */
- (void)addDefaultEmptyViewFullScreen;

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

/**
 * 支持禁止Push跳转（与TopVC是同一个VC以及，参数相同的页面），默认是NO（走之前逻辑）
 * 当Push来了后，如果当前顶部VC与Push不是同一个或者参数不同（比如和不同的经纪人聊天），则新建页面
 * 用于判断页面是否是同一个页面
 * 不需要重写
 */
- (BOOL)isSamePageAndParams:(NSURL *)openUrl;
/**
 * 子类重载当前页面
 * 用于判断页面参数是否相同
 */
- (BOOL)isOpenUrlParamsSame:(NSDictionary *)queryParams;


/// 定制Loading动画
/// @param inView 展示loading动画的宿主视图
- (void)showLoading:(UIView *_Nullable)inView;

- (void)showLoading:(UIView *_Nullable)inView offset:(CGPoint)offset;

- (void)hideLoading;

@end

NSHashTable *wrap_weak(NSObject * obj);
NSObject *unwrap_weak(NSHashTable *table);

NS_ASSUME_NONNULL_END
