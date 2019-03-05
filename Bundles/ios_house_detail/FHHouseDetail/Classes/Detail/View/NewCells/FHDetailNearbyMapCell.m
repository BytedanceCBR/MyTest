//
//  FHDetailNearbyMapCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/12.
//

#import "FHDetailNearbyMapCell.h"

#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

#import <HMSegmentedControl.h>
#import <FHEnvContext.h>
#import <ToastManager.h>

#import "FHMyMAAnnotation.h"
#import "FHDetailNearbyMapItemCell.h"
#import "FHDetailNewModel.h"
#import "FHDetailHeaderView.h"
#import "UIColor+Theme.h"
#import "TTRoute.h"

static const float kSegementedOneWidth = 50;
static const float kSegementedHeight = 56;
static const float kSegementedPadingTop = 5;

@interface FHDetailNearbyMapCell () <AMapSearchDelegate,MAMapViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic , assign) NSInteger requestIndex;
@property (nonatomic , strong) HMSegmentedControl *segmentedControl;
@property (nonatomic , strong) UIImageView *mapImageView;
@property (nonatomic , strong) UIImageView *mapAnnotionImageView;
@property (nonatomic , strong) UITableView *locationList;
@property (nonatomic , strong) UIView *bottomLine;
@property (nonatomic , strong) UILabel *emptyInfoLabel;
@property (nonatomic , strong) UIButton *mapMaskBtn;
@property (nonatomic , strong) UIButton *mapMaskBtnLocation;
@property (nonatomic , assign) CLLocationCoordinate2D centerPoint;
@property (nonatomic , strong) AMapSearchAPI *searchApi;
@property (nonatomic , strong) NSMutableArray <FHMyMAAnnotation *> *poiAnnotations;
@property (nonatomic , strong) FHMyMAAnnotation *pointCenterAnnotation;
@property (nonatomic , strong) MAMapView *mapView;
@property (nonatomic , strong) NSString * searchCategory;
@property (nonatomic , strong) NSArray * nameArray;
@property (nonatomic , assign) BOOL isFirst;
@property (nonatomic , assign) NSInteger retrySnap;
@property (nonatomic , strong) NSMutableDictionary *countCategoryDict;
@property (nonatomic , strong) NSMutableDictionary *poiDatasDict;
@property (nonatomic , strong) FHDetailNearbyMapModel *dataModel;

@end

@implementation FHDetailNearbyMapCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _isFirst = YES;
         self.searchCategory = @"交通";
        self.centerPoint = CLLocationCoordinate2DMake(39.98269504123264, 116.3078908962674);
        _retrySnap = 2;
        
        _nameArray = [NSArray arrayWithObjects:@"交通",@"购物",@"医院",@"教育", nil];
        _countCategoryDict = [NSMutableDictionary new];
        _poiDatasDict = [NSMutableDictionary new];
        
        //设置title
        [self setUpHeaderView];
        
        //初始化左右切换
        [self setUpSegmentedControl];

        [self setUpMapImageView];
        
        self.searchApi = [[AMapSearchAPI alloc] init];
        self.searchApi.delegate = self;
        
        [self setUpLocationListTableView];
    }
    return self;
}

- (void)setUpHeaderView
{
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"周边配套";
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(46);
    }];
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"map";
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    if (_isFirst) {
        [self requestPoiInfo:self.centerPoint andKeyWord:_nameArray.firstObject];
        _isFirst = NO;
    }
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNearbyMapModel class]]) {
        return;
    }
    
    FHDetailNearbyMapModel *dataModel = (FHDetailNearbyMapModel *)data;
    dataModel.cell = self;
    _dataModel = dataModel;
    self.centerPoint = CLLocationCoordinate2DMake([dataModel.gaodeLat floatValue], [dataModel.gaodeLng floatValue]);
    [self.mapView setCenterCoordinate:self.centerPoint];
    
}

- (void)setUpSegmentedControl
{
    _segmentedControl = [HMSegmentedControl new];
    _segmentedControl.sectionTitles = @[@"交通(0)",@"购物(0)",@"医院(0)",@"教育(0)"];
    _segmentedControl.selectionIndicatorHeight = 2;
    _segmentedControl.selectionIndicatorColor = [UIColor themeRed1];
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    _segmentedControl.isNeedNetworkCheck = NO;
    
    NSDictionary *attributeNormal = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontRegular:16],NSFontAttributeName,
                                     [UIColor themeGray3],NSForegroundColorAttributeName,nil];
    
    NSDictionary *attributeSelect = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontRegular:16],NSFontAttributeName,
                                     [UIColor themeRed1],NSForegroundColorAttributeName,nil];
    _segmentedControl.titleTextAttributes = attributeNormal;
    _segmentedControl.selectedTitleTextAttributes = attributeSelect;
