//
//  TTTopBar.m
//  Article
//
//  Created by fengyadong on 16/8/25.
//
//

#import "TTTopBar.h"
#import "TTTopBarManager.h"
#import <TTImage/TTImageView.h>
#import "UIImageView+WebCache.h"
#import <TTUIWidget/TTBadgeNumberView.h>
#import "ArticleBadgeManager.h"
#import "TTSettingMineTabGroup.h"
#import "TTSettingMineTabManager.h"
#import "TTBadgeTrackerHelper.h"
#import "TTArticleSearchManager.h"
#import "TTCategoryBadgeNumberManager.h"
#import <TTTracker.h>
#import <TTAccountBusiness.h>
#import "TTSearchHomeSugModel.h"
#import "TTTintThemeButton.h"
#import "TTTabBarProvider.h"
//#import "PopoverView.h"
//#import "TTPostUGCEntrance.h"
//#import "TTUGCPermissionService.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAlphaThemedButton.h"
#import <BDWebImage/SDWebImageAdapter.h>
#import "FHHomeSearchPanelView.h"
//#import "Bubble-Swift.h"
#import <UIFont+House.h>
#import "UIImageView+BDWebImage.h"

#import "FHEnvContext.h"

#import "UIImageAdditions.h"

NSString * const TTTopBarMineIconTapNotification = @"TTTopBarMineIconTapNotification";

@interface TTTopBar ()<UIGestureRecognizerDelegate, TTAccountMulticastProtocol>

@property (nonatomic, strong) TTCategorySelectorView *selectorView;
@property (nonatomic, strong) SSThemedImageView *backgroundImageView;
//@property (nonatomic, strong) SSThemedImageView *searchBarImageView;
@property (nonatomic, strong) SSThemedLabel *currentCityLabel;
@property (nonatomic, strong) SSThemedLabel *searchLabel;
@property (nonatomic, strong) UITapGestureRecognizer *searchFieldTapGesture;
@property (nonatomic, strong) TTTopBarManager *manager;
//@property (nonatomic, strong) SSThemedImageView *mineIcon;
//@property (nonatomic, strong) SSThemedImageView *mineIconMaskView;
//@property (nonatomic, strong) SSThemedButton *mineIconButton;
@property (nonatomic, strong) TTBadgeNumberView *badgeView;

@property (nonatomic, assign) CGFloat touchOffset;
@property (nonatomic, assign) CGFloat textLeftOffset;
@property (nonatomic,assign) BOOL isHighlighted;
@property (nonatomic, strong) NSArray *curKeywords;
@property (nonatomic, assign) BOOL isDisplaying;
@property (nonatomic, assign) BOOL shouldRefreshSearchLabel;
@property (nonatomic, copy) NSString *lastShowPlaceHolder;
@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic, strong) UIView *topUnAvalibleCityContainer;

@end

@implementation TTTopBar

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        _manager = [TTTopBarManager sharedInstance_tt];
        self.shouldRefreshSearchLabel = NO;
        [TTAccount addMulticastDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchPlaceholderChanged:) name:@"kSearchPlaceHolderHasChanged" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveBadgeMangerChangedNotification:) name:kArticleBadgeManagerRefreshedNotification object:nil];
    }
    return self;
}


- (void)showUnValibleCity
{
    FHConfigDataModel *dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    if (dataModel.cityAvailability && [dataModel.cityAvailability.enable respondsToSelector:@selector(boolValue)] &&[dataModel.cityAvailability.enable boolValue] == false) {
        self.pageSearchPanel.hidden = YES;

        if (self.topUnAvalibleCityContainer) {
            [self.topUnAvalibleCityContainer removeFromSuperview];
            self.topUnAvalibleCityContainer = nil;
        }
        
        self.topUnAvalibleCityContainer = [[UIView alloc] init];
        [self.backgroundImageView addSubview:self.topUnAvalibleCityContainer];
        [self.backgroundImageView bringSubviewToFront:self.topUnAvalibleCityContainer];
        
        [self.topUnAvalibleCityContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.backgroundImageView);
        }];
        if (dataModel.cityAvailability.backgroundColor) {
            [self.topUnAvalibleCityContainer setBackgroundColor:[UIColor colorWithHexString:dataModel.cityAvailability.backgroundColor]];
        }
        
        CGFloat padingTop = 8;
        if ([TTDeviceHelper isIPhoneXDevice]) {
            padingTop = 20;
        }
        UIButton *citySwichButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.topUnAvalibleCityContainer addSubview:citySwichButton];
