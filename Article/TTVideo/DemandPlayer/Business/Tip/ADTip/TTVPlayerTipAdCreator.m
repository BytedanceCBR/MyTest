//
//  TTVPlayerTipAdCreator.m
//  Article
//
//  Created by panxiang on 2017/5/25.
//
//

#import "TTVPlayerTipAdCreator.h"

@implementation TTVPlayerTipAdCreator

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
    return [[TTVPlayerTipAdFinished alloc] initWithFrame:frame];
}

@end
