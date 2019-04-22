//
//  TTVPlayerTipAdNewCreator.m
//  Article
//
//  Created by panxiang on 2017/7/20.
//
//

#import "TTVPlayerTipAdNewCreator.h"

@implementation TTVPlayerTipAdNewCreator

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
    return [[TTVPlayerTipAdNewFinished alloc] initWithFrame:frame];
}

@end
