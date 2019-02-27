//
//  FHDetailNeighborhoodInfoCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/19.
//

#import "FHDetailNeighborhoodInfoCell.h"
#import <Masonry.h>
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
#import "FHSingleImageInfoCell.h"
#import "FHSingleImageInfoCellModel.h"
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

@interface FHDetailNeighborhoodInfoCell ()<MAMapViewDelegate, AMapSearchDelegate >

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, assign)   CGFloat       mapHightScale;

@property (nonatomic, strong)   UILabel       *nameKey;
@property (nonatomic, strong)   UILabel       *nameValue;
@property (nonatomic, strong)   MAPointAnnotation       *pointAnnotation;
@property (nonatomic, strong)   UILabel       *schoolKey;
@property (nonatomic, strong)   UILabel       *schoolLabel;
@property (nonatomic, strong)   UIImageView       *mapImageView;
@property (nonatomic, strong)   UIImageView       *mapAnnotionImageView;
@property (nonatomic, strong)   MAMapView       *mapView;
@property (nonatomic, strong)   UIView       *bgView;
@property (nonatomic, strong)   UILabel       *evaluateLabel;
@property (nonatomic, strong)   UIImageView       *rightArrow;
@property (nonatomic, strong)   FHDetailStarsCountView       *starsContainer;
@property (nonatomic, strong)   UITapGestureRecognizer       *mapViewGesture;

@property (nonatomic, assign)   CLLocationCoordinate2D       centerPoint;

@end

@implementation FHDetailNeighborhoodInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = self.centerPoint;
    [self.mapView addAnnotation:pointAnnotation];
    self.pointAnnotation = pointAnnotation;
    [self snapshotMap];
}

- (void)snapshotMap {
    UIView *annotionView = [self.mapView viewForAnnotation:self.pointAnnotation];
    UIView *superAnnotionView = annotionView.superview;
    if (superAnnotionView) {
        self.mapAnnotionImageView.image = [self getImageFromView:superAnnotionView];
    } else {
        self.mapAnnotionImageView.image = nil;
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

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodInfoModel class]]) {
        return;
    }
    self.currentData = data;
    //
    FHDetailNeighborhoodInfoModel *model = (FHDetailNeighborhoodInfoModel *)data;
    // 二手房
    if (model.neighborhoodInfo) {
        [self updateErshouCellData];
    }
    // 租房
    if (model.rent_neighborhoodInfo) {
        [self updateRentCellData];
    }
    [self layoutIfNeeded];
}

// 小区信息
- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"neighborhood_detail";
}

- (void)updateRentCellData {
    FHDetailNeighborhoodInfoModel *model = (FHDetailNeighborhoodInfoModel *)self.currentData;
    if (model) {
        NSString *headerName = [NSString stringWithFormat:@"小区 %@",model.rent_neighborhoodInfo.name];
        self.headerView.label.text = headerName;
        NSString *districtName = model.rent_neighborhoodInfo.districtName;
        self.nameValue.text = districtName;
        FHRentDetailResponseDataEvaluationInfo *evaluationInfo = model.rent_neighborhoodInfo.evaluationInfo;
        if (evaluationInfo) {
            self.starsContainer.hidden = NO;
            [self.starsContainer updateStarsCount:evaluationInfo.totalScore];
            [self.starsContainer mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(50);
            }];
            [self.nameKey mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(20);
                make.top.mas_equalTo(self.starsContainer.mas_bottom);
                make.height.mas_equalTo(20);
            }];
        } else {
            [self.starsContainer mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            self.starsContainer.hidden = YES;
            [self.nameKey mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(20);
                make.top.mas_equalTo(self.headerView.mas_bottom).offset(10);
                make.height.mas_equalTo(20);
            }];
        }
        
        if (evaluationInfo.detailUrl.length > 0) {
            self.bgView.hidden = NO;
        } else {
            self.bgView.hidden = YES;
        }
        
        NSString *lat = model.rent_neighborhoodInfo.gaodeLat;
        NSString *lng = model.rent_neighborhoodInfo.gaodeLng;
        if (lat.length > 0 && lng.length > 0) {
            [self setLocation:lat lng:lng];
        }
        NSString *schoolName = model.rent_neighborhoodInfo.schoolInfo.schoolName;
        if (schoolName.length) {
            self.schoolLabel.text = schoolName;
            [self schoolLabelIsHidden:NO];
        } else {
            [self schoolLabelIsHidden:YES];
        }
    }
}

