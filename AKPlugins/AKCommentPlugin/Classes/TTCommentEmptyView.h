//
//  TTCommentEmptyView.h
//  Article
//
//  Created by 冯靖君 on 16/4/1.
//
//

#import <TTThemed/SSThemed.h>


typedef NS_ENUM(NSInteger, TTCommentEmptyViewType) {
    TTCommentEmptyViewTypeHidden,
    TTCommentEmptyViewTypeEmpty,
    TTCommentEmptyViewTypeNotNetwork,
    TTCommentEmptyViewTypeFailed,
    TTCommentEmptyViewTypeForceShowCommentButton, // 详情页不显示评论，点击显示评论
    TTCommentEmptyViewTypeLoading,
    TTCommentEmptyViewTypeCommentDetailEmpty, //评论详情空页面
    TTCommentEmptyViewTypeWDDetailEmpty // 问答详情页空页面
};

@class TTCommentEmptyView;

@protocol TTCommentEmptyViewDelegate <NSObject>

- (void)emptyView:(TTCommentEmptyView *)view buttonClickedForType:(TTCommentEmptyViewType)type;

@end

@interface TTCommentEmptyView : SSThemedView

@property (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) SSThemedLabel *emptyTipLabel;
@property (nonatomic, strong) UIButton *emptyButton;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, assign) TTCommentEmptyViewType type;
@property (nonatomic, weak) id<TTCommentEmptyViewDelegate> delegate;

- (void)refreshType:(TTCommentEmptyViewType)type;

@end
