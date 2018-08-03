//
//  TSVSeondUseSwipeAnimation.h
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 07/12/2017.
//

#import <Foundation/Foundation.h>

@interface TSVSeondUseSwipeAnimation : NSObject

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *arrowParentView;

+ (instancetype)sharedAnimation;

- (void)startAnimation;
- (void)stopAnimation;

@end
