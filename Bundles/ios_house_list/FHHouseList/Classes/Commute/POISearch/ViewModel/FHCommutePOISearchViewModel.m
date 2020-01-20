//
//  FHCommutePOISearchViewModel.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/22.
//

#import "FHCommutePOISearchViewModel.h"
#import <FHHouseBase/FHCommonDefines.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <FHHouseBase/FHLocManager.h>
#import <FHHouseBase/FHEnvContext.h>
#import <MJRefresh/MJRefresh.h>
#import <FHCommonUI/FHRefreshCustomFooter.h>
#import <FHCommonUI/ToastManager.h>
#import <FHHouseBase/FHEnvContext.h>
#import <TTReachability/TTReachability.h>
#import <FHHouseBase/NSString+Emoji.h>
#import <TTUIWidget/TTThemedAlertController.h>

#import "FHCommutePOIInputBar.h"
#import "FHCommutePOIInfoCell.h"
#import "FHCommuteItemHeader.h"
#import "FHCommutePOIHeaderView.h"
#import "FHCommutePOISearchViewController.h"


#define CELL_ID @"cell_id"
#define LOCATION_HEADER_HEIGHT 76
#define MAX_AROUND_BUILD_COUNT 8

@interface FHCommutePOISearchViewModel ()<UITableViewDelegate,UITableViewDataSource,AMapSearchDelegate,FHCommutePOIInputBarDelegate>

@property(nonatomic , strong) NSArray *aroundPois;
@property(nonatomic , strong) NSMutableArray *searchPois;
@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , strong) FHCommutePOIInputBar *inputBar;
@property(nonatomic , strong) FHCommutePOIHeaderView *locationHeaderView;
@property(nonatomic , strong) FHCommuteItemHeader *itemHeader;
@property(nonatomic , strong) AMapSearchAPI *searchAPI;
@property(nonatomic , strong) AMapLocationReGeocode * currentReGeocode;
@property(nonatomic , strong) AMapPOIKeywordsSearchRequest *keywordRequest;
//@property(nonatomic , strong) AMapPOIKeywordsSearchRequest *arroundPOIRequest;//当没有定位时获取所在城市的poi数据
@property(nonatomic , strong) AMapPOIAroundSearchRequest *aroundRequest;
@property(nonatomic , strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic , strong) UIView *defaultHeader;

@end

@implementation FHCommutePOISearchViewModel

-(instancetype)initWithTableView:(UITableView *)tableView inputBar:(FHCommutePOIInputBar *)inputBar
{
    self = [super init];
    if (self) {
        
        _searchPois = [NSMutableArray new];
        
        _tableView = tableView;
        _inputBar = inputBar;
        _inputBar.delegate = self;
        
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.1)];
        _tableView.tableHeaderView = header;
        _defaultHeader = header;
        
        [tableView registerClass:[FHCommutePOIInfoCell class] forCellReuseIdentifier:CELL_ID];
        
        tableView.delegate = self;
        tableView.dataSource = self;
  
        //TODO: android 没有实现该功能，先关闭翻页
//        __weak typeof(self)wself = self;
//        self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
//            wself.keywordRequest.page++;
//            [wself.searchAPI AMapPOIKeywordsSearch:wself.keywordRequest];
//        }];
//        [self.refreshFooter setUpNoMoreDataText:@"没有更多信息了"];
//        self.tableView.mj_footer = self.refreshFooter;
//        self.tableView.mj_footer.hidden = YES;
        
        _searchAPI = [[AMapSearchAPI alloc] init];
        _searchAPI.delegate = self;
        //
        NSString *selectCityName = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
        _currentReGeocode =  [FHLocManager sharedInstance].currentReGeocode;
        
        if ([FHEnvContext isSameLocCityToUserSelect] && _currentReGeocode.city &&([_currentReGeocode.city hasPrefix:selectCityName] || [selectCityName hasPrefix:_currentReGeocode.city])) {
            //定位地和选择地是同一城市才选择
            self.locationHeaderView.location = _currentReGeocode.AOIName;
            tableView.tableHeaderView = _locationHeaderView;

            [self nearBySearch:YES];
        }else {
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusNotDetermined || !_currentReGeocode) {
                self.locationHeaderView.location = @"无法获取当前位置";
                tableView.tableHeaderView = _locationHeaderView;
            }else{
                self.locationHeaderView.showNotInCityTip = YES;
                tableView.tableHeaderView = self.locationHeaderView;
            }
            [self nearBySearch:NO];
        }
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:TTReachabilityChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];        
    }
    return self;
    
}

