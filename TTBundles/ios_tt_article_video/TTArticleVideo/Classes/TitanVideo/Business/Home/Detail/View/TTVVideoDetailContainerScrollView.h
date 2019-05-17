//
//  TTVVideoDetailContainerScrollView.h
//  Article
//
//  Created by pei yun on 2017/5/21.
//
//

#import <TTVContainerScrollView/TTVContainerScrollView.h>

@interface TTVVideoDetailContainerScrollView : TTVContainerScrollView

@property(nonatomic, assign) CGFloat contentOffsetWhenLeave;
@property(nonatomic, assign) CGFloat referHeight;

- (void)checkVisibleAtContentOffset:(CGFloat)contentOffset referViewHeight:(CGFloat)referHeight;
- (void)sendNatantItemsShowEventWithContentOffset:(CGFloat)natantContentoffsetY scrollView:(UIScrollView*)scrollView isScrollUp:(BOOL)isScrollUp;

@end