//    _segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(-10, 5, 0, 5);
    _segmentedControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 3);
    _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    WeakSelf;
    _segmentedControl.indexChangeBlock = ^(NSInteger index) {
        StrongSelf;

        [self cleanAllAnnotations];
        
        if (self.nameArray.count > index) {
            self.poiAnnotations = [NSMutableArray arrayWithArray:self.poiDatasDict[self.nameArray[index]]];
        }
        
        self.emptyInfoLabel.text = [NSString stringWithFormat:@"附近没有%@信息",self.nameArray[index]];
        
        [self setUpAnnotations];
        
    };
    [self.contentView addSubview:_segmentedControl];
    
    [_segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.width.mas_equalTo(MAIN_SCREEN_WIDTH);
        make.height.mas_equalTo(kSegementedHeight);
    }];
}

- (void)setUpMapViewSetting:(BOOL)isRetry
{
    _mapView.runLoopMode = NSDefaultRunLoopMode;
    _mapView.showsCompass = NO;
    _mapView.showsScale = NO;
    _mapView.zoomEnabled = NO;
    _mapView.scrollEnabled = NO;
    _mapView.zoomLevel = 14;
    _mapView.delegate = self;
    [_mapView forceRefresh];
    
    CGRect mapRect = CGRectMake(0.0f, 0.0f, MAIN_SCREEN_WIDTH, 160);
    WeakSelf;
    [_mapView takeSnapshotInRect:mapRect withCompletionBlock:^(UIImage *resultImage, NSInteger state) {
        StrongSelf;
        if (resultImage) {
            self.mapImageView.image = resultImage;
        }
    }];
    
    if (self.centerPoint.latitude && self.centerPoint.longitude) {
        [self.mapView setCenterCoordinate:self.centerPoint animated:NO];
    }
    if (isRetry) {
        [self.mapImageView addSubview:_mapView];
        _mapView.hidden = YES;
    }
}

- (void)setUpMapImageView
{
    CGRect mapRect = CGRectMake(0.0f, 0.0f, MAIN_SCREEN_WIDTH, 160);
    
    _mapView = [[MAMapView alloc] initWithFrame:mapRect];
    
    //3秒如果截图失败则重试一次
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.mapImageView.image == nil) {
                if (_mapView) {
                    [_mapView removeFromSuperview];
                    _mapView = nil;
                }
                _mapView = [[MAMapView alloc] initWithFrame:mapRect];
                [self setUpMapViewSetting:YES];
            }
        });
    });
    
    [self setUpMapViewSetting:NO];

    _mapImageView = [[UIImageView alloc] initWithFrame:mapRect];
    _mapImageView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_mapImageView];
    
    [_mapImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.top.equalTo(self.segmentedControl.mas_bottom);
        make.width.mas_equalTo(MAIN_SCREEN_WIDTH);
        make.height.mas_equalTo(160);
    }];
    
    _mapAnnotionImageView = [[UIImageView alloc] initWithFrame:mapRect];
    [_mapImageView addSubview:_mapAnnotionImageView];
    [_mapAnnotionImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_mapImageView);
    }];
    
    
    _mapMaskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_mapMaskBtn];

    
    [_mapMaskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentedControl.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    [_mapMaskBtn setBackgroundColor:[UIColor clearColor]];
    
    [_mapMaskBtn addTarget:self action:@selector(mapMaskBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    

}

- (void)mapMaskBtnClick:(UIButton *)sender
{
    //地图页调用示例
    double longitude = self.centerPoint.longitude;
    double latitude = self.centerPoint.latitude;
    NSNumber *latitudeNum = @(latitude);
    NSNumber *longitudeNum = @(longitude);
    NSString *selectCategory = @"公交";
    if (_nameArray.count > _segmentedControl.selectedSegmentIndex) {
        if (_segmentedControl.selectedSegmentIndex != 0) {
            selectCategory = [NSString stringWithFormat:@"%@",_nameArray[_segmentedControl.selectedSegmentIndex]];
        }
    }
    
    NSMutableDictionary *infoDict = [NSMutableDictionary new];
    [infoDict setValue:selectCategory forKey:@"category"];
    [infoDict setValue:latitudeNum forKey:@"latitude"];
    [infoDict setValue:longitudeNum forKey:@"longitude"];

    NSMutableDictionary *tracer = [NSMutableDictionary dictionaryWithDictionary:self.baseViewModel.detailTracerDic];
    
    if (sender == _mapMaskBtnLocation) {
        [tracer setValue:@"map_list" forKey:@"click_type"];
    }
    
    if (sender == _mapMaskBtn) {
        [tracer setValue:@"map" forKey:@"click_type"];
    }
    
    [tracer setValue:@"map" forKey:@"element_from"];
    [tracer setObject:tracer[@"page_type"] forKey:@"enter_from"];
    [infoDict setValue:tracer forKey:@"tracer"];
    
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://fh_map_detail"] userInfo:info];
}

- (void)setUpLocationListTableView
{
    _locationList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _locationList.separatorStyle = UITableViewCellSelectionStyleNone;
    _locationList.allowsSelection = NO;
    _locationList.userInteractionEnabled = YES;
    _locationList.delegate = self;
    _locationList.dataSource = self;
    [_locationList registerClass:[FHDetailNearbyMapItemCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNearbyMapItemCell class])];
    [self.contentView addSubview:_locationList];
    
    
    [_locationList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_mapImageView.mas_bottom).offset(10);
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-10);
        make.height.mas_equalTo(105);
    }];
    
    
    _emptyInfoLabel = [UILabel new];
    _emptyInfoLabel.text = @"附近没有交通信息";
    _emptyInfoLabel.textAlignment = NSTextAlignmentCenter;