-(void)dealloc
{
    [_searchAPI cancelAllRequests];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark - search

/*
 120000    商务住宅    商务住宅相关    商务住宅相关
 120100    商务住宅    产业园区    产业园区
 120200    商务住宅    楼宇    楼宇相关
 120201    商务住宅    楼宇    商务写字楼
 120202    商务住宅    楼宇    工业大厦建筑物
 120203    商务住宅    楼宇    商住两用楼宇
 */

-(NSString *)searchTypes
{
    return @"060000|060100|060101|060300|060301|060302|060303|060304|090100|090101|120000|120100|120200|120201|120202|120203|141200|141201|150300|150500|150600|170100";
}

-(void)reGeoSearch
{
    self.locationHeaderView.loading = YES;
    __weak typeof(self) wself = self;
    [[FHLocManager sharedInstance] requestCurrentLocation:NO completion:^(AMapLocationReGeocode * _Nonnull reGeocode) {
        if (!wself) {
            return ;
        }
        if (reGeocode) {
            wself.locationHeaderView.location = reGeocode.AOIName;
            wself.currentReGeocode = reGeocode;
            wself.locationHeaderView.loading = NO;
            
            NSString *chooseCity = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
            if ([reGeocode.city hasPrefix:chooseCity] || [chooseCity hasPrefix:reGeocode.city]) {
                wself.locationHeaderView.showNotInCityTip = NO;
                wself.tableView.tableHeaderView = wself.locationHeaderView;
                [wself nearBySearch:YES];
            }else{
                //不是同一城市
                wself.locationHeaderView.showNotInCityTip = YES;
                wself.tableView.tableHeaderView = wself.locationHeaderView;
                [wself nearBySearch:NO];
            }
        }else{
//            SHOW_TOAST(@"定位失败");
            [wself resetLocationFail];
        }
    }];

}

-(void)nearBySearch:(BOOL)sameCity
{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.types = [self searchTypes];
    
    CLLocation *location = nil;
    if (sameCity) {
        location = [FHLocManager sharedInstance].currentLocaton;
    }
    
    if (location) {
        AMapGeoPoint *geo = [[AMapGeoPoint alloc] init];
        geo.latitude = location.coordinate.latitude;
        geo.longitude = location.coordinate.longitude;
        request.location = geo;
        request.city = _currentReGeocode.city;
//        request.radius = 3000;
        self.aroundRequest = request;
        [_searchAPI AMapPOIAroundSearch:request];
        
//    }else{
//        NSString *cityName = [FHEnvContext getCurrentUserDeaultCityNameFromLocal ];
//        if (![cityName hasSuffix:@"市"]) {
//            cityName = [cityName stringByAppendingString:@"市"];
//        }
//        AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
//        request.keywords = nil;
//        request.sortrule = 1;
//        request.city = cityName;
//        request.cityLimit = YES;
//        request.types = [self searchTypes];
//        request.offset = 20;//每页20个
//        self.arroundPOIRequest = request;
//
//        [_searchAPI AMapPOIKeywordsSearch:request];
    }
}

-(void)tryReload
{
    if (![TTReachability isNetworkConnected]) {
        return;
    }
    
    self.keywordRequest.page = 1;
//    self.keywordRequest.keywords = self.inputBar.text;
    if (self.inputBar.text.length > 0) {
        [self poiSearch:self.inputBar.text force:YES];
    }else{
        [self.searchPois removeAllObjects];
        [self.tableView reloadData];
        [self.viewController.emptyView hideEmptyView];
    }
    
}

-(void)poiSearch:(NSString *)keyword force:(BOOL)force
{
    if (![TTReachability isNetworkConnected]) {
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        return;
    }
    
    keyword = [keyword stringByRemoveEmoji]; //输入表情 高德地图可能会crash
    
    if (!force && [self.keywordRequest.keywords isEqualToString:keyword]) {
        return;
    }
    
    NSString *cityName = [FHEnvContext getCurrentUserDeaultCityNameFromLocal ];
    if (![cityName hasSuffix:@"市"]) {
        cityName = [cityName stringByAppendingString:@"市"];
    }
    
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords = keyword;
    request.sortrule = 1;
    request.city = cityName;
    request.cityLimit = YES;
    request.types = [self searchTypes];
    request.offset = 20;//每页20个
    self.keywordRequest = request;
    
    [_searchAPI AMapPOIKeywordsSearch:request];
}

-(void)poiSearchMore
{
    self.keywordRequest.page++;
    [_searchAPI AMapPOIKeywordsSearch:self.keywordRequest];
}

-(void)resetLocationFail
{
    if (self.tableView.tableHeaderView != self.defaultHeader ) {
        self.locationHeaderView.location = @"定位失败";
        self.locationHeaderView.loading = NO;
    }
}

#pragma mark - search delegate
/**
 * @brief 当请求发生错误时，会调用代理的此方法.
 * @param request 发生错误的请求.
 * @param error   返回的错误.
 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
//    NSLog(@"[POI] request is: %@ error is: %@",request,error);
    if ([request isKindOfClass:[AMapReGeocodeSearchRequest class]]) {
        [self resetLocationFail];
    }
}

/**
 * @brief POI查询回调函数
 * @param request  发起的请求，具体字段参考 AMapPOISearchBaseRequest 及其子类。
 * @param response 响应结果，具体字段参考 AMapPOISearchResponse 。
 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (request == self.keywordRequest) {
        
//        if (response.count == 0) {
//            [self.tableView.mj_footer endRefreshingWithNoMoreData];
//        }else{
//            [self.tableView.mj_footer endRefreshing];
//        }
        
        if (request.page == 1) {
            [self.searchPois removeAllObjects];
            if (response.count > 0) {
                [self.tableView.mj_footer resetNoMoreData];
            }
        }
        
//        if (request.page == 1 && response.count == 0) {
//            self.tableView.mj_footer.hidden = YES;
//        }else{
//            self.tableView.mj_footer.hidden = NO;
//        }
        
        [self.searchPois addObjectsFromArray:response.pois];
        
//        if (self.searchPois.count == response.count) {
//            //没有数据了
//            [self.tableView.mj_footer endRefreshingWithNoMoreData];
//        }
        
        [self.tableView reloadData];
        if (self.searchPois.count > 0) {
            self.tableView.tableHeaderView = self.defaultHeader;
            if (request.page == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    @try {
                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    } @catch (NSException *exception) {
                        
                    } @finally {
                        
                    }

                });
            }
        }else{
            self.tableView.tableHeaderView = self.locationHeaderView;
        }
        
        if (self.keywordRequest.keywords.length > 0 && self.searchPois.count == 0) {
            //无结果
            [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoDataForCondition];
        }else{
            [self.viewController.emptyView hideEmptyView];
        }
        
    }else if (request == self.aroundRequest){
        
        [self handleAroundPois:response.pois];
        [self.tableView reloadData];
        self.aroundRequest = nil;        
    }
}

/**
 * @brief 逆地理编码查询回调函数
 * @param request  发起的请求，具体字段参考 AMapReGeocodeSearchRequest 。
 * @param response 响应结果，具体字段参考 AMapReGeocodeSearchResponse 。
 */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode) {
        
        AMapAddressComponent *addr =  response.regeocode.addressComponent;
        NSString *chooseCity = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
        BOOL sameCity = NO;
        if (chooseCity.length > 0 && ( [addr.city hasPrefix:chooseCity] || [chooseCity hasPrefix:addr.city])) {
            sameCity = YES;
        }
        
        if (!sameCity) {
            self.locationHeaderView.showNotInCityTip = YES;
            self.tableView.tableHeaderView = self.locationHeaderView;
            return;
        }
        
        AMapPOI *poi = nil;
        if (response.regeocode.aois.count > 0) {
           poi = [response.regeocode.aois firstObject];
        }else if (response.regeocode.pois.count > 0){
           poi = [response.regeocode.pois firstObject];
        }
        NSString *name = nil;
        
        if (poi) {
            name = poi.name;
        }else if (addr.building.length > 0){
            name = addr.building;
        }else{
            name = response.regeocode.formattedAddress;
        }
        self.locationHeaderView.location = name;
        _tableView.tableHeaderView = _locationHeaderView;
        self.locationHeaderView.loading = NO;
    }
}

