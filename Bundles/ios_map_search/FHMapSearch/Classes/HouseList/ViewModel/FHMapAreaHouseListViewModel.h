//
//  FHMapAreaHouseListViewModel.h
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/6.
//

#import <Foundation/Foundation.h>
#import <FHHouseBase/FHHouseType.h>
//#import <FHHouseBase/FHHouseFilterDelegate.h>

NS_ASSUME_NONNULL_BEGIN
@class FHMapAreaHouseListViewController;
@protocol FHHouseFilterBridge;
@class ArticleListNotifyBarView;
@protocol FHMapAreaHouseListViewModelDelegate;
@interface FHMapAreaHouseListViewModel : NSObject

@property(nonatomic , assign)FHHouseType houseType;
@property(nonatomic , weak) id<FHMapAreaHouseListViewModelDelegate> delegate;

-(instancetype)initWithWithController:(FHMapAreaHouseListViewController *)viewController tableView:(UITableView *)table userInfo:(NSDictionary *)userInfo;

-(void)viewWillAppear:(BOOL)animated;

-(void)viewWillDisappear:(BOOL)animated;

//更新筛选 并请求
-(void)refreshWithFilter:(NSString *)filter;

-(void)loadData;

-(void)addStayCategoryLog;

@end

@protocol FHMapAreaHouseListViewModelDelegate <NSObject>

-(void)overwriteWithOpenUrl:(NSString *)openUrl andViewModel:(FHMapAreaHouseListViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
