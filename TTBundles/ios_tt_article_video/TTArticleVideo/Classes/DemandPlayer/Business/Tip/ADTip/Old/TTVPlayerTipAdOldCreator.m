//
//  TTVPlayerTipCreator.m
//  Article
//
//  Created by panxiang on 2017/5/17.
//
//

#import "TTVPlayerTipAdOldCreator.h"
#import "TTVPlayerTipAdOldFinish.h"

@implementation TTVPlayerTipAdOldCreator
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
    return [[TTVPlayerTipAdOldFinish alloc] initWithFrame:frame];
}

@end
