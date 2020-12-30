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
#import "MAMapView.h"
#import "FHCommonDefines.h"
#import "MAAnnotation.h"
#import "MAMapKit.h"
#import "FHDetailMapViewSnapService.h"
#import <ByteDanceKit/ByteDanceKit.h>
#import "HMDUserExceptionTracker.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import <FHHouseBase/NSObject+FHOptimize.h>

@interface FHNeighborhoodDetailMapCollectionCell ()<AMapSearchDelegate, FHStaticMapDelegate, MAMapViewDelegate>

//@property (nonatomic, strong) FHDetailStaticMap *mapView;
@property(nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) UIImageView *nativeMapImageView;
@property (nonatomic, strong) UIButton *mapMaskBtn;

@property (nonatomic, strong) UIView *categoryContentView;
@property (nonatomic, strong) UIStackView *categoryStackView;

@property (nonatomic, strong) UIButton *baiduPanoButton;

@property (nonatomic, assign) CLLocationCoordinate2D centerPoint;
//@property (nonatomic, strong) AMapSearchAPI *searchApi;

//@property (nonatomic, strong) NSArray *nameArray;
@property (nonatomic, strong) FHStaticMapAnnotation *centerAnnotation;

@end

@implementation FHNeighborhoodDetailMapCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    return CGSizeMake(width, ceil(width/16.0*9.0));
}

- (NSString *)elementType {
    return @"map";
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.centerPoint = CLLocationCoordinate2DMake(39.98269504123264, 116.3078908962674);
        
        self.centerAnnotation = [[FHStaticMapAnnotation alloc] init];
        self.centerAnnotation.extra = @"center_annotation";
        
//        self.nameArray = @[@"地铁", @"公交", @"教育", @"医疗", @"生活"];
        
        //初始化poi搜索器
//        self.searchApi = [[AMapSearchAPI alloc] init];
//        self.searchApi.delegate = self;
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
    self.centerAnnotation.title = dataModel.mapCentertitle;
        
    [self cleanSubViews];
    [self setupViews];
    [self refreshWithDataPoiDetail];
}

- (void)cleanSubViews {
    
//    [self.mapView removeFromSuperview];
//    self.mapView = nil;
    
    [self.nativeMapImageView removeFromSuperview];
    self.nativeMapImageView = nil;
    
    [self.mapMaskBtn removeFromSuperview];
    self.mapMaskBtn = nil;
}

