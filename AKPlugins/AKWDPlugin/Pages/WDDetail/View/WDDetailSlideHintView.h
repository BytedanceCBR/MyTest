//
//  WDDetailSlideHintView.h
//  Article
//
//  Created by wangqi.kaisa on 2017/6/26.
//
//

#import "SSThemed.h"

/*
 * 6.26 滑动提示view
 * 8.3  改成新版动画样式
 * 8.11 修改动画时间
 */

@protocol WDDetailSlideHintViewDelegate <NSObject>

- (void)wdDetailSlideHintViewSlideTrigger;
- (void)wdDetailSlideHintViewWillDismiss;

@end

@interface WDDetailSlideHintView : SSThemedView

@property (nonatomic, weak) id<WDDetailSlideHintViewDelegate>delegate;

- (void)setSlideHintViewIfNeeded;

@end
