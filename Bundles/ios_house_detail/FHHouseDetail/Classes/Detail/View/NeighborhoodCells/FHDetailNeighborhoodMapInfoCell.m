//
//  FHDetailNeighborhoodMapInfoCell.m
//  FHHouseDetail
//
//  Created by 谢飞 on 2019/3/4.
//

#import "FHDetailNeighborhoodMapInfoCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHDetailHeaderView.h"
#import "FHExtendHotAreaButton.h"
#import "FHDetailFoldViewButton.h"
#import "UILabel+House.h"
#import "FHDetailBottomOpenAllView.h"
#import "FHDetailStarsCountView.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <MAMapKit/MAAnnotationView.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "UILabel+House.h"
#import "UIColor+Theme.h"
#import <FHEnvContext.h>
#import "HMDTTMonitor.h"
#import "FHDetailMapView.h"

@interface FHDetailNeighborhoodMapInfoCell ()<MAMapViewDelegate,FHDetailVCViewLifeCycleProtocol>

@property (nonatomic, strong)   UIImageView       *mapImageView;
@property (nonatomic, weak)     MAMapView       *mapView;
@property (nonatomic, assign)   CGFloat       mapHightScale;
@property (nonatomic, assign)   CLLocationCoordinate2D       centerPoint;
@property (nonatomic, strong)   MAPointAnnotation       *pointAnnotation;
@property (nonatomic, assign)  BOOL isFirstSnapshot;// 首次截屏
@property (nonatomic, assign)  BOOL mapMaskClicked;

@end

@implementation FHDetailNeighborhoodMapInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _isFirstSnapshot = YES;
    _mapMaskClicked = NO;
    _mapHightScale = 0.36;

    //
    self.mapView = [[FHDetailMapView sharedInstance] defaultMapViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160)];
    self.mapView.delegate = self;
    
    _mapImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160)];
    _mapImageView.backgroundColor = [UIColor themeGray7];
   
    self.mapImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.mapImageView];
    [self.mapImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
        make.height.mas_equalTo(160);
    }];
    
    CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, 160);
    __weak typeof(self) weakSelf = self;
    // 延时绘制地图
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf snapshotMap];
    });
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewClick)];
    [self.mapImageView addGestureRecognizer:tapGes];
    self.mapImageView.userInteractionEnabled = YES;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodMapInfoModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailNeighborhoodMapInfoModel *model = (FHDetailNeighborhoodMapInfoModel *)data;
    
    if (model.gaodeLat && model.gaodeLng) {
        [self setLocation:model.gaodeLat lng:model.gaodeLng];
    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"map";
}

- (void)setLocation:(NSString *)lat lng:(NSString *)lng
{
    double theLat = [lat doubleValue];
    double theLng = [lng doubleValue];
    self.centerPoint = CLLocationCoordinate2DMake(theLat, theLng);
    [self.mapView setCenterCoordinate:self.centerPoint animated:false];
    [self addUserAnnotation];
}

- (void)addUserAnnotation {
    [[FHDetailMapView sharedInstance] clearAnnotationDatas];
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = self.centerPoint;
    self.mapView.delegate = self;
    [self.mapView addAnnotation:pointAnnotation];
    self.pointAnnotation = pointAnnotation;
    __weak typeof(self) weakSelf = self;
    // 延时绘制地图
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf snapshotMap];
    });
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    NSString *pointResueseIdetifier = @"pointReuseIndetifier";
    MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointResueseIdetifier];
    if (annotationView == nil) {
        annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointResueseIdetifier];
    }
    annotationView.image = [UIImage imageNamed:@"detail_map_loc_annotation"];
    //设置中心点偏移，使得标注底部中间点成为经纬度对应点
    annotationView.centerOffset = CGPointMake(0, -18);
    return annotationView;
}

- (void)mapViewClick {
    
    self.mapMaskClicked = YES;
    
    NSMutableDictionary *infoDict = [NSMutableDictionary new];
    [infoDict setValue:@(self.centerPoint.latitude) forKey:@"latitude"];
    [infoDict setValue:@(self.centerPoint.longitude) forKey:@"longitude"];
    

    FHDetailNeighborhoodMapInfoModel *model = (FHDetailNeighborhoodMapInfoModel *)self.currentData;
    
    if (!self.centerPoint.latitude || !self.centerPoint.longitude) {
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:@"用户点击详情页地图进入地图页失败" forKey:@"desc"];
        [params setValue:@"经纬度缺失" forKey:@"reason"];
        [params setValue:model.houseId forKey:@"house_id"];
        [params setValue:model.houseType forKey:@"house_type"];
        [[HMDTTMonitor defaultManager] hmdTrackService:@"detail_map_location_failed" attributes:params];
    }
    
    if ([model isKindOfClass:[FHDetailNeighborhoodMapInfoModel class]]) {
        if (model.title.length > 0) {
            [infoDict setValue:model.title forKey:@"title"];
        }
        
        if (model.category.length > 0) {
            [infoDict setValue:model.category forKey:@"category"];
        }
    }
    
   
    
    NSMutableDictionary *tracer = [NSMutableDictionary dictionaryWithDictionary:self.baseViewModel.detailTracerDic];
    [tracer setValue:@"map" forKey:@"click_type"];
    [tracer setValue:@"house_info" forKey:@"element_from"];
    [tracer setObject:tracer[@"page_type"] forKey:@"enter_from"];
    [infoDict setValue:tracer forKey:@"tracer"];
    
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://fh_map_detail"] userInfo:info];
}

@end

// FHDetailNeighborhoodMapInfoModel
@implementation FHDetailNeighborhoodMapInfoModel


@end
