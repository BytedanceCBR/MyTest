//
//  EssayDetailViewController.m
//  Article
//
//  Created by Hua Cao on 13-10-21.
//
//

#import "EssayDetailViewController.h"
#import "EssayDetailView.h"
#import "SSNavigationBar.h"
#import "UIButton+TTAdditions.h"
#import "TTViewWrapper.h"
#import "ExploreSearchViewController.h"
#import "SSWebViewBackButtonView.h"
#import <TTUIWidget/TTAlphaThemedButton.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import <TTUIWidget/TTNavigationController.h>
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "ArticleSearchBar.h"

#import "TTRoute.h"
#import <TTInteractExitHelper.h>

@interface EssayDetailViewController () <ExploreSearchViewDelegate,TTInteractExitProtocol>

@property (nonatomic, retain) EssayDetailView *essayDetailView;
@property (nonatomic, retain) EssayData * essayData;
@property (nonatomic, assign) BOOL needScrollToComment;
@property (nonatomic, copy) NSString * trackEvent;
@property (nonatomic, copy) NSString * trackLabel;
@property (nonatomic, strong) TTAlphaThemedButton *moreButton;
@property (nonatomic, strong) TTAlphaThemedButton *searchButton;
@property (nonatomic, strong) SSWebViewBackButtonView *backButton;
@property (nonatomic, strong) UIView *snapNaviBar;
@end

@implementation EssayDetailViewController

- (void)dealloc {
    self.essayDetailView = nil;
    self.essayData = nil;
    self.trackEvent = nil;
    self.trackLabel = nil;
}

- (EssayDetailViewController *)initWithEssayData:(EssayData *)essayData
                                 scrollToComment:(BOOL)scrollToComment
                                      trackEvent:(NSString *)trackEvent
                                      trackLabel:(NSString *)trackLabel {
    self = [super init];
    if (self) {
        self.essayData = essayData;
        self.needScrollToComment = scrollToComment;
        self.trackEvent = trackEvent;
        self.statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
        self.trackLabel = trackLabel;
    }
    return self;
}

- (id)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    
    EssayData * essayData = nil;
    NSDictionary * params = paramObj.allParams;
    if ([params.allKeys containsObject:@"groupid"]) {
        NSNumber * groupID = [NSNumber numberWithLongLong:[[params objectForKey:@"groupid"] longLongValue]];
        NSNumber * fixedgroupID = [SSCommonLogic fixNumberTypeGroupID:groupID];
        
//        essayData = [EssayData insertInManager:[SSModelManager sharedManager]
//                          entityWithDictionary:@{@"uniqueID": fixedgroupID}];
//        [[SSModelManager sharedManager] save:nil];
        
        NSArray *array = [EssayData objectsWithQuery:@{@"uniqueID": [fixedgroupID stringValue]}];
        if (array.count > 0) {
            essayData = array.firstObject;
        } else {
            essayData = [EssayData objectWithDictionary:@{@"uniqueID": [fixedgroupID stringValue]}];
        }
    }
    
    return [self initWithEssayData:essayData scrollToComment:NO trackEvent:nil trackLabel:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Do any additional setup after loading the view.
    self.essayDetailView = [[EssayDetailView alloc] initWithFrame: [self frameForDetailView]
                                                         essayData: _essayData
                                                   scrollToComment: _needScrollToComment
                                                        trackEvent: _trackEvent
                                                        trackLabel: _trackLabel];
    
    if ([TTDeviceHelper isPadDevice]) {
        TTViewWrapper *wrapperView = [[TTViewWrapper alloc] initWithFrame:self.view.bounds];
        [wrapperView addSubview:self.essayDetailView];
        wrapperView.targetView = self.essayDetailView;
        [self.view addSubview:wrapperView];
    }
    else {
        [self.view addSubview:self.essayDetailView];
    }
    
    wrapperTrackEvent(@"essay_detail", [NSString stringWithFormat:@"enter_%@", _trackLabel]);
    
    [self initLeftBarButton];
    [self initRightBarButtons];
}

- (CGRect)frameForDetailView {
    if ([TTDeviceHelper isPadDevice]) {
   
        CGFloat padding = [TTUIResponderHelper paddingForViewWidth:0];
        return CGRectInset(self.view.frame, padding, 0);
        
    }
    return self.view.bounds;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.essayDetailView.frame = [self frameForDetailView];
}

- (void)showMoreSettingView
{
    [self.essayDetailView moreButtonClicked];
}

- (void)initLeftBarButton {
    if (_backButton == nil) {
        _backButton = [[SSWebViewBackButtonView alloc] init];
        [_backButton.backButton addTarget:self action:@selector(backButtonFired:) forControlEvents:UIControlEventTouchUpInside];
        [_backButton showCloseButton:NO];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_backButton];
}

- (void)initRightBarButtons {
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    _moreButton = [self p_generateBarButtonWithImageName:@"new_more_titlebar.png" selector:@selector(showMoreSettingView)];
    [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:_moreButton]];
    
    if ([SSCommonLogic searchInDetailNavBarEnabled]) {
        _searchButton = [self p_generateBarButtonWithImageName:@"search_topic.png" selector:@selector(p_showSearchViewController)];
        [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:_searchButton]];
    }
    self.navigationItem.rightBarButtonItems = buttons;
}

- (void)backButtonFired:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (TTAlphaThemedButton *)p_generateBarButtonWithImageName:(NSString *)imageName selector:(SEL)selector {
    TTAlphaThemedButton *barButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    barButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
    [barButton setImage:[UIImage themedImageNamed:imageName] forState:UIControlStateNormal];
    [barButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [barButton sizeToFit];
    
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        [barButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -2)];
    }
    else {
        [barButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -4)];
    }
    return barButton;
}