-(void)handleAroundPois:(NSArray<AMapPOI *> *)pois
{
    NSMutableArray *hpois = [NSMutableArray new];
    if (!self.currentReGeocode) {
        [hpois addObjectsFromArray:pois];
    }else{
        for (AMapAOI *poi in pois) {
            if (![poi.name isEqualToString:self.currentReGeocode.AOIName]) {
                [hpois addObject:poi];
            }
        }
    }
    
    if (hpois.count > MAX_AROUND_BUILD_COUNT) {
        self.aroundPois = [hpois subarrayWithRange:NSMakeRange(0, MAX_AROUND_BUILD_COUNT)];
    }else{
        self.aroundPois = hpois;
    }
}

#pragma mark - ui

-(FHCommuteItemHeader *)itemHeader

{
    if (!_itemHeader) {
        _itemHeader = [[FHCommuteItemHeader alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        _itemHeader.tip = @"附近职场";
    }
    return _itemHeader;
}

-(FHCommutePOIHeaderView *)locationHeaderView;
{
    if (!_locationHeaderView) {
        _locationHeaderView = [[FHCommutePOIHeaderView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, LOCATION_HEADER_HEIGHT)];
        __weak typeof(self) wself = self;
        _locationHeaderView.refreshBlock = ^{
            [wself tryRequestAuthority];
        };
        
        _locationHeaderView.locationTapBlock = ^{
            [wself tryUseLocation];
        };
    }
    return _locationHeaderView;
    
}

-(void)tryRequestAuthority
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status != kCLAuthorizationStatusDenied ){
        [self reGeoSearch];
        self.locationHeaderView.loading = YES;
        return;
    }
    TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:@"您还没有开启定位权限" message:@"请前往系统设置开启，以便我们更好地为您推荐房源及丰富信息推荐维度" preferredType:TTThemedAlertControllerTypeAlert];
      [alertVC addActionWithGrayTitle:@"我知道了" actionType:TTThemedAlertActionTypeCancel actionBlock:^{

      }];
      
      [alertVC addActionWithTitle:@"前往设置" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
          NSURL *jumpUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
          
          if ([[UIApplication sharedApplication] canOpenURL:jumpUrl]) {
              [[UIApplication sharedApplication] openURL:jumpUrl];
          }
      }];
    
    [alertVC showFrom:self.viewController.navigationController animated:YES];
    
}

