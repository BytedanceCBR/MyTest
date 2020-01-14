//
//  FHDetailOldNearbyMapCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/5/21.
//

#import "FHDetailOldNearbyMapCell.h"

#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

#import "HMSegmentedControl.h"
#import <FHEnvContext.h>
#import "ToastManager.h"

#import "FHMyMAAnnotation.h"
#import "FHDetailNearbyMapItemCell.h"
#import "FHDetailNewModel.h"
#import "FHDetailHeaderView.h"
#import "UIColor+Theme.h"
#import "TTRoute.h"
#import "HMDTTMonitor.h"
#import "FHDetailMapView.h"
#import "FHDetailHeaderStarTitleView.h"
#import <FHHouseBase/FHBaseTableView.h>

static const float kSegementedOneWidth = 50;
static const float kSegementedHeight = 56;
static const float kSegementedPadingTop = 5;

@interface FHDetailOldNearbyMapCell () <AMapSearchDelegate,
MAMapViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
FHDetailVCViewLifeCycleProtocol>

@property (nonatomic, strong)   FHDetailHeaderStarTitleView       *headerView;
@property (nonatomic , assign) NSInteger requestIndex;
@property (nonatomic , strong) HMSegmentedControl *segmentedControl;
@property (nonatomic , strong) UIImageView *mapImageView;
@property (nonatomic , strong) UITableView *locationList;
@property (nonatomic , strong) UIView *bottomLine;
@property (nonatomic , strong) UILabel *emptyInfoLabel;
@property (nonatomic , strong) UIButton *mapMaskBtn;
@property (nonatomic , strong) UIButton *mapMaskBtnLocation;
@property (nonatomic , assign) CLLocationCoordinate2D centerPoint;
@property (nonatomic , strong) AMapSearchAPI *searchApi;
@property (nonatomic , strong) NSMutableArray <FHMyMAAnnotation *> *poiAnnotations;
@property (nonatomic , strong) FHMyMAAnnotation *pointCenterAnnotation;
@property (nonatomic , weak)   MAMapView *mapView;
@property (nonatomic , strong) NSString * searchCategory;
@property (nonatomic , strong) NSArray * nameArray;
@property (nonatomic , assign) BOOL isFirst;
@property (nonatomic , strong) NSMutableDictionary *countCategoryDict;
@property (nonatomic , strong) NSMutableDictionary *poiDatasDict;
@property (nonatomic , strong) FHDetailOldNearbyMapModel *dataModel;
@property (nonatomic, assign)  BOOL isFirstSnapshot;// 首次截屏
@property (nonatomic, assign)  BOOL mapMaskClicked;
@property (nonatomic, weak) UIImageView *shadowImage;

@end

@implementation FHDetailOldNearbyMapCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _isFirstSnapshot = YES;
        _mapMaskClicked = NO;
        _isFirst = YES;
        self.searchCategory = @"交通";
        self.centerPoint = CLLocationCoordinate2DMake(39.98269504123264, 116.3078908962674);
        
        _nameArray = [NSArray arrayWithObjects:@"交通",@"购物",@"医院",@"教育", nil];
        _countCategoryDict = [NSMutableDictionary new];
        _poiDatasDict = [NSMutableDictionary new];
        
        [self setupShadowView];
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

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (void)setupShadowView {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
}

- (void)setUpHeaderView
{
    _headerView = [[FHDetailHeaderStarTitleView alloc] init];
    [_headerView updateTitle:@"便捷指数"];
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
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
    if (self.currentData == data || ![data isKindOfClass:[FHDetailOldNearbyMapModel class]]) {
        return;
    }
    
    FHDetailOldNearbyMapModel *dataModel = (FHDetailOldNearbyMapModel *)data;
    self.shadowImage.image = dataModel.shadowImage;
    dataModel.cell = self;
    _dataModel = dataModel;
    if (dataModel.title.length > 0) {
        [_headerView updateTitle:dataModel.title];
    }
    [self.headerView updateStarsCount:[dataModel.score integerValue]];
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
        [self clickFacilitiesTracker:index];
        [self cleanAllAnnotations];
        
        if (self.nameArray.count > index) {
            self.poiAnnotations = [NSMutableArray arrayWithArray:self.poiDatasDict[self.nameArray[index]]];
        }
        
        self.emptyInfoLabel.text = [NSString stringWithFormat:@"附近没有%@信息",self.nameArray[index]];
        
        [self setUpAnnotations];
        
    };
    [self.contentView addSubview:_segmentedControl];
    _segmentedControl.backgroundColor = [UIColor clearColor];
    
    [_segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(52);
        make.left.right.equalTo(self.contentView);
        make.width.mas_equalTo(MAIN_SCREEN_WIDTH);
        make.height.mas_equalTo(50);
    }];
}

- (void)clickFacilitiesTracker:(NSInteger)index {
    NSArray *facilities = @[@"traffic",@"shopping",@"hospital",@"education"];
    if (index >= 0 && index < facilities.count) {
        // click_facilities
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"element_type"] = [self elementTypeString:self.baseViewModel.houseType];
        tracerDic[@"click_position"] = facilities[index];
        [FHUserTracker writeEvent:@"click_facilities" params:tracerDic];
    }
}

