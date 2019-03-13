//
//  UIViewController+TTVHiritageSearch.m
//  Article
//
//  Created by panxiang on 2017/7/24.
//
//

#import "UIViewController+TTVHiritageSearch.h"

@implementation UIViewController (TTVHiritageSearch)

+ (BOOL)responder:(UIResponder *)resonder befiltered:(NSArray *)clazzArray
{
    for (Class clazz in clazzArray) {
        if ([resonder isKindOfClass:clazz]) {
            return YES;
        }
    }
    return NO;
}

+ (UIViewController*)ttv_topViewControllerFor:(UIResponder*)responder exceptClasses:(NSArray *)clazzArray
{
    UIResponder *topResponder = responder;
    while(topResponder &&
          (![topResponder isKindOfClass:[UIViewController class]] || [self responder:topResponder befiltered:clazzArray]))
    {
        topResponder = [topResponder nextResponder];
    }
    
    if(!topResponder)
    {
        topResponder = [[[UIApplication sharedApplication] delegate].window rootViewController];
    }
    
    return (UIViewController*)topResponder;
}

@end
