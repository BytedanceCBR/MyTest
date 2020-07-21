//
//  FHDetailStaticMapCell.m
//  AKCommentPlugin
//
//  Created by zhulijun on 2019/11/26.
//

#import "FHEnvContext.h"
#import <FHHouseDetail/FHDetailHeaderView.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import "FHDetailStaticMapCell.h"
#import "AMapSearchAPI.h"
#import "MAMapKit.h"
#import "FHDetailStarHeaderView.h"
#import "HMSegmentedControl.h"
#import "FHBaseTableView.h"
#import "FHDetailNearbyMapItemCell.h"
#import "UIViewAdditions.h"
#import "FHDetailMapViewSnapService.h"
#import "HMDUserExceptionTracker.h"

@implementation FHDetailStaticMapCellModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _bottomMargin = 30;
    }
    return self;
}

@end

@implementation FHDetailStaticMapPOIAnnotationView
- (instancetype)initWithAnnotation:(FHStaticMapAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImage *imageAnna = [UIImage imageNamed:@"mapsearch_detail_annotation_bg"];//mapsearch_detail_annotation_bg
        CGFloat width = imageAnna.size.width;
        CGFloat height = imageAnna.size.height;
        imageAnna = [imageAnna resizableImageWithCapInsets:UIEdgeInsetsMake(height * 0.5, width * 0.5, height * 0.5, width * 0.5) resizingMode:UIImageResizingModeStretch];

        self.backImageView = [[UIImageView alloc] init];
        self.backImageView.image = imageAnna;
        self.backImageView.layer.masksToBounds = YES;
        [self addSubview:self.backImageView];

        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont themeFontRegular:12];
        self.titleLabel.textColor = [UIColor themeGray1];
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];

        self.arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapsearch_annotation_arrow"]];
        [self.backImageView addSubview:self.arrowView];
    }
    return self;
}
@end

@implementation FHDetailStaticMapCenterAnnotationView
- (instancetype)initWithAnnotation:(FHStaticMapAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        UIImage *centerImage = [UIImage imageNamed:@"detail_map_loc_annotation"];
        self.imageView.image = centerImage;
        self.centerOffset = CGPointMake(0, -centerImage.size.height * 0.5);
        self.imageView.frame = CGRectMake(0, 0, centerImage.size.width, centerImage.size.height);
        [self addSubview:self.imageView];
    }
    return self;
}
@end

@interface FHDetailStaticMapCell () <AMapSearchDelegate, UITableViewDelegate, UITableViewDataSource, FHDetailVCViewLifeCycleProtocol, FHStaticMapDelegate, MAMapViewDelegate>
//ui
@property(nonatomic, strong) FHDetailStarHeaderView *starHeaderView;
@property(nonatomic, strong) FHDetailHeaderView *headerView;
@property(nonatomic, strong) HMSegmentedControl *segmentedControl;
@property(nonatomic, strong) FHDetailStaticMap *mapView;
@property(nonatomic, strong) UIImageView *nativeMapImageView;
@property(nonatomic, strong) UITableView *locationList;
@property(nonatomic, strong) UILabel *emptyInfoLabel;
@property(nonatomic, strong) UIButton *mapMaskBtn;
@property(nonatomic, strong) UIButton *mapMaskBtnLocation;
@property(nonatomic, strong) UIView *backView;

//data
@property(nonatomic, copy) NSString *curCategory;
@property(nonatomic, assign) CLLocationCoordinate2D centerPoint;
@property(nonatomic, strong) AMapSearchAPI *searchApi;
@property(nonatomic, strong) NSArray *nameArray;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *countCategoryDict;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSArray<FHStaticMapAnnotation *> *> *poiAnnotations;
@property(nonatomic, strong) FHStaticMapAnnotation *centerAnnotation;
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *poiSearchStatus;

@property (nonatomic, strong) UIButton *baiduPanoButton;

@end

