//
//  TTHeaderScrollView.h
//  Article
//
//  Created by 王霖 on 16/8/3.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTHeaderViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class TTHeaderScrollView;


typedef NS_ENUM(NSInteger, TTScrollViewScrollDirection) {
    TTScrollViewScrollDirectionNone,
    TTScrollViewScrollDirectionUp,
    TTScrollViewScrollDirectionDown,
};

@protocol TTHeaderScrollViewDelegate <UIScrollViewDelegate>

@optional
- (BOOL)headerScrollView:(TTHeaderScrollView *)headerScrollView shouldScrollWithScrollView:(UIScrollView *)scrollView;
- (void)scrollViewExtraTaskWithDirection:(TTScrollViewScrollDirection)direction;
@end

@interface TTHeaderScrollView : SSThemedScrollView

@property (nonatomic, strong) UIView <TTHeaderViewProtocol> * headerView; //头部view
@property (nonatomic, strong) UIView * contentView; //内容view
@property (nonatomic, weak, nullable) id <TTHeaderScrollViewDelegate> delegate;
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

