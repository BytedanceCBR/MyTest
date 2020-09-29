//
//  FHNewHouseDetailMapCollectionCell.m
//  Pods
//
//  Created by bytedance on 2020/9/11.
//

#import "FHNewHouseDetailMapCollectionCell.h"
#import "FHEnvContext.h"
#import "FHDetailStaticMapCell.h"
#import "FHSegmentControl.h"
#import "AMapSearchAPI.h"
#import "MAMapKit.h"
#import "FHDetailMapViewSnapService.h"
#import <ByteDanceKit/ByteDanceKit.h>
#import "HMDUserExceptionTracker.h"

@interface FHNewHouseDetailMapCollectionCell ()<AMapSearchDelegate, FHStaticMapDelegate, MAMapViewDelegate>

@property(nonatomic, strong) FHSegmentControl *segmentedControl;
@property(nonatomic, strong) FHDetailStaticMap *mapView;
@property(nonatomic, strong) UIImageView *nativeMapImageView;
@property(nonatomic, strong) UIButton *mapMaskBtn;
@property(nonatomic, weak) UIImageView *shadowImage;
@property(nonatomic, strong) UIView *bottomGradientView;

@property (nonatomic, strong) UIButton *baiduPanoButton;

//data
@property(nonatomic, assign) NSString *curCategory;
@property(nonatomic, assign) CLLocationCoordinate2D centerPoint;
@property(nonatomic, strong) AMapSearchAPI *searchApi;
@property(nonatomic, strong) NSArray *nameArray;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *countCategoryDict;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSArray<FHStaticMapAnnotation *> *> *poiAnnotations;
@property(nonatomic, strong) FHStaticMapAnnotation *centerAnnotation;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *poiSearchStatus;

+ (NSString *)keyWordConver:(NSString *)category;
+ (NSString *)keyWordConverReverse:(NSString *)category;
@end

@implementation FHNewHouseDetailMapCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNewHouseDetailMapCellModel class]]) {
//        FHNewHouseDetailMapCellModel *cellModel = (FHNewHouseDetailMapCellModel *)data;
        CGFloat mapHeight = width * kStaticMapHWRatio;
        mapHeight += 33;
        mapHeight += 10;
        return CGSizeMake(width, mapHeight);
    }
    return CGSizeZero;
}

- (void)setCurCategory:(NSString *)curCategory {
    _curCategory = curCategory;
    if (self.categoryChangeBlock) {
        self.categoryChangeBlock(curCategory);
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.curCategory = @"交通";
        self.centerPoint = CLLocationCoordinate2DMake(39.98269504123264, 116.3078908962674);
        
        _centerAnnotation = [[FHStaticMapAnnotation alloc] init];
        _centerAnnotation.extra = @"center_annotation";
        
        _nameArray = @[@"交通", @"教育", @"医疗", @"生活"];
        _countCategoryDict = [NSMutableDictionary new];
        _poiAnnotations = [NSMutableDictionary new];
        _poiSearchStatus = [NSMutableDictionary dictionary];
        //初始化空数据
        for (NSString *name in _nameArray) {
            _poiSearchStatus[name] = @(0);
            _countCategoryDict[name] = @(0);
            _poiAnnotations[name] = [NSMutableArray arrayWithCapacity:3];
        }
        
        //初始化poi搜索器
        self.searchApi = [[AMapSearchAPI alloc] init];
        self.searchApi.delegate = self;
    }
    return self;
}

- (UIView *)bottomGradientView {
    if(!_bottomGradientView){
        CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), 29);
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = frame;
        gradientLayer.colors = @[
            (__bridge id)[UIColor colorWithWhite:1 alpha:1].CGColor,
            (__bridge id)[UIColor colorWithWhite:1 alpha:0].CGColor
        ];
        gradientLayer.startPoint = CGPointMake(0.5, 0.2);
        gradientLayer.endPoint = CGPointMake(0.5, 1);
        
        _bottomGradientView = [[UIView alloc] initWithFrame:frame];
        [_bottomGradientView.layer addSublayer:gradientLayer];
    }
    return _bottomGradientView;
}

