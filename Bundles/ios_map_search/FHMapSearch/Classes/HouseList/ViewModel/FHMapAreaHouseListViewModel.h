//
//  FHMapAreaHouseListViewModel.h
//  FHMapSearch
//
//  Created by 春晖 on 2019/5/6.
//

#import <Foundation/Foundation.h>
#import <FHHouseBase/FHHouseType.h>
#import <FHHouseBase/FHHouseFilterDelegate.h>

NS_ASSUME_NONNULL_BEGIN
@class FHMapAreaHouseListViewController;
@protocol FHHouseFilterBridge;
@interface FHMapAreaHouseListViewModel : NSObject<FHHouseFilterDelegate>

@property(nonatomic , assign)FHHouseType houseType;
@property (nonatomic , strong) id<FHHouseFilterBridge> houseFilterBridge;

-(instancetype)initWithWithController:(FHMapAreaHouseListViewController *)viewController tableView:(UITableView *)table userInfo:(NSDictionary *)userInfo;

-(void)viewWillAppear:(BOOL)animated;

-(void)viewWillDisappear:(BOOL)animated;

-(void)loadData;

-(void)addStayCategoryLog;

@end

NS_ASSUME_NONNULL_END
