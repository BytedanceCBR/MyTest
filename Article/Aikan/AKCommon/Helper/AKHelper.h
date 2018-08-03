//
//  AKHelper.h
//  Article
//
//  Created by 冯靖君 on 2018/3/8.
//

#import <Foundation/Foundation.h>
#import <TTUIResponderHelper.h>
#import <TTIndicatorView.h>

@interface AKHelper : NSObject

@end

static inline void showIndicatorWithTip(NSString *tip)
{
    if (!isEmptyString(tip)) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:nil maxLine:3 autoDismiss:YES dismissHandler:nil];
    }
}

static inline UIViewController * ak_top_vc() {
    UIViewController *topvc = [TTUIResponderHelper correctTopmostViewController];
    int maxCount = 0;
    while (topvc.presentedViewController && maxCount < 10) {
        topvc = topvc.presentedViewController;
        maxCount++;
    }
    
    return topvc;
}

static inline BOOL ak_banEmojiInput()
{
    return YES;
}

static inline BOOL hasLoginWeChat()
{
    BOOL hasWechatLoginInfo = NO;
    for (TTAccountPlatformEntity * entity in [TTAccount sharedAccount].user.connects) {
        TTAccountAuthType accountAuthType = TTAccountGetPlatformTypeByName(entity.platform);
        if (accountAuthType == TTAccountAuthTypeWeChat) {
            hasWechatLoginInfo = YES;
        }
    }
    return hasWechatLoginInfo && tta_IsLogin();
}
