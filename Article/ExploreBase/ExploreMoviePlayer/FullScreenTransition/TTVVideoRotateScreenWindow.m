//
//  TTVVideoRotateScreenWindow.m
//  Article
//
//  Created by pei yun on 2017/5/31.
//
//

#import "TTVVideoRotateScreenWindow.h"
#import <Aspects/Aspects.h>

@interface TTVRotateRootView : UIView

@property (nonatomic, strong) id<AspectToken> aspectToken;

@end

@implementation TTVRotateRootView

- (void)dealloc
{
    [self.aspectToken remove];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    self.aspectToken =[self aspect_hookSelector:@selector(hitTest:withEvent:) withOptions:AspectOptionAutomaticRemoval | AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
        NSInvocation *invocation = aspectInfo.originalInvocation;
        CGPoint previousPoint = point;
        [invocation setArgument:&previousPoint atIndex:2];
        [invocation retainArguments];
    }error:nil];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        [self.aspectToken remove];
        self.aspectToken = nil;
    });
    return [super hitTest:point withEvent:event];
}

@end

@interface TTVRotateRootViewController : UIViewController

@end

@implementation TTVRotateRootViewController

- (void)loadView
{
    CGRect frame = CGRectMake(0, 0, MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height), MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height));
    self.view = [[TTVRotateRootView alloc] initWithFrame:frame];
    [self.view aspect_hookSelector:@selector(setFrame:) withOptions:AspectOptionAutomaticRemoval | AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
        NSInvocation *invocation = aspectInfo.originalInvocation;
        CGRect fr = frame;
        [invocation setArgument:&fr atIndex:2];
        [invocation retainArguments];
    }error:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//http://stackoverflow.com/questions/32323506/ios9-custom-uiwindow-makes-status-bar-disappear
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end

@implementation TTVVideoRotateScreenWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.windowLevel = UIWindowLevelNormal;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.rootViewController = [[TTVRotateRootViewController alloc] init];
    }
    return self;
}

@end
