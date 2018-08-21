//
//  WDDetailHeaderView.h
//  Article
//
//  Created by ZhangLeonardo on 15/12/14.
//
//

#import "SSThemed.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WDDetailHeaderViewStyle) {
    WDDetailHeaderViewStyleOld = 0, //老样式
    WDDetailHeaderViewStyleNew = 1  //新卡片样式
};

@class WDDetailModel;
@protocol WDDetailHeaderViewDelegate;

@protocol WDDetailHeaderView <NSObject>

@required
- (instancetype)initWithFrame:(CGRect)frame detailModel:(WDDetailModel *)detailModel;

@property (nonatomic, weak, nullable) id<WDDetailHeaderViewDelegate> delegate;

@end

@protocol WDDetailHeaderViewDelegate <NSObject>

@optional
/** 头部回答按钮点击回调 */
- (void)headerView:(UIView<WDDetailHeaderView> *)headerView answerButtonDidTap:(UIButton *)button;
/** 头部我有靠谱回答按钮点击回调 */
- (void)headerView:(UIView<WDDetailHeaderView> *)headerView goodAnswerButtonDidTap:(UIButton *)button;
/** 头部整体背景点击回调 */
- (void)headerView:(UIView<WDDetailHeaderView> *)headerView bgButtonDidTap:(UIButton *)button;
/** 头部回答按钮露出回调 */
- (void)headerView:(UIView<WDDetailHeaderView> *)headerView answerButtonDidShow:(UIButton *)button;
/** 头部回答按钮隐藏回调 */
- (void)headerView:(UIView<WDDetailHeaderView> *)headerView answerButtonDidHide:(UIButton *)button;
/** 头部我有靠谱回答按钮露出回调 */
- (void)headerView:(UIView<WDDetailHeaderView> *)headerView goodAnswerButtonDidShow:(UIButton *)button;
/** 头部我有靠谱回答按钮隐藏回调 */
- (void)headerView:(UIView<WDDetailHeaderView> *)headerView goodAnswerButtonDidHide:(UIButton *)button;

@end


@interface WDDetailHeaderView : SSThemedView <WDDetailHeaderView>

- (instancetype)initWithFrame:(CGRect)frame detailModel:(WDDetailModel *)detailModel;

@end

NS_ASSUME_NONNULL_END
