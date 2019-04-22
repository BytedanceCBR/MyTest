//
//  TTVADCellApp+ComputedProperties.m
//  Article
//
//  Created by pei yun on 2017/4/1.
//
//

#import "TTVADCellApp+ComputedProperties.h"
#import <objc/runtime.h>

#define kSeperatorString        @"://"

@implementation TTVADCellApp (ComputedProperties)

- (NSString *)appURL {
    NSString *appURL = objc_getAssociatedObject(self, @selector(appURL));
    if (appURL == nil) {
        NSRange seperateRange = [self.openURL rangeOfString:kSeperatorString];
        if (seperateRange.length > 0) {
            NSString *appURL = [self.openURL substringWithRange:NSMakeRange(0, NSMaxRange(seperateRange))];
            objc_setAssociatedObject(self, @selector(appURL), appURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            NSString *tabURL = [self.openURL substringWithRange:NSMakeRange(NSMaxRange(seperateRange), [self.openURL length] - NSMaxRange(seperateRange))];
            objc_setAssociatedObject(self, @selector(tabURL), tabURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        } else {
            NSString *appURL = self.openURL;
            objc_setAssociatedObject(self, @selector(appURL), appURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    return appURL;
}

- (NSString *)tabURL {
    NSString *tabURL = objc_getAssociatedObject(self, @selector(tabURL));
    if (tabURL == nil) {
        NSRange seperateRange = [self.openURL rangeOfString:kSeperatorString];
        if (seperateRange.length > 0) {
            NSString *appURL = [self.openURL substringWithRange:NSMakeRange(0, NSMaxRange(seperateRange))];
            objc_setAssociatedObject(self, @selector(appURL), appURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            NSString *tabURL = [self.openURL substringWithRange:NSMakeRange(NSMaxRange(seperateRange), [self.openURL length] - NSMaxRange(seperateRange))];
            objc_setAssociatedObject(self, @selector(tabURL), tabURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        } else {
            NSString *appURL = self.openURL;
            objc_setAssociatedObject(self, @selector(appURL), appURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    return tabURL;
}

@end