//        citySwichButton.layer.masksToBounds = YES;
        citySwichButton.layer.cornerRadius = 20;
        citySwichButton.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1f].CGColor;
        citySwichButton.layer.shadowOffset = CGSizeMake(0.f, 2.f);
        citySwichButton.layer.shadowRadius = 6.f;
        citySwichButton.layer.shadowOpacity = 1.f;
        [citySwichButton.titleLabel setFont:[UIFont themeFontRegular:14]];
        citySwichButton.backgroundColor = [UIColor whiteColor];;
        [citySwichButton setTitle:dataModel.currentCityName forState:UIControlStateNormal];
        [citySwichButton setTitleColor:[UIColor tt_themedColorForKey:kFHColorCharcoalGrey] forState:UIControlStateNormal];
        [citySwichButton setTitleColor:[UIColor tt_themedColorForKey:kFHColorCharcoalGrey] forState:UIControlStateHighlighted];
        [citySwichButton setTitle:dataModel.currentCityName forState:UIControlStateNormal];
        [citySwichButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topUnAvalibleCityContainer).offset(20);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(self.topUnAvalibleCityContainer.mas_bottom).offset(-12);
            make.width.mas_equalTo(dataModel.currentCityName.length * 14 + 44);
        }];
        [citySwichButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 22, 0, 0)];
        [citySwichButton addTarget:self withActionBlock:^{
            NSURL *url = [[NSURL alloc] initWithString:@"sslocal://city_list"];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:NULL];
        } forControlEvent:UIControlEventTouchUpInside];
        
        UIImageView *imageButtonLeftIcon = [UIImageView new];
        [citySwichButton addSubview:imageButtonLeftIcon];
        [imageButtonLeftIcon setImage:[UIImage imageNamed:@"combined-shape-1"]];
        [imageButtonLeftIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(citySwichButton).offset(14);
            make.height.mas_equalTo(18);
            make.centerY.equalTo(citySwichButton);
            make.width.mas_equalTo(18);
        }];
        
        
        UIImageView *imageRightView = [UIImageView new];
        [self.topUnAvalibleCityContainer addSubview:imageRightView];
        
        [imageRightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.topUnAvalibleCityContainer).offset(0);
            make.height.mas_equalTo(52);
            make.centerY.equalTo(self.topUnAvalibleCityContainer).offset(padingTop);
            make.width.mas_equalTo(108);
        }];
        
        
        UILabel *topTipForCityLabel = [UILabel new];
        topTipForCityLabel.text = @"找房服务即将开通，敬请期待";
        topTipForCityLabel.font = [UIFont themeFontRegular:14];
        topTipForCityLabel.textColor = [UIColor tt_themedColorForKey:kFHColorCoolGrey3];
        [self.topUnAvalibleCityContainer addSubview:topTipForCityLabel];
        
        [topTipForCityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(citySwichButton.mas_right).offset(10);
            make.height.mas_equalTo(20);
            make.bottom.equalTo(self.topUnAvalibleCityContainer.mas_bottom).offset(-22);
            make.width.mas_equalTo(183);
        }];
        
        
        if (dataModel.cityAvailability.iconImage.url) {
            [imageRightView bd_setImageWithURL:[NSURL URLWithString:dataModel.cityAvailability.iconImage.url]];
        }
        
    }else
    {
        if (self.topUnAvalibleCityContainer) {
            [self.topUnAvalibleCityContainer removeFromSuperview];
            self.topUnAvalibleCityContainer = nil;
        }
        self.pageSearchPanel.hidden = NO;
    }
}

- (void)willAppear
{
    FHConfigDataModel *dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    if (dataModel.cityAvailability && [dataModel.cityAvailability.enable respondsToSelector:@selector(boolValue)] &&[dataModel.cityAvailability.enable boolValue] == false) {
        self.pageSearchPanel.hidden = YES;
    }else
    {
        self.pageSearchPanel.hidden = NO;
    }
}

- (void)hideUnValibleCity
{
    
}

