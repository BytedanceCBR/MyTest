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

@class FHMapSearchViewController;
@protocol HouseFilterViewModelDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface FHMapSearchViewModel : NSObject <MAMapViewDelegate,HouseFilterViewModelDelegate>

@property(nonatomic , weak) FHMapSearchViewController *viewController;
@property(nonatomic , strong) MAMapView *mapView;
@property(nonatomic , strong) FHMapSearchTipView *tipView;
@property(nonatomic , copy , readonly) NSString *navTitle;
@property(nonatomic , assign) FHMapSearchShowMode showMode;
@property(nonatomic , copy)  NSString *filterConditionParams;

-(instancetype)initWithConfigModel:(FHMapSearchConfigModel *)configModel mapView:(MAMapView *)mapView;

-(void)requestHouses;

-(void)showMap;

-(void)dismissHouseListView;

-(void)viewWillAppear:(BOOL)animated;
-(void)viewWillDisappear:(BOOL)animated;

-(void)addEnterMapLog;
-(void)addNavSwitchHouseListLog;

@end

NS_ASSUME_NONNULL_END