- (void)setupViews:(BOOL)useNativeMap {
    
//    FHNewHouseDetailMapCellModel *dataModel = (FHNewHouseDetailMapCellModel *) self.currentData;
    
    //初始化左右切换
    [self setUpSegmentedControl];
    
    //初始化静态地图
    [self setUpMapView:useNativeMap];
   
    [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(33);
    }];
    CGFloat mapHeight = CGRectGetWidth(self.contentView.bounds) * kStaticMapHWRatio;
    CGRect mapFrame = CGRectMake(0, 33, CGRectGetWidth(self.contentView.bounds), mapHeight);
    self.mapView.frame = mapFrame;
    self.nativeMapImageView.frame = mapFrame;
    self.mapMaskBtn.frame = mapFrame;
    [self.baiduPanoButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(CGRectGetMinY(mapFrame) + mapHeight - 40 - 8);
    }];
}

- (void)cleanSubViews {
    [self.segmentedControl removeFromSuperview];
    self.segmentedControl = nil;
    
    [self.mapView removeFromSuperview];
    self.mapView = nil;
    
    [self.nativeMapImageView removeFromSuperview];
    self.nativeMapImageView = nil;
    
    [self.mapMaskBtn removeFromSuperview];
    self.mapMaskBtn = nil;
}

- (void)setUpSegmentedControl {
    _segmentedControl = [FHSegmentControl new];
    _segmentedControl.sectionTitles = @[@"交通", @"教育", @"医疗", @"生活"];
    _segmentedControl.selectionIndicatorSize = CGSizeMake(12, 3);
    _segmentedControl.selectionIndicatorCornerRadius = 1.5;
    _segmentedControl.selectionIndicatorColor = [UIColor themeGray1];
    NSDictionary *attributeNormal = @{NSFontAttributeName: [UIFont themeFontRegular:16], NSForegroundColorAttributeName: [UIColor themeGray3]};
    NSDictionary *attributeSelect = @{NSFontAttributeName: [UIFont themeFontMedium:16], NSForegroundColorAttributeName: [UIColor themeGray1]};
    _segmentedControl.backgroundColor = [UIColor whiteColor];
    _segmentedControl.titleTextAttributes = attributeNormal;
    _segmentedControl.selectedTitleTextAttributes = attributeSelect;
    
    WeakSelf;
    _segmentedControl.indexChangeBlock = ^(NSInteger index) {
        StrongSelf;
        [self clickFacilitiesTracker:index];
        if (self.nameArray.count > index) {
            [self showPoiInfoWithCategory:self.nameArray[index]];
        }
    };
    [self.contentView addSubview:_segmentedControl];
}

- (void)setUpMapView:(BOOL)useNativeMap {
    CGFloat mapHeight = CGRectGetWidth(self.contentView.bounds) * kStaticMapHWRatio;
    CGRect mapRect = CGRectMake(15, 0, CGRectGetWidth(self.contentView.bounds), mapHeight);
    
    if (useNativeMap) {
        _nativeMapImageView = [[UIImageView alloc] initWithFrame:mapRect];
        _nativeMapImageView.image = [UIImage imageNamed:@"static_map_empty"];
        [self.contentView addSubview:_nativeMapImageView];
    } else {
        _mapView = [FHDetailStaticMap mapWithFrame:mapRect];
        _mapView.backgroundColor = [UIColor colorWithHexStr:@"#ececec"];
        _mapView.delegate = self;
        [self.contentView addSubview:_mapView];
        [self.contentView sendSubviewToBack:_mapView];
    }
    
    _mapMaskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_mapMaskBtn];
    [self.mapMaskBtn addSubview:self.bottomGradientView];
    
    [_mapMaskBtn setBackgroundColor:[UIColor clearColor]];
    [_mapMaskBtn addTarget:self action:@selector(mapMaskBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (!self.baiduPanoButton) {
        self.baiduPanoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.baiduPanoButton setImage:[UIImage imageNamed:@"baidu_panorama_entrance_icon"] forState:UIControlStateNormal];
        [self.baiduPanoButton addTarget:self action:@selector(baiduPanoButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.baiduPanoButton];
        [self.baiduPanoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40, 40));
            make.right.mas_equalTo(-23);
            make.top.mas_equalTo(0);
        }];
    }
}