@implementation FHDetailStaticMapCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.curCategory = @"交通";
        self.centerPoint = CLLocationCoordinate2DMake(39.98269504123264, 116.3078908962674);
        _backView = [[UIView alloc] init];
        [self.contentView addSubview:_backView];

        [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.contentView).offset(-20);
            make.height.mas_equalTo(0);
        }];

        _centerAnnotation = [[FHStaticMapAnnotation alloc] init];
        _centerAnnotation.extra = @"center_annotation";

        _nameArray = @[@"交通", @"购物", @"医院", @"教育"];
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

- (void)setupViewMapOnly:(BOOL)useNativeMap {
    //初始化静态地图
    [self setUpMapView:useNativeMap];

    CGFloat mapHeight = MAIN_SCREEN_WIDTH * kStaticMapHWRatio;
    CGRect mapFrame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, mapHeight);
    self.mapView.frame = mapFrame;
    self.nativeMapImageView.frame = mapFrame;
    self.mapMaskBtn.frame = mapFrame;

    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.mapMaskBtn);
        make.bottom.mas_greaterThanOrEqualTo(self.mapMaskBtn).offset(30);
    }];
}

//TODO zlj 判断使用native地图
- (void)addCenterAnnotationMapOnly:(BOOL)useNativeMap {
    self.centerAnnotation.coordinate = self.centerPoint;
    CGFloat mapHeight = MAIN_SCREEN_WIDTH * kStaticMapHWRatio;
    CGRect frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, mapHeight);

    if (!useNativeMap) {
        [self.mapView removeAllAnnotations];
        [self.mapView addAnnotations:@[self.centerAnnotation]];
        return;
    }

    WeakSelf;
    [[FHDetailMapViewSnapService sharedInstance] takeSnapWith:self.centerPoint frame:frame targetRect:frame annotations:@[self.centerAnnotation] delegate:self block:^(FHDetailMapSnapTask *task, UIImage *image, BOOL success) {
        StrongSelf;
        if (!success) {
            return;
        }
        wself.nativeMapImageView.image = image;
    }];

}

- (void)setupViews:(BOOL)useNativeMap {
    //初始化Header
    [self setUpHeaderView];

    //初始化左右切换
    [self setUpSegmentedControl];

    //初始化静态地图
    [self setUpMapView:useNativeMap];

    //初始化poi信息列表
    [self setUpLocationListTableView];

    self.headerView.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 46);
    self.starHeaderView.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 110);
    self.segmentedControl.frame = CGRectMake(0,self.headerView.bottom, MAIN_SCREEN_WIDTH, 50);

    CGFloat mapHeight = MAIN_SCREEN_WIDTH * kStaticMapHWRatio;
    CGRect mapFrame = CGRectMake(0, self.segmentedControl.bottom, MAIN_SCREEN_WIDTH, mapHeight);
    self.mapView.frame = mapFrame;
    self.nativeMapImageView.frame = mapFrame;
    self.mapMaskBtn.frame = mapFrame;
    self.locationList.frame = CGRectMake(0, self.mapMaskBtn.bottom + 20, MAIN_SCREEN_WIDTH, 105);
    self.emptyInfoLabel.frame = self.locationList.bounds;
    self.mapMaskBtnLocation.frame = self.locationList.frame;
    self.baiduPanoButton.frame = CGRectMake(MAIN_SCREEN_WIDTH - 8 - 40, CGRectGetMaxY(mapFrame) - 8 - 40, 40, 40);

    CGFloat cellHeight = self.locationList.bottom;
    [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(cellHeight);
    }];
}

- (void)cleanSubViews {
    [self.headerView removeFromSuperview];
    self.headerView = nil;

    [self.starHeaderView removeFromSuperview];
    self.starHeaderView = nil;

    [self.segmentedControl removeFromSuperview];
    self.segmentedControl = nil;

    [self.mapView removeFromSuperview];
    self.mapView = nil;

    [self.nativeMapImageView removeFromSuperview];
    self.nativeMapImageView = nil;

    [self.mapMaskBtn removeFromSuperview];
    self.mapMaskBtn = nil;

    [self.locationList removeFromSuperview];
    self.locationList = nil;

    [self.emptyInfoLabel removeFromSuperview];
    self.emptyInfoLabel = nil;

    [self.mapMaskBtnLocation removeFromSuperview];
    self.mapMaskBtnLocation = nil;
}

