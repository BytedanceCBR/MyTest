//
//  TTVPlayerTipCreator.h
//  Article
//
//  Created by panxiang on 2017/7/20.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerTipLoading.h"
#import "TTVPlayerTipRetry.h"
#import "TTVPlayerTipFinished.h"

@protocol TTVPlayerTipCreator
@property (nonatomic ,weak)UIView <TTVPlayerTipLoading> *tipLoadinView;
@property (nonatomic ,weak)UIView <TTVPlayerTipRetry> *tipRetryView;
@property (nonatomic ,weak)UIView <TTVPlayerTipFinished> *tipFinishedView;

- (UIView <TTVPlayerTipLoading> *)tip_loadingViewWithFrame:(CGRect)frame;
- (UIView <TTVPlayerTipRetry> *)tip_retryViewWithFrame:(CGRect)frame;
- (UIView <TTVPlayerTipFinished> *)tip_finishedViewWithFrame:(CGRect)frame;
@end


@interface TTVPlayerTipCreator : NSObject <TTVPlayerTipCreator>
@property (nonatomic ,weak)UIView <TTVPlayerTipLoading> *tipLoadinView;
@property (nonatomic ,weak)UIView <TTVPlayerTipRetry> *tipRetryView;
@property (nonatomic ,weak)UIView <TTVPlayerTipFinished> *tipFinishedView;

- (UIView <TTVPlayerTipLoading> *)tip_loadingViewWithFrame:(CGRect)frame;
- (UIView <TTVPlayerTipRetry> *)tip_retryViewWithFrame:(CGRect)frame;
- (UIView <TTVPlayerTipFinished> *)tip_finishedViewWithFrame:(CGRect)frame;
@end


@interface TTVPlayerTipNoFinishedViewCreator : TTVPlayerTipCreator
@end

