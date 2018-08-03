//
//  TTHTSHeaderScrollView.h
//  Article
//
//  Created by 王双华 on 2017/5/10.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTHeaderViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class TTHTSHeaderScrollView;

@protocol TTHTSHeaderScrollViewDelegate <UIScrollViewDelegate>

@optional
- (BOOL)headerScrollView:(TTHTSHeaderScrollView *)headerScrollView shouldScrollWithScrollView:(UIScrollView *)scrollView;

@end

@interface TTHTSHeaderScrollView : SSThemedScrollView

@property (nonatomic, strong) UIView <TTHeaderViewProtocol> * headerView; //头部view
@property (nonatomic, strong) UIView * contentView; //内容view
@property (nonatomic, weak, nullable) id <TTHTSHeaderScrollViewDelegate> delegate;
@property (nonatomic, assign) BOOL animationEnable;

/**
 *  是否开启视图的监听滚动
 */

- (void)switchScrollViewObserverOn:(BOOL)on;

/**
 *  向上滚动到head的最小高度
 */
- (void)scrollUp;

/**
 *  向下滑动到head的高度
 */
- (void)scrollDown;
@end

NS_ASSUME_NONNULL_END

