//
//  UIViewController+HUD.m
//  Article
//
//  Created by 谷春晖 on 2018/11/1.
//

#import "UIViewController+HUD.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Bubble-Swift.h"
#import "UIFont+House.h"
#import <objc/runtime.h>

static void *hudKey = &hudKey;

@implementation UIViewController (HUD)

-(MBProgressHUD *)hud
{
    return objc_getAssociatedObject(self, hudKey);
}

-(void)setHud:(MBProgressHUD *)hud
{
    objc_setAssociatedObject(self, hudKey, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);    
}


-(void)showLoadingAlert:(NSString *_Nullable)message
{
    [self showLoadingAlert:message offset:CGPointZero];
}

-(void)showLoadingAlert:(NSString *_Nullable)message offset:(CGPoint)offset
{
    [self.hud hideAnimated:NO];
    self.hud.userInteractionEnabled = NO;
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.bezelView.color = [UIColor colorWithWhite:0 alpha:0.8];
    hud.contentColor = [UIColor whiteColor];
    hud.label.font = [UIFont themeFontRegular:17];
    hud.label.text = message;
    hud.offset = offset;
    self.hud = hud;

}

-(void)dismissLoadingAlert
{
    [self.hud hideAnimated:YES];
    [self.hud removeFromSuperview];
    self.hud = nil;
}

@end