-(void)tryUseLocation
{
    
    if (self.currentReGeocode && [self.viewController.sugDelegate respondsToSelector:@selector(userChooseLocation:geoCode:inViewController:)]) {
        CLLocation *location = [FHLocManager sharedInstance].currentLocaton;
        [self.viewController.sugDelegate userChooseLocation:location geoCode:self.currentReGeocode inViewController:self.viewController];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (_searchPois.count == 0) {
            return _aroundPois.count;
        }
        return 0;
    }
    return _searchPois.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHCommutePOIInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    
    AMapPOI *poi = nil;
    if (indexPath.section == 0) {
        poi = _aroundPois[indexPath.row];
    }else{
        poi = _searchPois[indexPath.row];
    }
    
    [cell updateName:poi.name address:poi.address inputKey:_keywordRequest.keywords];
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AMapPOI *poi = nil;
    if (indexPath.section == 0) {
        poi = _aroundPois[indexPath.row];
    }else{
        poi = _searchPois[indexPath.row];
    }
    CGFloat height = 59;
    if (poi.address.length == 0) {
        //没有地址
        height = 40;
    }
    
    if (indexPath.section == 1 && indexPath.row == 0 && _aroundPois.count == 0 &&  tableView.tableHeaderView != _locationHeaderView) {
        return height - 6;//第一个距离输入框
    }
    
    return height;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 && _searchPois.count == 0 && _aroundPois.count > 0) {
        return 40;
    }
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 && _searchPois.count == 0 && _aroundPois.count > 0) {
        return self.itemHeader;
    }
    return [[UIView alloc]init];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AMapPOI *poi = nil;
    if (indexPath.section == 0) {
        poi = _aroundPois[indexPath.row];
    }else{
        poi = _searchPois[indexPath.row];
    }
    
    if (poi && [self.viewController.sugDelegate respondsToSelector:@selector(userChoosePoi:inViewController:)]) {
        [self.viewController.sugDelegate userChoosePoi:poi inViewController:self.viewController];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.isDragging && scrollView.isTracking) {
        [self.inputBar resignFirstResponder];
    }
}


