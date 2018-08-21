//
//  TTKeyboardListener.m
//  Article
//
//  Created by yuxin on 2/25/16.
//
//

#import "TTKeyboardListener.h"
#import "TTDeviceHelper.h"


static TTKeyboardListener *sharedInstance;

@interface TTKeyboardListener ()

@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation TTKeyboardListener

+ (TTKeyboardListener *)sharedInstance
{
    return sharedInstance;
}

+ (void)load
{
    sharedInstance = [[self alloc] init];
}

- (BOOL)isVisible
{
    return _visible;
}

- (void)didShow:(NSNotification *)notification
{
    _visible = YES;
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        _keyboardHeight = keyboardRect.size.width;
    }
    else
        _keyboardHeight = keyboardRect.size.height;
}

- (void)didHide
{
    _keyboardHeight = 0;
    _visible = NO;
}

- (id)init
{
    if ((self = [super init])) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(didShow:) name:UIKeyboardDidShowNotification object:nil];
        [center addObserver:self selector:@selector(didHide) name:UIKeyboardWillHideNotification object:nil];
        [center addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (void)keyboardWillChangeFrame:(NSNotification *) notification {
    NSDictionary * userInfo = notification.userInfo;
    /// keyboard相对于屏幕的坐标
    CGRect keyboardScreenFrame = [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = keyboardScreenFrame.size.height;
}

@end
