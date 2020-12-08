//
//  FHNeighborhoodDetailMapCollectionCell.m
//  FHHouseDetail
//
//  Created by 谢雷 on 2020/12/9.
//

#import "FHNeighborhoodDetailMapCollectionCell.h"
#import "FHEnvContext.h"
#import "FHDetailStaticMapCell.h"
#import "AMapSearchAPI.h"
#import "MAMapKit.h"
#import "FHDetailMapViewSnapService.h"
#import <ByteDanceKit/ByteDanceKit.h>
#import "HMDUserExceptionTracker.h"
#import <TTSettingsManager/TTSettingsManager.h>

@interface FHNeighborhoodDetailMapCollectionCell ()<AMapSearchDelegate, FHStaticMapDelegate, MAMapViewDelegate>

@property (nonatomic, strong) FHDetailStaticMap *mapView;
@property (nonatomic, strong) UIImageView *nativeMapImageView;
@property (nonatomic, strong) UIButton *mapMaskBtn;

@property (nonatomic, strong) UIStackView *categoryStackView;

@property (nonatomic, strong) UIButton *baiduPanoButton;

@property (nonatomic, assign) CLLocationCoordinate2D centerPoint;
@property (nonatomic, strong) AMapSearchAPI *searchApi;

@property (nonatomic, strong) NSArray *nameArray;
@property (nonatomic, strong) FHStaticMapAnnotation *centerAnnotation;

//+ (NSString *)keyWordConver:(NSString *)category;
//+ (NSString *)keyWordConverReverse:(NSString *)category;

@end

@implementation FHNeighborhoodDetailMapCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    return CGSizeMake(width, width/16.0*9.0);
}

- (NSString *)elementType {
    return @"map";
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.centerPoint = CLLocationCoordinate2DMake(39.98269504123264, 116.3078908962674);
        
        self.centerAnnotation = [[FHStaticMapAnnotation alloc] init];
        self.centerAnnotation.extra = @"center_annotation";
        
        self.nameArray = @[@"地铁", @"公交", @"教育", @"医疗", @"生活"];
        
        //初始化poi搜索器
        self.searchApi = [[AMapSearchAPI alloc] init];
        self.searchApi.delegate = self;
    }
    return self;
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
    if (self.baiduPanoramaBlock) {
        self.baiduPanoramaBlock();
    }
}

- (void)bindViewModel:(id)viewModel {
    [self refreshWithData:viewModel];
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHNeighborhoodDetailMapCellModel class]]) {
        return;
    }
    FHNeighborhoodDetailMapCellModel *dataModel = (FHNeighborhoodDetailMapCellModel *) data;
    if (self.currentData == data) {
        return;
    }
    self.currentData = data;
    
    self.centerPoint = CLLocationCoordinate2DMake([dataModel.gaodeLat floatValue], [dataModel.gaodeLng floatValue]);
    
    NSDictionary *fhSettings = [[TTSettingsManager sharedManager] settingForKey:@"kFHSettingsKey" defaultValue:@{} freeze:NO];
    dataModel.useNativeMap = [fhSettings btd_unsignedIntegerValueForKey:@"f_use_static_map"] == 0;
    
    [self cleanSubViews];
    [self setupViews:dataModel.useNativeMap];
    

    [self refreshWithDataPoiDetail];
}

- (void)cleanSubViews {
    
    [self.mapView removeFromSuperview];
    self.mapView = nil;
    
    [self.nativeMapImageView removeFromSuperview];
    self.nativeMapImageView = nil;
    
    [self.mapMaskBtn removeFromSuperview];
    self.mapMaskBtn = nil;
}

