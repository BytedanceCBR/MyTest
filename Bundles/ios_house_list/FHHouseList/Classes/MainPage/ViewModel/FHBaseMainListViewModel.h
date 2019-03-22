//
//  FHBaseMainListViewModel.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/8.
//

#import <Foundation/Foundation.h>
#import <FHHouseBase/FHHouseType.h>
#import <FHCommonUI/FHFakeInputNavbar.h>
#import <FHCommonUI/FHErrorView.h>

NS_ASSUME_NONNULL_BEGIN
@class TTRouteParamObj;
@class FHBaseMainListViewController;
@class FHMainListTopView;
@interface FHBaseMainListViewModel : NSObject

@property(nonatomic , strong) UIView *filterPanel;
@property(nonatomic , strong) UIView *filterBgControl;
@property(nonatomic , strong) UIView *topBannerView;

@property(nonatomic , strong) FHFakeInputNavbar *navbar;
@property(nonatomic , strong) FHErrorView *errorMaskView;
@property(nonatomic , strong) FHMainListTopView *topView;
@property(nonatomic , strong) UIView *topContainerView;
@property(nonatomic , weak) FHBaseMainListViewController *viewController;

@property (nonatomic , assign) NSInteger subScribeOffset;
@property (nonatomic , strong) NSString * subScribeSearchId;
@property (nonatomic , strong) NSString * subScribeQuery;
@property (nonatomic , strong) NSDictionary * subScribeShowDict;

-(instancetype)initWithTableView:(UITableView *)tableView houseType:(FHHouseType)houseType  routeParam:(TTRouteParamObj *)paramObj;

-(void)requestData:(BOOL)isHead;

-(void)showMapSearch;

-(void)showInputSearch;

-(NSString *)navbarPlaceholder;

-(NSString *)categoryName;

-(void)addStayLog:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
