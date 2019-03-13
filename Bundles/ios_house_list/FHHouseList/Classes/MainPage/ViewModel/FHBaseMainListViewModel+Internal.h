//
//  FHBaseMainListViewModel+Internal.h
//  Pods
//
//  Created by 春晖 on 2019/3/12.
//

#ifndef FHBaseMainListViewModel_Internal_h
#define FHBaseMainListViewModel_Internal_h

#import <TTNetworkManager/TTHttpTask.h>

@interface FHBaseMainListViewModel ()<UITableViewDelegate,UITableViewDataSource,FHConditionFilterViewModelDelegate,FHMainRentTopViewDelegate,FHMainOldTopViewDelegate>

@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , assign) FHHouseType houseType;

@property(nonatomic , strong) NSMutableArray *houseList;
@property(nonatomic , strong) FHSearchFilterOpenUrlModel *filterOpenUrlMdodel;
@property(nonatomic , strong) FHHouseRentDataModel *currentRentDataModel;
@property(nonatomic , copy)  NSString *conditionFilter;
@property(nonatomic , strong) NSString *suggestion;
@property(nonatomic , strong) NSDictionary *houseSearchDict;
@property(nonatomic , assign) BOOL showPlaceHolder;
@property(nonatomic , strong) UIImage *placeHolderImage;
@property(nonatomic , copy  ) NSString *mapFindHouseOpenUrl;
@property(nonatomic , weak) TTHttpTask *requestTask;

@property (nonatomic , strong) FHConditionFilterViewModel *houseFilterViewModel;
@property (nonatomic , strong) id<FHHouseFilterBridge> houseFilterBridge;

@property(nonatomic , strong) NSMutableDictionary *showHouseDict;
@property(nonatomic , strong) NSMutableDictionary *stayTraceDict;
@property(nonatomic , assign) CGFloat headerHeight;

@property(nonatomic , copy) NSString *originSearchId;
@property(nonatomic , copy) NSString *originFrom;
@property(nonatomic , assign) BOOL isFirstLoad;
@property(nonatomic , assign) BOOL fromRecommend;

@property(nonatomic , copy) NSString *mapFindHouseOpenUrl;
@property(nonatomic , copy) NSString *searchId;
@property(nonatomic , copy) NSString *recommendSearchId;
@property(nonatomic , copy) NSString *originSearchId;
@property(nonatomic , copy) NSString *originFrom;
@property(nonatomic , strong) NSDictionary *houseSearchDic;


@property (nonatomic , strong) FHConfigDataRentOpDataModel *rentModel;


-(void)showErrorMask:(BOOL)show tip:(FHEmptyMaskViewType )type enableTap:(BOOL)enableTap showReload:(BOOL)showReload;

@end

#endif /* FHBaseMainListViewModel_Internal_h */
