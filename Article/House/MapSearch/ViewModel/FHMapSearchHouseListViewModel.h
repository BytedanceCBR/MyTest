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
@class FHMapSearchConfigModel;

@interface FHMapSearchHouseListViewModel : NSObject<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) FHMapSearchHouseListViewController *listController;
@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , strong) FHHouseAreaHeaderView *headerView;
@property(nonatomic , strong) FHMapSearchConfigModel *configModel;

-(void)registerCells:(UITableView *)tableView;
-(void)updateWithHouseData:(FHSearchHouseDataModel *)data neighbor:(FHMapSearchDataListModel *)neighbor;
-(void)dismiss;
-(NSString *)searchId;


@end

NS_ASSUME_NONNULL_END
