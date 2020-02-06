//
//  TTLoadMoreStateView.h
//  TTUIWidget
//
//  Created by carl on 2018/3/1.
//

#import <UIKit/UIKit.h>
#import "TTLoadingView.h"
#import "SSThemed.h"
#import "TTRefreshView.h"

@protocol TTLoadMoreStateView <NSObject>
@property (nonatomic, assign) PullDirectionState state;
@optional
- (void)updateScrollPercent:(CGFloat)percent;
- (void)reduxState:(PullDirectionState)state;
@end

@interface TTLoadMoreStateView : SSThemedView <TTLoadMoreStateView>
@property (nonatomic, assign) PullDirectionState state;
@end

@interface TTLoadMoreStateNomoreView : TTLoadMoreStateView

- (void)updateScrollPercent:(CGFloat)percent;

- (void)reduxState:(PullDirectionState)state;
@end