- (void)setupViews {
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *layer = [[CAShapeLayer alloc]init];
    layer.frame = self.bounds;
    layer.path = maskPath.CGPath;
    self.layer.mask = layer;
    
//    self.mapView = [FHDetailStaticMap mapWithFrame:self.contentView.bounds];
//    self.mapView.backgroundColor = [UIColor colorWithHexStr:@"#ececec"];
//    self.mapView.delegate = self;
//    [self.contentView addSubview:self.mapView];
//    [self.contentView sendSubviewToBack:self.mapView];
//    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(UIEdgeInsetsZero);
//    }];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.contentView.bounds];
    self.mapView.runLoopMode = NSDefaultRunLoopMode;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomLevel = 14.5;
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = self;
    self.mapView.hidden = NO;
    [self.contentView addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    //初始化静态地图
    self.nativeMapImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.nativeMapImageView.image = [UIImage imageNamed:@"map_detail_default_bg"];
    self.nativeMapImageView.hidden = YES;
    [self.contentView addSubview:self.nativeMapImageView];
    [self.nativeMapImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    self.mapMaskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:self.mapMaskBtn];
    [self.mapMaskBtn setBackgroundColor:[UIColor clearColor]];
    [self.mapMaskBtn addTarget:self action:@selector(mapMaskBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.mapMaskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
//    if (!self.baiduPanoButton) {
//        self.baiduPanoButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self.baiduPanoButton setImage:[UIImage imageNamed:@"baidu_panorama_entrance_icon"] forState:UIControlStateNormal];
//        [self.baiduPanoButton addTarget:self action:@selector(baiduPanoButtonAction) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:self.baiduPanoButton];
//        [self.baiduPanoButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(CGSizeMake(40, 40));
//            make.right.mas_equalTo(-23);
//            make.bottom.mas_equalTo(-40);
//        }];
//    }
    if (!self.categoryStackView) {
        self.categoryContentView = [[UIView alloc] init];
        self.categoryContentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.96];
        self.categoryContentView.layer.masksToBounds = YES;
        self.categoryContentView.layer.cornerRadius = 4.0;
        [self.contentView addSubview:self.categoryContentView];
        [self.categoryContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.right.mas_equalTo(-12);
            make.bottom.mas_equalTo(-12);
            make.height.mas_equalTo(40);
        }];
        
        self.categoryStackView = [[UIStackView alloc] init];
        self.categoryStackView.axis = UILayoutConstraintAxisHorizontal;
        [self.categoryContentView addSubview:self.categoryStackView];
        [self.categoryStackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
        [self.categoryStackView addArrangedSubview:[self itemViewWithName:@"交通" icon:@"detail_map_v3_sub_icon"]];
        [self.categoryStackView addArrangedSubview:[self itemViewWithName:@"教育" icon:@"detail_map_v3_jiaoyu_icon"]];
        [self.categoryStackView addArrangedSubview:[self itemViewWithName:@"医疗" icon:@"detail_map_v3_hospital_icon"]];
        [self.categoryStackView addArrangedSubview:[self itemViewWithName:@"生活" icon:@"detail_map_v3_eat_icon"]];
        [self.categoryStackView addArrangedSubview:[self itemViewWithName:@"休闲" icon:@"detail_map_v3_play_icon"]];
    }
    [self.contentView bringSubviewToFront:self.categoryContentView];
    
}

- (UIControl *)itemViewWithName:(NSString *)name icon:(NSString *)icon {
    UIControl *itemView = [[UIControl alloc] init];
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    [itemView addSubview:iconImageView];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(itemView).mas_offset(-14);
        make.centerY.mas_equalTo(itemView);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.textColor = [UIColor themeGray1];
    nameLabel.font = [UIFont themeFontRegular:14];
    nameLabel.text = name;
    [itemView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(iconImageView.mas_right).mas_offset(4);
        make.centerY.mas_equalTo(itemView);
    }];
    
    __weak typeof(self) weakSelf = self;
    [itemView btd_addActionBlock:^(__kindof UIControl * _Nonnull sender) {
        if (weakSelf.categoryClickBlock) {
            weakSelf.categoryClickBlock(name);
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat itemWidth = 0;
    if (self.contentView.bounds.size.width > 0) {
        itemWidth = floor((CGRectGetWidth(self.contentView.bounds) - 12 * 2) * 0.2);
    }
    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.categoryStackView.mas_height);
        if (itemWidth > 0) {
            make.width.mas_equalTo(itemWidth);
        } else {
            make.width.mas_equalTo(self.categoryStackView.mas_width).multipliedBy(0.2);
        }
    }];
    
    return itemView;
}

#pragma mark - Data
- (void)refreshWithDataPoiDetail {
    FHNeighborhoodDetailMapCellModel *dataModel = (FHNeighborhoodDetailMapCellModel *) self.currentData;
    
    //地图标签
    NSMutableArray *annotations = [NSMutableArray array];
    //center
    self.centerAnnotation.coordinate = self.centerPoint;
    [annotations addObject:self.centerAnnotation];
    
    self.baiduPanoButton.hidden = !dataModel.baiduPanoramaUrl.length;
    
//    [self.mapView loadMap:nil center:self.centerPoint latRatio:[dataModel.staticImage.latRatio floatValue] lngRatio:[dataModel.staticImage.lngRatio floatValue]];

    self.mapView.centerCoordinate = self.centerPoint;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:annotations];
}

- (void)showPoiInfo {
    

    
//    FHNeighborhoodDetailMapCellModel *dataModel = (FHNeighborhoodDetailMapCellModel *) self.currentData;
//    [self.mapView removeAllAnnotations];
//    [self.mapView addAnnotations:annotations];

    
}

- (void)takeSnapWith:(NSString *)category annotations:(NSArray<id <MAAnnotation>> *)annotations {
//    CGRect frame = self.contentView.bounds;

//    [self.mapView takeSnapshotInRect:frame withCompletionBlock:^(UIImage *resultImage, NSInteger state) {
//        if (state == 1) {
//
//        }
//
//    }];
//    WeakSelf;
//    [[FHDetailMapViewSnapService sharedInstance] takeSnapWith:self.centerPoint frame:frame targetRect:frame annotations:annotations delegate:self block:^(FHDetailMapSnapTask *task, UIImage *image, BOOL success) {
//        StrongSelf;
//        if (!success) {
//            //展示默认图
//            self.nativeMapImageView.image = [UIImage imageNamed:@"map_detail_default_bg"];
//        } else {
//            self.nativeMapImageView.image = image;
//        }
////        [self showPoiInfo];
//    }];
}

