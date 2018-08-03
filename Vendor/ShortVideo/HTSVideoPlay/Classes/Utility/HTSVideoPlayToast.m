//
//  HTSVideoPlayToast.m
//  Pods
//
//  Created by pc on 2017/4/24.
//
//

#import "HTSVideoPlayToast.h"
#import <TTIndicatorView.h>

@implementation HTSVideoPlayToast

+ (void)show:(NSString *)message
{
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:message indicatorImage:nil autoDismiss:YES dismissHandler:nil];
}

@end