- (void)setUpMapImageView
{
    CGRect mapRect = CGRectMake(0.0f, 0.0f, MAIN_SCREEN_WIDTH, 160);
    
    _mapView = [[FHDetailMapView sharedInstance] defaultMapViewWithFrame:mapRect];
    
    __weak typeof(self) weakSelf = self;
    // 延时绘制地图
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf snapshotMap];
    });
    
    _mapImageView = [[UIImageView alloc] initWithFrame:mapRect];
    _mapImageView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_mapImageView];
    
    [_mapImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.top.equalTo(self.segmentedControl.mas_bottom);
        make.width.mas_equalTo(MAIN_SCREEN_WIDTH-40);
        make.height.mas_equalTo(160);
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
    self.mapMaskClicked = YES;
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
    [infoDict setValue:self.dataModel.mapCentertitle forKey:@"title"];
    
    
    
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
    _locationList = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _locationList.separatorStyle = UITableViewCellSelectionStyleNone;
    _locationList.backgroundColor = [UIColor clearColor];
    _locationList.allowsSelection = NO;
    _locationList.userInteractionEnabled = YES;
    _locationList.delegate = self;
    _locationList.dataSource = self;
    [_locationList registerClass:[FHDetailNearbyMapItemCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNearbyMapItemCell class])];
    [self.contentView addSubview:_locationList];
    
    
    [_locationList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mapImageView.mas_bottom).offset(10);
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-20);
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
        make.center.equalTo(self.locationList);
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
        make.top.equalTo(self.mapImageView.mas_bottom).offset(10);
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo((poiCount > 3 ? 3 : (poiCount == 0 ? 2 : poiCount)) * 35);
    }];
    
    if (poiCount == 0) {
        _emptyInfoLabel.hidden = NO;
        [_emptyInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.locationList);
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
    [[FHDetailMapView sharedInstance] clearAnnotationDatas];
    self.mapView.delegate = self;
    for (NSInteger i = 0; i < _poiAnnotations.count; i++) {
        if (i < 3) {
            [self.mapView addAnnotation:_poiAnnotations[i]];
        }
    }
    FHMyMAAnnotation *userAnna = [[FHMyMAAnnotation alloc] init];
    userAnna.type = @"user";
    
    userAnna.coordinate = self.centerPoint;
    [self.mapView addAnnotation:userAnna];
    self.pointCenterAnnotation = userAnna;
    
    [self.mapView setCenterCoordinate:self.centerPoint];
    [self snapshotMap];
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
                [self requestPoiInfo:self.centerPoint andKeyWord:self.nameArray[i]];
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
            [sectionTitleArray addObject:[NSString stringWithFormat:@"%@(%ld)",_nameArray[i],[self.countCategoryDict[_nameArray[i]] integerValue]]];
        }else
        {
            [sectionTitleArray addObject:[NSString stringWithFormat:@"%@(0)",_nameArray[i]]];
        }
    }
    
    _segmentedControl.sectionTitles = sectionTitleArray;
}

- (UIImage *)getIconImageFromCategory:(NSString *)category
{
    return [UIImage imageNamed:@"detail_map_loc_annotation"];
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
            annotationV.centerOffset = CGPointMake(0, -18);
        }else
        {
            UIImageView *backImageView = [UIImageView new];
            [annotationV addSubview:backImageView];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 38)];
            titleLabel.text = annotation.title;
            titleLabel.frame = CGRectMake(0, 0, titleLabel.text.length * 13, 32);
            backImageView.frame = CGRectMake(0, 0, titleLabel.text.length * 13 + 20, 35);
            
            UIImage *imageAnna = [UIImage imageNamed:@"mapsearch_detail_annotation_bg"];//mapsearch_annotation_bg
            
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
            backImageView.frame = CGRectMake(0, 0, titleLabel.frame.size.width + 40, 35);
            titleLabel.center = CGPointMake(backImageView.center.x, backImageView.center.y - 1);
            
            UIImageView *bottomArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapsearch_annotation_arrow"]];
            [backImageView addSubview:bottomArrowView];
            bottomArrowView.backgroundColor = [UIColor clearColor];
            bottomArrowView.frame = CGRectMake(backImageView.frame.size.width / 2.0 - 5, backImageView.frame.size.height - 12, 10.5, 10.5);
            annotationV.centerOffset = CGPointMake(-backImageView.frame.size.width / 2.0, -40);
        }
        
        return annotationV ? annotationV : [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"default"];
    }
    
    return [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"default"];
}


- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
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
//    NSLog(@"table cell click!!!");
}

// 地图截屏
- (void)snapshotMap {
    // 截屏
    __weak typeof(self) weakSelf = self;
    CGRect frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 160);
    if (self.isFirstSnapshot) {
        self.isFirstSnapshot = NO;
        // 截图返回可能不正确
        [self.mapView takeSnapshotInRect:frame withCompletionBlock:^(UIImage *resultImage, NSInteger state) {
            // 注意点，如果进入周边地图页面，截屏可能不正确
            BOOL isVCDidDisappear = weakSelf.baseViewModel.detailController.isViewDidDisapper; // 是否 不可见
            if (!isVCDidDisappear) {
                weakSelf.mapImageView.image = resultImage;
            }
        }];
        
        // 第一次
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf) {
                [weakSelf realSnapShotMap];
                // 第二次
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (weakSelf) {
                        [weakSelf realSnapShotMap];
                    }
                });
            }
        });
    } else {
        [self realSnapShotMap];
    }
}

- (void)fh_willDisplayCell {
}

//
- (void)vc_viewDidAppear:(BOOL)animated {
    if (!self.isFirstSnapshot) {
        self.mapMaskClicked = NO;
    }
}

- (void)realSnapShotMap {
    if (!self.baseViewModel.detailController.isViewDidDisapper && !self.mapMaskClicked) {
        self.mapView.hidden = NO;
        [self.mapView forceRefresh];
        self.mapImageView.image = [self getImageFromView:self.mapView];
        self.mapView.hidden = YES;
    }
}

- (UIImage *)getImageFromView:(UIView *)view
{
    if (view.frame.size.height <= 0.1 || view.frame.size.width <= 0.1) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *imageResult = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageResult;
}

@end

@implementation FHDetailOldNearbyMapModel


@end
