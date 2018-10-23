//
//  FRDetailNatantPaddingView.h
//  Article
//
//  Created by 王霖 on 4/25/16.
//
//

//#import "TTDetailNatantViewBase.h"
#import "SSThemed.h"
#import "TTUGCDetailNatantViewBaseProtocol.h"

@interface FRDetailNatantPaddingView : SSThemedView<TTUGCDetailNatantViewBaseProtocol>

@property(nonatomic, assign)CGFloat paddingHeight;

//- (instancetype)initWithWidth:(CGFloat)width;

@property (nonatomic, assign) BOOL hasShow;
@property (nonatomic, copy, nullable) NSString * eventLabel;
@property (nonatomic, copy, nullable) UGCLayoutSubViewsBlock relayOutBlock;
@property (nonatomic, copy, nullable) UGCScrollInOrOutBlock scrollInOrOutBlock;
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