//    _emptyInfoLabel.hidden = [FHEnvContext isNetworkConnected] ? YES : NO;
    _emptyInfoLabel.hidden = NO;
    _emptyInfoLabel.textColor = [UIColor themeGray1];
    
    [_locationList addSubview:_emptyInfoLabel];
    
    [_emptyInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_locationList);
        make.width.mas_greaterThanOrEqualTo(100);
        make.height.mas_equalTo(20);
    }];
    
    
    _mapMaskBtnLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_mapMaskBtnLocation];

    [_mapMaskBtnLocation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.locationList);
    }];
    [_mapMaskBtnLocation setBackgroundColor:[UIColor clearColor]];
    [_mapMaskBtnLocation addTarget:self action:@selector(mapMaskBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)changeListLayout:(NSInteger)poiCount
{
//    [_dataModel.tableView beginUpdates];
    [_locationList mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_mapImageView.mas_bottom).offset(10);
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-10);
        make.height.mas_equalTo((poiCount > 3 ? 3 : (poiCount == 0 ? 2 : poiCount)) * 35);
    }];
    
    if (poiCount == 0) {
        _emptyInfoLabel.hidden = NO;
        [_emptyInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_locationList);
            make.width.mas_greaterThanOrEqualTo(100);
            make.height.mas_equalTo(20);
        }];
    }else
    {
        _emptyInfoLabel.hidden = YES;
    }
    
    [_mapMaskBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentedControl.mas_bottom);
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_mapMaskBtnLocation mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.locationList);
    }];

    if (self.indexChangeCallBack) {
        self.indexChangeCallBack();
    }
}

- (void)cleanAllAnnotations
{
    [self.mapView removeAnnotation:self.pointCenterAnnotation];
    [self.mapView removeAnnotations:self.poiAnnotations];
    [self.poiAnnotations removeAllObjects];
}

- (void)setUpAnnotations
{
    for (NSInteger i = 0; i < _poiAnnotations.count; i++) {
        [self.mapView addAnnotation:_poiAnnotations[i]];
    }
    
    FHMyMAAnnotation *userAnna = [[FHMyMAAnnotation alloc] init];
    userAnna.type = @"user";
    
    userAnna.coordinate = self.centerPoint;
    [self.mapView addAnnotation:userAnna];
    self.pointCenterAnnotation = userAnna;
    
    [self.mapView setCenterCoordinate:self.centerPoint];
    
    [self performSelector:@selector(snapShotAnnotationImage) withObject:nil afterDelay:0.3];
    
    //改变显示的tableview数据
    [self changePoiData];
}

