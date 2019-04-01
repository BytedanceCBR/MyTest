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

#import "FHCommutePOIInputBar.h"
#import "FHCommutePOIInfoCell.h"
#import "FHCommuteItemHeader.h"
#import "FHCommutePOIHeaderView.h"
#import "FHCommutePOISearchViewController.h"


#define CELL_ID @"cell_id"
#define LOCATION_HEADER_HEIGHT 76
#define MAX_AROUND_BUILD_COUNT 5

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
        
        __weak typeof(self)wself = self;
        self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
            wself.keywordRequest.page++;
            [wself.searchAPI AMapPOIKeywordsSearch:wself.keywordRequest];
        }];
        [self.refreshFooter setUpNoMoreDataText:@"没有更多信息了"];
        self.tableView.mj_footer = self.refreshFooter;
        self.tableView.mj_footer.hidden = YES;
        
        _searchAPI = [[AMapSearchAPI alloc] init];
        _searchAPI.delegate = self;
        //
        if ([FHEnvContext isSameLocCityToUserSelect]) {
            //定位地和选择地是同一城市才选择
            _currentReGeocode =  [FHLocManager sharedInstance].currentReGeocode;
            if (_currentReGeocode) {
                self.locationHeaderView.location = _currentReGeocode.AOIName;
                tableView.tableHeaderView = _locationHeaderView;
            }else{
                [self reGeoSearch];
            }
            
            [self nearBySearch:YES];
        }else {
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusNotDetermined) {
                self.locationHeaderView.location = @"无法获取当前位置";
                self.locationHeaderView.showRefresh = YES;
                tableView.tableHeaderView = _locationHeaderView;
            }
            [self nearBySearch:NO];
        }
        
        
    }
    return self;
    
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

-(void)reGeoSearch
{
    CLLocation *location = [FHLocManager sharedInstance].currentLocaton;
    if (location) {
        AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
        AMapGeoPoint *geo = [[AMapGeoPoint alloc] init];
        geo.latitude = location.coordinate.latitude;
        geo.longitude = location.coordinate.longitude;
        request.location = geo;
        [_searchAPI AMapReGoecodeSearch:request];
    }else{
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
            }else{
                SHOW_TOAST(@"定位失败");
            }
        }];
    }
}

-(void)nearBySearch:(BOOL)sameCity
{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.types = @"120000|120100|120200|120201|120202|120203";
    
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
        request.radius = 1000;
    }else{
        request.city = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
    }
    
    self.aroundRequest = request;
    [_searchAPI AMapPOIAroundSearch:request];
    
}

-(void)poiSearch:(NSString *)keyword
{
    if ([self.keywordRequest.keywords isEqualToString:keyword]) {
        return;
    }
    
    NSString *cityName = [FHEnvContext getCurrentUserDeaultCityNameFromLocal ];
    if (![cityName hasSuffix:@"市"]) {
        cityName = [cityName stringByAppendingString:@"市"];
    }
    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.keywords = keyword;
    request.city = cityName;
    request.cityLimit = YES;
    self.keywordRequest = request;
    
    [_searchAPI AMapPOIKeywordsSearch:request];
}

-(void)poiSearchMore
{
    self.keywordRequest.page++;
    [_searchAPI AMapPOIKeywordsSearch:self.keywordRequest];
}

#pragma mark - search delegate
/**
 * @brief 当请求发生错误时，会调用代理的此方法.
 * @param request 发生错误的请求.
 * @param error   返回的错误.
 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"[POI] request is: %@ error is: %@",request,error);
}

/**
 * @brief POI查询回调函数
 * @param request  发起的请求，具体字段参考 AMapPOISearchBaseRequest 及其子类。
 * @param response 响应结果，具体字段参考 AMapPOISearchResponse 。
 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (request == self.keywordRequest) {
        
        if (response.count == 0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [self.tableView.mj_footer endRefreshing];
        }
        
        if (request.page == 1) {
            [self.searchPois removeAllObjects];
            if (response.count > 0) {
                [self.tableView.mj_footer resetNoMoreData];
            }
        }
        
        if (request.page == 1 && response.count == 0) {
            self.tableView.mj_footer.hidden = YES;
        }else{
            self.tableView.mj_footer.hidden = NO;
        }
        
        [self.searchPois addObjectsFromArray:response.pois];
        [self.tableView reloadData];
        if (self.searchPois.count > 0) {
            self.tableView.tableHeaderView = self.defaultHeader;
        }else{
            self.tableView.tableHeaderView = _locationHeaderView;
        }
        
    }else if (request == self.aroundRequest){
        
//        if (response.count > MAX_AROUND_BUILD_COUNT) {
//            self.aroundPois = [response.pois subarrayWithRange:NSMakeRange(0, MAX_AROUND_BUILD_COUNT)];
//        }else{
            self.aroundPois = response.pois;
//        }
        [self.tableView reloadData];
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
        AMapPOI *poi = nil;
        if (response.regeocode.aois.count > 0) {
           poi = [response.regeocode.aois firstObject];
        }else if (response.regeocode.pois.count > 0){
           poi = [response.regeocode.pois firstObject];
        }
        NSString *name = nil;
        
        if (poi) {
            name = poi.name;
        }else{
            name = response.regeocode.formattedAddress;
        }
        self.locationHeaderView.location = name;
        _tableView.tableHeaderView = _locationHeaderView;
        self.locationHeaderView.loading = NO;
    }
}

/**
 * @brief 附近搜索回调
 * @param request  发起的请求，具体字段参考 AMapNearbySearchRequest 。
 * @param response 响应结果，具体字段参考 AMapNearbySearchResponse 。
 */
- (void)onNearbySearchDone:(AMapNearbySearchRequest *)request response:(AMapNearbySearchResponse *)response
{
    
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
                    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"开启定位服务" message:@"请允许幸福里使用您的位置来为您提供更好的找房服务" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *config = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [[NSURL alloc] initWithString:UIApplicationOpenSettingsURLString];
        if( [[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    
    [alert addAction:cancel];
    [alert addAction:config];
    
    [self.viewController presentViewController:alert animated:YES completion:nil];
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
    return 10;//CGFLOAT_MIN;
    
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
    if (scrollView.isDragging) {
        [self.inputBar resignFirstResponder];
    }
}


#pragma mark - input bar delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    self.lastSugDate = [NSDate date];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.inputBar showClear:NO];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.viewController.sugDelegate) {
        NSString *content =  [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *result  =  [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (result.length > 0) {
            [self poiSearch:result];
        }
    }
    
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
        [self poiSearch:result];
    }else{
        //reset to history mode
        self.keywordRequest = nil;
        [self.tableView reloadData];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
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
    [self.tableView setContentOffset:CGPointZero animated:YES];
    [self.tableView reloadData];
    self.tableView.tableHeaderView = _locationHeaderView;
}


@end
