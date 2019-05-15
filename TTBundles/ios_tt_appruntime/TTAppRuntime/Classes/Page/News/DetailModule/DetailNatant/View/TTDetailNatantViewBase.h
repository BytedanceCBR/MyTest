//
//  TTDetailNatantViewBase.h
//  Article
//
//  Created by Ray on 16/4/11.
//
//

#import "SSThemed.h"

typedef void(^LayoutSubViewsBlock)(BOOL animated);
typedef void(^ScrollInOrOutBlock)(BOOL isVisible);

@protocol TTDetailNatantViewBase <NSObject>
@optional
@property (nonatomic, assign) BOOL hasShow;
@property (nonatomic, copy, nullable) NSString * eventLabel;
@property (nonatomic, copy, nullable) LayoutSubViewsBlock relayOutBlock;
@property (nonatomic, copy, nullable) ScrollInOrOutBlock scrollInOrOutBlock;
-(void)reloadData:(nullable id)object;

-(void)trackEventIfNeeded;

- (void)trackEventIfNeededWithStyle:(NSString * _Nonnull)style;

- (void)checkVisableRelatedArticlesAtContentOffset:(CGFloat)offsetY referViewHeight:(CGFloat)referHeight;

- (void)scrollViewDidEndDraggingAtContentOffset:(CGFloat)offsetY referViewHeight:(CGFloat)referHeight;

- (void)fontChanged;

@end

@interface TTDetailNatantViewBase : SSThemedView<TTDetailNatantViewBase>

@property (nonatomic, assign) BOOL hasShow;
@property (nonatomic, copy, nullable) NSString * eventLabel;
@property (nonatomic, copy, nullable) LayoutSubViewsBlock relayOutBlock;
@property (nonatomic, copy, nullable) ScrollInOrOutBlock scrollInOrOutBlock;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

/**
 *  实现刷新的协议
 *
 *  @param object
 */
-(void)reloadData:(nullable id)object;
/**
 *  打点统计
 */
-(void)trackEventIfNeeded;
/**
 *  检测view是否可见
 */
- (void)checkVisableRelatedArticlesAtContentOffset:(CGFloat)offsetY referViewHeight:(CGFloat)referHeight;
/**
 *  构造方法
 *
 *  @param width 传递浮层的宽度
 */
- (nullable id)initWithWidth:(CGFloat)width;

/**
 *  浮层宽度变化后， 调用该方法， 会引发自身frame的变化
 *
 *  @param width 浮层的宽度
 */
- (void)refreshWithWidth:(CGFloat)width;

/**
 *  刷新UI, 可能会引发自身frame的变化
 */
- (void)refreshUI;

/**
 * 浮层显示时发送track
 */
- (void)sendShowTrackIfNeededForGroup:(nullable NSString *)groupID withLabel:(nullable NSString *)label;

/**
 *  切换字体得到通知
 */
- (void)fontChanged;
@end
