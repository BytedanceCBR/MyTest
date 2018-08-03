//
//  TTAdVideoRelateRightImageView.h
//  Article
//
//  Created by yin on 16/8/17.
//
//

#import "TTDetailNatantRelateReadView.h"

@interface TTAdVideoRelateRightImageView : TTDetailNatantRelateReadRightImgView

- (instancetype)initWithWidth:(CGFloat)width successBlock:(TTRelateVideoImageViewBlock)block;

- (void)adVideoRelateImageViewtrackShow;

@end
