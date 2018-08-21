//
//  TTProfileFillViewController.m
//  Article
//
//  Created by tyh on 2017/5/25.
//
//

#import "TTProfileFillViewController.h"
#import "SSThemed.h"
#import <TTServiceKit/TTModuleBridge.h>
#import <TTPlatformBaseLib/TTProfileFillManager.h>
#import "TTProfileFillFrontView.h"
#import <TTUIWidget/TTIndicatorView.h>
#import <TTAccountBusiness.h>
#import <TTDialogDirector/TTDialogDirector.h>


static CGFloat cachedEndY = 0.0;

@interface TTProfileFillViewController ()

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong) UIView *maskBg;

@property (nonatomic,strong) TTProfileFillViewController *retainSelf;

@property (nonatomic, strong) TTProfileFillFrontView *frontView;

@property (nonatomic, assign) CGPoint expandLocation;

@property (nonatomic, assign) TTProfileFillExpandDirection direction;

@property (nonatomic, assign) BOOL keyboardIsWaiting;

@end

@implementation TTProfileFillViewController


+ (void)load
{
    [[TTModuleBridge sharedInstance_tt] registerAction:@"TTProfileFillVCPresent" withBlock:^id _Nullable(id  _Nullable object, id  _Nullable params) {
        //未提供展开点和展开方向的调用，暂时不支持
        if (params[@"expandPoint"] && [params[@"expandPoint"] CGPointValue].x > 0 && [params[@"expandPoint"] CGPointValue].y > 0) {
            if ([params[@"expandDirection"] isEqualToString:@"down"]) {
                TTProfileFillViewController *vc = [[TTProfileFillViewController alloc] init];
                [vc presentExpandLocation:[params[@"expandPoint"] CGPointValue] direction:TTProfileFillExpandDirectionDown];
            } else if ([params[@"expandDirection"] isEqualToString:@"up"]) {
                TTProfileFillViewController *vc = [[TTProfileFillViewController alloc] init];
                [vc presentExpandLocation:[params[@"expandPoint"] CGPointValue] direction:TTProfileFillExpandDirectionUp];
            }
        }
        return nil;
    }];
}

