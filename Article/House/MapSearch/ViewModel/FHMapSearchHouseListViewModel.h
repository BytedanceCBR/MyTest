//
//  FHMapSearchHouseListViewModel.h
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class FHMapSearchHouseListViewController;
@class FHSearchHouseDataModel;
@class FHHouseAreaHeaderView;
@class FHMapSearchDataListModel;

@interface FHMapSearchHouseListViewModel : NSObject<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) FHMapSearchHouseListViewController *listController;
@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , strong) FHHouseAreaHeaderView *headerView;

-(void)registerCells:(UITableView *)tableView;
-(void)updateWithInitHouseData:(FHSearchHouseDataModel *)data neighbor:(FHMapSearchDataListModel *)neighbor;

@end

NS_ASSUME_NONNULL_END
