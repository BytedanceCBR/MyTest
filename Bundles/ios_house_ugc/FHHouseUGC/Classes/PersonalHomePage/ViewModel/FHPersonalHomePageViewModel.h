//
//  FHPersonalHomePageViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/11.
//

#import <Foundation/Foundation.h>
#import "FHPersonalHomePageController.h"
#import "FHUGCBaseViewModel.h"
#import "FHUGCCellManager.h"
#import "FHTopicHeaderModel.h"
#import "SSImpressionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPersonalHomePageViewModel : FHUGCBaseViewModel<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)   FHUGCCellManager       *ugcCellManager;
@property (nonatomic, strong) NSHashTable<id>      *hashTable;
@property (nonatomic, assign)   NSInteger       currentSelectIndex;
@property (nonatomic, strong)     UITableView       *currentTableView;
@property (nonatomic, strong)   FHTopicHeaderModel       *headerModel;
@property (nonatomic, assign)   int64_t cid;// 话题id
@property (nonatomic, copy)     NSString       *enter_from;// 从哪进入的当前页面

-(instancetype)initWithController:(FHPersonalHomePageController *)viewController;

- (void)startLoadData;

- (void)refreshLoadData;

- (void)loadMoreData;

- (void)viewWillAppear;

- (void)viewWillDisappear;

- (void)needRerecordImpressions;

@end

NS_ASSUME_NONNULL_END
