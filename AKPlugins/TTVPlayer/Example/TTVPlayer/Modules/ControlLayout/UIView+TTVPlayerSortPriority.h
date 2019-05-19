//
//  UIView+TTVPlayerSortPriority.h
//  Article
//
//  Created by yangshaobo on 2018/11/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView(TTVPlayerSortPriority)

/**
 * 需要加到播放器四个角上的 SortContainerView 的 Views 需要设置此优先级，
 * 优先级范围 => [0， inf), 数值越小越靠近左边(竖直的SortContainerView为上边)，默认为0
 */
@property (nonatomic, assign) double ttvPlayerSortContainerPriority;

@end

NS_ASSUME_NONNULL_END
