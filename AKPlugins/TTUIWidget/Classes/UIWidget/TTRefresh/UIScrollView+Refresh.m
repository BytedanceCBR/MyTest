//
//  UIScrollView+Refresh.m
//  Zhidao
//
//  Created by Nick Yu on 3/13/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import "UIScrollView+Refresh.h"
#import <objc/runtime.h>

#define BottomInsetNotSet -1

static char TTPullRefreshViewDown, TTPullRefreshViewUp, TTPullRefreshViewMutex, TTPullRefreshViewHasMore, TTPullRefreshViewDisableWhenLoad,TTPullRefreshViewHideNoneIcon,TTPullRefreshViewNeedPullRefresh, TTPullRefreshViewDisableWifiOptimize;

@implementation UIScrollView (Refresh)

@dynamic pullDownView, pullUpView, isMutex, hasMore, disableWhenLoad;

- (void)addPullDownWithInitText:(NSString *)initText pullText:(NSString *)pullText loadingText:(NSString *)loadingText
                     noMoreText:(NSString *)noMoreText timeText:(NSString *)timeText lastTimeKey:(NSString *)timeKey
                  actionHandler:(pullActionHandler)actionHandler
{
    if (!self.pullDownView) {
        CGRect frame = CGRectMake(0, self.ttRefreshViewTopInset-kTTPullRefreshHeight, self.bounds.size.width, kTTPullRefreshHeight);
        TTRefreshView *view = [[TTRefreshView alloc] initWithFrame:frame
                                                             pullDirection:PULL_DIRECTION_DOWN
                                                                  initText:initText
                                                                  pullText:pullText
                                                               loadingText:loadingText
                                                                noMoreText:noMoreText
                                                                  timeText:timeText
                                                               lastTimeKey:timeKey];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        view.isPullUp = NO;
        [self addSubview:view];

        self.pullDownView = view;
        self.pullDownView.actionHandler = actionHandler;
        self.pullDownView.scrollView = self;
        [self.pullDownView startObserve];

 
    }
    self.pullDownView.actionHandler = actionHandler;

}

- (void)addPullUpWithInitText:(NSString *)initText pullText:(NSString *)pullText loadingText:(NSString *)loadtingText
                   noMoreText:(NSString *)noMoreText timeText:(NSString *)timeText lastTimeKey:(NSString *)timeKey
               ActioinHandler:(pullActionHandler)actionHandler
{
    if (!self.pullUpView) {
        NSInteger height = MAX(self.contentSize.height, self.bounds.size.height);
        CGRect frame = CGRectMake(0, height, self.bounds.size.width, kTTPullRefreshHeight);
        TTLoadMoreView *view = [[TTLoadMoreView alloc] initWithFrame:frame
                                                             pullDirection:PULL_DIRECTION_UP
                                                                  initText:initText
                                                                  pullText:pullText
                                                               loadingText:loadtingText
                                                                noMoreText:noMoreText
                                                                  timeText:timeText
                                                               lastTimeKey:timeKey];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        view.isPullUp = YES;
        [self addSubview:view];

        self.pullUpView = view;
        self.pullUpView.scrollView = self;
        [self.pullUpView startObserve];
        
        self.currentRestingContentInsetBottom = BottomInsetNotSet;
        
        //self.contentInset = UIEdgeInsetsMake(self.contentInset.top, self.contentInset.left, self.contentInset.bottom+50, self.contentInset.right);
    }
    self.pullUpView.actionHandler = actionHandler;

}

- (void)triggerPullDownAndHideAnimationView {
    if (self.pullDownView && self.pullDownView.state != PULL_REFRESH_STATE_LOADING) {
        [self.pullDownView triggerRefreshAndHideAnimationView];
    }
}

- (void)triggerPullDown
{
    if (self.pullDownView && self.pullDownView.state != PULL_REFRESH_STATE_LOADING) {
        [self.pullDownView triggerRefresh];
    }
}

- (void)triggerPullUp
{
    if (self.pullUpView) {
        [self.pullUpView triggerRefresh];
    }
}

