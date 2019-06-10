//
//  TTAdVideoTipCreator.h
//  Article
//
//  Created by yin on 2017/9/26.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerTipLoading.h"
#import "TTVPlayerTipRetry.h"
#import "TTVPlayerTipFinished.h"
#import "TTVPlayerTipCreator.h"

@interface TTAdVideoTipCreator : NSObject <TTVPlayerTipCreator>
@property (nonatomic ,weak)UIView <TTVPlayerTipLoading> *tipLoadinView;
@property (nonatomic ,weak)UIView <TTVPlayerTipRetry> *tipRetryView;
@property (nonatomic ,weak)UIView <TTVPlayerTipFinished> *tipFinishedView;

- (UIView <TTVPlayerTipLoading> *)tip_loadingViewWithFrame:(CGRect)frame;
- (UIView <TTVPlayerTipRetry> *)tip_retryViewWithFrame:(CGRect)frame;
- (UIView <TTVPlayerTipFinished> *)tip_finishedViewWithFrame:(CGRect)frame;



@end

@interface TTAdVideoTipFinished:UIView<TTVPlayerTipFinished>
@property(nonatomic, assign)BOOL isFullScreen;
@property(nonatomic, copy)FinishAction finishAction;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@end
