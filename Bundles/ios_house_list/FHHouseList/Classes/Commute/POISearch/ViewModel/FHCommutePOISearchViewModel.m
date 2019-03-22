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

#import "FHCommutePOIInputBar.h"
#import "FHCommutePOIInfoCell.h"
#import "FHCommuteItemHeader.h"
#import "FHCommutePOIHeaderView.h"
#import "FHCommutePOISearchViewController.h"


#define CELL_ID @"cell_id"
#define LOCATION_HEADER_HEIGHT 76

@interface FHCommutePOISearchViewModel ()<UITableViewDelegate,UITableViewDataSource,AMapSearchDelegate>

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

@end

@implementation FHCommutePOISearchViewModel

-(instancetype)initWithTableView:(UITableView *)tableView inputBar:(FHCommutePOIInputBar *)inputBar
{
    self = [super init];
    if (self) {
        
        _searchPois = [NSMutableArray new];
        
        _tableView = tableView;
        _inputBar = inputBar;
        
        
        [tableView registerClass:[FHCommutePOIInfoCell class] forCellReuseIdentifier:CELL_ID];
        tableView.delegate = self;
        tableView.dataSource = self;
        
        _searchAPI = [[AMapSearchAPI alloc] init];
        
        if ([FHLocManager sharedInstance].isSameToLocCity) {
            //定位地和选择地是同一城市才选择
            _currentReGeocode =  [FHLocManager sharedInstance].currentReGeocode;
            if (_currentReGeocode) {
                self.locationHeaderView.location = _currentReGeocode.POIName;
                tableView.tableHeaderView = _locationHeaderView;
            }else{
                [self reGeoSearch];
            }
            
            [self nearBySearch];
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
    }
}

-(void)nearBySearch
{
    CLLocation *location = [FHLocManager sharedInstance].currentLocaton;
    if (location) {
        AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
        request.types = @"120000|120100|120200|120201|120202|120203";
        AMapGeoPoint *geo = [[AMapGeoPoint alloc] init];
        geo.latitude = location.coordinate.latitude;
        geo.longitude = location.coordinate.longitude;
        request.location = geo;
        request.city = _currentReGeocode.city;
        self.aroundRequest = request;
        [_searchAPI AMapPOIAroundSearch:request];
    }
}

-(void)poiSearch:(NSString *)keyword
{
    NSString *cityName = [FHEnvContext getCurrentUserDeaultCityNameFromLocal ];
    if ([cityName hasSuffix:@"市"]) {
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
    
}

/**
 * @brief POI查询回调函数
 * @param request  发起的请求，具体字段参考 AMapPOISearchBaseRequest 及其子类。
 * @param response 响应结果，具体字段参考 AMapPOISearchResponse 。
 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (request == self.keywordRequest) {
        
        if (request.page == 1) {
            [self.searchPois removeAllObjects];
        }else{
            
        }
        [self.searchPois addObjectsFromArray:response.pois];
        [self.tableView reloadData];
        
        
    }else if (request == self.aroundRequest){
        
        self.aroundPois = response.pois;
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
        AMapPOI *poi = [response.regeocode.pois firstObject];
        if (poi) {
            self.locationHeaderView.location = poi.name;
            _tableView.tableHeaderView = _locationHeaderView;
        }
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
    }
    return _locationHeaderView;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _aroundPois.count;
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
    
    [cell updateName:poi.name address:poi.address];
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 59;
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
    return nil;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
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
//        [self.viewController.sugDelegate searchByInput:content inController:self.viewController];
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
        //        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestSug:) object:content];
        //        if (content.length == 1 || [[NSDate date] timeIntervalSinceDate:_lastSugDate] > 1) {
        [self poiSearch:result];
        //        }else{
        //            [self performSelector:@selector(requestSug:) withObject:content afterDelay:1];
        //        }
    }else{
        //reset to history mode
//        self.inputMode = FHSugInputModeHistory;
        [self.tableView reloadData];
    }
    
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

-(void)inputBarCancel
{
//    if ([self.viewController.sugDelegate respondsToSelector:@selector(sugCancelled:)]) {
//        [self.viewController.sugDelegate sugCancelled:self.viewController];
//    }else{
//        [self.viewController.navigationController popViewControllerAnimated:YES];
//    }
}
-(void)textFieldClear
{
//    self.associatedCount = 0;
//    [self.sugTask cancel];
//    self.inputMode = FHSugInputModeHistory;
//    [self requestHistory];
    [self.tableView reloadData];
}


@end
