//
//  FHMapSearchViewController.m
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import "FHMapSearchViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "Bubble-Swift.h"
#import "TTNetworkManager.h"
#import "FHMapSearchTypes.h"
#import "FHNeighborhoodAnnotationView.h"
#import "FHDistrictAreaAnnotationView.h"
#import "FHHouseAnnotation.h"
#import "FHMapSearchViewModel.h"
#import "FHMapSearchViewModel.h"
#import <Masonry/Masonry.h>
#import "FHMapSearchTipView.h"

#define kTapDistrictZoomLevel  16

@interface FHMapSearchViewController ()

@property(nonatomic , strong) FHMapSearchConfigModel *configModel;
@property(nonatomic , strong) MAMapView *mapView;
@property(nonatomic , strong) FHMapSearchViewModel *viewModel;
@property(nonatomic , strong) UIView *filterPanel;
@property(nonatomic , strong) UIControl *filterBgControl;
@property(nonatomic , strong) HouseFilterViewModel* houseFilterViewModel;
@property(nonatomic , strong) FHMapSearchTipView *tipView;

@end

@implementation FHMapSearchViewController

-(instancetype)initWithConfigModel:(FHMapSearchConfigModel *)configModel
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.configModel = configModel;
    }
    return self;
}

-(MAMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MAMapView alloc]initWithFrame:self.view.bounds];
        _mapView.rotateEnabled = false;
        _mapView.showsUserLocation = true;
        _mapView.showsCompass = false;
        _mapView.showsIndoorMap = false;
        _mapView.showsIndoorMapControl = false;
        
        CLLocationCoordinate2D center = {_configModel.centerLatitude.floatValue,_configModel.centerLongitude.floatValue};
        if (center.latitude > 0 && center.longitude > 0) {
            [_mapView setCenterCoordinate:center];
        }
        if(_configModel.resizeLevel > 0){
            _mapView.zoomLevel = _configModel.resizeLevel;
        }else{
            _mapView.zoomLevel = 11;
        }
        _mapView.userTrackingMode = MAUserTrackingModeFollow;
        MAUserLocationRepresentation *representation = [[MAUserLocationRepresentation alloc] init];
        representation.showsAccuracyRing = YES;
        [_mapView updateUserLocationRepresentation:representation];
    }
    return _mapView;
}

-(FHMapSearchTipView *)tipView
{
    if (!_tipView) {
        _tipView = [[FHMapSearchTipView alloc]initWithFrame:CGRectZero];
    }
    return _tipView;
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showHouseList
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initNavbar
{
    UIImage *img = [UIImage imageNamed:@"icon-return"];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    img = [UIImage imageNamed:@"mapsearch_nav_list"];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(showHouseList)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *title = @"二手房";
    switch (self.configModel.houseType) {
            case HouseTypeNewHouse:{
                title = @"新房";
                break;
            }
            case HouseTypeRentHouse:{
                title = @"小区";
                break;
            }
            
        default:
            break;
    }
    self.title = title;
    [self initNavbar];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    MapFindHouseFilterFactory* factory = [[MapFindHouseFilterFactory alloc] init];
    self.houseFilterViewModel = [factory createFilterPanelViewModelWithHouseType: HouseTypeSecondHandHouse];
    self.filterBgControl = [[UIControl alloc] init];
    self.filterPanel = self.houseFilterViewModel.filterPanelView;
    self.filterBgControl = self.houseFilterViewModel.filterConditionPanel;
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.filterBgControl];
    [self.view addSubview:self.filterPanel];
    self.filterBgControl.hidden = YES;
    
    [self initConstraints];
    
    self.viewModel = [[FHMapSearchViewModel alloc]initWithConfigModel:_configModel];
    self.viewModel.viewController = self;
    _viewModel.mapView = _mapView;
    _viewModel.tipView = self.tipView;
    _mapView.delegate = _viewModel;    
    self.houseFilterViewModel.delegate = _viewModel;
    
}

-(void)initConstraints
{
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.bottom.right.mas_equalTo(self.view);
    }];
    [self.filterBgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.view);
        make.top.equalTo(self.filterPanel.mas_bottom);
    }];
    [self.filterPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(51);
    }];
}


@end
