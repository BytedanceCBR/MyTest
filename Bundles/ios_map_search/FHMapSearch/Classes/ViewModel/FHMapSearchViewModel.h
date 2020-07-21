//
//  FHMapSearchViewModel.h
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>
#import "FHMapSearchConfigModel.h"
#import "FHMapSearchTipView.h"
#import "FHMapSearchShowMode.h"
#import "FHConditionPanelNodeSelection.h"
#import "FHConditionFilterViewModel.h"
#import "FHMapSearchBottomBar.h"
#import "FHMapSearchWayChooseView.h"
#import "FHMapSearchInfoTopBar.h"
#import "FHMapSearchSideBar.h"
@class FHMapSimpleNavbar;
@class FHMapSearchViewController;
@class FHMapDrawMaskView;

//@protocol HouseFilterViewModelDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface FHMapSearchViewModel : NSObject <MAMapViewDelegate, FHConditionFilterViewModelDelegate,FHMapSearchBottomBarDelegate>

@property(nonatomic , weak) FHMapSearchViewController *viewController;
@property(nonatomic , strong) MAMapView *mapView;
@property(nonatomic , strong) FHMapSearchTipView *tipView;
@property(nonatomic , copy , readonly) NSString *navTitle;
@property(nonatomic , assign) FHMapSearchShowMode showMode;
@property(nonatomic , strong) FHMapSearchBottomBar *bottomBar;
@property(nonatomic , strong) FHMapSearchWayChooseView *chooseView;
@property(nonatomic , strong) FHMapDrawMaskView *drawMaskView;
@property(nonatomic , strong) FHMapSearchInfoTopBar *topInfoBar;
@property(nonatomic , strong) FHMapSearchSideBar *sideBar;
@property(nonatomic , copy)  NSString *filterConditionParams;
@property(nonatomic , copy) void (^resetConditionBlock)(NSDictionary *condition);
@property(nonatomic , copy) NSString *_Nullable (^conditionNoneFilterBlock)(NSDictionary *params);//获取非过滤器显示的过滤条件
@property(nonatomic , copy) NSString *_Nullable (^getFilterConditionBlock)();
@property(nonatomic , weak) FHMapSimpleNavbar *simpleNavBar;

-(instancetype)initWithConfigModel:(FHMapSearchConfigModel *)configModel viewController:(FHMapSearchViewController *)viewController;

-(FHMapSearchConfigModel *)configModel;

-(void)showMap;

-(void)dismissHouseListView;

-(void)viewWillAppear:(BOOL)animated;
-(void)viewWillDisappear:(BOOL)animated;

-(void)addEnterMapLog;

-(void)moveToUserLocation;

//-(BOOL)conditionChanged;

-(NSString *)backHouseListOpenUrl;

-(void)showMapUserLocationLayer;

//当前城市是否有地铁
-(BOOL)suportSubway;

//退出当前模式
-(void)exitCurrentMode;

-(void)tryUpdateSideBar;

//附近或区域列表页
-(void)hideAreaHouseList;

-(void)showFilterForAreaHouseList;

-(void)reDrawMapCircle;

@end

NS_ASSUME_NONNULL_END
