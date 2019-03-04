//
//  TTMotionView.h
//  Article
//
//  Created by yin on 2017/1/22.
//
//

#import "SSThemed.h"

@protocol TTMotionViewDelegate <NSObject>

- (void)motionViewScrollViewDidScrollToOffset:(CGPoint)offset;


@end

typedef NS_ENUM(NSUInteger, TTMotionViewType) {
    TTMotionViewTypeImmersion,
    TTMotionViewTypeFullView
};

@interface TTMotionView : SSThemedView

@property (nonatomic, weak) __weak id <TTMotionViewDelegate> delegate;

@property (nonatomic, strong) UIImage  *image;
@property (nonatomic, assign) BOOL motionEnabled;
@property (nonatomic, assign) BOOL scrollIndicatorEnabled;
@property (nonatomic, assign) BOOL scrollBounceEnabled;
@property (nonatomic, assign) BOOL isShowGyroTipView;
@property (nonatomic, strong) CADisplayLink* displayLink;
@property (nonatomic, assign) TTMotionViewType type;
@property (nonatomic, weak)   UITableView  *tableView;

- (instancetype)initWithType:(TTMotionViewType)type;

- (void)resetContentOffset;

- (void)willDisplaying;
- (void)didEndDisplaying;
- (void)resumeDisplay;

@end

