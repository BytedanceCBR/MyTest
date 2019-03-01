//
//  TTAdDetailViewDefine.h
//  Article
//
//  Created by carl on 2017/6/12.
//
//

#import <Foundation/Foundation.h>

@class ArticleDetailADModel;
@protocol TTAdDetailADViewDelegate;
@class TTAdDetailViewModel;
@protocol  TTAdDetailADView;
@protocol TTAdDetailContainerView;

static const CGFloat kTTAdDetailADContainerLineSpacing = 8;

@protocol TTAdDetailSubviewState <NSObject>
- (void)restoreWithView:(UIView<TTAdDetailADView>*_Nullable)view;
@end

@protocol TTAdDetailContainerViewDelegate  <NSObject>

/**
 详情页浮层 容器 删除子对象接口
 @param natantView 当前被删除的子视图
 @param animated 删除是否需要动画
 */
- (void)removeNatantView:(UIView *_Nonnull)natantView animated:(BOOL)animated;
@end


/**
 广告视图的 容器
 */
@protocol TTAdDetailContainerView
@end

/**
 * 子视图
 */
@protocol TTAdDetailADView <NSObject>

- (nullable instancetype)initWithWidth:(CGFloat)width;

/**
 数据模型
 */
@property (nullable, nonatomic, strong) ArticleDetailADModel *adModel;

/**
 容器
 */
@property (nullable, nonatomic, weak)   id<TTAdDetailADViewDelegate> delegate;

/**
 容器 上下文环境
 */
@property (nullable, nonatomic, strong) TTAdDetailViewModel *viewModel;
@property (nullable, nonatomic, strong) UIView *dislikeView;

+ (CGFloat)heightForADModel:(nonnull ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width;

- (void)didSendShowEvent;
- (void)didSendClickEvent;

/**
 触发 背景点击事件
 */
- (void)sendActionForTapEvent;

/**
 *  判断广告是否滑出页面
 *
 *  @param isVisible 广告是否在屏幕内
 */
- (void)scrollInOrOutBlock:(BOOL)isVisible;
- (void)sendAction:(nullable UIControl*)sender;

@end



/**
 提供广告数据的 容器
 */
@protocol TTAdNatantDataModel <NSObject>

/**
 根据字典获取获取数据

 @param key4Data 数据描述符 例如 kNatantAd
 @return 返回key4Data对应的数据，数据类型根据约定走
 */
- (id _Nullable )adNatantDataModel:(NSString *_Nonnull)key4Data;
@end


/**
  浮层容器应该包含的功能
 */
@protocol TTAdDetailADViewDelegate <NSObject>
@optional
- (void)detailBaseADView:(nonnull UIView<TTAdDetailADView> *)adView didClickWithModel:(nonnull ArticleDetailADModel *)adModel;
- (void)detailBaseADView:(nonnull UIView<TTAdDetailADView> *)adView playInDetailWithModel:(nonnull ArticleDetailADModel *)adModel withProcess:(CGFloat)video_progress;

- (void)dislikeClick:(nonnull ArticleDetailADModel*)adModel;
@end

