//
//  MLeaksFinderController.m
//  Article
//
//  Created by Dai Dongpeng on 8/10/16.
//
//
#if DEBUG
#import "MLeaksFinderController.h"
#import <MLeaksFinder.h>
#import <MLeaksFinder/NSObject+MemoryLeak.h>
#import <RSSWizzle.h>

@import ObjectiveC;

/*
 
 + (void)alertWithTitle:(NSString *)title message:(NSString *)message;
 + (void)alertWithTitle:(NSString *)title
 message:(NSString *)message
 delegate:(id<UIAlertViewDelegate>)delegate
 additionalButtonTitle:(NSString *)additionalButtonTitle;
 */
@implementation MLeaksFinderController

+ (void)load
{
    Class class = NSClassFromString(@"MLeaksMessenger");
    if (class)
    {
        RSSwizzleClassMethod(class, NSSelectorFromString(@"alertWithTitle:message:"), RSSWReturnType(void), RSSWArguments(NSString *title, NSString *message), RSSWReplacement({
            BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:@"KTTMLeaksFinderEnableAlertKey"];
            if (enable) {
                RSSWCallOriginal(title, message);
            }
        }));
        
        RSSwizzleClassMethod(class, NSSelectorFromString(@"alertWithTitle:message:delegate:additionalButtonTitle:"), RSSWReturnType(void), RSSWArguments(NSString *title, NSString *message, id delegate, NSString *additionalButtonTitle), RSSWReplacement({
            BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:@"KTTMLeaksFinderEnableAlertKey"];
            if (enable) {
                RSSWCallOriginal(title, message, delegate, additionalButtonTitle);
            }
        }));
    }
}

@end

#endif