// 二手房
- (void)updateErshouCellData {
    FHDetailNeighborhoodInfoModel *model = (FHDetailNeighborhoodInfoModel *)self.currentData;
    if (model) {
        NSString *headerName = [NSString stringWithFormat:@"小区 %@",model.neighborhoodInfo.name];
        self.headerView.label.text = headerName;
        NSString *areaName = model.neighborhoodInfo.areaName;
        NSString *districtName = model.neighborhoodInfo.districtName;
        if (areaName.length > 0 && districtName.length > 0) {
            self.nameValue.text = [NSString stringWithFormat:@"%@-%@",districtName,areaName];
        } else {
            self.nameValue.text = districtName;
        }
        self.bgView.hidden = model.neighborhoodInfo.evaluationInfo.detailUrl.length > 0 ? NO : YES;
        NSString *lat = model.neighborhoodInfo.gaodeLat;
        NSString *lng = model.neighborhoodInfo.gaodeLng;
        if (lat.length > 0 && lng.length > 0) {
            [self setLocation:lat lng:lng];
            FHDetailOldDataNeighborhoodInfoEvaluationInfoModel *evaluationInfo = model.neighborhoodInfo.evaluationInfo;
            if (evaluationInfo) {
                self.starsContainer.hidden = NO;
                [self.starsContainer updateStarsCount:[evaluationInfo.totalScore integerValue]];
                NSInteger scoreValue = [evaluationInfo.totalScore integerValue];
                if (scoreValue > 0) {
                    [self.starsContainer mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(50);
                    }];
                    self.starsContainer.hidden = NO;
                } else {
                    [self.starsContainer mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(0);
                    }];
                    self.starsContainer.hidden = YES;
                }
                if (evaluationInfo.detailUrl.length > 0) {
                    self.bgView.hidden = NO;
                } else {
                    self.bgView.hidden = YES;
                }
            } else {
                [self.starsContainer mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(0);
                }];
                self.starsContainer.hidden = YES;
            }
        }
        if (model.neighborhoodInfo.schoolInfo.count > 0) {
            FHDetailOldDataNeighborhoodInfoSchoolInfoModel *schoolInfo = model.neighborhoodInfo.schoolInfo[0];
            self.schoolLabel.text = schoolInfo.schoolName;
            [self.schoolLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(20);
            }];
            [self.schoolKey mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(20);
            }];
            [self.mapImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.schoolKey.mas_bottom).offset(20);
            }];
            self.schoolKey.hidden = NO;
            self.schoolLabel.hidden = NO;
        } else {
            [self.schoolLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            [self.schoolKey mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            [self.mapImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.schoolKey.mas_bottom).offset(10);
            }];
            self.schoolKey.hidden = YES;
            self.schoolLabel.hidden = YES;
        }
    }
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
    _mapHightScale = 0.36;
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"小区 ";
    _headerView.isShowLoadMore = YES; // 点击可以跳转小区详情
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(46);
    }];
    [self.headerView addTarget:self  action:@selector(gotoNeighborhood) forControlEvents:UIControlEventTouchUpInside];
    //
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    self.mapView.runLoopMode = NSDefaultRunLoopMode;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomLevel = 14;
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = self;
    
    // starsContainer
    _starsContainer = [[FHDetailStarsCountView alloc] init];
    [self.contentView addSubview:_starsContainer];
    
    _nameKey = [UILabel createLabel:@"所属区域" textColor:@"#a1aab3" fontSize:15];
    _nameValue = [UILabel createLabel:@"" textColor:@"#081f33" fontSize:14];
    _schoolKey = [UILabel createLabel:@"教育资源" textColor:@"#a1aab3" fontSize:15];
    _schoolLabel = [UILabel createLabel:@"" textColor:@"#081f33" fontSize:14];
    _mapImageView = [[UIImageView alloc] init];
    _mapImageView.backgroundColor = [UIColor colorWithHexString:@"#f4f5f6"];
    _mapAnnotionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.5];
    _evaluateLabel = [UILabel createLabel:@"小区测评" textColor:@"#ffffff" fontSize:14];
    _rightArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon-feed-white"]];
    _mapViewGesture = [[UITapGestureRecognizer alloc] init];
    //
    [self.starsContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(10);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(50);
    }];
    [self.contentView addSubview:_nameKey];
    [self.nameKey mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.starsContainer.mas_bottom);
        make.height.mas_equalTo(20);
    }];
    [self.contentView addSubview:self.nameValue];
    [self.nameValue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameKey.mas_right).offset(12);
        make.top.mas_equalTo(self.nameKey);
        make.height.mas_equalTo(20);
    }];
    [self.contentView addSubview:_schoolKey];
    [self.schoolKey mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameKey);
        make.top.mas_equalTo(self.nameKey.mas_bottom).offset(10);
        make.height.mas_equalTo(20);
    }];
    [self.contentView addSubview:self.schoolLabel];
    [self.schoolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.schoolKey.mas_right).offset(12);
        make.top.mas_equalTo(self.schoolKey);
        make.height.mas_equalTo(20);
    }];
    self.mapImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.mapImageView];
    [self.mapImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(SCREEN_WIDTH * self.mapHightScale);
        make.top.mas_equalTo(self.schoolKey.mas_bottom).offset(20);
    }];
    self.mapAnnotionImageView.backgroundColor = UIColor.clearColor;
    [self.mapImageView addSubview:self.mapAnnotionImageView];
    
    CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * self.mapHightScale);
    __weak typeof(self) weakSelf = self;
    [self.mapView takeSnapshotInRect:frame withCompletionBlock:^(UIImage *resultImage, NSInteger state) {
        weakSelf.mapImageView.image = resultImage;
    }];
    
    [self.contentView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.mapImageView);
        make.height.mas_equalTo(40);
    }];
    
    [self.bgView addSubview:self.evaluateLabel];
    [self.evaluateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.bgView);
        make.left.mas_equalTo(20);
    }];
    [self.bgView addSubview:self.rightArrow];
    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-13);
        make.centerY.mas_equalTo(self.evaluateLabel);
    }];
    
    UITapGestureRecognizer *evaluateGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(evaluateTapEvent)];
    [self.bgView addGestureRecognizer:evaluateGest];
    self.bgView.userInteractionEnabled = YES;
    
    self.mapViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewClick)];
    [self.mapImageView addGestureRecognizer:self.mapViewGesture];
    self.mapImageView.userInteractionEnabled = YES;
}

