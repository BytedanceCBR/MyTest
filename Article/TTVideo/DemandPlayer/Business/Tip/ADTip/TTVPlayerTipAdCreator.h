//
//  TTVPlayerTipAdCreator.h
//  Article
//
//  Created by panxiang on 2017/5/25.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerTipCreator.h"
#import "TTVPlayerTipLoading.h"
#import "TTVPlayerTipRetry.h"
#import "TTVPlayerTipAdFinished.h"

/**
 旧feed使用新播放器的时候使用
 */
@interface TTVPlayerTipAdCreator : NSObject<TTVPlayerTipCreator>
- (UIView <TTVPlayerTipLoading> *)tip_loadingViewWithFrame:(CGRect)frame;
- (UIView <TTVPlayerTipRetry> *)tip_retryViewWithFrame:(CGRect)frame;
- (UIView <TTVPlayerTipFinished> *)tip_finishedViewWithFrame:(CGRect)frame;
@property (nonatomic ,weak)UIView <TTVPlayerTipLoading> *tipLoadinView;
@property (nonatomic ,weak)UIView <TTVPlayerTipRetry> *tipRetryView;
@property (nonatomic ,weak)UIView <TTVPlayerTipFinished> *tipFinishedView;
@end