#pragma mark - input bar delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    BOOL show = textField.text.length > 0;
    [self.inputBar showClear:show];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.viewController.sugDelegate) {
        NSString *content =  [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *result  =  [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (result.length > 0) {
            [self poiSearch:result force:NO];
        }
    }
    [textField resignFirstResponder];
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *content = [[NSMutableString alloc] initWithString:textField.text];
    [content replaceCharactersInRange:range withString:string];
    if (content.length > MAX_INPUT) {
        return NO;
    }
    
    [self.inputBar showClear:content.length > 0];
    
    NSString *result  =  [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (result.length > 0) {
        [self poiSearch:result force:NO];
    }else{
        //reset to history mode
        [self textFieldClear];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

-(void)textFieldChanged:(NSString *)text
{
    if (text.length > 0 && ![text isEqualToString:self.keywordRequest.keywords]) {
        [self poiSearch:text force:YES];
    }
}

-(void)inputBarCancel
{
    if ([self.viewController.sugDelegate respondsToSelector:@selector(userCanced:)]) {
        [self.viewController.sugDelegate userCanced:self.viewController];
    }else{
        [self.viewController.navigationController popViewControllerAnimated:YES];
    }
}
-(void)textFieldClear
{
    self.keywordRequest = nil;
    self.tableView.mj_footer.hidden = YES;
    [self.searchPois removeAllObjects];
    [self.tableView reloadData];
//    NSString *selectCityName = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
//    if (!self.locationHeaderView.showNotInCityTip &&[FHEnvContext isSameLocCityToUserSelect] && _currentReGeocode &&([_currentReGeocode.city hasPrefix:selectCityName] || [selectCityName hasPrefix:_currentReGeocode.city])) {
    self.tableView.tableHeaderView = _locationHeaderView;
//    }else{
//        self.tableView.tableFooterView = self.defaultHeader;
//    }
    self.tableView.contentOffset = CGPointZero;
    
    if ([TTReachability isNetworkConnected]) {
        [self.viewController.emptyView hideEmptyView];
    }
    
}


#pragma mark - network changed
-(void)connectionChanged:(NSNotification *)notification
{
    TTReachability *reachability = (TTReachability *)notification.object;
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status != NotReachable) {
        //有网络了，重新请求
        if (self.aroundPois.count == 0) {
            NSString *selectCityName = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
            _currentReGeocode =  [FHLocManager sharedInstance].currentReGeocode;
            if ([FHEnvContext isSameLocCityToUserSelect] && _currentReGeocode &&([_currentReGeocode.city hasPrefix:selectCityName] || [selectCityName hasPrefix:_currentReGeocode.city])) {
                [self nearBySearch:YES];
            }            
        }
    }
}

-(void)applicationWillResignActive:(NSNotification *)notification
{
    //当用户下滑到屏幕底部时上滑显示 设置网络等的页面时 tableview手势会断开
    if (self.tableView.contentOffset.y < 0) {
        self.tableView.contentOffset = CGPointZero;
    }
}

@end