- (void)setupSubviews
{
    ///背景图，支持下发
    _backgroundImageView = [[SSThemedImageView alloc] init];
    _backgroundImageView.clipsToBounds = YES;
    [self addSubview:_backgroundImageView];
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        if (self.selectorView){
            make.bottom.equalTo(self.selectorView.mas_top);
        }else{
            make.bottom.equalTo(self);
        }
    }];
    self.backgroundImageView.layer.zPosition = -1;
    self.backgroundImageView.userInteractionEnabled = YES;
    
    /*
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(searchActionFired:)];
    [self.backgroundImageView addGestureRecognizer:tap];
    tap.delegate = self;
    self.searchFieldTapGesture = tap;
     */
    
    /*
     _searchBarImageView = [[SSThemedImageView alloc] init];
     _searchBarImageView.clipsToBounds = YES;
     _searchBarImageView.hidden = YES;
     [self.backgroundImageView addSubview:_searchBarImageView];
     */
    
    _pageSearchPanel = [[FHHomeSearchPanelView alloc] init];
//    _pageSearchPanel = [[HomePageSearchPanel alloc] init];
    [self.backgroundImageView addSubview:_pageSearchPanel];
    
    /*
     _currentCityLabel = [[SSThemedLabel alloc] init];
     _currentCityLabel.text = @"北京";
     [_searchBarImageView addSubview:_currentCityLabel];
     */
    
    /* 隐藏首页搜索usericon
     ///我的icon，只在第四个tab不是我的时显示
     if (![TTTabBarProvider isMineTabOnTabBar]) {
     _mineIcon = [[SSThemedImageView alloc] init];
     _mineIcon.hidden = YES;
     [self.backgroundImageView addSubview:_mineIcon];
     [_mineIcon mas_makeConstraints:^(MASConstraintMaker *make) {
     make.right.equalTo(self).offset(-kPublishRightOffset);
     make.width.mas_equalTo(@(kMineIconW));
     make.height.mas_equalTo(@(kMineIconH));
     make.centerY.mas_equalTo(_backgroundImageView.mas_bottom).offset(-kNavBarHeight / 2);
     }];
     
     _mineIconMaskView = [[SSThemedImageView alloc] init];
     [_mineIcon addSubview:_mineIconMaskView];
     [_mineIconMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
     make.edges.equalTo(self.mineIcon);
     }];
     _mineIconMaskView.image = [UIImage imageWithSize:CGSizeMake(kMineIconW, kMineIconH) backgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
     
     _badgeView = [[TTBadgeNumberView alloc] init];
     _badgeView.badgeViewStyle = TTBadgeNumberViewStyleDefaultWithBorder;
     _badgeView.hidden = YES;
     [self.backgroundImageView addSubview:_badgeView];
     
     _mineIconButton = [[SSThemedButton alloc] init];
     [self.backgroundImageView addSubview:_mineIconButton];
     [_mineIconButton mas_makeConstraints:^(MASConstraintMaker *make) {
     make.center.equalTo(_mineIcon);
     make.width.height.mas_equalTo(@(kMineIconButtonH));
     }];
     [_mineIconButton addTarget:self action:@selector(mineIconClick:) forControlEvents:UIControlEventTouchUpInside];
     _mineIconButton.accessibilityLabel = @"我的";
     }
     */
    
    ///搜索文案，支持下发，refresh_tips/settings接口下发，优先refresh_tips
    _searchLabel = [[SSThemedLabel alloc] init];
    if (self.manager.topBarConfigValid.boolValue && [TTTopBarManager sharedInstance_tt].searchTextColors.count == 2) {
        _searchLabel.textColor = [UIColor colorWithDayColorName:[TTTopBarManager sharedInstance_tt].searchTextColors[0] nightColorName:[TTTopBarManager sharedInstance_tt].searchTextColors[1]];
    } else {
        _searchLabel.textColorThemeKey = kColorText14;
    }
    _searchLabel.textAlignment = NSTextAlignmentLeft;
    _searchLabel.font = [UIFont systemFontOfSize:14.f];
    [self.backgroundImageView addSubview:_searchLabel];
    
    [self refreshData];
    [self refreshLayout];
    
    
    WeakSelf;
    [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
        StrongSelf;
        [self showUnValibleCity];
    }];
}