- (NSString *)getEvaluateWebParams:(NSDictionary *)dic {
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONReadingAllowFragments error:&error];
    if (data && !error) {
        NSString *temp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        temp = [temp stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        return temp;
    }
    return nil;
}

// 小区测评
- (void)evaluateTapEvent {
    FHDetailNeighborhoodInfoModel *model = (FHDetailNeighborhoodInfoModel *)self.currentData;
    if (model) {
        NSString *enter_from = @"old_detail";
        NSString *neighborhood_id = @"0";
        NSString *urlStr = @"";
        if (model.neighborhoodInfo) {
            // 二手房
            enter_from = @"old_detail";
            neighborhood_id = model.neighborhoodInfo.id;
            urlStr = model.neighborhoodInfo.evaluationInfo.detailUrl;
        }
        if (model.rent_neighborhoodInfo) {
            // 租房
            enter_from = @"rent_detail";
            neighborhood_id = model.rent_neighborhoodInfo.id;
            urlStr = model.rent_neighborhoodInfo.evaluationInfo.detailUrl;
        }
        if (urlStr.length > 0) {
            NSMutableDictionary *tracerDic = [NSMutableDictionary new];
            NSDictionary *temp = [self.baseViewModel.detailTracerDic dictionaryWithValuesForKeys:@[@"origin_from",@"origin_search_id"]];
            [tracerDic addEntriesFromDictionary:temp];
            tracerDic[@"enter_from"] = enter_from;
            if (self.baseViewModel.listLogPB) {
                tracerDic[@"log_pb"] = self.baseViewModel.listLogPB;
            }
            [FHUserTracker writeEvent:@"enter_neighborhood_evaluation" params:tracerDic];
            //
            NSString *reportParams = [self getEvaluateWebParams:tracerDic];
            NSString *jumpUrl = @"sslocal://webview";
            NSString *openUrl = [NSString stringWithFormat:@"%@&report_params=%@",urlStr,reportParams];
            
            TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:@{@"title":@"小区评测",@"url":openUrl}];
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:jumpUrl] userInfo:info];
        }
    }
}