- (void)pullView:(UIView *)view stateChange:(PullDirectionState)state
{
    if (self.isMutex && self.pullDownView && self.pullUpView) {
        UIView *sibling = ((TTRefreshView *)view).direction == PULL_DIRECTION_DOWN ? self.pullUpView : self.pullDownView;
        if (state == PULL_REFRESH_STATE_LOADING) {
            sibling.hidden = YES;
        } else {
            sibling.hidden = NO;
        }
    }

    if (self.disableWhenLoad) {
        if (state == PULL_REFRESH_STATE_LOADING) {
            self.scrollEnabled = NO;
        } else {
            self.scrollEnabled = YES;
        }
    }
}

- (TTRefreshView *)pullDownView
{
    return objc_getAssociatedObject(self, &TTPullRefreshViewDown);
}

- (void)setPullDownView:(TTRefreshView *)pullDownView
{
    [self willChangeValueForKey:@"TTPullRefreshViewDown"];
    objc_setAssociatedObject(self, &TTPullRefreshViewDown, pullDownView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"TTPullRefreshViewDown"];
}

- (TTLoadMoreView *)pullUpView
{
    return objc_getAssociatedObject(self, &TTPullRefreshViewUp);
}

- (void)setPullUpView:(TTLoadMoreView *)pullUpView
{
    [self willChangeValueForKey:@"TTPullRefreshViewUp"];
    objc_setAssociatedObject(self, &TTPullRefreshViewUp, pullUpView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"TTPullRefreshViewUp"];
}

- (BOOL)isMutex
{
    NSNumber *number = objc_getAssociatedObject(self, &TTPullRefreshViewMutex);
    return [number boolValue];
}

