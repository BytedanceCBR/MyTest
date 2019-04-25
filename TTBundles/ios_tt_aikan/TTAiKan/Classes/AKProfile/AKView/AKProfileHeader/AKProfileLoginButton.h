//
//  AKProfileLoginButton.h
//  Article
//
//  Created by chenjiesheng on 2018/3/2.
//

#import <TTAlphaThemedButton.h>
#import <UIKit/UIKit.h>

#define PLATFORM_MORE               @"profile_more_login"

typedef NS_ENUM(NSInteger,AKProfileLoginButtonType)
{
    AKProfileLoginButtonTypeDefault = 0,
    AKProfileLoginButtonTypeSimply = 1,
};

@interface AKProfileLoginButton : TTAlphaThemedButton

@property (nonatomic, copy, readonly)  NSString                 *platform;
+ (instancetype)buttonWithLoginButtonType:(AKProfileLoginButtonType)buttonType platform:(NSString *)platform;
+ (instancetype)weiXinButtonWithTarget:(id)target buttonClicked:(void (^)(AKProfileLoginButton *))clickBlock;
@end
