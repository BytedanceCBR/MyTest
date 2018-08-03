//
//  TTAccountLoginAlertViewGuide.m
//  Article
//
//  Created by liuzuopeng on 04/06/2017.
//
//

#import "TTAccountLoginAlertViewGuide.h"
#import "NewsBaseDelegate.h"
#import "SSCommonLogic.h"
#import <TTAccountBusiness.h>
#import <objc/runtime.h>



@implementation TTAccountLoginAlertViewGuide

#pragma mark - TTGuideProtocol Method

- (BOOL)shouldDisplay:(id)context
{
    return YES;
}

- (void)showWithContext:(id)context
{
    if ([context isKindOfClass:[NewsBaseDelegate class]]) {
        
        TTAccountLoginAlert *loginAlert = [TTAccountLoginManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:@"splash" completion:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
            
        }];
        
        loginAlert.didDismissCompletedHandler = ^(TTAccountAlertCompletionEventType type) {
            if (type != TTAccountAlertCompletionEventTypeTip) {
               [[TTGuideDispatchManager sharedInstance_tt] removeGuideViewItem:self];
            }
        };
    }
}

- (id)context
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setContext:(id)context
{
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