- (void)presentExpandLocation:(CGPoint)expandLocation direction:(TTProfileFillExpandDirection)direction
{
    if ([TTDialogDirector isDialogShowing]) {
        return;
    }
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    //window
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.windowLevel = UIWindowLevelStatusBar + 50.0;
    self.window.rootViewController = self;
    [self.window makeKeyAndVisible];
    
    //半透明遮罩
    self.maskBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    self.maskBg.backgroundColor = [UIColor blackColor];
    self.maskBg.alpha = 0;
    [self.window addSubview:self.maskBg];
    
    //frontView
    CGFloat x = [TTDeviceUIUtils tt_newPadding:15.0f];
    CGFloat w = [UIScreen mainScreen].bounds.size.width - 2 * x;
    CGFloat h = [TTDeviceUIUtils tt_newPadding:283.0f + 7.0f + 7.0f];
    self.frontView = [[TTProfileFillFrontView alloc] initWithFrame:CGRectMake(x, 0, w, h)];
    self.frontView.profileFillViewController = self;
    
    //正常情况下，完全不看那两个字断
    if ([[[TTProfileFillManager manager].profileModel is_avatar_valid] boolValue] ) {
        [self.frontView setAvatarUrl:[TTProfileFillManager manager].profileModel.avatar_url];
    }
    if ([[[TTProfileFillManager manager].profileModel is_name_valid] boolValue] ) {
        [self.frontView setUserName:[TTProfileFillManager manager].profileModel.name];
    }
    
    [self.view addSubview:self.frontView];
    [self.window addSubview:self.view];
    
    //防止释放
    self.retainSelf = self;

    //把弹出点和弹出方向存下来
    self.expandLocation = expandLocation;
    self.direction = direction;
    
    //展开动画相关
    CGRect dstFrame;    
    if (direction == TTProfileFillExpandDirectionDown) {
        //向下展开
        self.frontView.topPointerView.hidden = NO;
        self.frontView.bottomPointerView.hidden = YES;
        self.frontView.topPointerView.left = expandLocation.x - 2;
        dstFrame = CGRectMake(self.frontView.left, expandLocation.y, self.frontView.width, self.frontView.height);
        self.frontView.topPointerView.left = expandLocation.x - self.frontView.left;
    } else {
        self.frontView.topPointerView.hidden = YES;
        self.frontView.bottomPointerView.hidden = NO;
        self.frontView.bottomPointerView.left = expandLocation.x - 2;
        dstFrame = CGRectMake(self.frontView.left, expandLocation.y - self.frontView.height, self.frontView.width, self.frontView.height);
        self.frontView.bottomPointerView.left = expandLocation.x - self.frontView.left;
    }
    self.frontView.frame = dstFrame;
    CGPoint p = [self.frontView convertPoint:expandLocation fromView:SSGetMainWindow()];
    CGPoint anchorP = CGPointMake(p.x/self.frontView.width, p.y/self.frontView.height);
    self.frontView.layer.anchorPoint = anchorP;
    self.frontView.frame = dstFrame;

    self.frontView.transform = CGAffineTransformMakeScale(0.1, 0.1);

    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frontView.transform = CGAffineTransformMakeScale(1.05, 1.05);
        self.maskBg.alpha = 0.4;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frontView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            [TTTrackerWrapper eventV3:@"profile_modify_show" params:@{@"refer":@"comment_list",@"demand_id":@100379}];
            
            [self.frontView actionsAfterShow];
        }];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)keyboardWillShow:(NSNotification *)notification {

}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (self.direction == TTProfileFillExpandDirectionDown) {
        //之前是向下展开，在上面展示箭头，让左上角等于expandLocation
        self.frontView.topPointerView.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.frontView.top = self.expandLocation.y;
        }];
        
    } else {
        //之前是向上展开，需要在下面展示箭头，让左下角等于expandLocation
        self.frontView.bottomPointerView.hidden = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.frontView.top = self.expandLocation.y - kProfileFillHeight;
        }];
    }
}

- (void)keyboardWillChange:(NSNotification *)notification {
    
    CGRect endFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSLog(@"endY %f",endFrame.origin.y);
    cachedEndY = endFrame.origin.y;
    if (!self.keyboardIsWaiting) {
        self.keyboardIsWaiting = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //等待0.1s，通过一个全局变量记录键盘最后的位置，防止键盘不断换的时候，我们的框也跟着走
            self.keyboardIsWaiting = NO;
            if (cachedEndY < [UIScreen mainScreen].bounds.size.height) {
                CGFloat startY = cachedEndY - kProfileFillHeight - [TTDeviceUIUtils tt_newPadding:15.0 -7.0];
                self.frontView.topPointerView.hidden = YES;
                self.frontView.bottomPointerView.hidden = YES;
                [UIView animateWithDuration:0.2 animations:^{
                    self.frontView.top = startY;
                }];
            } else {
                //收起键盘操作
            }
        });
    }
}

- (void)closeAction:(BOOL)animated
{
    if (self.completeBlock) {
        self.completeBlock();
    }
    if (self.dissmissBlock) {
        self.dissmissBlock();
    }
    [[TTProfileFillManager manager] clearProfileModel];
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:.84 initialSpringVelocity:1 options:UIViewAnimationOptionLayoutSubviews animations:^{
            self.maskBg.alpha = 0;
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [self.view removeFromSuperview];
                [self.maskBg removeFromSuperview];
                self.window.hidden = YES;
                self.window = nil;
                self.retainSelf = nil;
            }
        }];
    }else{
        [self.view removeFromSuperview];
        [self.maskBg removeFromSuperview];
        self.window.hidden = YES;
        self.window = nil;
        self.retainSelf = nil;
    }
}

@end
