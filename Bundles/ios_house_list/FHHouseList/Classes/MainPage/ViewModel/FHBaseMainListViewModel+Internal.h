//
//  FHBaseMainListViewModel+Internal.h
//  Pods
//
//  Created by 春晖 on 2019/3/12.
//

#ifndef FHBaseMainListViewModel_Internal_h
#define FHBaseMainListViewModel_Internal_h

#import <TTNetworkManager/TTHttpTask.h>
#import <FHConditionFilterViewModel.h>
#import <FHHouseBase/FHSearchFilterOpenUrlModel.h>
#import <FHHouseBase/FHHouseFilterBridge.h>
#import <FHHouseBase/FHUserTracker.h>
#import <FHHouseBase/FHTracerModel.h>
#import <FHHouseBase/FHHouseListModel.h>

#import "FHMainRentTopView.h"
#import "FHMainOldTopView.h"
#import "FHHouseListRedirectTipView.h"


@interface FHBaseMainListViewModel ()<UITableViewDelegate,UITableViewDataSource,FHConditionFilterViewModelDelegate,FHMainRentTopViewDelegate,FHMainOldTopViewDelegate>

@property(nonatomic , strong) UITableView *tableView;
@property(nonatomic , assign) FHHouseType houseType;
@property(nonatomic , strong) FHTracerModel *tracerModel;
@property(nonatomic , strong) NSMutableArray *houseList;

@property (nonatomic, copy) NSString *houseListOpenUrl;
@property(nonatomic , copy  ) NSString *mapFindHouseOpenUrl;
@property(nonatomic , strong) FHSearchFilterOpenUrlModel *filterOpenUrlMdodel;

@property(nonatomic , strong) NSString *suggestion;
@property(nonatomic , assign) BOOL showPlaceHolder;
@property(nonatomic , strong) UIImage *placeHolderImage;

@property(nonatomic , weak) TTHttpTask *requestTask;

@property(nonatomic , copy)   NSString *conditionFilter;
@property (nonatomic , strong) FHConditionFilterViewModel *houseFilterViewModel;
@property (nonatomic , strong) id<FHHouseFilterBridge> houseFilterBridge;

@property(nonatomic , strong) NSMutableDictionary *showHouseDict;
@property(nonatomic , strong) NSMutableDictionary *stayTraceDict;

@property(nonatomic , copy) NSString *searchId;
@property(nonatomic , copy) NSString *originSearchId;
@property(nonatomic , copy) NSString *originFrom;
@property(nonatomic , assign) BOOL isFirstLoad;

@property(nonatomic , assign) BOOL mainListPage;//是否是大类页

//list
@property(nonatomic , assign) BOOL canChangeHouseSearchDic;
@property(nonatomic , assign,getter=isFromRecommend) BOOL fromRecommend;
@property(nonatomic , strong) NSMutableArray *sugesstHouseList;
@property(nonatomic , copy)   NSString *recommendSearchId;
@property(nonatomic , strong) NSDictionary *houseSearchDic;
@property(nonatomic , assign) BOOL addEnterCategory; // 是否算enter_category
@property(nonatomic , assign) BOOL showRedirectTip;
@property(nonatomic , strong) FHSearchHouseDataRedirectTipsModel *redirectTips;
@property(nonatomic , weak)   FHHouseListRedirectTipView *redirectTipView;

@property(nonatomic , assign) BOOL showFilter;

-(void)showErrorMask:(BOOL)show tip:(FHEmptyMaskViewType )type enableTap:(BOOL)enableTap showReload:(BOOL)showReload;

-(NSString *)pageTypeString;

-(NSString *)pageTypeString;

-(NSString *)houseTypeString;

-(void)addStayLog:(NSTimeInterval)duration;

-(void)gotoCommuteList:(UIViewController *)popController;

@end

#endif /* FHBaseMainListViewModel_Internal_h */
