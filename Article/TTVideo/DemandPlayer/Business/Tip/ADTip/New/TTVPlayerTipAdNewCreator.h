//
//  TTVPlayerTipAdNewCreator.h
//  Article
//
//  Created by panxiang on 2017/7/20.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerTipCreator.h"
#import "TTVPlayerTipLoading.h"
#import "TTVPlayerTipRetry.h"
#import "TTVPlayerTipAdNewFinished.h"

/**
 新重构业务使用新播放器使用
 */
@interface TTVPlayerTipAdNewCreator : NSObject<TTVPlayerTipCreator>
- (UIView <TTVPlayerTipLoading> *)tip_loadingViewWithFrame:(CGRect)frame;
- (UIView <TTVPlayerTipRetry> *)tip_retryViewWithFrame:(CGRect)frame;
- (UIView <TTVPlayerTipFinished> *)tip_finishedViewWithFrame:(CGRect)frame;
@property (nonatomic ,weak)UIView <TTVPlayerTipLoading> *tipLoadinView;
@property (nonatomic ,weak)UIView <TTVPlayerTipRetry> *tipRetryView;
@property (nonatomic ,weak)UIView <TTVPlayerTipFinished> *tipFinishedView;
@end
