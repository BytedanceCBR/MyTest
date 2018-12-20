//
//  ToastManager.m
//  Pods
//
//  Created by 张元科 on 2018/12/20.
//

#import "ToastManager.h"
#import "UIView+Toast.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>

@interface ToastManager ()

@property (nonatomic, strong)   FHToastView       *toastView;
@property (nonatomic, strong)   CSToastStyle      *toastStyle;

@end

@implementation ToastManager

+ (instancetype)manager {
    static ToastManager *_sharedInstance = nil;
    if (!_sharedInstance){
        _sharedInstance = [[ToastManager alloc] init];
    }
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createDefaultStyle];
    }
    return self;
}

- (void)createDefaultStyle {
    _toastStyle = [[CSToastStyle alloc] initWithDefaultStyle];
    _toastStyle.backgroundColor = RGBA(0x08, 0x1f, 0x33,0.96);
    _toastStyle.cornerRadius = 4.0;
    _toastStyle.messageFont = [UIFont systemFontOfSize:14.0];
    _toastStyle.messageAlignment = NSTextAlignmentCenter;
    _toastStyle.verticalPadding = 15.0;
    _toastStyle.horizontalPadding = 20;
    _toastStyle.messageColor = UIColor.whiteColor;
}

- (void)showToast:(NSString *)message {
    [self showToast:message duration:1.0 isUserInteraction:NO];
}

- (void)showToast:(NSString *)message duration:(NSTimeInterval)duration isUserInteraction:(BOOL)isUserInteraction {
    [self dismissToast];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    _toastView = [[FHToastView alloc] initWithFrame:window.bounds];
    _toastView.userInteractionEnabled = isUserInteraction;
    [window addSubview:_toastView];
    [_toastView makeToast:message duration:duration position:CSToastPositionCenter title:NULL image:NULL style:_toastStyle completion:^(BOOL didTap) {
    }];
}

- (void)dismissToast {
    [_toastView removeFromSuperview];
    _toastView = NULL;
}

@end

@implementation FHToastView


@end