- (void)takeSnapWith:(NSString *)category annotations:(NSArray<id <MAAnnotation>> *)annotations {
    CGFloat mapHeight = CGRectGetWidth(self.contentView.bounds) * kStaticMapHWRatio;
    CGRect frame = CGRectMake(15, 0, CGRectGetWidth(self.contentView.bounds), mapHeight);
    WeakSelf;
    [[FHDetailMapViewSnapService sharedInstance] takeSnapWith:self.centerPoint frame:frame targetRect:frame annotations:annotations delegate:self block:^(FHDetailMapSnapTask *task, UIImage *image, BOOL success) {
        StrongSelf;
        if (!success) {
            //展示默认图
            self.nativeMapImageView.image = [UIImage imageNamed:@"static_map_empty"];
            return;
        }
        if ([category isEqualToString:wself.curCategory]) {
            wself.nativeMapImageView.image = image;
        }
    }];
}

- (void)mapMaskBtnClick:(UIButton *)sender {
    if (self.mapBtnClickBlock) {
        self.mapBtnClickBlock(@"map");
    }
}

- (void)baiduPanoButtonAction {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }

//    NSMutableDictionary *param = [NSMutableDictionary new];
//    FHNewHouseDetailMapCellModel *dataModel = (FHNewHouseDetailMapCellModel *) self.currentData;
//    NSMutableDictionary *tracerDict = self.baseViewModel.detailTracerDic.mutableCopy;
//    tracerDict[@"element_from"] = @"map";
//    if ([self.baseViewModel.detailData isKindOfClass:[FHDetailOldModel class]]) {
//        // 二手房数据
//        tracerDict[@"enter_from"] = @"old_detail";
//    }else if ([self.baseViewModel.detailData isKindOfClass:[FHDetailNewModel class]]) {
//        tracerDict[@"enter_from"] = @"new_detail";
//    }else if ([self.baseViewModel.detailData isKindOfClass:[FHDetailNeighborhoodModel class]]) {
//        tracerDict[@"enter_from"] = @"neighborhood_detail";
//    }
//    param[TRACER_KEY] = tracerDict.copy;
//    if (dataModel.gaodeLat.length && dataModel.gaodeLng.length) {
//        param[@"gaodeLat"] = dataModel.gaodeLat;
//        param[@"gaodeLon"] = dataModel.gaodeLng;
//        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://baidu_panorama_detail"]] userInfo:TTRouteUserInfoWithDict(param)];
//    }
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHNewHouseDetailMapCellModel class]]) {
        return;
    }
    FHNewHouseDetailMapCellModel *dataModel = (FHNewHouseDetailMapCellModel *) data;
    if (self.currentData == data) {
        return;
    }
    self.currentData = data;
    
    self.centerPoint = CLLocationCoordinate2DMake([dataModel.gaodeLat floatValue], [dataModel.gaodeLng floatValue]);
    
    NSDictionary *fhSettings = [self fhSettings];
    dataModel.useNativeMap = [fhSettings btd_unsignedIntegerValueForKey:@"f_use_static_map"] == 0;
    
    [self cleanSubViews];
    [self setupViews:dataModel.useNativeMap];
    

    [self refreshWithDataPoiDetail];
}

- (void)refreshWithDataPoiDetail {
    FHNewHouseDetailMapCellModel *dataModel = (FHNewHouseDetailMapCellModel *) self.currentData;
    
    self.baiduPanoButton.hidden = !dataModel.baiduPanoramaUrl.length;
    if (!dataModel.useNativeMap) {
        if (!dataModel.staticImage || isEmptyString(dataModel.staticImage.url) || isEmptyString(dataModel.staticImage.latRatio) || isEmptyString(dataModel.staticImage.lngRatio)) {
            NSString *message = !dataModel.staticImage ? @"static_image_null" : @"bad_static_image";
            [self mapView:self.mapView loadFinished:NO message:message];
            return;
        }
        [self.mapView loadMap:dataModel.staticImage.url center:self.centerPoint latRatio:[dataModel.staticImage.latRatio floatValue] lngRatio:[dataModel.staticImage.lngRatio floatValue]];
    }
    
    if ([self isPoiSearchDone:self.curCategory]) {
        [self showPoiResultInfo];
    } else {
        [self requestPoiInfo:self.centerPoint];
    }
}