- (void)changePoiData
{
    [_locationList reloadData];
    
    [self changeListLayout:self.poiAnnotations.count];
}

- (void)requestPoiInfo:(CLLocationCoordinate2D)center andKeyWord:(NSString *)categoryName
{
    if (![FHEnvContext isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    AMapPOIKeywordsSearchRequest *requestPoi = [AMapPOIKeywordsSearchRequest new];
    if ([categoryName isEqualToString:@"交通"]) {
        requestPoi.keywords = @"公交地铁";
    }else
    {
        requestPoi.keywords = categoryName;
    }
    requestPoi.location = [AMapGeoPoint locationWithLatitude:self.centerPoint.latitude longitude:self.centerPoint.longitude];
    requestPoi.requireExtension = YES;
    requestPoi.requireSubPOIs = YES;
    requestPoi.cityLimit = YES;
    
    [self.searchApi AMapPOIIDSearch:requestPoi];
}

#pragma poi Delegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.count == 0) {
        [[ToastManager manager] showToast:@"暂无相关信息"];
        return;
    }
    
    NSInteger poiCount = response.pois.count > 50 ? 50 :  response.pois.count;
    NSMutableArray *poiArray = [NSMutableArray new];
    for (NSInteger i = 0; i < poiCount; i++) {
        AMapPOI * poi = response.pois[i];
        
        MAMapPoint from = MAMapPointForCoordinate(self.centerPoint);
        MAMapPoint to =  MAMapPointForCoordinate(CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude));
        CLLocationDistance distance = MAMetersBetweenMapPoints(from, to);
        if (distance < 2000) {
            FHMyMAAnnotation *maAnna = [FHMyMAAnnotation new];
            AMapPOIKeywordsSearchRequest *searchReqeust = (AMapPOIKeywordsSearchRequest *)request;
            maAnna.type = @"poi";
            maAnna.coordinate = CLLocationCoordinate2DMake(poi.location.latitude,poi.location.longitude);
            maAnna.title = poi.name;
            [poiArray addObject:maAnna];
        }
        
        if (poiArray.count >= 10) {
            break;
        }
    }
    
    AMapPOIKeywordsSearchRequest *searchReqeust = (AMapPOIKeywordsSearchRequest *)request;
    
    if ([searchReqeust.keywords isEqualToString:@"公交地铁"]) {
        [_countCategoryDict setObject:@(poiArray.count) forKey:_nameArray.firstObject];
        [_poiDatasDict setObject:poiArray forKey:_nameArray.firstObject];
        [self cleanAllAnnotations];
        self.poiAnnotations = [NSMutableArray arrayWithArray:poiArray];
        [self setUpAnnotations];
        //请求其他三个类别
        for (NSInteger i = 1; i < _nameArray.count; i++) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                // 处理耗时操作的代码块...
                [self requestPoiInfo:self.centerPoint andKeyWord:_nameArray[i]];
                
                //通知主线程刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    //回调或者说是通知主线程刷新，
                });
                
            });
        }
    }else
    {
        [_countCategoryDict setObject:@(poiArray.count) forKey:searchReqeust.keywords];
        [_poiDatasDict setObject:poiArray forKey:searchReqeust.keywords];
    }

    
    NSMutableArray *sectionTitleArray = [NSMutableArray new];
    for (NSInteger i = 0; i < _nameArray.count; i++) {
        if (_countCategoryDict[_nameArray[i]]) {
            [sectionTitleArray addObject:[NSString stringWithFormat:@"%@(%d)",_nameArray[i],[_countCategoryDict[_nameArray[i]] integerValue]]];
        }else
        {
            [sectionTitleArray addObject:[NSString stringWithFormat:@"%@(0)",_nameArray[i]]];
        }
    }
    
    _segmentedControl.sectionTitles = sectionTitleArray;
}

- (UIImage *)getIconImageFromCategory:(NSString *)category
{
    return [UIImage imageNamed:@"icon-location"];
}

