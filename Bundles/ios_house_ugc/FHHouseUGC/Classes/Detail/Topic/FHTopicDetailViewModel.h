//
//  FHTopicDetailViewModel.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/8/22.
//

#import <Foundation/Foundation.h>
#import "FHTopicDetailViewController.h"
#import "FHUGCBaseViewModel.h"
#import "FHUGCCellManager.h"
#import "FHTopicHeaderModel.h"
#import "SSImpressionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHTopicDetailViewModel : FHUGCBaseViewModel

@property (nonatomic, strong)   FHUGCCellManager       *ugcCellManager;
@property (nonatomic, strong) NSHashTable<id>      *hashTable;
@property (nonatomic, assign)   NSInteger       currentSelectIndex;
@property (nonatomic, strong)     UITableView       *currentTableView;
@property (nonatomic, strong)   FHTopicHeaderModel       *headerModel;
@property (nonatomic, assign)   int64_t cid;// 话题id
@property (nonatomic, copy)     NSString       *enter_from;// 从哪进入的当前页面

-(instancetype)initWithController:(FHTopicDetailViewController *)viewController;

- (void)startLoadData;

- (void)refreshLoadData;

- (void)loadMoreData;

- (void)viewWillAppear;

- (void)viewWillDisappear;

- (void)needRerecordImpressions;

@end

NS_ASSUME_NONNULL_END