- (void)refreshLayout {
    
    //    [_searchBarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
    //        CGFloat offset = kSearchImageBackLeft;
    //        make.left.equalTo(self).offset(offset);
    //        make.centerY.mas_equalTo(_backgroundImageView.mas_bottom).offset(-kNavBarHeight / 2);
    //        make.right.equalTo(self).offset(-offset);
    //        make.height.mas_equalTo(44.0f);
    //        /*
    //        if(![TTTabBarProvider isMineTabOnTabBar]) {
    //            make.right.equalTo(self.mineIcon.mas_left).offset(-kPublishLeftOffset);
    //        } else {
    //            make.right.equalTo(self).offset(-kSearchFieldExtendRight);
    //        }
    //       */
    //    }];
    
    //    [_currentCityLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    //        CGFloat offset = kSearchCityLabelLeft;
    //        make.left.equalTo(_searchBarImageView).offset(offset);
    //        make.centerY.mas_equalTo(_searchBarImageView);
    //        make.right.equalTo(self).offset(-offset);
    //        make.height.mas_equalTo(44.0f);
    //    }];
    
    
    [_pageSearchPanel mas_remakeConstraints:^(MASConstraintMaker *make) {
        CGFloat offset = kSearchImageBackLeft;
        make.left.equalTo(self).offset(offset);
        make.centerY.mas_equalTo(_backgroundImageView.mas_bottom).offset(-kNavBarHeight / 2 - 3);
        make.right.equalTo(self).offset(-offset);
        make.height.mas_equalTo(52.0f);
    }];
   
    [_pageSearchPanel setBackgroundColor:[UIColor whiteColor]];
    [self remakeConstraintsForSearchLabel];
}

- (void)remakeConstraintsForSearchLabel {
    //    [self.searchLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    //        make.left.equalTo(self.backgroundImageView.mas_left).with.offset(self.textLeftOffset);
    //        if (![TTTabBarProvider isMineTabOnTabBar]){
    //            make.right.equalTo(self.searchBarImageView.mas_right).offset(-15);
    //        } else {
    //            make.right.equalTo(self.backgroundImageView.mas_right).with.offset(-30);
    //        }
    //        make.height.mas_equalTo(28);
    //        make.centerY.equalTo(_searchBarImageView);
    //    }];
}

#pragma mark -- Public Method

- (void)addTTCategorySelectorView:(TTCategorySelectorView *)selectorView delegate:(id<TTCategorySelectorViewDelegate>)delegate {
    self.selectorView = selectorView;
    [self addSubview:self.selectorView];
    self.selectorView.delegate = delegate;
    [self.selectorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(@(kSelectorViewHeight));
        make.bottom.equalTo(self);
    }];
}

- (void)refreshData
{
    [self refreshBackgroundImageView];
    // [self refreshMineIcon];
    [self refreshSearchLabel];
    [self refreshBadgeView];
}

- (void)refreshBackgroundImageView
{
    //to do 根据服务端下发配置背景图
    //    self.backgroundImageView.image = [[self class] searchBackgroundImage];
    //    self.searchBarImageView.image = [[self class] searchBarImage];
    self.backgroundImageView.backgroundColor = [UIColor whiteColor];
    //    self.searchBarImageView.backgroundColor = [UIColor whiteColor];
    self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;
}


- (void)refreshMineIcon
{
    /*
     if ([TTTabBarProvider isMineTabOnTabBar]) {
     return;
     }
     NSString *iconURLString = nil;
     if ([TTAccountManager isLogin]) {
     iconURLString = [TTAccountManager avatarURLString];
     [self.mineIcon mas_updateConstraints:^(MASConstraintMaker *make) {
     make.width.height.mas_equalTo(kMineIconW);
     }];
     self.mineIcon.layer.cornerRadius = kMineIconW / 2;
     self.mineIcon.clipsToBounds = YES;
     [self.mineIcon sda_setImageWithURL:[NSURL URLWithString:iconURLString] placeholderImage:[UIImage imageNamed:@"topbar_unlogin_default"]];
     }
     else{
     [self.mineIcon mas_updateConstraints:^(MASConstraintMaker *make) {
     make.width.mas_equalTo(kMineIconW);
     make.height.mas_equalTo(kMineIconH);
     }];
     self.mineIcon.layer.cornerRadius = 0;
     self.mineIcon.clipsToBounds = NO;
     [self.mineIcon setImage:[TTTopBarManager sharedInstance_tt].unloginImage];
     }
     
     if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight && ![TTAccountManager isLogin]) {
     _mineIconMaskView.hidden = NO;
     UIImage *image = nil;
     if (_mineIcon.image) {
     image = _mineIcon.image;
     }
     else{
     image = [UIImage themedImageNamed:@"hs_newmine_tabbar"];
     }
     UIImageView* newImageView = [[UIImageView alloc] initWithImage:image];
     newImageView.frame = CGRectMake(0, 0, kMineIconW, kMineIconH);
     newImageView.contentMode = UIViewContentModeScaleAspectFill;
     _mineIconMaskView.layer.mask = newImageView.layer;
     }
     else if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight &&[TTAccountManager isLogin]){
     _mineIconMaskView.hidden = NO;
     _mineIconMaskView.layer.mask = nil;
     }
     else{
     _mineIconMaskView.hidden = YES;
     }
     */
}

