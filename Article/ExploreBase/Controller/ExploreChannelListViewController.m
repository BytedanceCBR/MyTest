//
//  ExploreChannelListViewController.m
//  Article
//
//  Created by Chen Hong on 14-10-13.
//
//

#import "ExploreChannelListViewController.h"
#import "ExploreChannelListView.h"
#import "TTAlphaThemedButton.h"
#import "UIButton+TTAdditions.h"
#import "TTArticleCategoryManager.h"
#import "TTCategory.h"
#import "TTIndicatorView.h"
#import "WDCommonLogic.h"
#import "TTRoute.h"
#import "TTCategoryStayTrackManager.h"

#define iconfont   @"ask_icon"
#define details_add_icon                @"\U0000E651"

@interface ExploreChannelListViewController () <ExploreChannelListViewDelegate, TTRouteInitializeProtocol>
@property (nonatomic, strong) ExploreChannelListView *listView;
@property (nonatomic, strong) TTAlphaThemedButton *addFirstButton;
@property (nonatomic, strong) TTCategory *category;
@end

@implementation ExploreChannelListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.baseCondition = paramObj.allParams;
        self.params = paramObj.allParams;
        self.hidesBottomBarWhenPushed = YES;
        
        TTCategory *model = [TTArticleCategoryManager categoryModelByCategoryID:[self.params tt_stringValueForKey:@"category"]];
        self.category = model;
    }
    return self;
}

- (instancetype)initWithRouteParams:(NSDictionary *)params
{
    if (self = [super init]) {
        self.baseCondition = params;
        self.params = params;
        self.hidesBottomBarWhenPushed = YES;
        TTCategory *model = [TTArticleCategoryManager categoryModelByCategoryID:[self.params tt_stringValueForKey:@"category"]];
        self.category = model;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *title  = [self.params objectForKey:@"name"];;
    if (!isEmptyString(title)) {
        title = [NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"频道", nil)];
    } else {
        title = NSLocalizedString(@"频道", nil);
    }
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:title];
    
    [self.view addSubview:self.listView];
    [self configAddFirstBarButton];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_listView willAppear];
    [self enterCategory];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_listView didAppear];
    [self leaveCategory];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_listView willDisappear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_listView didDisappear];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [_listView didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - Private

- (void)configAddFirstBarButton
{
    if ([WDCommonLogic isChannelAddFristPageEnabled]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.addFirstButton];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.listView.navigationBar.rightBarView];
    }
    
}

#pragma mark - ExploreChannelListViewDelegate

- (void)listViewFinishRequest:(ExploreChannelListView *)listView error:(NSError *)error
{
    if (!error) {
        [self configAddFirstBarButton];
    }
}

#pragma mark - TTRouteInitializeProtocol
+ (NSURL * _Nonnull )redirectURLWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    if ([paramObj.host isEqualToString:@"category_feed"]) {
        NSMutableString *mutableStr = [NSMutableString string];
        [mutableStr appendString:paramObj.scheme];
        [mutableStr appendString:@"target?action=category_feed&"];
        NSArray *array = [paramObj.allParams allKeys];
        for (NSUInteger i = 0; i < array.count; i++) {
            NSString *key = [array objectAtIndex:i];
            NSString *value = [paramObj.allParams tt_stringValueForKey:[array objectAtIndex:i]];
            NSString *str = [NSString stringWithFormat:@"%@=%@", key, value];
            [mutableStr appendString:str];
        }
        
        return [NSURL URLWithString:[mutableStr copy]];
    }
    // Duang 新增一个识别feed
    else if ([paramObj.host isEqualToString:@"feed"]) {
        NSMutableString *mutableStr = [NSMutableString string];
        [mutableStr appendString:paramObj.scheme];
        [mutableStr appendString:@"target?action=feed&"];
        NSArray *array = [paramObj.allParams allKeys];
        for (NSUInteger i = 0; i < array.count; i++) {
            NSString *key = [array objectAtIndex:i];
            NSString *value = [paramObj.allParams tt_stringValueForKey:[array objectAtIndex:i]];
            NSString *str = [NSString stringWithFormat:@"%@=%@", key, value];
            [mutableStr appendString:str];
        }
        return [NSURL URLWithString:[mutableStr copy]];
    }
    return [NSURL URLWithString:@""];
}

#pragma mark - Actions & Response

- (void)addFirstPageButtonFired:(TTAlphaThemedButton *)button
{
    [UIView animateWithDuration:0.3 animations:^{
        button.layer.opacity = 0;
    } completion:^(BOOL finished) {
        button.hidden = YES;
        [WDCommonLogic setChannelAddFristPageEnabled:NO];
    }];
    
    TTCategory *model = [TTArticleCategoryManager categoryModelByCategoryID:[self.params tt_stringValueForKey:@"category"]];
    NSDictionary *userInfo = @{kTTInsertCategoryNotificationCategoryKey:model};
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTInsertCategoryToLastPositionNotification object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:kArticleCategoryTipNewChangedNotification object:nil];
    
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"已放到首屏", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    
    [TTTrackerWrapper ttTrackEventWithCustomKeys:@"channel_detail" label:[NSString stringWithFormat:@"add_%@",model.categoryID] value:nil source:nil extraDic:nil];
}

#pragma mark - Getter

- (ExploreChannelListView *)listView
{
    if (!_listView) {
        _listView = [[ExploreChannelListView alloc] initWithFrame:self.view.bounds
                                                    baseCondition:self.baseCondition];
        _listView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _listView.delegate = self;
    }
    return _listView;
}

- (NSAttributedString *)titleForRightBarButtonItem
{
    NSString *iconString = [NSString stringWithFormat:@"%@ ",details_add_icon];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:iconString
                                                                              attributes:@{
                                                                                           NSFontAttributeName : [UIFont fontWithName:iconfont size:14],                       NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5]}
                                        ];
    
    NSMutableAttributedString *token = [[NSMutableAttributedString alloc] initWithString:@"添加到首屏"
                                                                              attributes:@{
                                                                                           NSFontAttributeName : [UIFont systemFontOfSize:14],                       NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5]}
                                        ];
    
    
    [title appendAttributedString:token];
    return [title copy];
}

- (TTAlphaThemedButton *)addFirstButton
{
    if (!_addFirstButton) {
        TTAlphaThemedButton *addFirstButton = [[TTAlphaThemedButton alloc] init];
        [addFirstButton setAttributedTitle:[self titleForRightBarButtonItem] forState:UIControlStateNormal];
        [addFirstButton setTitleColor:[UIColor tt_themedColorForKey:kColorText5]forState:UIControlStateNormal];
        [addFirstButton sizeToFit];
        
        [addFirstButton addTarget:self action:@selector(addFirstPageButtonFired:) forControlEvents:UIControlEventTouchUpInside];
        _addFirstButton = addFirstButton;
    }
    return _addFirstButton;
}

#pragma mark - 频道驻留时长统计

- (void)enterCategory {
    if (self.category) {
        NSString *from = [self.params objectForKey:@"enter_from"];
        NSString *enterType = @"click";
        [[TTCategoryStayTrackManager shareManager] startTrackForCategoryID:self.category.categoryID concernID:self.category.concernID enterType:enterType];
    }
}

- (void)leaveCategory {
    if (self.category) {
        [[TTCategoryStayTrackManager shareManager] endTrackCategory:self.category.categoryID];
    }
}

@end