#pragma FHStaticMapDelegate

- (FHStaticMapAnnotationView *)mapView:(FHDetailStaticMap *)mapView viewForStaticMapAnnotation:(FHStaticMapAnnotation *)annotation {
    if ([annotation.extra isEqualToString:@"center_annotation"]) {
        NSString *reuseIdentifier = @"center_annotation";
        FHDetailStaticMapNeighborhoodPOIAnnotationView *annotationView = (FHDetailStaticMapNeighborhoodPOIAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        if (!annotationView) {
            annotationView = [[FHDetailStaticMapNeighborhoodPOIAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        }
        
        UILabel *titleLabel = annotationView.titleLabel;
        titleLabel.frame = CGRectMake(0, 0, titleLabel.text.length * 13, 12);
        titleLabel.text = annotation.title;
        
        CGSize size = CGSizeMake([titleLabel btd_widthWithHeight:12], 34 + 12);
        annotationView.imageView.frame = CGRectMake(size.width / 2 - 17 , 0, 34, 34);
        
        [titleLabel sizeToFit];
        titleLabel.center = CGPointMake(size.width / 2, size.height - titleLabel.frame.size.height / 2);
        
        annotationView.annotationSize = size;
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
    
    [self cleanSubViews];
    [self setupViews];
    [self refreshWithDataPoiDetail];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[FHStaticMapAnnotation class]]) {
        FHStaticMapAnnotation *staticMapAnnotation = (FHStaticMapAnnotation *) annotation;
        if ([staticMapAnnotation.extra isEqualToString:@"center_annotation"]) {
            NSString *reuseIdentifier = @"center_annotation";
            MAAnnotationView *annotationView = (MAAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
            if (!annotationView) {
                annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
            }

//            UIView *contentView = [[UIView alloc] init];
//            contentView.backgroundColor = [UIColor clearColor];
//            contentView.opaque = NO;
//
//            UIImageView *imageView = [[UIImageView alloc] init];
//            imageView.image = [UIImage imageNamed:@"detail_map_neighbor_annotation"];
//            imageView.contentMode = UIViewContentModeCenter;
//            [contentView addSubview:imageView];
//
//            UILabel *titleLabel = [[UILabel alloc] init];
//            titleLabel.font = [UIFont themeFontMedium:12];
//            titleLabel.textColor = [UIColor themeGray1];
//            titleLabel.numberOfLines = 1;
//            titleLabel.textAlignment = NSTextAlignmentCenter;
//            titleLabel.text = annotation.title;
//            [contentView addSubview:titleLabel];
//            [titleLabel sizeToFit];
//
//            CGSize size = CGSizeMake([titleLabel btd_widthWithHeight:12], 34 + 12);
//            contentView.frame = CGRectMake(0, 0, size.width, size.height);
//            imageView.frame = CGRectMake(size.width / 2 - 17 , 0, 34, 34);
//            titleLabel.center = CGPointMake(size.width / 2, size.height - titleLabel.frame.size.height / 2);

            annotationView.image = [UIImage imageNamed:@"detail_map_neighbor_annotation"];
            annotationView.centerOffset = CGPointMake(0, 0);
            return annotationView;
        }
    }
    return [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"default"];
}

- (void)updateStaticImage:(UIImage *)image {
//    self.nativeMapImageView.image = [UIImage imageNamed:@"map_detail_default_bg"];
    self.nativeMapImageView.hidden = NO;
    self.nativeMapImageView.image = image;
    self.mapView.delegate = nil;
    [self.mapView removeFromSuperview];
    self.mapView = nil;
}

- (void)startSnapMap {
    __weak typeof(self) weakSelf = self;
    [self.mapView takeSnapshotInRect:self.contentView.bounds withCompletionBlock:^(UIImage *resultImage, NSInteger state) {
        if (state == 1 && resultImage) {
            //完整截图
            [weakSelf updateStaticImage:resultImage];
        }
    }];
}

- (void)mapViewDidFinishLoadingMap:(MAMapView *)mapView {
    NSLog(@"mapViewDidFinishLoadingMap");
    [self startSnapMap];
}

@end

@implementation FHNeighborhoodDetailMapCellModel

@end