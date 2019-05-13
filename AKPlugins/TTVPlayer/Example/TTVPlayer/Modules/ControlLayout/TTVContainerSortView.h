//
//  TTVContainerSortView.h
//  Article
//
//  Created by yangshaobo on 2018/11/7.
//

#import <UIKit/UIKit.h>
#import "UIView+TTVPlayerSortPriority.h"
#import "TTVPlayerKeyView.h"

typedef NS_ENUM(NSUInteger, TTVContainerSortViewLayoutDirection) {
    TTVContainerSortViewLayoutDirectionVertical = 0,
    TTVContainerSortViewLayoutDirectionHorizontal
};

@interface TTVContainerSortView : TTVPlayerKeyView

@property (nonatomic, assign) CGFloat spacing;

@property (nonatomic, assign, readonly) NSUInteger countOfSortedViews;

- (instancetype)initWithLayoutDirection:(TTVContainerSortViewLayoutDirection)layoutDirection spacing:(CGFloat)spacing;

- (void)addView:(UIView *)view;

@end

