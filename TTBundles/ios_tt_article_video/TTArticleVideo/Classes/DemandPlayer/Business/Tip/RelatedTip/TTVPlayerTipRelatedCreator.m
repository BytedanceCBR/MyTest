//
//  TTVPlayerTipRelatedCreator.m
//  Article
//
//  Created by lishuangyang on 2017/7/16.
//
//

#import "TTVPlayerTipRelatedCreator.h"
#import "TTVPlayerTipRelatedFinishedForward.h"

@implementation TTVPlayerTipRelatedCreator

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
    return [[TTVPlayerTipRelatedFinishedForward alloc] initWithFrame:frame];
}

@end
