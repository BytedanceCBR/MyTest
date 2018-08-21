//
//  WDDetailNatantHeaderItemBase.h
//  Article
//
//  Created by Zhang Leonardo on 14-10-23.
//
//  详情浮层 item base view

#import "SSViewBase.h"


@interface WDDetailNatantHeaderItemBase : SSViewBase

/**
 * 浮层item的show事件用到的标记
 */
@property (nonatomic, assign) BOOL hasShown;

/**
 *  构造方法
 *
 *  @param width 传递浮层的宽度
 */
- (id)initWithWidth:(CGFloat)width;

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
- (void)sendShowTrackIfNeededForGroup:(NSString *)groupID withLabel:(NSString *)label;

@end
