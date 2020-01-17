//
//  TTRefreshView.h
//  TestUniversaliOS6
//
//  Created by yuxin on 3/31/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTAnimatedRefreshView.h"

@class TTRefreshAnimationContainerView;

#define kTTPullRefreshTextDown                      @"下拉更新问题"
#define kTTPullRefreshTextUp                        @"上拉加载更多问题"
#define kTTPullRefreshTextNomore                    @"没有更多问题了"
#define kTTPullRefreshTextMore                      @"松开即可加载"
#define kTTPullRefreshTextRefresh                   @"松开即可更新"
#define kTTPullRefreshTextLoading                   @"正在努力加载..."
#define kTTPullRefreshTextTime                      @"最后一次更新 "

#define kTTPUllRefreshTimeTextZero @"从未"
#define kTTPullRefreshHeight 76
#define kTTPullRefreshLoadingHeight 32
#define kTTPullRefreshTitleFontSize 14
#define kTTPUllRefreshSubTitleFontSize 12
#define kTTPullRefreshTitleLabelRect(width) CGRectMake(128, 15, width, 15)
#define kTTPullRefreshSubTitleRect(width) CGRectMake(0, 40, width, 12)
#define kTTPullRefreshIconRect(size) CGRectMake(90, 10, size.width, size.height)
#define kTTScrollViewTipsNum sizeof(SCROLL_VIEW_TIPS) / sizeof(SCROLL_VIEW_TIPS[0])
#define KTTSecondsNeedScrollToLoading 0.4

typedef void (^pullActionHandler)();

typedef enum {
    PULL_DIRECTION_DOWN,
    PULL_DIRECTION_UP,
} PullDirectionType;

typedef enum {
    PULL_REFRESH_STATE_INIT,
    PULL_REFRESH_STATE_PULL,
    PULL_REFRESH_STATE_PULL_OVER,
    PULL_REFRESH_STATE_LOADING,
    PULL_REFRESH_STATE_NO_MORE,
    PULL_REFRESH_STATE_ENTER_SECOND_FLOOR,  // 头条二楼
} PullDirectionState;


typedef enum {
    Pull_MoveDirectionNone,
    Pull_MoveDirectionUp,
    Pull_MoveDirectionDown,
} PullMoveDirectionType;


typedef void(^RefreshCompletionBlock)(BOOL isSucess);

@class SSThemedView;
@class TTRefreshView;
@class SSThemedImageView;

@protocol TTRefreshAttachViewDelegate <NSObject>

- (void)willShowAttachView;
- (void)didShowEntireAttachView;
- (BOOL)isAttachViewEmpty;

@end

@protocol TTRefreshViewDelegate <NSObject>

- (void)refreshViewWillStartDrag:(UIView *)refreshView;
- (void)refreshViewDidScroll:(UIView *)refreshView WithScrollOffset:(CGFloat)offset;
- (void)refreshViewDidEndDrag:(UIView *)refreshView;

@optional
- (void)refreshViewWillChangePullDirection:(TTRefreshView *)refreshView changedPullDirection:(PullMoveDirectionType)pullDirection;
- (void)refreshViewDidMessageBarResetContentInset;
- (void)refreshViewWillBeTriggered:(UIView *)refreshView;
- (void)refreshViewStartLoading:(UIView *)refreshView;

@end

@protocol TTRefreshAnimationDelegate <NSObject>

- (void)startLoading;

- (void)updateAnimationWithScrollOffset:(CGFloat)offset;

- (void)updateViewWithPullState:(PullDirectionState)state;

- (void)stopLoading;

- (void)configurePullRefreshLoadingHeight:(CGFloat)pullRefreshLoadingHeight;

@optional

- (void)animationWithScrollViewBackToLoading;

- (void)completionWithScrollViewBackToLoading;

@end


@interface TTRefreshView : UIView

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

- (void)showAnimationView;
- (void)triggerRefresh;
- (void)triggerRefreshAndHideAnimationView;
- (void)triggerRefreshWithDefaultRefreshView:(BOOL)useDefaultRefreshView;

- (void)stopAnimation:(BOOL)success;

- (void)messageBarResetContentInset;

- (void)setUpRefreshBackColor:(UIColor *)backColor;

// 设置自定义下拉刷新动画，支持图片/gif/lottie。传入nil可清理上次设置的内容
- (BOOL)configAnimatedRefreshWithImageStyle:(TTAnimatedRefreshStyle)imageStyle imageFilePath:(NSString *)imageFilePath lotComposition:(LOTComposition *)lotComposition lottieThreshold:(CGFloat)lottieThreshold width:(CGFloat)width height:(CGFloat)height;

-(void)reConfigureWithRefreshAnimateView:(SSThemedView<TTRefreshAnimationDelegate> *)refreshAnimateView WithConfigureSuccessCompletion:(RefreshCompletionBlock)completion;

-(void)resetWithDefaultAnimateViewWithConfigureSuccessCompletion:(RefreshCompletionBlock)completion;

@property (nonatomic, assign, readwrite) PullDirectionState state;
@property (nonatomic, assign, readwrite) NSInteger lastTime;
@property (nonatomic, copy, readwrite) pullActionHandler actionHandler;
@property (nonatomic, weak, readwrite) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) PullDirectionType direction;
@property (nonatomic, assign, readwrite) BOOL isObserving;
@property (nonatomic, assign, readwrite) BOOL isObservingContentInset;
@property (nonatomic, assign, readwrite) BOOL displayTips;
@property (nonatomic, assign, readwrite) BOOL isPullUp;
@property (nonatomic) BOOL enabled;
@property (nonatomic, assign, readwrite) BOOL isUserPullAndRefresh;
@property (nonatomic, strong, readonly) SSThemedView *bgView;
@property (nonatomic) CGFloat pullRefreshLoadingHeight;
@property (nonatomic) CGFloat messagebarHeight;
@property (nonatomic, copy, readonly) NSString *refreshLoadingText;
@property (nonatomic, assign, readwrite) CGFloat secondsNeedScrollToLoading;
@property (nonatomic, strong) SSThemedView<TTRefreshAttachViewDelegate> *ttAttachView;
@property (nonatomic, weak) id<TTRefreshViewDelegate> delegate;
@property (nonatomic, strong, readonly) TTRefreshAnimationContainerView *defaultRefreshAnimateView;
@property (nonatomic) BOOL enableAnimatedRefresh;
@property (nonatomic) BOOL ignoreInsetAnimation; // 是否跳过contentInset动画

@end
