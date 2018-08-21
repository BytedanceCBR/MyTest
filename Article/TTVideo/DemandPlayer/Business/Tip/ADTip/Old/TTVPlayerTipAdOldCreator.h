//
//  TTVPlayerTipCreator.h
//  Article
//
//  Created by panxiang on 2017/5/17.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerTipLoading.h"
#import "TTVPlayerTipRetry.h"
#import "TTVPlayerTipFinished.h"
#import "TTVPlayerTipCreator.h"

@interface TTVPlayerTipAdOldCreator : NSObject<TTVPlayerTipCreator>
@property (nonatomic ,weak)UIView <TTVPlayerTipLoading> *tipLoadinView;
@property (nonatomic ,weak)UIView <TTVPlayerTipRetry> *tipRetryView;
@property (nonatomic ,weak)UIView <TTVPlayerTipFinished> *tipFinishedView;
- (UIView <TTVPlayerTipLoading> *)tip_loadingViewWithFrame:(CGRect)frame;
- (UIView <TTVPlayerTipRetry> *)tip_retryViewWithFrame:(CGRect)frame;
- (UIView <TTVPlayerTipFinished> *)tip_finishedViewWithFrame:(CGRect)frame;
@end
