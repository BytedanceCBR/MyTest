//
//  TTRefreshView.h
//  TestUniversaliOS6
//
//  Created by yuxin on 3/31/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTRefreshView.h"

@protocol TTLoadMoreView <NSObject>

- (void)startObserve;

- (void)removeObserve:(UIScrollView *)scrollView;

- (void)triggerRefresh;

- (void)stopAnimation:(BOOL)success;

@property (nonatomic, assign, readwrite) PullDirectionState state;
@property (nonatomic, copy, readwrite) pullActionHandler actionHandler;
@property (nonatomic, weak, readwrite) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) PullDirectionType direction;
@property (nonatomic, assign, readwrite) BOOL isObserving;
@property (nonatomic, assign, readwrite) BOOL isObservingContentInset;
@property (nonatomic, assign, readwrite) BOOL isPullUp;
@property (nonatomic, assign) BOOL   enabled;
@property (nonatomic, assign, readwrite) BOOL isUserPullAndRefresh;
@property (nonatomic, assign, readwrite) BOOL hasMore;

@end


@interface TTLoadMoreView : UIView <TTLoadMoreView>

- (id)initWithFrame:(CGRect)frame
      pullDirection:(PullDirectionType)direction
           initText:(NSString *)initText
           pullText:(NSString *)pullText
        loadingText:(NSString *)loadingText
         noMoreText:(NSString *)noMoreText
           timeText:(NSString *)timeText
        lastTimeKey:(NSString *)timeKey;

- (id)initWithFrame:(CGRect)frame
      pullDirection:(PullDirectionType)direction
           initText:(NSString *)initText
           pullText:(NSString *)pullText
        loadingText:(NSString *)loadingText
         noMoreText:(NSString *)noMoreText;


- (id)initWithFrame:(CGRect)frame pullDirection:(PullDirectionType)direction;

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
@property (nonatomic) BOOL   enabled;
@property (nonatomic, assign, readwrite) BOOL isUserPullAndRefresh;
@property (nonatomic, assign, readwrite) BOOL hasMore;

@end
