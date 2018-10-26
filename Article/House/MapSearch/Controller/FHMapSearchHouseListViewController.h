//
//  FHMapSearchHouseListViewController.h
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHBaseViewController.h"
#import "FHMapSearchHouseListViewModel.h"

@class FHSearchHouseDataModel;

NS_ASSUME_NONNULL_BEGIN


@interface FHMapSearchHouseListViewController : FHBaseViewController

@property(nonatomic , strong) FHMapSearchHouseListViewModel *viewModel;

-(void)showWithHouseData:(FHSearchHouseDataModel *)data neighbor:(FHMapSearchDataListModel *)neighbor;

@end

NS_ASSUME_NONNULL_END