- (void)setIsMutex:(BOOL)isMutex
{
    NSNumber *number = [NSNumber numberWithBool:isMutex];
    objc_setAssociatedObject(self, &TTPullRefreshViewMutex, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hasMore
{
    NSNumber *number = objc_getAssociatedObject(self, &TTPullRefreshViewHasMore);
    return [number boolValue];
}

- (void)setHasMore:(BOOL)hasMore
{
    self.pullUpView.hasMore = hasMore;

    NSNumber *number = [NSNumber numberWithBool:hasMore];
    objc_setAssociatedObject(self, &TTPullRefreshViewHasMore, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hideNoneIcon
{
    NSNumber *number = objc_getAssociatedObject(self, &TTPullRefreshViewHideNoneIcon);
    return [number boolValue];
}

- (void)setHideNoneIcon:(BOOL)hideNoneIcon
{
    NSNumber *number = [NSNumber numberWithBool:hideNoneIcon];
    objc_setAssociatedObject(self, &TTPullRefreshViewHideNoneIcon, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (BOOL)needPullRefresh {
    NSNumber *number = objc_getAssociatedObject(self, &TTPullRefreshViewNeedPullRefresh);
    if (!number) {
        return YES;
    }
    return [number boolValue];
}

- (void)setNeedPullRefresh:(BOOL)needPullRefresh {
    objc_setAssociatedObject(self, &TTPullRefreshViewNeedPullRefresh, @(needPullRefresh), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.pullDownView.enabled = needPullRefresh;
}


- (BOOL)disableWhenLoad
{
    NSNumber *number = objc_getAssociatedObject(self, &TTPullRefreshViewDisableWhenLoad);
    return [number boolValue];
}

- (void)setDisableWhenLoad:(BOOL)disableWhenLoad
{
    NSNumber *number = [NSNumber numberWithBool:disableWhenLoad];
    objc_setAssociatedObject(self, &TTPullRefreshViewDisableWhenLoad, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)disableWifiOptimize
{
    NSNumber *number = objc_getAssociatedObject(self, &TTPullRefreshViewDisableWifiOptimize);
    return [number boolValue];
}

- (void)setDisableWifiOptimize:(BOOL)disableWifiOptimize
{
    NSNumber *number = [NSNumber numberWithBool:disableWifiOptimize];
    objc_setAssociatedObject(self, &TTPullRefreshViewDisableWifiOptimize, number, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isDone
{
    NSNumber *number = objc_getAssociatedObject(self, @selector(isDone));
    return [number boolValue];
}

- (void)setIsDone:(BOOL)isDone
{
    NSNumber *number = [NSNumber numberWithBool:isDone];
    objc_setAssociatedObject(self,@selector(isDone), number, OBJC_ASSOCIATION_RETAIN);
}

- (UIEdgeInsets)originContentInset
{
    NSValue * value = objc_getAssociatedObject(self, @selector(originContentInset));
    return [value UIEdgeInsetsValue];
}

- (void)setOriginContentInset:(UIEdgeInsets)originContentInset
{
    NSValue *value = [NSValue valueWithUIEdgeInsets:originContentInset];
    objc_setAssociatedObject(self, @selector(originContentInset), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)currentRestingContentInsetBottom
{
    NSNumber * num = objc_getAssociatedObject(self, @selector(currentRestingContentInsetBottom));
    return (CGFloat)[num floatValue];
}

- (void)setCurrentRestingContentInsetBottom:(CGFloat)currentRestingContentInsetBottom
{
    NSNumber *value = [NSNumber numberWithFloat:currentRestingContentInsetBottom];
    objc_setAssociatedObject(self, @selector(currentRestingContentInsetBottom), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)customTopOffset
{
    NSNumber * num = objc_getAssociatedObject(self, @selector(customTopOffset));
    return (CGFloat)[num floatValue];
}

- (void)setCustomTopOffset:(CGFloat)customTopOffset
{
    NSNumber *value = [NSNumber numberWithFloat:customTopOffset];
    objc_setAssociatedObject(self, @selector(customTopOffset), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)ttRefreshViewTopInset
{
    NSNumber * num = objc_getAssociatedObject(self, @selector(ttRefreshViewTopInset));
    return (CGFloat)[num floatValue];
}

- (void)setTtRefreshViewTopInset:(CGFloat)ttRefreshViewTopInset
{
    NSNumber *value = [NSNumber numberWithFloat:ttRefreshViewTopInset];
    objc_setAssociatedObject(self, @selector(ttRefreshViewTopInset), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)finishPullDownWithSuccess:(BOOL)success
{
    [self.pullDownView stopAnimation:success];
}

- (void)finishPullUpWithSuccess:(BOOL)success
{
    [self.pullUpView stopAnimation:success];
}

- (void)removePullUpView
{
    [self.pullUpView removeFromSuperview];
    self.pullUpView = nil;
}


- (BOOL)ttHasIntegratedMessageBar
{
    NSNumber *number = objc_getAssociatedObject(self, @selector(ttHasIntegratedMessageBar));
    return [number boolValue];
}

- (void)setTtHasIntegratedMessageBar:(BOOL)ttHasIntegratedMessageBar
{
    NSNumber *number = [NSNumber numberWithBool:ttHasIntegratedMessageBar];
    objc_setAssociatedObject(self,@selector(ttHasIntegratedMessageBar), number, OBJC_ASSOCIATION_RETAIN);
}

- (UIView *)ttIntegratedMessageBar
{
    return objc_getAssociatedObject(self, @selector(ttIntegratedMessageBar));
}

- (void)setTtIntegratedMessageBar:(UIView *)ttIntegratedMessageBar
{
    objc_setAssociatedObject(self, @selector(ttIntegratedMessageBar), ttIntegratedMessageBar, OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation UIScrollView (TTSimpleCreates)

- (void)tt_addDefaultPullDownRefreshWithHandler:(pullActionHandler)handler
{
    [self addPullDownWithInitText:@"下拉刷新"
                         pullText:@"松开即可刷新"
                      loadingText:@"正在努力加载"
                       noMoreText:@"暂无新数据"
                         timeText:nil
                      lastTimeKey:nil
                    actionHandler:handler];
}

- (void)tt_addDefaultPullUpLoadMoreWithHandler:(pullActionHandler)handler
{
    return [self tt_addPullUpLoadMoreWithNoMoreText:@"暂无更多数据" withHandler:handler];
}

- (void)tt_addPullUpLoadMoreWithNoMoreText:(NSString *)noMoreText withHandler:(pullActionHandler)hander
{
    [self addPullUpWithInitText:@"上拉加载更多"
                       pullText:@"松开即可加载"
                    loadingText:@"正在努力加载"
                     noMoreText:noMoreText
                       timeText:nil
                    lastTimeKey:nil
                 ActioinHandler:hander];
}

@end
