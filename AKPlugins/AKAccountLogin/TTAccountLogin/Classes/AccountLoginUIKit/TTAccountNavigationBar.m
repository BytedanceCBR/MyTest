//
//  TTAccountNavigationBar.m
//  TTAccountLogin
//
//  Created by 杨心雨 on 16/8/21.
//
//

#import "TTAccountNavigationBar.h"
#import <UIViewAdditions.h>


#define DEVICE_SYS_FLOAT_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])

#define IS_IOS_11_LATER (DEVICE_SYS_FLOAT_VERSION >= 11.0)


@implementation TTAccountNavigationBar

- (void)setCenter:(CGPoint)center
{
    CGPoint oldValue = self.center;
    [super setCenter:center];
    if (self.center.y - oldValue.y == 20) {
        [self setCenterY:self.center.y - 20];
    }
}

@end
