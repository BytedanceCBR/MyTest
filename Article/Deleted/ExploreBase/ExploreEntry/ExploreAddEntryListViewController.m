//
//  ExploreAddEntryListViewController.m
//  Article
//
//  Created by Zhang Leonardo on 14-11-23.
//
//

#import "ExploreAddEntryListViewController.h"
#import "ExploreAddEntryListView.h"
#import "ExploreSearchViewController.h"
#import "TTViewWrapper.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"


@interface ExploreAddEntryListViewController ()

@property (nonatomic, strong) NSString *needShowGroupID;

@end

@implementation ExploreAddEntryListViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
    }
    return self;
}

- (instancetype)initWithShowGroupID:(NSString *)needShowGroupID
{
    self = [self init];
    if(self) {
        self.needShowGroupID = needShowGroupID;
    }
    return self;
}

- (CGRect)frameForListView {
    if ([TTDeviceHelper isPadDevice]) {

        CGFloat padding = [TTUIResponderHelper paddingForViewWidth:0];
        return CGRectInset(self.view.frame, padding, 0);
        
    }
    return self.view.bounds;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.subscriptionListView.frame = [self frameForListView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.subscriptionListView = [[ExploreAddEntryListView alloc] initWithFrame:[self frameForListView] showGroupID:self.needShowGroupID];
    
    if ([TTDeviceHelper isPadDevice]) {
        TTViewWrapper *wrapperView = [[TTViewWrapper alloc] initWithFrame:self.view.bounds];
        [wrapperView addSubview:_subscriptionListView];
        wrapperView.targetView = _subscriptionListView;
        [self.view addSubview:wrapperView];
    }
    else {
        [self.view addSubview:_subscriptionListView];
    }
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle: NSLocalizedString(@"头条号", nil)];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setImage:[UIImage themedImageNamed:@"search_subscibe_titilebar.png"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage themedImageNamed:@"search_subscibe_titilebar_press.png"] forState:UIControlStateHighlighted];
    [searchButton setContentEdgeInsets:UIEdgeInsetsMake(5, 20, 5, 8)];
    [searchButton sizeToFit];
    [searchButton addTarget:self action:@selector(showSearch:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
}


- (void)showSearch:(id)sender
{
    ExploreSearchViewController *controller = [[ExploreSearchViewController alloc] initWithNavigationBar:YES showBackButton:![TTDeviceHelper isPadDevice] queryStr:nil fromType:ListDataSearchFromTypeSubscribe searchType:ExploreSearchViewTypeEntrySearch];
    [self.navigationController pushViewController:controller animated:YES];
    wrapperTrackEvent(@"subscription", @"search");
}
#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_subscriptionListView didAppear];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_subscriptionListView willAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_subscriptionListView willDisappear];
}

@end
