//
//  TTVPlayerTipCreator.m
//  Article
//
//  Created by panxiang on 2017/7/20.
//
//

#import "TTVPlayerTipCreator.h"
#import "TTVPlayerTipFinished.h"

@implementation TTVPlayerTipCreator

- (UIView <TTVPlayerTipLoading> *)tip_loadingViewWithFrame:(CGRect)frame
{
    return [[TTVPlayerTipLoading alloc] initWithFrame:frame];
}

- (UIView <TTVPlayerTipRetry> *)tip_retryViewWithFrame:(CGRect)frame
{
    return [[TTVPlayerTipRetry alloc] initWithFrame:frame];
}

- (UIView <TTVPlayerTipFinished> *)tip_finishedViewWithFrame:(CGRect)frame
{
    return [[TTVPlayerTipFinished alloc] initWithFrame:frame];
}

@end

@implementation TTVPlayerTipNoFinishedViewCreator

- (UIView <TTVPlayerTipFinished> *)tip_finishedViewWithFrame:(CGRect)frame
{
    return nil;
}

@end





