//
//  ExploreVideoDetailHelper.m
//  Article
//
//  Created by 冯靖君 on 15/11/15.
//
//

#import "ExploreVideoDetailHelper.h"
#import "TTDeviceHelper.h"


@implementation ExploreVideoDetailHelper

+ (VideoDetailRelatedStyle)currentVideoDetailRelatedStyle {
    return [self currentVideoDetailRelatedStyleForMaxWidth:[TTUIResponderHelper windowSize].width];
}

+ (VideoDetailRelatedStyle)currentVideoDetailRelatedStyleForMaxWidth:(CGFloat)maxWidth
{
    if (![TTDeviceHelper isPadDevice]) {
        return VideoDetailRelatedStyleNatant;
    }
    else {
        if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
            return VideoDetailRelatedStyleNatant;
        }
        else {
            CGFloat distinctRelatedWidth = [TTDeviceHelper isIpadProDevice] ? 460.f : 344.f;
            CGFloat minVideoWidth = 620.f;
            if (maxWidth - distinctRelatedWidth < minVideoWidth) {
                return VideoDetailRelatedStyleNatant;
            }
            else {
                return VideoDetailRelatedStyleDistinct;
            }
        }
    }
}

+ (CGSize)videoAreaSizeForMaxWidth:(CGFloat)maxWidth areaAspect:(CGFloat)areaAspect
{
    if (areaAspect <= 0) {
        areaAspect = 9.f/16.f;
    }
    if ([TTDeviceHelper isPadDevice]) {
        areaAspect = 9.f/16.f;
    }
    CGFloat videoWidth;
    if ([self currentVideoDetailRelatedStyle] == VideoDetailRelatedStyleNatant) {
        //最新设计：竖屏下，两边铺满
        videoWidth = maxWidth;
    }
    else {
        //铺满
        videoWidth = maxWidth - ([TTDeviceHelper isIpadProDevice] ? 460.f : 344.f);
    }
    return CGSizeMake(videoWidth, ceilf(videoWidth * areaAspect));
}

@end