- (void)refreshSearchLabel
{
    if (self.manager.topBarConfigValid.boolValue && [TTTopBarManager sharedInstance_tt].searchTextColors.count == 2) {
        _searchLabel.textColor = [UIColor colorWithDayColorName:[TTTopBarManager sharedInstance_tt].searchTextColors[0] nightColorName:[TTTopBarManager sharedInstance_tt].searchTextColors[1]];
    }
    
    NSString *placeholder = [self.tab isEqualToString:@"video"] ? [SSCommonLogic searchBarTipForVideo] : [SSCommonLogic searchBarTipForNormal];
    
    if ([SSCommonLogic searchHintSuggestEnable]) {
        NSArray *array = [placeholder componentsSeparatedByString:@"|"];
        if (array.count > 0) {
            placeholder = [array firstObject];
            placeholder = [placeholder trimmed];
        }
        if (placeholder.length == 0) {
            placeholder = kSearchBarPlaceholdString;
        }
    }
    _searchLabel.backgroundColor = kSearchLabelBackColor;
    _searchLabel.text = placeholder;
}

- (void)refreshBadgeView
{
    /*
     if ([TTTabBarProvider isMineTabOnTabBar]) {
     return;
     }
     NSUInteger number = [self badgeNumber];
     CGFloat topInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.top;
     if (topInset == 0){
     topInset = 20;
     }
     
     [self.badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
     make.right.equalTo(self.mineIcon.mas_right).offset(7.f);
     make.top.equalTo(self.mineIcon.mas_top).offset(-4.f);
     }];
     
     self.badgeView.right = self.mineIcon.right + 7.f;
     self.badgeView.top = self.mineIcon.top - 4.f;
     
     if (number == TTBadgeNumberPoint) {
     self.badgeView.hidden = NO;
     self.badgeView.badgeNumber = TTBadgeNumberPoint;
     }
     else if (number > 99) {//大于99显示 ...
     self.badgeView.hidden = NO;
     self.badgeView.badgeNumber = TTBadgeNumberMore;
     }
     else if (number > 0) {
     self.badgeView.hidden = NO;
     self.badgeView.badgeNumber = number;
     }
     else{
     self.badgeView.hidden = YES;
     self.badgeView.badgeNumber = TTBadgeNumberHidden;
     }
     */
}


- (void)topBarWillAppear {
    if(self.shouldRefreshSearchLabel){
        self.shouldRefreshSearchLabel = NO;
        //        [self searchLabelAnimated:self.lastShowPlaceHolder placeholder:self.placeHolder];
        
    }
}

- (void)topBarWillDisappear {
}

#pragma mark - Gesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.searchFieldTapGesture){
        CGPoint location = [gestureRecognizer locationInView:self.backgroundImageView];
        CGRect actionBounds = CGRectMake(self.touchOffset, 0, CGRectGetWidth(self.backgroundImageView.bounds), CGRectGetHeight(self.backgroundImageView.bounds));
        if (CGRectContainsPoint(actionBounds, location)) {
            return YES;
            LOGD(@"searchFieldClick");
        }
        
        return NO;
    }
    return NO;
}