- (void)setUpHeaderView{
    _headerView = [[FHDetailHeaderView alloc] init];
    [self.contentView addSubview:_headerView];
    _headerView.label.text = @"周边配套";
    [self.contentView sendSubviewToBack:_headerView];
}

- (void)setUpSegmentedControl {
    _segmentedControl = [HMSegmentedControl new];
    _segmentedControl.sectionTitles = @[@"交通(0)", @"购物(0)", @"医院(0)", @"教育(0)"];
    _segmentedControl.selectionIndicatorHeight = 2;
    _segmentedControl.selectionIndicatorColor = [UIColor themeOrange1];
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    _segmentedControl.isNeedNetworkCheck = NO;

    NSDictionary *attributeNormal = @{NSFontAttributeName: [UIFont themeFontRegular:16], NSForegroundColorAttributeName: [UIColor themeGray3]};
    NSDictionary *attributeSelect = @{NSFontAttributeName: [UIFont themeFontRegular:16], NSForegroundColorAttributeName: [UIColor themeOrange1]};

    _segmentedControl.titleTextAttributes = attributeNormal;
    _segmentedControl.selectedTitleTextAttributes = attributeSelect;
    _segmentedControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 3);
    _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentedControl.backgroundColor = [UIColor clearColor];

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
    CGFloat mapHeight = MAIN_SCREEN_WIDTH * kStaticMapHWRatio;
    CGRect mapRect = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, mapHeight);

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

    [_mapMaskBtn setBackgroundColor:[UIColor clearColor]];
    [_mapMaskBtn addTarget:self action:@selector(mapMaskBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (!self.baiduPanoButton) {
        self.baiduPanoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.baiduPanoButton setImage:[UIImage imageNamed:@"baidu_panorama_entrance_icon"] forState:UIControlStateNormal];
        [self.baiduPanoButton addTarget:self action:@selector(baiduPanoButtonAction) forControlEvents:UIControlEventTouchUpInside];
        self.baiduPanoButton.hidden = YES;
        [self.contentView addSubview:self.baiduPanoButton];
    }
}

- (void)takeSnapWith:(NSString *)category annotations:(NSArray<id <MAAnnotation>> *)annotations {
    CGFloat mapHeight = MAIN_SCREEN_WIDTH * kStaticMapHWRatio;
    CGRect frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, mapHeight);
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

