//
//  TTViewControllerHirarchyHelper.m
//  Article
//
//  Created by xushuangqing on 2017/7/26.
//
//

#import "TTViewControllerHierarchyHelper.h"
#import "TTDetailContainerViewController.h"
#import "TTDetailModel.h"
//#import "FRThreadSmartDetailViewController.h"

@implementation TTViewControllerHierarchyHelper

+ (NSString *)viewControllerHierarchyString {
    return [self _recursiveViewControllerDescription:[[[UIApplication sharedApplication] keyWindow] rootViewController] formarString:@"" prefix:@"" childPrefix:@""];
}

+ (NSString *)_viewControllerDescription:(UIViewController *)vc {
    BOOL viewDidLoaded = [vc isViewLoaded];
    BOOL viewIsShowing = (vc.view.window != nil);
    NSString *gid = nil;
    if ([vc isKindOfClass:[TTDetailContainerViewController class]]) {
        TTDetailContainerViewController *detailVC = (TTDetailContainerViewController *)vc;
        gid = detailVC.viewModel.detailModel.article.groupModel.groupID;
    }
//    if ([vc isKindOfClass:[FRThreadSmartDetailViewController class]]) {
//        FRThreadSmartDetailViewController *threadVC = (FRThreadSmartDetailViewController *)vc;
//        gid = [@(threadVC.tid) stringValue];
//    }
    NSMutableString *desc = [[NSMutableString alloc] initWithFormat:@"%@ ", [vc class]];
    if (viewDidLoaded && viewIsShowing) {
        [desc appendString:@"● "];//当前展示的vc
    }
    if (!viewDidLoaded) {
        [desc appendString:@"unloaded "];//还未加载的vc
    }
    if (!isEmptyString(gid)) {
        [desc appendString:gid];
    }
    return desc;
}

//参考facebook chisel的视线，源码 https://github.com/facebook/chisel/blob/master/fblldbviewcontrollerhelpers.py
+ (NSString *)_recursiveViewControllerDescription:(UIViewController *)vc formarString:(NSString *)string prefix:(NSString *)prefix childPrefix:(NSString *)childPrefix {
    NSString *s = [NSString stringWithFormat:@"%@%@%@\n", prefix, prefix.length == 0 ? @"" : @" ", [self _viewControllerDescription:vc]];
    NSString *nextPrefix = [NSString stringWithFormat:@"%@ |", childPrefix];
    NSArray <UIViewController *> * childControllers = [vc childViewControllers];
    NSMutableString * mutableS = [s mutableCopy];
    for (UIViewController *childController in childControllers) {
        [mutableS appendString:[self _recursiveViewControllerDescription:childController formarString:string prefix:nextPrefix childPrefix:nextPrefix]];
    }
    BOOL isModal = vc && ([[vc presentedViewController] presentingViewController] == vc);
    if (isModal) {
        [mutableS appendString:[self _recursiveViewControllerDescription:[vc presentedViewController] formarString:string prefix:[NSString stringWithFormat:@"%@ *M", childPrefix] childPrefix:nextPrefix]];
    }
    return [NSString stringWithFormat:@"%@%@", string, mutableS];
}


@end
