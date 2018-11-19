//
//  FHMapSearchHouseListViewModel.h
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import <Foundation/Foundation.h>
#import "FHErrorMaskView.h"

NS_ASSUME_NONNULL_BEGIN
@class FHMapSearchHouseListViewController;
@class FHSearchHouseDataModel;
@class FHHouseAreaHeaderView;
@class FHMapSearchDataListModel;
@class FHMapSearchConfigModel;
@class EmptyMaskView;

@interface FHMapSearchHouseListViewModel : NSObject<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , weak) FHMapSearchHouseListViewController *listController;
@property(nonatomic , strong) FHHouseAreaHeaderView *headerView;
@property(nonatomic , strong) FHMapSearchConfigModel *configModel;
@property(nonatomic , strong) FHErrorMaskView *maskView;


-(instancetype)initWithController:(FHMapSearchHouseListViewController *)viewController tableView:(UITableView *)tableView;

-(void)updateWithHouseData:(FHSearchHouseDataModel *_Nullable)data neighbor:(FHMapSearchDataListModel *)neighbor;
-(void)dismiss;
-(NSString *)searchId;

-(void)reloadingHouseData;

-(void)viewWillAppear:(BOOL)animated;
-(void)viewWillDisappear:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
