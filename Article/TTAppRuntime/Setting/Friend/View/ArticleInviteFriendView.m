//
//  ArticleInviteFriendView.m
//  Article
//
//  Created by Zhang Leonardo on 13-12-30.
//
//

#import "ArticleInviteFriendView.h"
#import "ArticleTitleImageView.h"

#import "ArticleFriend.h"
#import "SSNavigationBar.h"
#import "TTDeviceHelper.h"

#import "FriendListView.h"
@implementation ArticleInviteFriendView
- (void)dealloc
{
//    self.leftButton = nil;
    self.inviteFriendListView = nil;
    self.titleBarView = nil;
    self.navigationBar = nil;
}

- (id)initWithFrame:(CGRect)frame style:(ArticleInviteFriendViewStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UIView * navigationBar;
        if (![TTDeviceHelper isPadDevice]) {
            self.navigationBar = [[SSNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.width, [SSNavigationBar navigationBarHeight])];
            self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.navigationBar.title = NSLocalizedString(@"告诉朋友", nil);
            self.navigationBar.leftBarView = [SSNavigationBar navigationBackButtonWithTarget:self action:@selector(goBack:)];
            [self addSubview:self.navigationBar];
            navigationBar = self.navigationBar;
        } else {
            self.titleBarView = [[ArticleTitleImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [SSTitleBarView titleBarHeight])];
            
            if (style == ArticleInviteFriendViewStyleExplore) {
                _titleBarView.titleUItype = ArticleTitleImageViewUITypeExplore;
            }
            [_titleBarView setTitleText:NSLocalizedString(@"告诉朋友", nil)];
            [self addSubview:_titleBarView];
            navigationBar = self.titleBarView;
        }
        
        self.inviteFriendListView = [[FriendListView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(navigationBar.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(navigationBar.frame))];
        [self addSubview:_inviteFriendListView];
        
    }
    return self;
}

- (void)willAppear
{
    [super willAppear];
    [_inviteFriendListView willAppear];
}

- (void)didAppear
{
    [super didAppear];
    [_inviteFriendListView didAppear];
}

- (void)willDisappear
{
    [super willDisappear];
    [_inviteFriendListView willDisappear];
}

- (void)didDisappear
{
    [super didDisappear];
    [_inviteFriendListView didDisappear];
}


- (void)goBack:(id)sender
{
    [[TTUIResponderHelper topNavigationControllerFor: self] popViewControllerAnimated:YES];
}

@end
