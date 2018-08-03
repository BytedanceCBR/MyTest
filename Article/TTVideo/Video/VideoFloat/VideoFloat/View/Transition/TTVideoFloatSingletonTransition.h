//
//  TTVideoFloatSingletonTransition.h
//  Article
//
//  Created by panxiang on 16/7/14.
//
//

#import <Foundation/Foundation.h>
#import "TTSharedViewTransition.h"

@interface TTVideoFloatSingletonTransition : NSObject<Singleton>
@property (nonatomic, strong) UIView *fromAnimatedView;
@property (nonatomic, strong) UIViewController *fromViewController;
@property (nonatomic, strong) UIImage *fromAnimatedImage;
@property (nonatomic, strong) UIImage *fixedAnimatedImage;//经过裁剪的图片,主要是解决图片比例不同,闪现的bug
@property (nonatomic, strong) UIView *to;
@property (nonatomic, assign) BOOL isPresent;//present or dismiss
@property (nonatomic, weak) NSObject <TTSharedViewTransitionFrom> *fromView;
@end
