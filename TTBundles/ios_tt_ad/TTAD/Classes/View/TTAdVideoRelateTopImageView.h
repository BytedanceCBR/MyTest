//
//  TTAdVideoRelateTopImageView.h
//  Article
//
//  Created by lijun.thinker on 2017/6/22.
//

#import "TTDetailNatantRelateReadView.h"

@interface TTAdVideoRelateTopImageView : TTDetailNatantRelateReadTopImgView

- (instancetype)initWithWidth:(CGFloat)width successBlock:(TTRelateVideoImageViewBlock)block;

-(void)adVideoRelateImageViewtrackShow;

@end

