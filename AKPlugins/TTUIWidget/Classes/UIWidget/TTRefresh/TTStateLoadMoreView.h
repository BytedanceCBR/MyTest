//
//  TTStateLoadMoreView.h
//  TTUIWidget
//
//  Created by carl on 2018/3/1.
//

#import <UIKit/UIKit.h>
#import "TTRefreshView.h"
#import "TTLoadMoreStateView.h"
#import "TTLoadMoreView.h"

@interface TTStateLoadMoreView : SSThemedView <TTLoadMoreView>

- (instancetype)initWithFrame:(CGRect)frame pullDirection:(PullDirectionType)direction;

- (void)startObserve;

- (void)removeObserve:(UIScrollView *)scrollView;

- (void)triggerRefresh;

- (void)stopAnimation:(BOOL)success;

@property (nonatomic, assign, readwrite) PullDirectionState state;
@property (nonatomic, assign, readwrite) NSInteger lastTime;
@property (nonatomic, copy, readwrite) pullActionHandler actionHandler;
@property (nonatomic, weak, readwrite) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) PullDirectionType direction;
@property (nonatomic, assign, readwrite) BOOL isObserving;
@property (nonatomic, assign, readwrite) BOOL isObservingContentInset;
@property (nonatomic, assign, readwrite) BOOL displayTips;
@property (nonatomic, assign, readwrite) BOOL isPullUp;
@property (nonatomic, assign) BOOL   enabled;
@property (nonatomic, assign, readwrite) BOOL isUserPullAndRefresh;
@property (nonatomic, assign, readwrite) BOOL hasMore;

@end


