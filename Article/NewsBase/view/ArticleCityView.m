//
//  ArticleCityView.m
//  Article
//
//  Created by Kimimaro on 13-6-6.
//
//

#import "ArticleCityView.h"
#import "TTArticleCategoryManager.h"
#import "ArticleCityManager.h"
#import "SSThemed.h"

#import "NewsUserSettingManager.h"
#import "ExploreExtenstionDataHelper.h"
#import "TTLocationManager.h"
#import "TTThemedAlertController.h"
#import "MBProgressHUD.h"
#import "ArticleListNotifyBarView.h"
#import "TTLocationManager.h"
#import "TTIndicatorView.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"


#define LocationCity NSLocalizedString(@"您当前可能在", nil)
#define NotFindCityTip NSLocalizedString(@"没有找到您的位置，点击重试", nil)


typedef NS_ENUM(NSInteger, LoadCityState) {
    LoadCityStateNoCity,
    LoadCityStateLoading,
    LoadCityStateFailed,
    LoadCityStateSuccess,
    LoadCityStateUnsupported
};


@interface ArticleCityListCellView : SSThemedTableViewCell
@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UIImageView *backgroundImageView;
@end


@interface ArticleCityView () <UITableViewDataSource, UITableViewDelegate, ArticleCityManagerDelegate> {
    BOOL _hasApppear;
    
    LoadCityState _loadState;
}
@property (nonatomic, retain) UITableView *listView;
@property (nonatomic, retain) NSArray *groupedCities;
@property (nonatomic, retain) NSDictionary *currentCityDict;
@property(nonatomic, retain)ArticleListNotifyBarView * notifyBarView;

@end


@implementation ArticleCityView

- (void)dealloc
{
    [ArticleCityManager sharedManager].delegate = nil;
    
    self.listView = nil;
    self.groupedCities = nil;
    self.currentCityDict = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _loadState = LoadCityStateNoCity;
        
        [self loadView];
        [self reloadThemeUI];
        
    }
    return self;
}


- (void)themeChanged:(NSNotification *)notification
{
    [self updateThemes];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self trySSLayoutSubviews];
}

- (void)ssLayoutSubviews
{
    [super ssLayoutSubviews];
    [self updateFrames];
}

#pragma mark - ViewLifecycle

- (void)loadView
{
    self.listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) style:UITableViewStylePlain];
    _listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _listView.backgroundColor = [UIColor clearColor];
    _listView.delegate = self;
    _listView.dataSource = self;
    _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0, *)) {
        _listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self addSubview:_listView];
    
    
    self.notifyBarView = [[ArticleListNotifyBarView alloc] initWithFrame:CGRectMake(0, 0, self.width, [SSCommonLogic articleNotifyBarHeight])];
    [self addSubview:_notifyBarView];
}

- (void)didAppear
{
    [super didAppear];
    if (!_hasApppear) {
        _hasApppear = YES;
        [self loadData];
    }
    else {
        [_listView reloadData];
    }
}

#pragma mark - private

- (void)updateThemes
{
    // need code
}

- (void)updateFrames
{
    // need code
}

- (void)updateDataSourceForLoadCityState {
    NSString *city = [TTLocationManager sharedManager].city;
    if (isEmptyString(city)) {
        city = [TTLocationManager sharedManager].baiduPlacemarkItem.city;
    }
    if (isEmptyString(city)) {
        city = [TTLocationManager sharedManager].placemarkItem.city;
    }
    if (!isEmptyString(city)) {
        _loadState = LoadCityStateSuccess;
    } else {
        if (_loadState != LoadCityStateLoading) {
            _loadState = LoadCityStateLoading;
        }
    }
    
    NSString *currentCityName = [self loadCityTextForLoadCityStateWithName:city];
    
    if (![currentCityName isEqualToString:NotFindCityTip]) {
        // 判断当前城市是否在已支持的新闻列表中
        __block BOOL supported = NO;
        [_groupedCities enumerateObjectsUsingBlock:^(NSDictionary *cityDict, NSUInteger idx, BOOL *stop) {
            NSArray *cities = [cityDict.allValues objectAtIndex:0];
            [cities enumerateObjectsUsingBlock:^(NSString *cityName, NSUInteger idx2, BOOL *stop2) {
                if ([cityName isEqualToString:currentCityName]) {
                    supported = YES;
                    *stop = YES;
                    *stop2 = YES;
                }
            }];
        }];
        
        if (!supported) {
            _loadState = LoadCityStateUnsupported;
            wrapperTrackEvent(@"category", @"current_city_hidden");
        }
        
        // 更新当前城市dict
        currentCityName = [self loadCityTextForLoadCityStateWithName:city];

    }
    if (_currentCityDict != nil && _groupedCities != nil && [_groupedCities containsObject:_currentCityDict]) {
        NSMutableArray * tmpArray = [NSMutableArray arrayWithArray:_groupedCities];
        [tmpArray removeObject:_currentCityDict];
        self.groupedCities = [NSArray arrayWithArray:tmpArray];
    }

    if (!isEmptyString(currentCityName)) {
        self.currentCityDict = @{LocationCity : @[currentCityName]};
    }
    else {
        self.currentCityDict = nil;
    }
}

