//
//  TTVPlayerTipRelatedCreator.h
//  Article
//
//  Created by lishuangyang on 2017/7/16.
//
//
#import <Foundation/Foundation.h>
#import "TTVPlayerTipCreator.h"
#import "TTVPlayerTipLoading.h"
#import "TTVPlayerTipRetry.h"
#import "TTVPlayerTipRelatedFinished.h"
@interface TTVPlayerTipRelatedCreator : NSObject<TTVPlayerTipCreator>
- (UIView <TTVPlayerTipLoading> *)tip_loadingViewWithFrame:(CGRect)frame;
- (UIView <TTVPlayerTipRetry> *)tip_retryViewWithFrame:(CGRect)frame;
- (UIView <TTVPlayerTipFinished> *)tip_finishedViewWithFrame:(CGRect)frame;
@property (nonatomic ,weak)UIView <TTVPlayerTipLoading> *tipLoadinView;
@property (nonatomic ,weak)UIView <TTVPlayerTipRetry> *tipRetryView;
@property (nonatomic ,weak)UIView <TTVPlayerTipFinished> *tipFinishedView;
@end