- (void)clickFacilitiesTracker:(NSInteger)index {
    NSArray *facilities = @[@"traffic", @"education", @"hospital", @"life"];
    if (index >= 0 && index < facilities.count) {
        // click_facilities
//        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
//        tracerDic[@"element_type"] = [self elementTypeString:self.baseViewModel.houseType];
//        tracerDic[@"click_position"] = facilities[index];
//        [FHUserTracker writeEvent:@"click_facilities" params:tracerDic];
    }
}

- (void)requestPoiInfo:(CLLocationCoordinate2D)center {
    if (![FHEnvContext isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    for (NSString *categoryName in self.nameArray) {
        if ([self isPoiSearchDone:categoryName]) {
            continue;
        }
        AMapPOIAroundSearchRequest *requestPoi = [AMapPOIAroundSearchRequest new];
        
        requestPoi.keywords = [FHNewHouseDetailMapCollectionCell keyWordConver:categoryName];
        requestPoi.location = [AMapGeoPoint locationWithLatitude:center.latitude longitude:center.longitude];
        requestPoi.requireExtension = YES;
        requestPoi.radius = 2000;
        requestPoi.requireSubPOIs = NO;
        
        [self.searchApi AMapPOIAroundSearch:requestPoi];
    }
}

+ (NSString *)keyWordConver:(NSString *)category{
    if([category isEqualToString:@"交通"]){
        return @"公交地铁";
    }else if([category isEqualToString:@"教育"]){
        return @"学校";
    }else if([category isEqualToString:@"医疗"]){
        return @"医院";
    }else if([category isEqualToString:@"生活"]){
        return @"购物|银行";
    }else if([category isEqualToString:@"休闲"]){
        return @"电影院|咖啡厅|影剧院";
    }else{
        return @"公交地铁";
    }
}

+ (NSString *)keyWordConverReverse:(NSString *)category{
    if([category isEqualToString:@"公交地铁"]){
        return @"交通";
    }else if([category isEqualToString:@"学校"]){
        return @"教育";
    }else if([category isEqualToString:@"医院"]){
        return @"医疗";
    }else if([category isEqualToString:@"购物|银行"]){
        return @"生活";
    }else if([category isEqualToString:@"电影院|咖啡厅|影剧院"]){
        return @"休闲";
    }else{
        return @"交通";
    }
}

#pragma FHStaticMapDelegate

- (FHStaticMapAnnotationView *)mapView:(FHDetailStaticMap *)mapView viewForStaticMapAnnotation:(FHStaticMapAnnotation *)annotation {
    if ([annotation.extra isEqualToString:@"center_annotation"]) {
        NSString *reuseIdentifier = @"center_annotation";
        FHDetailStaticMapCenterAnnotationView *annotationView = (FHDetailStaticMapCenterAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        if (!annotationView) {
            annotationView = [[FHDetailStaticMapCenterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        }
        annotationView.annotationSize = CGSizeMake(CGRectGetWidth(annotationView.imageView.frame), CGRectGetHeight(annotationView.imageView.frame));
        return annotationView;
    }
    
    if ([annotation.extra isEqualToString:@"poi_annotation"]) {
        NSString *reuseIdentifier = @"poi_annotation";
        FHDetailStaticMapPOIAnnotationView *annotationView = (FHDetailStaticMapPOIAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        if (!annotationView) {
            annotationView = [[FHDetailStaticMapPOIAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        }
        UILabel *titleLabel = annotationView.titleLabel;
        titleLabel.frame = CGRectMake(0, 0, titleLabel.text.length * 13, 32);
        titleLabel.text = annotation.title;
        [titleLabel sizeToFit];
        
        UIImageView *backImageView = annotationView.backImageView;
        backImageView.frame = CGRectMake(0, 0, titleLabel.frame.size.width + 40, 35);
        titleLabel.center = CGPointMake(backImageView.center.x, backImageView.center.y - 1);
        
        annotationView.arrowView.frame = CGRectMake(backImageView.frame.size.width / 2.0 - 5, backImageView.frame.size.height - 12, 10.5, 10.5);
        annotationView.centerOffset = CGPointMake(0, -16);
        annotationView.annotationSize = CGSizeMake(CGRectGetWidth(backImageView.frame), CGRectGetHeight(backImageView.frame));
        return annotationView;
    }
    return [[FHStaticMapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"default"];
}

- (void)mapView:(FHDetailStaticMap *)mapView loadFinished:(BOOL)success message:(NSString *)message {
    if (success) {
        return;
    }
    FHNewHouseDetailMapCellModel *dataModel = (FHNewHouseDetailMapCellModel *) self.currentData;
    //失败回退 报警
    NSString *eventName = @"f_static_map_bad_data";
    NSDictionary *cat = @{@"status": @(1)};
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    extra[@"url"] = dataModel.staticImage.url;
    extra[@"group_id"] = dataModel.houseId;
    extra[@"houseType"] = dataModel.houseType;
    extra[@"message"] = message;
    [[HMDTTMonitor defaultManager] hmdTrackService:eventName metric:nil category:cat extra:extra];
    
    NSMutableDictionary *filterDic = [NSMutableDictionary dictionary];
    filterDic[@"eventName"] = eventName;
    [[HMDUserExceptionTracker sharedTracker] trackUserExceptionWithType:eventName Log:eventName CustomParams:extra filters:filterDic callback:nil];
    
    dataModel.useNativeMap = YES;
    [self cleanSubViews];
    [self setupViews:dataModel.useNativeMap];
    [self refreshWithDataPoiDetail];
}

#pragma mark -

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation; {
    if ([annotation isKindOfClass:[FHStaticMapAnnotation class]]) {
        FHStaticMapAnnotation *staticMapAnnotation = (FHStaticMapAnnotation *) annotation;
        if ([staticMapAnnotation.extra isEqualToString:@"center_annotation"]) {
            NSString *reuseIdentifier = @"center_annotation";
            MAAnnotationView *annotationView = (MAAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
            if (!annotationView) {
                annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
            }
            UIImage *centerImage = [UIImage imageNamed:@"detail_map_loc_annotation"];
            annotationView.image = centerImage;
            annotationView.centerOffset = CGPointMake(0, -centerImage.size.height * 0.5);
            return annotationView;
        }
        
        if ([staticMapAnnotation.extra isEqualToString:@"poi_annotation"]) {
            NSString *reuseIdentifier = @"poi_annotation";
            MAAnnotationView *annotationView = (MAAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
            if (!annotationView) {
                annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
            }
            
            UIImageView *backImageView = [UIImageView new];
            [annotationView addSubview:backImageView];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 38)];
            titleLabel.text = annotation.title;
            titleLabel.frame = CGRectMake(0, 0, titleLabel.text.length * 13, 32);
            backImageView.frame = CGRectMake(0, 0, titleLabel.text.length * 13 + 20, 35);
            
            UIImage *imageAnna = [UIImage imageNamed:@"mapsearch_detail_annotation_bg"];//mapsearch_annotation_bg
            
            CGFloat width = imageAnna.size.width > 0 ? imageAnna.size.width : 10;
            CGFloat height = imageAnna.size.height > 0 ? imageAnna.size.height : 10;
            
            imageAnna = [imageAnna resizableImageWithCapInsets:UIEdgeInsetsMake(height / 2.0, width / 2.0, height / 2.0, width / 2.0) resizingMode:UIImageResizingModeStretch];
            backImageView.image = imageAnna;
            
            backImageView.layer.cornerRadius = 17.5;
            backImageView.layer.masksToBounds = YES;
            
            [annotationView addSubview:titleLabel];
            titleLabel.font = [UIFont themeFontRegular:12];
            titleLabel.textColor = [UIColor themeGray1];
            titleLabel.layer.masksToBounds = YES;
            
            titleLabel.numberOfLines = 1;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.backgroundColor = [UIColor clearColor];
            [titleLabel sizeToFit];
            backImageView.frame = CGRectMake(0, 0, titleLabel.frame.size.width + 40, 35);
            titleLabel.center = CGPointMake(backImageView.center.x, backImageView.center.y - 1);
            
            UIImageView *bottomArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"house_detail_map_ana_arrow"]];
            [backImageView addSubview:bottomArrowView];
            bottomArrowView.backgroundColor = [UIColor clearColor];
            bottomArrowView.frame = CGRectMake(backImageView.frame.size.width / 2.0 - 5, backImageView.frame.size.height - 12, 10.5, 10.5);
            annotationView.centerOffset = CGPointMake(-backImageView.frame.size.width / 2.0, -40);
            return annotationView;
        }
    }
    
    return [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"default"];
}

#pragma poi Delegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    NSInteger poiCount = MIN(response.pois.count, 50);
    NSMutableArray *poiArray = [NSMutableArray new];
    for (NSInteger i = 0; i < poiCount; i++) {
        AMapPOI *poi = response.pois[i];
        
        MAMapPoint from = MAMapPointForCoordinate(self.centerPoint);
        MAMapPoint to = MAMapPointForCoordinate(CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude));
        CLLocationDistance distance = MAMetersBetweenMapPoints(from, to);
        if (distance < 2000) {
            [poiArray addObject:poi];
        }
        
        if (poiArray.count >= 10) {
            break;
        }
    }
    AMapPOIKeywordsSearchRequest *searchRequest = (AMapPOIKeywordsSearchRequest *) request;
    NSString *category = [FHNewHouseDetailMapCollectionCell keyWordConverReverse:searchRequest.keywords];
    NSMutableArray *annotations = [NSMutableArray array];
    FHStaticMapAnnotation *annotation = nil;
    for (NSUInteger i = 0; i < poiArray.count; i++) {
        AMapPOI *poi = poiArray[i];
        annotation = [[FHStaticMapAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        annotation.extra = @"poi_annotation";
        annotation.title = poi.name;
        [annotations addObject:annotation];
        if (i >= 2) {
            break;
        }
    }
    _countCategoryDict[category] = @(poiArray.count);
    _poiAnnotations[category] = [annotations copy];
    _poiSearchStatus[category] = @(1);
    
    [self showPoiNumber];
    if ([category isEqualToString:self.curCategory]) {
        [self showPoiResultInfo];
    }
}

- (BOOL)isPoiSearchDone:(NSString *)category {
    return [self.poiSearchStatus[category] integerValue] != 0;
}

- (void)showPoiNumber {
    NSMutableArray *sectionTitleArray = [NSMutableArray new];
    for (NSInteger i = 0; i < _nameArray.count; i++) {
        if (_countCategoryDict[_nameArray[i]]) {
//            [sectionTitleArray addObject:[NSString stringWithFormat:@"%@(%ld)", _nameArray[i], [self.countCategoryDict[_nameArray[i]] integerValue]]];
            [sectionTitleArray addObject:[NSString stringWithFormat:@"%@", _nameArray[i]]];
        } else {
            [sectionTitleArray addObject:[NSString stringWithFormat:@"%@", _nameArray[i]]];
        }
    }
    
    _segmentedControl.sectionTitles = sectionTitleArray;
}

- (void)showPoiResultInfo {
    [self showPoiNumber];
    
    [self showPoiInfoWithCategory:self.curCategory];
}

- (void)showPoiInfoWithCategory:(NSString *)category {
    self.curCategory = category;
    
    //地图标签
    NSArray<id <MAAnnotation>> *poiAnnotation = self.poiAnnotations[self.curCategory];
    NSMutableArray *annotations = [NSMutableArray array];
    [annotations addObjectsFromArray:poiAnnotation];
    //center
    self.centerAnnotation.coordinate = self.centerPoint;
    [annotations addObject:self.centerAnnotation];
    
    FHNewHouseDetailMapCellModel *dataModel = (FHNewHouseDetailMapCellModel *) self.currentData;
    
    if (dataModel.useNativeMap) {
        [self takeSnapWith:category annotations:annotations];
    } else {
        [self.mapView removeAllAnnotations];
        [self.mapView addAnnotations:annotations];
    }
    
    dataModel.annotations = self.poiAnnotations[self.curCategory];
    if (dataModel.annotations.count) {
        dataModel.emptyString = [NSString stringWithFormat:@""];
    } else {
        dataModel.emptyString = [NSString stringWithFormat:@"附近没有%@信息", category];
    }
    if (self.refreshActionBlock) {
        self.refreshActionBlock();
    }
}

- (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]) {
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}

- (NSString *)elementType {
    return @"map";
}
@end

@implementation FHNewHouseDetailMapCellModel

@end