- (NSString *)loadCityTextForLoadCityStateWithName:(NSString *)cityName {
    NSString *ret = @"";
    switch (_loadState) {
        case LoadCityStateLoading:
            break;
        case LoadCityStateNoCity:
        case LoadCityStateFailed:
        {
            ret = NotFindCityTip;
        }
            break;
        case LoadCityStateSuccess:
        {
            // 简单处理了xx市的名字
            NSString *fullCity = cityName;
            NSString *cityUnit = NSLocalizedString(@"市", nil);
            if ([fullCity hasSuffix:cityUnit]) {
                fullCity = [fullCity substringToIndex:[fullCity length] - 1];
            }
            ret = fullCity;
        }
            break;
        default:
            break;
    }
    return ret;
}

- (void)reloadCity
{
    if (_loadState != LoadCityStateLoading) {
        _loadState = LoadCityStateLoading;
        [self prepareDataSource];
        [_listView reloadData];
    }
}

#pragma mark - load data

- (void)prepareDataSource
{
    [self updateDataSourceForLoadCityState];
    
    NSMutableArray *mutGroupedCities = [NSMutableArray arrayWithCapacity:27];
    if (_currentCityDict) {
        [mutGroupedCities addObject:_currentCityDict];
    }
    [mutGroupedCities addObjectsFromArray:_groupedCities];
    self.groupedCities = [mutGroupedCities copy];
}

- (void)loadData
{
    [ArticleCityManager sharedManager].delegate = self;
    self.groupedCities = [[ArticleCityManager sharedManager] groupedCities];
    [self prepareDataSource];
    [_listView reloadData];
}

- (void)loadMore
{
    // 城市列表不需要load more
}

#pragma mark - ArticleCityManagerDelegate

