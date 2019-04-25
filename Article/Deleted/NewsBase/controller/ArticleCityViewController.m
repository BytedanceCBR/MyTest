//
//  ArticleCityViewController.m
//  Article
//
//  Created by Kimimaro on 13-6-5.
//
//

#import "ArticleCityViewController.h"

#import "SSControllerViewBase.h"
#import "ArticleTitleImageView.h"
#import "TTArticleCategoryManager.h"
#import "SSNavigationBar.h"
#import "TTDeviceHelper.h"



@interface ArticleCityViewController () {
    BOOL _hasAppear;
}
@property (nonatomic, retain) UIView *titleBar;
@property (nonatomic, retain) ArticleCityView *cityView;
@end


@implementation ArticleCityViewController

- (void)dealloc
{
    self.titleBar = nil;
    self.cityView = nil;
}


- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
//        if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
//            self.automaticallyAdjustsScrollViewInsets = NO;
//        }

    }
    return self;
}

- (id)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
//        NSDictionary *params = paramObj.allParams;
//        NSString *clickFrom = [params objectForKey:@"click_from"];
//        if (!isEmptyString(clickFrom)) {
//            SSTracker(@"")
//        }
    }
    return self;
}

- (void)loadView
{
    
    self.preferredContentSize = CGSizeMake(320, 480);
    CGSize contentSize = [TTUIResponderHelper applicationSize];
    if ([TTDeviceHelper isPadDevice]) {
        contentSize = self.preferredContentSize;
    }
    SSControllerViewBase *contentView = [[SSControllerViewBase alloc] initWithFrame:CGRectMake(0, 0, contentSize.width, contentSize.height)];
    if ([TTDeviceHelper isPadDevice]) {
        contentView.backgroundColor = [UIColor colorWithHexString:@"e6e6e6"];
    }
    else {
        contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    }
    contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view = contentView;
    
    self.cityView = [[ArticleCityView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    _cityView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_cityView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString * city = [[TTArticleCategoryManager sharedManager] localCategory].name;
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textColorThemeKey = kColorText1;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    if ([city isEqualToString:kTTNewsLocalCategoryNoCityName] || [city length] == 0) {
        titleLabel.text = NSLocalizedString(@"当前城市-未选择", nil);
    }
    else {
        titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"当前城市-%@", nil), city];
    }
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_hasAppear) {
        _hasAppear = YES;
    }
    [_cityView didAppear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_cityView didDisappear];
}

#pragma mark - Action

- (void)backButtonClicked:(id)sender
{
    wrapperTrackEvent(@"category_nav", @"local_news_setting_cancel");
    UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor: self];
    [nav popViewControllerAnimated:YES];
}

@end

