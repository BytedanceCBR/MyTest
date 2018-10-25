//
//  FHMapSearchHouseListViewModel.h
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class FHMapSearchHouseListViewController;
@interface FHMapSearchHouseListViewModel : NSObject<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic , strong) NSMutableArray *houseList;
@property(nonatomic , weak) FHMapSearchHouseListViewController *listController;

@end

NS_ASSUME_NONNULL_END
