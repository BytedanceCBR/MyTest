//
//  TTProfileViewController+VisitorFunction.m
//  Article
//
//  Created by it-test on 8/8/16.
//
//

#import "TTProfileViewController+VisitorFunction.h"
#import "TTProfileHeaderVisitorView.h"
#import "TTRelationshipViewController.h"
#import "TTFollowingViewController.h"
#import "TTFollowedViewController.h"
#import "TTVisitorViewController.h"
#import "FriendDataManager.h"
#import <TTAccountBusiness.h>

/**
 * 社交关系类型
 */
typedef FriendDataListType TTSocialConnectionType;

@implementation TTProfileViewController (VisitorFunction)
- (void)visitorView:(TTProfileHeaderVisitorView *)visitorView didSelectButtonAtIndex:(NSUInteger)selectedIndex
{
}

+ (TTSocialConnectionType)visitorTypeForIndex:(NSUInteger)index
{
    TTSocialConnectionType type = FriendDataListTypeNone;
    if (index == 0) {
        type = FriendDataListTypeFowllowing;
    } else if (index == 1) {
        type = FriendDataListTypeFollower;
    } else if (index == 2) {
        type = FriendDataListTypeVisitor;
    }
    return type;
}

@end