- (void)mineIconClick:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(mineActionFired:)]) {
        NSString *position = nil;
        NSString *style = nil;
        position = @"mine_tab";
        if (self.badgeView.badgeValue) {
            if (self.badgeView.badgeNumber == TTBadgeNumberPoint) {
                style = @"red_tips";
            }
            else if (!isEmptyString(self.badgeView.badgeValue)) {
                style = @"num_tips";
            }
        }
        
        [[TTBadgeTrackerHelper class] trackTipsWithLabel:@"click" position:position style:style];
        //进入火山tab
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:@"mine" forKey:@"tab_name"];
        if ([SSCommonLogic threeTopBarEnable] && !isEmptyString(_tab)){
            [extraDict setValue:_tab forKey:@"from_tab_name"];
        }
        [TTTrackerWrapper eventV3:@"enter_tab" params:extraDict];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TTTopBarMineIconTapNotification object:nil];
        
        [self.delegate performSelector:@selector(mineActionFired:) withObject:nil];
    }
}

#pragma mark - Notification

- (void)searchPlaceholderChanged:(NSNotification *)notification {
    NSString *placeholder = [SSCommonLogic searchBarTipForNormal];
    NSString *tab = [[notification.userInfo tt_stringValueForKey:@"tab"] isEqualToString:@"video"] ? @"video" : @"normal";
    NSString *currentTab = [self.tab isEqualToString:@"video"] ? @"video" : @"normal";
    id obj = notification.object;
    if ([currentTab isEqualToString:tab] == NO){
        return;
    }
    
    if ([tab isEqualToString:@"video"]){
        placeholder = [SSCommonLogic searchBarTipForVideo];
    }
    if ([SSCommonLogic searchHintSuggestEnable]) {
        NSArray *array = [placeholder componentsSeparatedByString:@"|"];
        if (array.count > 0) {
            placeholder = [array firstObject];
            placeholder = [placeholder trimmed];
        }
        if (placeholder.length == 0) {
            placeholder = kSearchBarPlaceholdString;
        }
    }
    
    if([obj isKindOfClass:[NSString class]]){
        NSString *str = (NSString *)obj;
        if([str isEqualToString:@"shoudRefresh"])
            self.shouldRefreshSearchLabel = YES;
        self.lastShowPlaceHolder = _searchLabel.text;
        self.placeHolder = placeholder;
        return;
    }
    
    //    [self searchLabelAnimated:_searchLabel.text placeholder:placeholder];
}

- (void)receiveBadgeMangerChangedNotification:(NSNotification *)notification {
    [self refreshBadgeView];
}

#pragma mark - private methods

- (void)searchLabelAnimated:(NSString *)oldPlaceholder placeholder:(NSString *)placeholder{
    /*
     CGRect frame = _searchLabel.frame;
     SSThemedLabel *label = [[SSThemedLabel alloc] initWithFrame:frame];
     label.textColorThemeKey = kColorText1;
     label.textAlignment = NSTextAlignmentLeft;
     label.font = [UIFont systemFontOfSize:14.f];
     label.text = oldPlaceholder;
     label.height = self.searchBarImageView.height;
     [self.searchBarImageView addSubview:label];
     _searchLabel.text = placeholder;
     _searchLabel.centerY += CGRectGetHeight(frame);
     _searchLabel.alpha = 0;
     [UIView animateWithDuration:0.6 animations:^{
     _searchLabel.centerY -= CGRectGetHeight(frame);
     _searchLabel.alpha = 1;
     label.centerY -= CGRectGetHeight(frame);
     label.alpha = 0;
     } completion:^(BOOL finished) {
     [label removeFromSuperview];
     _searchLabel.alpha = 1;
     }];
     */
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    // [self refreshMineIcon];
}

- (void)onAccountUserProfileChanged:(NSDictionary *)changedFields error:(NSError *)error
{
    if (!error) {
        //  [self refreshMineIcon];
    }
}

#pragma mark - dataSource

