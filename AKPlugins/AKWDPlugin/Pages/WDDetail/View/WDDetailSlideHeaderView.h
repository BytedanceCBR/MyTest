//
//  WDDetailSlideHeaderView.h
//  Article
//
//  Created by wangqi.kaisa on 2017/5/24.
//
//

#import "SSThemed.h"

/*
 * 5.24 横向滑动切换回答的回答详情页上面共用的headerview
 */

@class WDDetailModel;

@protocol WDDetailSlideHeaderViewProtocol <NSObject>

- (void)updateCurrentDetailModel:(WDDetailModel *)detailModel;

- (void)reloadView;

@end

@protocol WDDetailSlideHeaderViewDelegate <NSObject>

- (void)wdDetailSlideHeaderViewShowAllAnswers;

@end

@interface WDDetailSlideHeaderView : SSThemedView<WDDetailSlideHeaderViewProtocol>

@property (nonatomic, weak) id<WDDetailSlideHeaderViewDelegate>delegate;

@property (nonatomic, assign, readonly) CGFloat titleHeight;

- (instancetype)initWithFrame:(CGRect)frame detailModel:(WDDetailModel *)detailModel;

@end