- (void)cityManager:(ArticleCityManager *)manager updateFinishedResult:(NSDictionary *)result error:(NSError *)error
{
    if (!error) {
        self.groupedCities = [[ArticleCityManager sharedManager] groupedCities];
        [self prepareDataSource];
        [_listView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_groupedCities count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *cityDict = [_groupedCities objectAtIndex:section];
    NSArray *array = [cityDict.allValues objectAtIndex:0];
    NSInteger ret = [array count];
    return ret;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 26;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *cityDict = [_groupedCities objectAtIndex:section];
    
    SSThemedView * sectionView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 26)];
    sectionView.backgroundColorThemeKey = kColorBackground1;
       
    SSThemedLabel * titleLb = [[SSThemedLabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 26)];
    titleLb.backgroundColor = [UIColor clearColor];
    titleLb.textColorThemeKey = kColorText1;
    [sectionView addSubview:titleLb];
    
    titleLb.text = cityDict.allKeys.firstObject;
    
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cityCellIdentifier = @"city_cell";
    static NSString *safeCellIdentifier = @"safe_cell";
    
    NSDictionary *cityDict = [_groupedCities objectAtIndex:indexPath.section];
    NSArray *cities = [cityDict.allValues objectAtIndex:0];
    if (indexPath.row < [cities count]) {
        ArticleCityListCellView *cell = [tableView dequeueReusableCellWithIdentifier:cityCellIdentifier];
        if (!cell) {
            cell = [[ArticleCityListCellView alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cityCellIdentifier];
        }
        
        cell.cityName = [cities objectAtIndex:indexPath.row];
        return cell;
    }
    else {

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:safeCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] init];
        }
 
        return cell;
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *mutAlphabet = [NSMutableArray arrayWithCapacity:26];
    [_groupedCities enumerateObjectsUsingBlock:^(NSDictionary *cityDict, NSUInteger idx, BOOL *stop) {
        NSString *sectionIndex = [cityDict.allKeys objectAtIndex:0];
        if ([sectionIndex length] > 1) {
            // 当前城市 
            sectionIndex = @"#";
        }
        [mutAlphabet addObject:sectionIndex];
    }];
    return [mutAlphabet copy];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cityName = @"";
    NSDictionary *cityDict = [_groupedCities objectAtIndex:indexPath.section];
    cityName = [[cityDict.allValues objectAtIndex:0] objectAtIndex:indexPath.row];
    if (!isEmptyString(cityName)) {
        if ([cityName isEqualToString:NotFindCityTip]) {
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
                TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"定位服务未开启", nil) message:NSLocalizedString(@"请去系统设置-隐私-定位服务内开启爱看访问权限", nil) preferredType:TTThemedAlertControllerTypeAlert];
                [alertController addActionWithTitle:NSLocalizedString(@"知道了", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
                [alertController showFrom:self.viewController animated:YES];
                
                wrapperTrackEvent(@"category", @"location_service_tips");
            }
            else {
                _loadState = LoadCityStateLoading;
                
                __weak typeof(self) wself = self;
                [[TTLocationManager sharedManager] regeocodeWithCompletionHandlerAfterAuthorization:^(NSArray *placemarks) {
                    
                    __strong typeof(self) sself = wself;
                    if (placemarks.count > 0) {
                        sself->_loadState = LoadCityStateSuccess;
                    } else {
                        sself->_loadState = LoadCityStateFailed;
                    }
                    [wself prepareDataSource];
                    [wself.listView reloadData];
                }];
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"定位中...", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
                wrapperTrackEvent(@"category", @"retry_current_city");
            }
        }
        else {
            
            if (cityDict == _currentCityDict) {
                wrapperTrackEvent(@"category", @"click_current_city");
            }
            else {
                wrapperTrackEvent(@"category", @"click_other_city");
            }
            [MBProgressHUD showHUDAddedTo:self animated:YES];
            self.viewController.view.userInteractionEnabled = NO;
            
            __weak typeof(self) wself = self;
            [[TTLocationManager sharedManager] uploadUserCityWithName:cityName completionHandler:^(NSError *error) {
                wself.viewController.view.userInteractionEnabled = YES;
                if (!error) {
                    [MBProgressHUD hideHUDForView:wself animated:NO];
                    TTArticleCategoryManager *manager = [TTArticleCategoryManager sharedManager];
                    if (![cityName isEqualToString:manager.localCategory.name]) {
                        manager.localCategory.name = cityName;
                        //本地频道用户切换了城市，把该城市对应的concernID清空
                        manager.localCategory.concernID = nil;
                        [manager save];
                        [NewsUserSettingManager setNeedLoadDataFromStart:YES];
                        //                wrapperTrackEvent(@"category_nav", @"local_news_setting_other");
                        [TTArticleCategoryManager setUserSelectedLocalCity];
                        [ExploreExtenstionDataHelper saveSharedUserSelectCity:[cityName copy]];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kArticleLocalCategoryConcernIDHasChangeNotification object:nil];
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kArticleCityDidChangedNotification object:self];
                    
                    if (![TTDeviceHelper isPadDevice]) {
                        UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor: self];
                        [nav popViewControllerAnimated:YES];
                    }
                } else {
                    [MBProgressHUD hideHUDForView:self animated:YES];
                    [self showNotifyBarMsg:NSLocalizedString(@"网络不给力，请稍后重试", nil)];
                }
            }];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)showNotifyBarMsg:(NSString *)msg  {
    if (!isEmptyString(msg)) {
        [_notifyBarView showMessage:msg actionButtonTitle:nil delayHide:YES duration:3 bgButtonClickAction:NULL actionButtonClickBlock:NULL didHideBlock:NULL];
    }
}
@end


#pragma mark - ArticleCityListCellView
@implementation ArticleCityListCellView

- (void)dealloc
{
    self.cityName = nil;
    self.nameLabel = nil;
    self.backgroundImageView = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImage *backgroundImage = [[UIImage themedImageNamed:@"city_alternation.png"] stretchableImageWithLeftCapWidth:0.25 topCapHeight:0.25];
        self.backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        _backgroundImageView.backgroundColor = [UIColor orangeColor];
        [self addSubview:_backgroundImageView];
        
        self.nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:18.f];
        [self addSubview:_nameLabel];
        
        [self themeChanged:nil];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    UIImage *backgroundImage = [[UIImage themedImageNamed:@"city_alternation.png"] stretchableImageWithLeftCapWidth:0.25 topCapHeight:0.25];
    _backgroundImageView.image = backgroundImage;
    
    _nameLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
}

- (void)setCityName:(NSString *)cityName
{
    if (![_cityName isEqualToString:cityName]) {
        _cityName = [cityName copy];
        
        _nameLabel.text = _cityName;
        [_nameLabel sizeToFit];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _backgroundImageView.frame = CGRectMake(0, self.height - 1.f, self.width - 41, 1.f);
    _nameLabel.origin = CGPointMake(29, (self.height - _nameLabel.height)/2);
}

@end
