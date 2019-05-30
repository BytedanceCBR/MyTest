//
//  FHBaseSugListViewModel+Internal.h
//  FHHouseList
//
//  Created by 张静 on 2019/4/18.
//

#ifndef FHBaseSugListViewModel_Internal_h
#define FHBaseSugListViewModel_Internal_h

#import <TTReachability/TTReachability.h>
#import <FHCommonUI/ToastManager.h>
#import "FHSuggestionListModel.h"
#import <FHHouseBase/FHBaseViewController.h>

@protocol FHHouseBaseDataProtocel,FHHouseSuggestionDelegate;

@interface FHBaseSugListViewModel ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property(nonatomic , strong) UITableView *suggestTableView;
@property(nonatomic , strong) TTHttpTask *sugHttpTask;
@property (nonatomic, strong) NSArray<FHSuggestionResponseDataModel> *sugListData;
@property (nonatomic, copy)     NSString       *highlightedText;
@property (nonatomic, weak)     id<FHHouseBaseDataProtocel>    delegate;
@property (nonatomic, weak)     id<FHHouseSuggestionDelegate>    suggestDelegate;
@property (nonatomic, weak)     UIViewController   *backListVC; // 需要返回到的页面

@end

#endif /* FHBaseSugListViewModel_Internal_h */