- (void)setupViews:(BOOL)useNativeMap {
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *layer = [[CAShapeLayer alloc]init];
    layer.frame = self.bounds;
    layer.path = maskPath.CGPath;
    self.layer.mask = layer;
    
    //初始化静态地图
    if (useNativeMap) {
        self.nativeMapImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        self.nativeMapImageView.image = [UIImage imageNamed:@"static_map_empty"];
        [self.contentView addSubview:self.nativeMapImageView];
        [self.nativeMapImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    } else {
        self.mapView = [FHDetailStaticMap mapWithFrame:self.contentView.bounds];
        self.mapView.backgroundColor = [UIColor colorWithHexStr:@"#ececec"];
        self.mapView.delegate = self;
        [self.contentView addSubview:self.mapView];
        [self.contentView sendSubviewToBack:self.mapView];
        [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
    }
    
    self.mapMaskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:self.mapMaskBtn];
    [self.mapMaskBtn setBackgroundColor:[UIColor clearColor]];
    [self.mapMaskBtn addTarget:self action:@selector(mapMaskBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.mapMaskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    if (!self.baiduPanoButton) {
        self.baiduPanoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.baiduPanoButton setImage:[UIImage imageNamed:@"baidu_panorama_entrance_icon"] forState:UIControlStateNormal];
        [self.baiduPanoButton addTarget:self action:@selector(baiduPanoButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.baiduPanoButton];
        [self.baiduPanoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40, 40));
            make.right.mas_equalTo(-23);
            make.bottom.mas_equalTo(-40);
        }];
    }
    
}

#pragma mark - Data
- (void)refreshWithDataPoiDetail {
    FHNeighborhoodDetailMapCellModel *dataModel = (FHNeighborhoodDetailMapCellModel *) self.currentData;
    
    self.baiduPanoButton.hidden = !dataModel.baiduPanoramaUrl.length;
    if (!dataModel.useNativeMap) {
        if (!dataModel.staticImage || isEmptyString(dataModel.staticImage.url) || isEmptyString(dataModel.staticImage.latRatio) || isEmptyString(dataModel.staticImage.lngRatio)) {
            NSString *message = !dataModel.staticImage ? @"static_image_null" : @"bad_static_image";
            [self mapView:self.mapView loadFinished:NO message:message];
            return;
        }
        [self.mapView loadMap:dataModel.staticImage.url center:self.centerPoint latRatio:[dataModel.staticImage.latRatio floatValue] lngRatio:[dataModel.staticImage.lngRatio floatValue]];
    }
    
    [self showPoiInfo];
//    if ([self isPoiSearchDone:self.curCategory]) {
//        [self showPoiResultInfo];
//    } else {
//        [self requestPoiInfo:self.centerPoint];
//    }
}

- (void)showPoiInfo {
    
    //地图标签
    NSMutableArray *annotations = [NSMutableArray array];
    //center
    self.centerAnnotation.coordinate = self.centerPoint;
    [annotations addObject:self.centerAnnotation];
    
    FHNeighborhoodDetailMapCellModel *dataModel = (FHNeighborhoodDetailMapCellModel *) self.currentData;
    
    if (dataModel.useNativeMap) {
        [self takeSnapWith:nil annotations:annotations];
    } else {
        [self.mapView removeAllAnnotations];
        [self.mapView addAnnotations:annotations];
    }
}

- (void)takeSnapWith:(NSString *)category annotations:(NSArray<id <MAAnnotation>> *)annotations {
    CGRect frame = self.contentView.bounds;
    WeakSelf;
    [[FHDetailMapViewSnapService sharedInstance] takeSnapWith:self.centerPoint frame:frame targetRect:frame annotations:annotations delegate:self block:^(FHDetailMapSnapTask *task, UIImage *image, BOOL success) {
        StrongSelf;
        if (!success) {
            //展示默认图
            self.nativeMapImageView.image = [UIImage imageNamed:@"static_map_empty"];
            return;
        }
    }];
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
    FHNeighborhoodDetailMapCellModel *dataModel = (FHNeighborhoodDetailMapCellModel *) self.currentData;
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


@end

@implementation FHNeighborhoodDetailMapCellModel

@end
