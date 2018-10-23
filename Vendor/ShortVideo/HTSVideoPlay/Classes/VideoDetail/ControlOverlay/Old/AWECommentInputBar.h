//
//  HTSVideoCommentInputBar.h
//  LiveStreaming
//
//  Created by SongLi.02 on 10/21/16.
//  Copyright © 2016 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTSVideoPlayGrowingTextView.h"

NS_ASSUME_NONNULL_BEGIN

@class AWECommentModel;

@interface AWECommentInputBar : SSThemedView

@property (nonatomic, strong, readonly) HTSVideoPlayGrowingTextView *textView;
@property (nonatomic, strong, readonly) UIButton *sendButton;

/// TextFiled内容改变回调
@property (nonatomic, copy, nullable) void(^textDidChangeBlock)(HTSVideoPlayGrowingTextView *growingTextView);

/// 最大输入字数(默认50)
@property (nonatomic, assign) NSUInteger maxInputCount;

/// 默认的TextField.placeHolder(clear之后会恢复此String)(默认“优质评论将会被优先展示”)
@property (nonatomic, copy) NSString *defaultPlaceHolder;

/// 回复对象model
@property (nonatomic, strong, nullable) AWECommentModel *targetCommentModel;

/// 附加参数
@property (nonatomic, strong, readonly) NSMutableDictionary *params;

/**
 *  
 */
- (instancetype)initWithFrame:(CGRect)frame textViewDelegate:(nullable id<HTSVideoPlayGrowingTextViewDelegate>)delegate sendBlock:(nullable void(^)(AWECommentInputBar *inputBar, NSString * _Nullable text))sendBlock;

/** 
 *  清空数据
 */
- (void)clearInputBar;

/**
 *  调起输入框
 */
- (void)becomeActive;

/**
 *  当前是否在输入状态
 */
- (BOOL)isActive;

/**
 *  收起输入框
 */
- (void)resignActive;

/**
 *  设置位置
 */
- (void)setMinY:(CGFloat)minY;

/**
 *  设置位置
 */
- (void)setMaxY:(CGFloat)maxY;

@end

NS_ASSUME_NONNULL_END