+ (UIImage *)searchBackgroundImage
{
    UIImage *image = nil;
    if ([TTTopBarManager sharedInstance_tt].topBarConfigValid.boolValue) {
        ///top bar需要替换背景图片，且头像不在左上角时，支持替换背景图片
        image = [[TTTopBarManager sharedInstance_tt] getImageForName:kTTPublishBackgroundImageName];
    } else {
        image = [UIImage themedImageNamed:@"surface_back_image_0"];
    }
    
    if(!image) {
        if ([TTDeviceHelper isIPhoneXDevice]){
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(46, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
        }
    }
    
    return image;
}

+ (UIImage *)searchBarImage {
    UIImage *image;
    if ([TTTopBarManager sharedInstance_tt].topBarConfigValid.boolValue) {
        ///top bar需要替换背景图片，且头像不在左上角时，支持替换背景图片
        image = [[TTTopBarManager sharedInstance_tt] getImageForName:kTTPublishSearchImageName];
    }
    
    if (!image) {
        image = [UIImage themedImageNamed:@"topbar_search_bar"];
    }
    
    CGFloat top = image.size.height/2.0 - 0.5;
    CGFloat left = image.size.width/2.0 - 0.5;
    CGFloat bottom = image.size.height/2.0 + 0.5;
    CGFloat right = image.size.width/2.0 + 0.5;
    
    UIEdgeInsets edge = UIEdgeInsetsMake(top,left,bottom,right);
    
    UIImage *stretchedImage = [image resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
    
    return stretchedImage;
}

- (NSUInteger)badgeNumber
{
    __block NSInteger number = 0;
    
    __block BOOL shouldDisplayRedBadge = NO;
    __block BOOL isTrackForMineTabShow = NO;
    
    TTSettingGeneralEntry * messageEntry = [[TTSettingMineTabManager sharedInstance_tt] getEntryForType:TTSettingMineTabEntyTypeMessage];
    TTSettingGeneralEntry *privateLetterEntry = [[TTSettingMineTabManager sharedInstance_tt] getEntryForType:TTSettingMineTabEntyTypePrivateLetter];
    
    NSArray<TTSettingMineTabGroup *> *sections = [TTSettingMineTabManager sharedInstance_tt].visibleSections;
    [sections enumerateObjectsUsingBlock:^(TTSettingMineTabGroup*  _Nonnull group, NSUInteger idx, BOOL * _Nonnull stop1) {
        [group.items enumerateObjectsUsingBlock:^(TTSettingGeneralEntry * _Nonnull entry, NSUInteger idx, BOOL * _Nonnull stop2) {
            //如果entry是message entry，并且message hint count需要显示到关注频道，则过滤；同时也一并过滤掉private-letter
            if ((entry != messageEntry && entry != privateLetterEntry) || ![[TTCategoryBadgeNumberManager sharedManager] isFollowCategoryNeedShowMessageBadgeNumber]) {
                if(entry.hintStyle == TTSettingHintStyleNumber)
                {
                    number += entry.hintCount;
                }
                if(entry.hintStyle == TTSettingHintStyleRedPoint || entry.hintStyle == TTSettingHintStyleNewFlag)
                {
                    shouldDisplayRedBadge = YES;
                    if (entry.isTrackForMineTabShow) {
                        isTrackForMineTabShow = YES;
                        entry.isTrackForMineTabShow = NO;
                    }
                }
            }
        }];
    }];
    
    if (number > 0) {
        shouldDisplayRedBadge = YES;
    }
    if (isTrackForMineTabShow) {
        NSString *position = nil;
        NSString *style = nil;
        position = @"mine_tab";
        if (number > 0) {
            style = @"num_tips";
        }
        else if (shouldDisplayRedBadge){
            style = @"red_tips";
        }
        [[TTBadgeTrackerHelper class] trackTipsWithLabel:@"show" position:position style:style];
    }
    if(number > 0) // 有数字显示数字
    {
        return number;
    }
    else if(shouldDisplayRedBadge)
    {
        return TTBadgeNumberPoint;
    }
    else
    {
        return 0;
    }
}

- (CGFloat)touchOffset
{
    if (self.manager.topBarConfigValid.boolValue && self.manager.touchAreaLeftOffset > 0) {
        _touchOffset = self.manager.touchAreaLeftOffset;
    }
    else{
        _touchOffset = 15;
    }
    return _touchOffset;
}

- (CGFloat)textLeftOffset
{
    if (self.manager.topBarConfigValid.boolValue && self.manager.textLeftOffset > 0) {
        _textLeftOffset = self.manager.textLeftOffset;
    }
    else{
        _textLeftOffset = [self touchOffset] + kSearchLabelLeft;
    }
    return _textLeftOffset;
}

@end