#pragma MapViewDelegata

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[FHMyMAAnnotation class]]) {
        NSString *pointResueseIdetifier = @"pointReuseIndetifier";
        MAAnnotationView *annotationV = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointResueseIdetifier];
        if (annotationV == nil) {
            annotationV = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointResueseIdetifier];
        }
        
        if ([((FHMyMAAnnotation *)annotation).type isEqualToString:@"user"]) {
            annotationV.image = [self getIconImageFromCategory:((FHMyMAAnnotation *)annotation).type];
        }else
        {
            UIImageView *backImageView = [UIImageView new];
            [annotationV addSubview:backImageView];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 38)];
            titleLabel.text = annotation.title;
            titleLabel.frame = CGRectMake(0, 0, titleLabel.text.length * 13, 32);
            backImageView.frame = CGRectMake(0, 0, titleLabel.text.length * 13 + 20, 35);
            
            UIImage *imageAnna = [UIImage imageNamed:@"mapsearch_annotation_bg"];
            
            CGFloat width = imageAnna.size.width > 0 ? imageAnna.size.width : 10;
            CGFloat height = imageAnna.size.height > 0 ? imageAnna.size.height : 10;

            imageAnna = [imageAnna resizableImageWithCapInsets:UIEdgeInsetsMake(height/2.0, width/2.0, height/2.0, width/2.0) resizingMode:UIImageResizingModeStretch];
            backImageView.image = imageAnna;
            
            backImageView.layer.cornerRadius = 17.5;
            backImageView.layer.masksToBounds = YES;
            
            [annotationV addSubview:titleLabel];
            titleLabel.font = [UIFont themeFontRegular:12];
            titleLabel.textColor = [UIColor themeGray1];
            titleLabel.layer.masksToBounds = YES;
            
            titleLabel.numberOfLines = 1;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.backgroundColor = [UIColor clearColor];
            [titleLabel sizeToFit];
            titleLabel.center = CGPointMake(backImageView.center.x, backImageView.center.y - 1);
            
            UIImageView *bottomArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapsearch_annotation_arrow"]];
            [backImageView addSubview:bottomArrowView];
            bottomArrowView.backgroundColor = [UIColor clearColor];
            bottomArrowView.frame = CGRectMake(backImageView.frame.size.width / 2.0 - 5, backImageView.frame.size.height - 12, 10.5, 10.5);
        }
        
        annotationV.centerOffset = CGPointMake(0, -18);
        
        return annotationV ? annotationV : [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"default"];
    }
    
    return [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"default"];
}


- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    MACircle * cicle = [MACircle circleWithMapRect:MAMapRectZero];
    MAOverlayRenderer *overlayRender = [[MAOverlayRenderer alloc] initWithOverlay:overlay];
    return overlayRender;
}


#pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _poiAnnotations.count > 3 ? 3 : _poiAnnotations.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHDetailNearbyMapItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"item"];
    if (!cell) {
        cell = [[FHDetailNearbyMapItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"item"];
    }
    MAMapPoint from = MAMapPointForCoordinate(self.centerPoint);
    FHMyMAAnnotation *annotation = nil;
    if (self.poiAnnotations.count > indexPath.row) {
        annotation = self.poiAnnotations[indexPath.row];
    }
    NSString *stringName= @"暂无信息";
    
    if ([annotation.title isKindOfClass:[NSString class]]) {
        stringName = annotation.title;
    }
    
    NSString *stringDistance = @"未知";
    if (annotation) {
        MAMapPoint to =  MAMapPointForCoordinate(CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude));
        CLLocationDistance distance = MAMetersBetweenMapPoints(from, to);
        if (distance < 1000)
        {
            stringDistance = [NSString stringWithFormat:@"%d米",(int)distance];
        }else
        {
            stringDistance = [NSString stringWithFormat:@"%.1f公里",((CGFloat)distance) / 1000.0];
        }
    }

    [cell updateText:stringName andDistance:stringDistance];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"table cell click!!!");
}

- (void)snapShotAnnotationImage
{
    UIView *annotationView = [self.mapView viewForAnnotation:self.pointCenterAnnotation];
    if (annotationView) {
        UIView *superAnnotationView = [annotationView superview];
        if (superAnnotationView) {
            self.mapAnnotionImageView.image = [self getImageFromView:superAnnotationView];
        }
    }else
    {
        self.mapAnnotionImageView.image = nil;
    }
    
    if (self.mapAnnotionImageView.image == nil && _retrySnap > 0) {
        [self snapShotAnnotationImage];
        _retrySnap --;
    }else
    {
        _retrySnap = 0;
    }
}

- (UIImage *)getImageFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *imageResult = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageResult;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