- (void)searchViewCancelButtonClicked:(ExploreSearchView *)searchView {
    [self p_dismissSearchViewController:searchView];
}

- (void)p_showSearchViewController {
    UIView *navibar = [TTNavigationController refactorNaviEnabled]? self.parentViewController.ttNavigationBar: self.navigationController.navigationBar;
    wrapperTrackEvent(@"search", @"detail_icon_essay");
    //动画分解
    //1.贴图
    //2.按钮隐藏
    //3.snapNaviBar左移 变淡,self.view变淡
    //4.snapSearchBar出现 左移 变深, snapContent向上 变深
    ExploreSearchViewController *searchViewController = [[ExploreSearchViewController alloc] initWithNavigationBar:YES showBackButton:NO queryStr:nil fromType:ListDataSearchFromDetail];
    
    searchViewController.ttDisableDragBack = YES;
    [searchViewController view];
    searchViewController.searchView.searchViewDelegate = self;
    searchViewController.animatedWhenDismiss = NO;
    UIView *snapContentView = [searchViewController.searchView.contentView snapshotViewAfterScreenUpdates:YES];
    snapContentView.alpha = 0.f;
    snapContentView.top = navibar.bottom + 50.f;
    
    UIView *snapNaviBar = [navibar snapshotViewAfterScreenUpdates:YES];
    _snapNaviBar = snapNaviBar;
    _snapNaviBar.alpha = 0.2f;
    
    ArticleSearchBar * searchBar = [ExploreSearchViewController searchBarWithWidth:self.view.width];
    UIView *snapSearchBar = [searchBar snapshotViewAfterScreenUpdates:YES];
    snapSearchBar.left = 30.f;
    snapSearchBar.alpha = 0.1f;
    snapSearchBar.hidden = YES;
    
    UIView *snapCancelBtn = [searchBar.cancelButton snapshotViewAfterScreenUpdates:YES];
    snapCancelBtn.left = snapSearchBar.right;
    snapCancelBtn.alpha = 0.1f;
    snapCancelBtn.hidden = YES;
    
    [self.navigationController.view addSubview:snapContentView];
    [navibar addSubview:snapNaviBar];
    [navibar addSubview:snapSearchBar];
    [navibar addSubview:snapCancelBtn];
    self.searchButton.hidden = YES;
    self.moreButton.hidden = YES;
    self.backButton.hidden = YES;
    [UIView animateWithDuration:0.15f animations:^{
        snapNaviBar.left -= 30.f;
        snapNaviBar.alpha = 0.f;
    } completion:^(BOOL finished) {
            snapSearchBar.hidden = NO;
            snapCancelBtn.hidden = NO;
            [UIView animateWithDuration:0.15f animations:^{
                snapSearchBar.left = 0.f;
                snapSearchBar.alpha = 1.f;
                
                snapCancelBtn.left = snapSearchBar.right - 7.f; //取消按钮距搜索框位置
                snapCancelBtn.alpha = 1.f;
                
                snapContentView.alpha = 1.f;
                snapContentView.top = navibar.bottom; //不能挡住导航栏
                
            } completion:^(BOOL finished) {
                [self.navigationController pushViewController:searchViewController animated:NO];
                self.searchButton.hidden = NO;
                self.moreButton.hidden = NO;
                self.backButton.hidden = NO;
                [snapSearchBar removeFromSuperview];
                [snapNaviBar removeFromSuperview];
                [snapContentView removeFromSuperview];
                [snapCancelBtn removeFromSuperview];
            }];
    }];
}

- (void)p_dismissSearchViewController:(ExploreSearchView *)searchView {
    UIView *navibar = [TTNavigationController refactorNaviEnabled]? self.parentViewController.ttNavigationBar: self.navigationController.navigationBar;
    //准备工作
    //1.搜索content,searchBar,原始的navibar分别snap
    //2.设置初始状态
    //3.pop searchController
    //动画开始
    //1.searchBar右移逐渐变淡,content下移逐渐变淡
    //2.naviBar从指定位置出现,右移,逐渐变深,self.view逐渐变深
    UIView *snapSearchBar = [searchView.searchBar snapshotViewAfterScreenUpdates:NO];
    UIView *snapContent = [searchView.contentView snapshotViewAfterScreenUpdates:NO];
    snapContent.top = navibar.bottom;
    
    _snapNaviBar.hidden = YES;
    _snapNaviBar.alpha = 0.f;
    _snapNaviBar.left = -50.f;
    [self.navigationController.view addSubview:snapContent];
    [navibar addSubview:_snapNaviBar];
    [navibar addSubview:snapSearchBar];
    [self.navigationController popViewControllerAnimated:NO];
    self.searchButton.hidden = YES;
    self.moreButton.hidden = YES;
    self.backButton.hidden = YES;
    
    [UIView animateWithDuration:0.15f animations:^{
        snapSearchBar.alpha = 0.f;
        snapSearchBar.left += 80.f;
        snapContent.alpha = 0.f;
        snapContent.top += 50.f;
    } completion:^(BOOL finished) {
        _snapNaviBar.hidden = NO;
        [UIView animateWithDuration:0.15f animations:^{
            _snapNaviBar.alpha = 0.2f;
            _snapNaviBar.left = 0.f;
        } completion:^(BOOL finished) {
            [_snapNaviBar removeFromSuperview];
            [snapSearchBar removeFromSuperview];
            [snapContent removeFromSuperview];
            
            self.searchButton.hidden = NO;
            self.moreButton.hidden = NO;
            self.backButton.hidden = NO;
            _snapNaviBar = nil;
        }];
    }];
}

#pragma mark -  InteractExitProtocol
- (UIView *)suitableFinishBackView{
    return _essayDetailView;
}

@end