- (void)setUpLocationListTableView {
    _locationList = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _locationList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _locationList.allowsSelection = NO;
    _locationList.userInteractionEnabled = YES;
    _locationList.delegate = self;
    _locationList.dataSource = self;
    [_locationList registerClass:[FHDetailNearbyMapItemCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNearbyMapItemCell class])];
    [self.contentView addSubview:_locationList];

    _emptyInfoLabel = [UILabel new];
    _emptyInfoLabel.text = @"附近没有交通信息";
    _emptyInfoLabel.textAlignment = NSTextAlignmentCenter;
    _emptyInfoLabel.hidden = NO;
    _emptyInfoLabel.textColor = [UIColor themeGray1];
    [_locationList addSubview:_emptyInfoLabel];

    _mapMaskBtnLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:_mapMaskBtnLocation];

    [_mapMaskBtnLocation setBackgroundColor:[UIColor clearColor]];
    [_mapMaskBtnLocation addTarget:self action:@selector(mapMaskBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)mapMaskBtnClick:(UIButton *)sender {
    FHDetailStaticMapCellModel *dataModel = (FHDetailStaticMapCellModel *) self.currentData;

    //地图页调用示例
    double longitude = self.centerPoint.longitude;
    double latitude = self.centerPoint.latitude;
    NSNumber *latitudeNum = @(latitude);
    NSNumber *longitudeNum = @(longitude);

    NSString *selectCategory = [self.curCategory isEqualToString:@"交通"] ? @"公交" : self.curCategory;
    NSMutableDictionary *infoDict = [NSMutableDictionary new];
    [infoDict setValue:selectCategory forKey:@"category"];
    [infoDict setValue:latitudeNum forKey:@"latitude"];
    [infoDict setValue:longitudeNum forKey:@"longitude"];
    [infoDict setValue:dataModel.mapCentertitle forKey:@"title"];
    if (dataModel.baiduPanoramaUrl.length) {
        infoDict[@"baiduPanoramaUrl"] = dataModel.baiduPanoramaUrl;
    }

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

- (void)baiduPanoButtonAction {
    FHDetailStaticMapCellModel *dataModel = (FHDetailStaticMapCellModel *) self.currentData;
    NSMutableDictionary *tracerDict = self.baseViewModel.detailTracerDic.mutableCopy;
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[TRACER_KEY] = tracerDict.copy;
    
    if (dataModel.gaodeLat.length && dataModel.gaodeLng.length) {
        param[@"gaodeLat"] = dataModel.gaodeLat;
        param[@"gaodeLon"] = dataModel.gaodeLng;
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://baidu_panorama_detail"]] userInfo:TTRouteUserInfoWithDict(param)];
    }
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailStaticMapCellModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailStaticMapCellModel *dataModel = (FHDetailStaticMapCellModel *) data;
    self.centerPoint = CLLocationCoordinate2DMake([dataModel.gaodeLat floatValue], [dataModel.gaodeLng floatValue]);

    NSDictionary *fhSettings = [self fhSettings];
    dataModel.useNativeMap = [fhSettings tt_unsignedIntegerValueForKey:@"f_use_static_map"] == 0;

    [self cleanSubViews];
    if (dataModel.mapOnly) {
        [self setupViewMapOnly:dataModel.useNativeMap];
        [self refreshWithDataMapOnly];
    } else {
        [self setupViews:dataModel.useNativeMap];
        [self refreshWithDataPoiDetail];
    }
}

- (void)refreshWithDataMapOnly {
    FHDetailStaticMapCellModel *dataModel = (FHDetailStaticMapCellModel *) self.currentData;
    self.baiduPanoButton.hidden = !dataModel.baiduPanoramaUrl.length;
    if (!dataModel.useNativeMap) {
        if (!dataModel.staticImage || isEmptyString(dataModel.staticImage.url) || isEmptyString(dataModel.staticImage.latRatio) || isEmptyString(dataModel.staticImage.lngRatio)) {
            NSString *message = !dataModel.staticImage ? @"static_image_null" : @"bad_static_image";
            [self mapView:self.mapView loadFinished:NO message:message];
            return;
        }
        [self.mapView loadMap:dataModel.staticImage.url center:self.centerPoint latRatio:[dataModel.staticImage.latRatio floatValue] lngRatio:[dataModel.staticImage.lngRatio floatValue]];
    }
    [self addCenterAnnotationMapOnly:dataModel.useNativeMap];
}

- (void)refreshWithDataPoiDetail {
    FHDetailStaticMapCellModel *dataModel = (FHDetailStaticMapCellModel *) self.currentData;
    self.baiduPanoButton.hidden = !dataModel.baiduPanoramaUrl.length;
    if (!dataModel.useNativeMap) {
        if (!dataModel.staticImage || isEmptyString(dataModel.staticImage.url) || isEmptyString(dataModel.staticImage.latRatio) || isEmptyString(dataModel.staticImage.lngRatio)) {
            NSString *message = !dataModel.staticImage ? @"static_image_null" : @"bad_static_image";
            [self mapView:self.mapView loadFinished:NO message:message];
            return;
        }
        [self.mapView loadMap:dataModel.staticImage.url center:self.centerPoint latRatio:[dataModel.staticImage.latRatio floatValue] lngRatio:[dataModel.staticImage.lngRatio floatValue]];
    }

    if (dataModel.title.length > 0) {
        self.headerView.titleLabel.text = dataModel.title;
    }
    if ([self isPoiSearchDone:self.curCategory]) {
        [self showPoiResultInfo];
    } else {
        [self requestPoiInfo:self.centerPoint];
    }
}

- (void)clickFacilitiesTracker:(NSInteger)index {
    NSArray *facilities = @[@"traffic", @"shopping", @"hospital", @"education"];
    if (index >= 0 && index < facilities.count) {
        // click_facilities
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"element_type"] = [self elementTypeString:self.baseViewModel.houseType];
        tracerDic[@"click_position"] = facilities[index];
        [FHUserTracker writeEvent:@"click_facilities" params:tracerDic];
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

        requestPoi.keywords = [categoryName isEqualToString:@"交通"] ? @"公交地铁" : categoryName;
        requestPoi.location = [AMapGeoPoint locationWithLatitude:center.latitude longitude:center.longitude];
        requestPoi.requireExtension = YES;
        requestPoi.requireSubPOIs = NO;

        [self.searchApi AMapPOIAroundSearch:requestPoi];
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
    FHDetailStaticMapCellModel *dataModel = (FHDetailStaticMapCellModel *) self.currentData;
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
    if (dataModel.mapOnly) {
        [self setupViewMapOnly:dataModel.useNativeMap];
        [self refreshWithDataMapOnly];
    } else {
        [self setupViews:dataModel.useNativeMap];
        [self refreshWithDataPoiDetail];
    }
}

#pragma

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

            UIImageView *bottomArrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapsearch_annotation_arrow"]];
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
    NSString *category = [searchRequest.keywords isEqualToString:@"公交地铁"] ? @"交通" : searchRequest.keywords;

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
            [sectionTitleArray addObject:[NSString stringWithFormat:@"%@(%ld)", _nameArray[i], [self.countCategoryDict[_nameArray[i]] integerValue]]];
        } else {
            [sectionTitleArray addObject:[NSString stringWithFormat:@"%@(0)", _nameArray[i]]];
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

    FHDetailStaticMapCellModel *dataModel = (FHDetailStaticMapCellModel *) self.currentData;

    if (dataModel.useNativeMap) {
        [self takeSnapWith:category annotations:annotations];
    } else {
        [self.mapView removeAllAnnotations];
        [self.mapView addAnnotations:annotations];
    }
    //底部列表

    NSInteger poiCount = [self.countCategoryDict[category] integerValue];
    NSInteger height = poiCount > 0 ? (poiCount > 3 ? 3 : (poiCount == 0 ? 2 : poiCount)) * 35 : 20;
    self.locationList.frame = CGRectMake(0, self.mapMaskBtn.bottom + 20, MAIN_SCREEN_WIDTH, height);
    self.emptyInfoLabel.frame = self.locationList.bounds;
    self.mapMaskBtnLocation.frame = self.locationList.frame;
    CGFloat cellHeight = self.locationList.bottom;
    [UIView performWithoutAnimation:^{
        [dataModel.tableView beginUpdates];
        [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(cellHeight);
        }];
        [self.backView setNeedsUpdateConstraints];
        [dataModel.tableView endUpdates];
    }];

    self.emptyInfoLabel.text = [NSString stringWithFormat:@"附近没有%@信息", category];
    self.emptyInfoLabel.hidden = poiCount > 0;
    [self.locationList reloadData];
}

#pragma UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray<FHStaticMapAnnotation *> *annotations = self.poiAnnotations[self.curCategory];
    return annotations.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHDetailNearbyMapItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"item"];
    if (!cell) {
        cell = [[FHDetailNearbyMapItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"item"];
    }

    NSArray<FHStaticMapAnnotation *> *annotations = self.poiAnnotations[self.curCategory];
    FHStaticMapAnnotation *annotation = annotations[indexPath.row];

    MAMapPoint from = MAMapPointForCoordinate(self.centerPoint);
    NSString *stringName = @"暂无信息";
    if (!isEmptyString(annotation.title)) {
        stringName = annotation.title;
    }

    NSString *stringDistance = @"未知";
    if (annotation) {
        MAMapPoint to = MAMapPointForCoordinate(CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude));
        CLLocationDistance distance = MAMetersBetweenMapPoints(from, to);
        if (distance < 1000) {
            stringDistance = [NSString stringWithFormat:@"%d米", (int) distance];
        } else {
            stringDistance = [NSString stringWithFormat:@"%.1f公里", ((CGFloat) distance) / 1000.0];
        }
    }

    [cell updateText:stringName andDistance:stringDistance];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"table cell click!!!");
}

- (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]) {
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"map";
}

@end