- (void)mapViewClick {
    NSMutableDictionary *infoDict = [NSMutableDictionary new];
    [infoDict setValue:@"公交" forKey:@"category"];
    [infoDict setValue:@(self.centerPoint.latitude) forKey:@"latitude"];
    [infoDict setValue:@(self.centerPoint.longitude) forKey:@"longitude"];
    
    NSMutableDictionary *tracer = [NSMutableDictionary dictionaryWithDictionary:self.baseViewModel.detailTracerDic];
    [tracer setValue:@"map" forKey:@"click_type"];
    [tracer setValue:@"house_info" forKey:@"element_from"];
    [tracer setObject:tracer[@"page_type"] forKey:@"enter_from"];
    [infoDict setValue:tracer forKey:@"tracer"];
    
    TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://fh_map_detail"] userInfo:info];
}

// 跳转小区
- (void)gotoNeighborhood {
    FHDetailNeighborhoodInfoModel *model = (FHDetailNeighborhoodInfoModel *)self.currentData;
    if (model) {
        NSString *enter_from = @"be_null";
        NSString *neighborhood_id = @"0";
        NSString *source = @"";
        if (model.neighborhoodInfo) {
            // 二手房
            enter_from = @"old_detail";
            neighborhood_id = model.neighborhoodInfo.id;
            source = @"";
        }
        if (model.rent_neighborhoodInfo) {
            // 租房
            enter_from = @"rent_detail";
            neighborhood_id = model.rent_neighborhoodInfo.id;
            source = @"rent_detail";
        }
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"card_type"] = @"no_pic";
        tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:self.baseViewModel.houseType];
        tracerDic[@"element_from"] = @"neighborhood_detail";
        tracerDic[@"enter_from"] = enter_from;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDic,@"house_type":@(FHHouseTypeNeighborhood),@"source":source}];
        NSString * urlStr = [NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@",neighborhood_id];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

- (void)schoolLabelIsHidden:(BOOL)isHidden {
    self.schoolKey.hidden = isHidden;
    self.schoolLabel.hidden = isHidden;
    if (isHidden) {
        [self.mapImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(self.contentView);
            make.height.mas_equalTo(SCREEN_WIDTH * self.mapHightScale);
            make.top.mas_equalTo(self.nameKey.mas_bottom).offset(20);
        }];
    } else {
        [self.mapImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(self.contentView);
            make.height.mas_equalTo(SCREEN_WIDTH * self.mapHightScale);
            make.top.mas_equalTo(self.schoolKey.mas_bottom).offset(20);
        }];
    }
}

#pragma MapViewDelegata

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    NSString *pointResueseIdetifier = @"pointReuseIndetifier";
    MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointResueseIdetifier];
    if (annotationView == nil) {
        annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointResueseIdetifier];
    }
    annotationView.image = [UIImage imageNamed:@"icon-location"];
    //设置中心点偏移，使得标注底部中间点成为经纬度对应点
    annotationView.centerOffset = CGPointMake(0, -18);
    return annotationView;
}

@end

// FHDetailNeighborhoodInfoModel
@implementation FHDetailNeighborhoodInfoModel


@end
