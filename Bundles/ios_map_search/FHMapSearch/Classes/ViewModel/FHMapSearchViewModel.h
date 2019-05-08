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

@class FHMapSearchViewController;
//@protocol HouseFilterViewModelDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface FHMapSearchViewModel : NSObject <MAMapViewDelegate, FHConditionFilterViewModelDelegate>

@property(nonatomic , weak) FHMapSearchViewController *viewController;
@property(nonatomic , strong) MAMapView *mapView;
@property(nonatomic , strong) FHMapSearchTipView *tipView;
@property(nonatomic , copy , readonly) NSString *navTitle;
@property(nonatomic , assign) FHMapSearchShowMode showMode;
@property(nonatomic , copy)  NSString *filterConditionParams;
@property(nonatomic , copy) void (^resetConditionBlock)(NSDictionary *condition);
@property(nonatomic , copy) NSString *_Nullable (^conditionNoneFilterBlock)(NSDictionary *params);//获取非过滤器显示的过滤条件

-(instancetype)initWithConfigModel:(FHMapSearchConfigModel *)configModel viewController:(FHMapSearchViewController *)viewController;

-(FHMapSearchConfigModel *)configModel;

-(void)showMap;

-(void)dismissHouseListView;

-(void)viewWillAppear:(BOOL)animated;
-(void)viewWillDisappear:(BOOL)animated;

-(void)addEnterMapLog;
-(void)addNavSwitchHouseListLog;

-(void)moveToUserLocation;

//-(BOOL)conditionChanged;

-(NSString *)backHouseListOpenUrl;

-(void)showMapUserLocationLayer;

@end

NS_ASSUME_NONNULL_END
