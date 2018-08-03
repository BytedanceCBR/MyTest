//
//  WDDetailAnswerEmptyView.h
//  Article
//
//  Created by wangqi.kaisa on 2017/6/27.
//
//

#import "SSThemed.h"

/*
 * 6.27 网络错误或者回答被删除时显示的占位tv
 */

@protocol WDDetailAnswerEmptyViewDelegate <NSObject>

- (void)wd_detailAnswerEmptyViewDidScrollWithContentOffsetY:(CGFloat)offsetY;

- (void)wd_detailAnswerEmptyViewReconnectLoadData;

@optional;
- (void)wd_detailAnswerEmptyViewStopScrollWithContentOffsetY:(CGFloat)offsetY;

@end

@interface WDDetailAnswerEmptyView : SSThemedView

@property (nonatomic, strong, readonly) SSThemedTableView *tableView;
@property (nonatomic, weak) id<WDDetailAnswerEmptyViewDelegate>delegate;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) CGFloat currentOffsetY;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)startShow;

- (void)setEmptyTypeReason:(NSInteger)reason error:(NSError *)error;

@end
