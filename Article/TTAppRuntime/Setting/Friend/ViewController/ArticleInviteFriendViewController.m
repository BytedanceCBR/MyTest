//
//  ArticleInviteFriendViewController.m
//  Article
//
//  Created by Zhang Leonardo on 13-12-30.
//
//

#import "ArticleInviteFriendViewController.h"


@interface ArticleInviteFriendViewController ()
{
    ArticleInviteFriendViewStyle _style;
}
@end

@implementation ArticleInviteFriendViewController

- (void)dealloc
{
    self.inviteFriendView = nil;
}

- (id)init
{
    self = [self initWithStyle:ArticleInviteFriendViewStyleNormal];
    if (self) {
        self.title = @"告诉好友";
    }
    return self;
}

- (id)initWithStyle:(ArticleInviteFriendViewStyle)style
{
    self = [super init];
    if (self) {
        _style = style;
//        if (_style == ArticleInviteFriendViewStyleExplore) {
            self.statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
//        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.inviteFriendView = [[ArticleInviteFriendView alloc] initWithFrame:[self frameforAddFriendView] style:_style];
    [self.view addSubview:_inviteFriendView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_inviteFriendView willAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_inviteFriendView willDisappear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_inviteFriendView didAppear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_inviteFriendView didDisappear];
}

- (CGRect)frameforAddFriendView
{
    return self.view.bounds;
}

@end
