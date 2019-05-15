//
//  TTVPlayerTipShareCreater.m
//  Article
//
//  Created by lishuangyang on 2017/7/16.
//
//

#import "TTVPlayerTipShareCreater.h"

@implementation TTVPlayerTipShareCreater

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
    return [[TTVPlayerTipShareFinished alloc] initWithFrame:frame];
}

@end
