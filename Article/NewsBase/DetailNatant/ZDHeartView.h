//
//  ZDHeartView.h
//  Zhidao
//
//  Created by Nick Yu on 8/13/14.
//  Copyright (c) 2014 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"

typedef void (^ZDHeartAnimationBlock)();

@interface ZDHeartView : SSViewBase
@property(nonatomic, strong) UIImageView * imageViewTop;
@property(nonatomic, strong) UIImageView * imageViewBase;
@property(nonatomic, strong) CAShapeLayer *shapelayer;
@property(nonatomic, assign) BOOL hasLiked;

-(void)doAnimationWithAppendAnimation:(ZDHeartAnimationBlock)animation completion:(ZDHeartAnimationBlock)completion;

@end
