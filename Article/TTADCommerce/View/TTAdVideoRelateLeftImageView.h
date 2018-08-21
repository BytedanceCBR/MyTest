//
//  TTAdVideoRelateLeftImageView.h
//  Article
//
//  Created by lijun.thinker on 2017/6/20.
//

#import "TTDetailNatantRelateReadView.h"

@interface TTAdVideoRelateLeftImageView : TTDetailNatantRelateReadLeftImgView

- (instancetype)initWithWidth:(CGFloat)width successBlock:(TTRelateVideoImageViewBlock)block;

-(void)adVideoRelateImageViewtrackShow;

@end
