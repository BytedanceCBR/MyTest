//
//  TTAdVideoViewFactory.h
//  Article
//
//  Created by yin on 16/9/7.
//
//

#import <Foundation/Foundation.h>
#import "TTDetailNatantViewBase.h"

@interface TTVideoDetailBannerPaddingView : TTDetailNatantViewBase

+ (float)viewHeight;

- (instancetype)initWithWidth:(CGFloat)width topLineShow:(BOOL)topShow bottomLineShow:(BOOL)bottomShow;

@end

@interface TTAdVideoViewFactory : NSObject

+ (UIView*)detailBannerPaddingView:(CGFloat)width topLineShow:(BOOL)topShow bottomLineShow:(BOOL)bottomShow;

@end
