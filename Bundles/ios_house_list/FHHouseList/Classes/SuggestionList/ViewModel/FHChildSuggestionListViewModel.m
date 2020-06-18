//
//  FHChildSuggestionListViewModel.m
//  FHHouseList
//
//  Created by xubinbin on 2020/4/16.
//

#import "FHChildSuggestionListViewModel.h"
#import "FHChildSuggestionListViewController.h"
#import "ToastManager.h"
#import "FHHouseTypeManager.h"
#import "FHHistoryView.h"
#import "FHUserTracker.h"
#import "FHHouseTypeManager.h"
#import "FHSugHasSubscribeView.h"
#import "FHSugSubscribeModel.h"
#import "FHSugSubscribeListViewModel.h"
#import "FHOldSuggestionItemCell.h"
#import "FHSuggestionListViewController.h"
#import "FHSuggestionEmptyCell.h"
#import "FHFindHouseHelperCell.h"
#import "FHHouseListRecommendTipCell.h"

@interface FHChildSuggestionListViewModel () <UITableViewDelegate, UITableViewDataSource, FHSugSubscribeListDelegate>

@property(nonatomic , weak) FHChildSuggestionListViewController *listController;
@property(nonatomic , weak) TTHttpTask *sugHttpTask;
@property(nonatomic , weak) TTHttpTask *historyHttpTask;
@property(nonatomic , weak) TTHttpTask *guessHttpTask;
@property(nonatomic , weak) TTHttpTask *sugSubscribeTask;
@property(nonatomic , weak) TTHttpTask *delHistoryHttpTask;

@property (nonatomic, strong , nullable) NSArray<FHSuggestionResponseDataModel> *sugListData;
@property (nonatomic, strong , nullable) NSArray<FHSuggestionSearchHistoryResponseDataDataModel> *historyData;
@property (nonatomic, strong , nullable) NSMutableArray<FHGuessYouWantResponseDataDataModel> *guessYouWantData;
@property (nonatomic, strong , nullable) FHGuessYouWantExtraInfoModel *guessYouWantExtraInfo;  //帮我找房入口信息

@property (nonatomic, copy)     NSString       *highlightedText;
@property (nonatomic, strong)   FHHistoryView *historyView;
@property (nonatomic, strong)   FHSugHasSubscribeView *subscribeView;// 已订阅搜索
@property (nonatomic, strong)   UIView       *sectionHeaderView;
@property (nonatomic, assign)   NSInteger       totalCount; // 订阅搜索总个数
@property (nonatomic, strong , nullable) NSMutableArray<FHSugSubscribeDataDataItemsModel> *subscribeItems;

@property (nonatomic, assign)   BOOL       hasShowKeyboard;

@end

@implementation FHChildSuggestionListViewModel

-(instancetype)initWithController:(FHChildSuggestionListViewController *)viewController {
    self = [super init];
    if (self) {
        self.listController = viewController;
        self.loadRequestTimes = 0;
        self.guessYouWantData = [NSMutableArray new];
        self.subscribeItems = [NSMutableArray new];
        self.guessYouWantShowTracerDic = [NSMutableDictionary new];
        self.associatedCount = 0;
        self.hasShowKeyboard = NO;
        self.sectionHeaderView = [[UIView alloc] init];
        self.sectionHeaderView.backgroundColor = [UIColor whiteColor];
        [self setupSubscribeView];
        [self setupHistoryView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sugSubscribeNoti:) name:@"kFHSugSubscribeNotificationName" object:nil];
    }
    return self;
}

- (void)sugSubscribeNoti:(NSNotification *)noti {
    NSDictionary *userInfo = noti.object;
    if (userInfo) {
        BOOL subscribe_state = [userInfo[@"subscribe_state"] boolValue];
        if (subscribe_state) {
            // 订阅
            FHSugSubscribeDataDataItemsModel *subscribe_item = userInfo[@"subscribe_item"];
            if (subscribe_item && [subscribe_item isKindOfClass:[FHSugSubscribeDataDataItemsModel class]]) {
                [self.subscribeItems insertObject:subscribe_item atIndex:0];
                self.totalCount += 1;
            }
        } else {
            // 取消订阅
            NSString *subscribe_id = userInfo[@"subscribe_id"];
            __block NSInteger findIndex = -1;
            if (subscribe_id.length > 0) {
                [self.subscribeItems enumerateObjectsUsingBlock:^(FHSugSubscribeDataDataItemsModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.subscribeId isEqualToString:subscribe_id]) {
                        findIndex = idx;
                        *stop = YES;
                    }
                }];
                if (findIndex >= 0 && findIndex < self.subscribeItems.count) {
                    [self.subscribeItems removeObjectAtIndex:findIndex];
                    self.totalCount -= 1;
                }
            }
        }
        __weak typeof(self) wself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            // count 和 数据要一起变
            wself.subscribeView.totalCount = wself.totalCount;
            wself.subscribeView.subscribeItems = wself.subscribeItems;
            [wself reloadHistoryTableView];
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupHistoryView {
    self.historyView = [[FHHistoryView alloc] init];
    self.historyView.vc = self.listController;
    __weak typeof(self) wself = self;
    self.historyView.clickBlk = ^(FHSuggestionSearchHistoryResponseDataDataModel * _Nonnull model, NSInteger index) {
        [wself historyItemClick:model andIndex:index];
    };
    self.historyView.delClick = ^{
        [wself deleteHisttoryBtnClick];
    };
    self.historyView.moreClick = ^{
        [wself reloadHistoryTableView];
    };
    [self.sectionHeaderView addSubview:self.historyView];
    [self.historyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.sectionHeaderView);
        make.top.mas_equalTo(self.subscribeView.mas_bottom);
        make.height.mas_equalTo(CGFLOAT_MIN);
    }];
    self.historyView.hidden = YES;
}

- (void)setHouseType:(FHHouseType)houseType {
    _houseType = houseType;
    self.subscribeView.houseType = houseType;
}

- (void)setupSubscribeView {
    self.subscribeView = [[FHSugHasSubscribeView alloc] init];
    self.subscribeView.vc = self.listController;
    self.subscribeView.houseType = self.houseType;
    __weak typeof(self) wself = self;
    self.subscribeView.clickBlk = ^(FHSugSubscribeDataDataItemsModel * _Nonnull model) {
        [wself subscribeItemClick:model];
    };
    self.subscribeView.clickHeader = ^{
        [wself sugSubscribeListClick];
    };
    [self.sectionHeaderView addSubview:self.subscribeView];
    [self.subscribeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.sectionHeaderView);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(CGFLOAT_MIN);
    }];
    self.subscribeView.hidden = YES;
}

- (void)sugSubscribeListClick {
    // 埋点添加
    NSDictionary *tracerDic = @{@"page_type":@"search_detail"};
    [FHUserTracker writeEvent:@"click_loadmore" params:tracerDic];
    
    NSHashTable *subscribeDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [subscribeDelegateTable addObject:self];
    
    NSString *openUrl = [NSString stringWithFormat:@"fschema://sug_subscribe_list?house_type=%ld",self.houseType];
    NSMutableDictionary *tracer = [NSMutableDictionary new];
    tracer[@"enter_type"] = @"click";
    tracer[@"element_from"] = @"search_detail";
    tracer[@"enter_from"] = @"search_detail";
    if (self.listController.tracerDict[@"origin_from"]) {
        tracer[@"origin_from"] = self.listController.tracerDict[@"origin_from"];
    }
    if (self.listController.tracerDict[@"origin_search_id"]) {
        tracer[@"origin_search_id"] = self.listController.tracerDict[@"origin_search_id"];
    }
    NSDictionary * infos = @{@"title":@"我订阅的搜索",
                             @"subscribe_delegate":subscribeDelegateTable,
                             @"tracer":tracer
                             };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infos];
    
    NSURL *url = [NSURL URLWithString:openUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

// 订阅搜索item点击
- (void)subscribeItemClick:(FHGuessYouWantResponseDataDataModel *)model {
    NSString *enter_from = @"search_detail";
    NSString *element_from = @"be_null";
    switch (self.houseType) {
        case FHHouseTypeSecondHandHouse:
            element_from = @"old_subscribe";
            break;
        case FHHouseTypeNewHouse:
            element_from = @"new_subscribe";
            break;
        case FHHouseTypeRentHouse:
            element_from = @"rent_subscribe";
            break;
        case FHHouseTypeNeighborhood:
            element_from = @"neighborhood_subscribe";
            break;
        default:
            break;
    }
    [self jumpCategoryListVCFromSubscribeItem:model enterFrom:enter_from elementFrom:element_from];
}

// 搜索订阅组合列表页cell点击：FHSugSubscribeListViewController
- (void)cellSubscribeItemClick:(FHSugSubscribeDataDataItemsModel *)model {
    NSString *enter_from = @"be_null";
    NSString *element_from = @"be_null";
    switch (self.houseType) {
        case FHHouseTypeSecondHandHouse:
            enter_from = @"old_subscribe_list";
            break;
        case FHHouseTypeNewHouse:
            enter_from = @"new_subscribe_list";
            break;
        case FHHouseTypeRentHouse:
            enter_from = @"rent_subscribe_list";
            break;
        case FHHouseTypeNeighborhood:
            enter_from = @"neighborhood_subscribe_list";
            break;
        default:
            break;
    }
    [self jumpCategoryListVCFromSubscribeItem:model enterFrom:enter_from elementFrom:element_from];
}

- (void)jumpCategoryListVCFromSubscribeItem:(FHSugSubscribeDataDataItemsModel *)model enterFrom:(NSString *)enter_from elementFrom:(NSString *)element_from {
    NSString *jumpUrl = model.openUrl;
    if (jumpUrl.length > 0) {
        NSString *queryType = @"subscribe"; // 订阅搜索
        NSString *pageType = [self pageTypeString];
        // 特殊埋点需求，此处enter_query和search_query都埋:be_null
        NSDictionary *houseSearchParams = @{
                                            @"enter_query":@"be_null",
                                            @"search_query":@"be_null",
                                            @"page_type":pageType.length > 0 ? pageType : @"be_null",
                                            @"query_type":queryType
                                            };
        NSMutableDictionary *infos = [NSMutableDictionary new];
        infos[@"houseSearch"] = houseSearchParams;
    
        NSMutableDictionary *tracer = [NSMutableDictionary new];
        tracer[@"enter_type"] = @"click";
        tracer[@"element_from"] = element_from.length > 0 ? element_from : @"be_null";
        tracer[@"enter_from"] = enter_from.length > 0 ? enter_from : @"be_null";
        if (self.listController.tracerDict[@"origin_from"]) {
            tracer[@"origin_from"] = self.listController.tracerDict[@"origin_from"];
        }
        infos[@"tracer"] = tracer;

        // 参数都在jumpUrl中
        [self.listController jumpToCategoryListVCByUrl:jumpUrl queryText:nil placeholder:nil infoDict:infos];
    }
}

- (void)historyItemClick:(FHSuggestionSearchHistoryResponseDataDataModel *)model andIndex:(NSInteger)index
{
    // 点击埋点
    NSDictionary *tracerDic = @{
                                @"word":model.text.length > 0 ? model.text : @"be_null",
                                @"history_id":model.historyId.length > 0 ? model.historyId : @"be_null",
                                @"rank":@(index),
                                @"show_type":@"list"
                                };
    [FHUserTracker writeEvent:@"search_history_click" params:tracerDic];
    
    NSString *jumpUrl = model.openUrl;
    if (jumpUrl.length > 0) {
        NSString *placeHolder = [model.text stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        if (placeHolder.length > 0) {
            jumpUrl = [NSString stringWithFormat:@"%@&placeholder=%@",jumpUrl,placeHolder];
        }
    }
    NSString *queryType = @"history"; // 历史记录
    NSString *pageType = [self pageTypeString];
    NSString *queryText = model.text.length > 0 ? model.text : @"be_null";
    NSDictionary *houseSearchParams = @{
                                        @"enter_query":queryText,
                                        @"search_query":queryText,
                                        @"page_type":pageType.length > 0 ? pageType : @"be_null",
                                        @"query_type":queryType
                                        };
    
    NSMutableDictionary *infos = [NSMutableDictionary new];
    infos[@"houseSearch"] = houseSearchParams;
    if (model.extinfo) {
        infos[@"suggestion"] = [self createQueryCondition:model.extinfo];
    }
    NSMutableDictionary *tracer = [NSMutableDictionary new];
    tracer[@"enter_type"] = @"click";
    if (self.listController.tracerDict != NULL) {
        if (self.listController.tracerDict[@"element_from"]) {
            tracer[@"element_from"] = self.listController.tracerDict[@"element_from"];
        }
        if (self.listController.tracerDict[@"enter_from"]) {
            tracer[@"enter_from"] = self.listController.tracerDict[@"enter_from"];
        }
        if (self.listController.tracerDict[@"origin_from"]) {
            tracer[@"origin_from"] = self.listController.tracerDict[@"origin_from"];
        }
    }
    infos[@"tracer"] = tracer;
    
    [self.listController jumpToCategoryListVCByUrl:jumpUrl queryText:model.text placeholder:model.text infoDict:infos];
}

- (void)trackClickEventData:(FHGuessYouWantResponseDataDataModel *)model rank:(NSInteger)rank {
    NSMutableDictionary *tracerDic = [NSMutableDictionary new];
    tracerDic[@"event_type"] = @"house_app2c_v2";
    tracerDic[@"word"] = model.logPb[@"word"] ? model.logPb[@"word"] : @"be_null";
    tracerDic[@"word_type"] = @"hot";
    tracerDic[@"rank"] = @(rank);
    tracerDic[@"gid"] = model.logPb[@"gid"] ? model.logPb[@"gid"] : @"be_null";
    tracerDic[@"log_pb"] = model.logPb ? model.logPb : @"be_null";
    
    tracerDic[@"recommend_reason"] = model.recommendReason ? [model.recommendReason toDictionary] : @"be_null";
    [FHUserTracker writeEvent:@"hot_word_click" params:tracerDic];
}

- (void)guessYouWantCellClick:(FHGuessYouWantResponseDataDataModel *)model {
    NSString *jumpUrl = model.openUrl;
    if (jumpUrl.length > 0) {
        NSString *placeHolder = [model.text stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        if (placeHolder.length > 0) {
            jumpUrl = [NSString stringWithFormat:@"%@&placeholder=%@",jumpUrl,placeHolder];
        }
        NSString *queryType = @"hot"; // 猜你想搜
        NSString *pageType = [self pageTypeString];
        NSString *queryText = model.text.length > 0 ? model.text : @"be_null";
        NSDictionary *houseSearchParams = @{
                                            @"enter_query":queryText,
                                            @"search_query":queryText,
                                            @"page_type":pageType.length > 0 ? pageType : @"be_null",
                                            @"query_type":queryType
                                            };
        NSMutableDictionary *infos = [NSMutableDictionary new];
        infos[@"houseSearch"] = houseSearchParams;
        if (model.extinfo) {
            infos[@"suggestion"] = [self createQueryCondition:model.extinfo];
        }
        NSMutableDictionary *tracer = [NSMutableDictionary new];
        tracer[@"enter_type"] = @"click";
        if (self.listController.tracerDict != NULL) {
            if (self.listController.tracerDict[@"element_from"]) {
                tracer[@"element_from"] = self.listController.tracerDict[@"element_from"];
            }
            if (self.listController.tracerDict[@"enter_from"]) {
                tracer[@"enter_from"] = self.listController.tracerDict[@"enter_from"];
            }
            if (self.listController.tracerDict[@"origin_from"]) {
                tracer[@"origin_from"] = self.listController.tracerDict[@"origin_from"];
            }
        }
        infos[@"tracer"] = tracer;

        [self.listController jumpToCategoryListVCByUrl:jumpUrl queryText:queryText placeholder:queryText infoDict:infos];
    }
}


// 联想词Cell点击
- (void)associateWordCellClick:(FHSuggestionResponseDataModel *)model rank:(NSInteger)rank {
    
    // 点击埋点
    NSString *impr_id = model.logPb.imprId.length > 0 ? model.logPb.imprId : @"be_null";
    NSDictionary *tracerDic = @{
                                @"word_text":model.text.length > 0 ? model.text : @"be_null",
                                @"associate_cnt":@(self.associatedCount),
                                @"associate_type":[[FHHouseTypeManager sharedInstance] traceValueForType:self.houseType],
                                @"word_id":model.info.wordid.length > 0 ? model.info.wordid : @"be_null",
                                @"element_type":@"search",
                                @"impr_id":impr_id,
                                @"rank":@(rank)
                                };
    [FHUserTracker writeEvent:@"associate_word_click" params:tracerDic];
    
    NSString *jumpUrl = model.openUrl;
    if (jumpUrl.length > 0) {
        NSString *placeHolder = [model.text stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        if (placeHolder.length > 0) {
            jumpUrl = [NSString stringWithFormat:@"%@&placeholder=%@",jumpUrl,placeHolder];
        }
    }
    NSString *queryType = @"associate"; // 联想词
    NSString *pageType = [self pageTypeString];
    NSString *inputStr = self.highlightedText.length > 0 ? self.highlightedText : @"be_null";
    NSString *queryText = model.text.length > 0 ? model.text : @"be_null";
    NSDictionary *houseSearchParams = @{
                                        @"enter_query":inputStr,
                                        @"search_query":queryText,
                                        @"page_type":pageType.length > 0 ? pageType : @"be_null",
                                        @"query_type":queryType
                                        };
    
    NSMutableDictionary *infos = [NSMutableDictionary new];
    infos[@"houseSearch"] = houseSearchParams;
    if (model.info) {
        NSDictionary *dic = [model.info toDictionary];
        infos[@"suggestion"] = [self createQueryCondition:dic];
    }
    NSMutableDictionary *tracer = [NSMutableDictionary new];
    tracer[@"enter_type"] = @"click";
    if (self.listController.tracerDict != NULL) {
        if (self.listController.tracerDict[@"element_from"]) {
            tracer[@"element_from"] = self.listController.tracerDict[@"element_from"];
        }
        if (self.listController.tracerDict[@"enter_from"]) {
            tracer[@"enter_from"] = self.listController.tracerDict[@"enter_from"];
        }
        if (self.listController.tracerDict[@"origin_from"]) {
            tracer[@"origin_from"] = self.listController.tracerDict[@"origin_from"];
        }
    }
    infos[@"tracer"] = tracer;
    
    [self.listController jumpToCategoryListVCByUrl:jumpUrl queryText:model.text placeholder:model.text infoDict:infos];
}

// 删除历史记录按钮点击
- (void)deleteHisttoryBtnClick {
    [self.listController requestDeleteHistory];
}

// 联想词埋点
- (void)associateWordShow {
    NSMutableArray *wordList = [NSMutableArray new];
    if (self.sugListData.count == 0) {
        return;
    }
    for (NSInteger index = 0; index < self.sugListData.count; index ++) {
        FHSuggestionResponseDataModel *item = self.sugListData[index];
        NSDictionary *dic = @{
                              @"text":item.text.length > 0 ? item.text : @"be_null",
                              @"word_id":item.info.wordid.length > 0 ? item.info.wordid : @"be_null",
                              @"rank":@(index)
                              };
        [wordList addObject:dic];
    }
    NSError *error = NULL;
    NSData *data = [NSJSONSerialization dataWithJSONObject:wordList options:NSJSONReadingAllowFragments error:&error];
    NSString *wordListStr = @"";
    if (data && error == NULL) {
        wordListStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    NSString *impr_id = @"be_null";
    if (self.sugListData.count > 0) {
        FHSuggestionResponseDataModel *item = self.sugListData[0];
        impr_id = item.logPb.imprId.length > 0 ? item.logPb.imprId : @"be_null";
    }
    
    NSDictionary *tracerDic = @{
                                @"word_list":wordListStr.length > 0 ? wordListStr : @"be_null",
                                @"associate_cnt":@(self.associatedCount),
                                @"associate_type":[[FHHouseTypeManager sharedInstance] traceValueForType:self.houseType],
                                @"word_cnt":@(wordList.count),
                                @"element_type":@"search",
                                @"impr_id":impr_id
                                };

    if (_isAssociatedCanTrack) {
        [FHUserTracker writeEvent:@"associate_word_show" params:tracerDic];
    }
}

- (NSString *)createQueryCondition:(NSDictionary *)conditionDic {
    NSString *retStr = @"";
    if ([conditionDic isKindOfClass:[NSString class]]) {
        retStr = conditionDic;
        return retStr;
    }
    NSError *error = NULL;
    NSData *data = [NSJSONSerialization dataWithJSONObject:conditionDic options:NSJSONReadingAllowFragments error:&error];
    if (data && error == NULL) {
        retStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return retStr;
}

- (NSString *)pageTypeString {
    NSString *retPageTypeStr = @"";
    switch (self.fromPageType) {
        case FHEnterSuggestionTypeDefault:
            retPageTypeStr = self.pageTypeStr.length > 0 ? self.pageTypeStr : @"be_null";
            break;
        case FHEnterSuggestionTypeHome:
            retPageTypeStr = @"maintab";
            break;
        case FHEnterSuggestionTypeRenting:
            retPageTypeStr = @"rent_list";
            break;
        case FHEnterSuggestionTypeFindTab:
            switch (self.houseType) {
                case FHHouseTypeNeighborhood:
                    retPageTypeStr = @"findtab_neighborhood";
                    break;
                case FHHouseTypeNewHouse:
                    retPageTypeStr = @"findtab_new";
                    break;
                case FHHouseTypeSecondHandHouse:
                    retPageTypeStr = @"findtab_old";
                    break;
                case FHHouseTypeRentHouse:
                    retPageTypeStr = @"findtab_rent";
                    break;
                default:
                     retPageTypeStr = @"findtab_old";
                    break;
            }
            break;
        case FHEnterSuggestionTypeList:
            switch (self.houseType) {
                case FHHouseTypeNeighborhood:
                    retPageTypeStr = @"neighborhood_list";
                    break;
                case FHHouseTypeNewHouse:
                    retPageTypeStr = @"new_list";
                    break;
                case FHHouseTypeSecondHandHouse:
                    retPageTypeStr = @"old_list";
                    break;
                case FHHouseTypeRentHouse:
                    retPageTypeStr = @"rent_list";
                    break;
                default:
                    retPageTypeStr = @"old_list";
                    break;
            }
            break;
        case FHEnterSuggestionTypeOldMain:
            retPageTypeStr = @"old_kind_list";
            break;
        default:
            retPageTypeStr = @"maintab";
            break;
    }
    return retPageTypeStr;
}

- (NSString *)categoryNameByHouseType {
    switch (self.houseType) {
        case FHHouseTypeNeighborhood:
            return @"neighborhood_list";
            break;
        case FHHouseTypeNewHouse:
            return @"new_list";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"old_list";
            break;
        case FHHouseTypeRentHouse:
            return @"rent_list";
            break;
        default:
            break;
    }
    return @"be_null";
}

//跳转到帮我找房
- (void)jump2HouseFindPageWithUrl:(NSString *)url {
    if (url.length > 0) {
        NSURL *openUrl = [NSURL URLWithString:url];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
    }
}

#pragma mark - tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        // 历史记录
        return self.guessYouWantData.count > 0 ? self.guessYouWantData.count + 1 : 0;
    } else if (tableView.tag == 2) {
        // 联想词
        if (self.sugListData.count == 0 && !self.listController.isLoadingData && self.listController.fatherVC.naviBar.searchInput.text.length != 0) {
            return 1;
        }
        return self.sugListData.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        // 历史记录
        if (indexPath.row == 0) {
            __weak typeof(self) weakSelf = self;
            FHSuggestHeaderViewCell *headerCell = (FHSuggestHeaderViewCell *)[tableView dequeueReusableCellWithIdentifier:@"suggestHeaderCell" forIndexPath:indexPath];
            headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
            //猜你想找增加帮我找房入口
            [headerCell refreshData:self.guessYouWantExtraInfo];
            headerCell.entryTapAction = ^(NSString *url) {
                [weakSelf jump2HouseFindPageWithUrl:url];
            };
            return headerCell;
        }
        FHGuessYouWantCell *cell = (FHGuessYouWantCell *)[tableView dequeueReusableCellWithIdentifier:@"guessYouWantCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row - 1 < self.guessYouWantData.count) {
            FHGuessYouWantResponseDataDataModel *model  = self.guessYouWantData[indexPath.row - 1];
            [cell refreshData:model];
        }
        return cell;
    } else if (tableView.tag == 2) {
        if (self.sugListData.count == 0) {
            //空页面
            FHSuggestionEmptyCell *cell = (FHSuggestionEmptyCell *)[tableView dequeueReusableCellWithIdentifier:@"suggetEmptyCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
        //服务端会同时下发cardType=9和cardType=16两种类型的卡片数据
        if (self.sugListData.count <= 2) {
            //XXX: 为支持1.0.1版本帮我找房需求，暂时根据model.cardType字段区分cell，后期需支持混排
            FHSuggestionResponseDataModel *model = self.sugListData[indexPath.row];
            if (model.cardType == 9) {
                FHHouseListRecommendTipCell *tipCell = (FHHouseListRecommendTipCell *)[tableView dequeueReusableCellWithIdentifier:@"tipcell" forIndexPath:indexPath];
                FHSearchGuessYouWantTipsModel *tipModel = [[FHSearchGuessYouWantTipsModel alloc] init];
                tipModel.text = model.text;
                [tipCell refreshWithData:tipModel];
                
                return tipCell;
            } else if (model.cardType == 15) {
                __weak typeof(self) weakSelf = self;
                FHFindHouseHelperCell *helperCell = (FHFindHouseHelperCell *)[tableView dequeueReusableCellWithIdentifier:@"helperCell" forIndexPath:indexPath];
                helperCell.cellTapAction = ^(NSString *url) {
                    [weakSelf jump2HouseFindPageWithUrl:url];
                };
                [helperCell updateWithData:model];
                
                return helperCell;;
            }
        }
        
        // 联想词列表
        if (self.houseType == FHHouseTypeNewHouse) {
            // 新房
            FHSuggestionNewHouseItemCell *cell = (FHSuggestionNewHouseItemCell *)[tableView dequeueReusableCellWithIdentifier:@"suggestNewItemCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row < self.sugListData.count) {
                FHSuggestionResponseDataModel *model  = self.sugListData[indexPath.row];
                NSAttributedString *text1 = [self processHighlightedDefault:model.text textColor:[UIColor themeGray1] fontSize:15.0];
                NSAttributedString *text2 = [self processHighlightedDefault:model.text2 textColor:[UIColor themeGray3] fontSize:12.0];
                
                cell.label.attributedText = [self processHighlighted:text1 originText:model.text textColor:[UIColor themeOrange1] fontSize:15.0];
                cell.subLabel.attributedText = [self processHighlighted:text2 originText:model.text2 textColor:[UIColor themeOrange1] fontSize:12.0];
                
                cell.secondaryLabel.text = model.tips;
                cell.secondarySubLabel.text = model.tips2;
            }
            return cell;
        } else if(_houseType == FHHouseTypeSecondHandHouse) {
            
            // 二手房
            FHOldSuggestionItemCell *cell = (FHOldSuggestionItemCell *)[tableView dequeueReusableCellWithIdentifier:@"FHOldSuggestionItemCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row < self.sugListData.count) {
                FHSuggestionResponseDataModel *model  = self.sugListData[indexPath.row];
                cell.highlightedText = self.highlightedText;
                cell.model = model;
            }
            return cell;
            
        }else  {
            FHSuggestionItemCell *cell = (FHSuggestionItemCell *)[tableView dequeueReusableCellWithIdentifier:@"suggestItemCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row < self.sugListData.count) {
                FHSuggestionResponseDataModel *model  = self.sugListData[indexPath.row];
                NSString *originText = model.text;
                NSAttributedString *text1 = [self processHighlightedDefault:model.text textColor:[UIColor themeGray1] fontSize:15.0];
                NSMutableAttributedString *resultText = [[NSMutableAttributedString alloc] initWithAttributedString:text1];
                if (model.text2.length > 0) {
                    originText = [NSString stringWithFormat:@"%@ (%@)", originText, model.text2];
                    NSAttributedString *text2 = [self processHighlightedGray:model.text2];
                    [resultText appendAttributedString:text2];
                }
                cell.label.attributedText = [self processHighlighted:resultText originText:originText textColor:[UIColor themeOrange1] fontSize:15.0];
                cell.secondaryLabel.text = model.tips;
                if (indexPath.row == self.sugListData.count - 1) {
                    // 末尾
                    [cell.label mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_equalTo(cell.contentView).offset(-20);
                    }];
                } else {
                    [cell.label mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_equalTo(cell.contentView).offset(0);
                    }];
                }
            }
            return cell;
        }
    }
    
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == 1) {
        // 猜你想搜
        if (indexPath.row - 1 < self.guessYouWantData.count) {
            FHGuessYouWantResponseDataDataModel *model  = self.guessYouWantData[indexPath.row - 1];
            [self trackClickEventData:model rank:indexPath.row - 1];
            [self guessYouWantCellClick:model];
            
        }
    } else if (tableView.tag == 2) {
        // 联想词
        if (indexPath.row < self.sugListData.count) {
            FHSuggestionResponseDataModel *model  = self.sugListData[indexPath.row];
            [self associateWordCellClick:model rank:indexPath.row];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        // 历史记录 & 已订阅搜索
        if (self.historyData.count > 0 || self.subscribeItems.count > 0) {
            return self.sectionHeaderView;
        }
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1) {
        // 猜你想搜
        if (indexPath.row == 0) {
            return 62;
        } else {
            if (self.guessYouWantData.count > 0) {
                FHGuessYouWantResponseDataDataModel *model = self.guessYouWantData.firstObject;
                if (model.recommendReason.content.length > 0) {
                    return 76;
                }
                return 42;
            }
            return 42;
        }
    } else if (tableView.tag == 2) {
        // 联想词
        if (self.sugListData.count == 0) {
            return self.listController.suggestTableView.frame.size.height;
        } else if (self.sugListData.count <= 2) {
            NSInteger row = indexPath.row;
            if (row < self.sugListData.count) {
                FHSuggestionResponseDataModel *model = self.sugListData[row];
                if (model.cardType == 9) {
                    return 40;
                } else if (model.cardType == 15) {  //帮我找房卡片高度
                    return 73;
                }
            }
        }
        if (self.houseType == FHHouseTypeNewHouse) {
            // 新房
            return 67;
        } else  if (self.houseType == FHHouseTypeSecondHandHouse) {
            // 二手房
            return 76;
        }else {
            if (indexPath.row == self.sugListData.count - 1) {
                return 61;
            } else {
                return 41;
            }
        }
    }
    
    return 41;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        // 历史记录
        if (self.historyData.count > 0 && self.subscribeItems.count > 0) {
            return self.historyView.historyViewHeight + self.subscribeView.hasSubscribeViewHeight;
        } else if (self.historyData.count > 0 || self.subscribeItems.count > 0) {
            if (self.historyData.count > 0) {
                return self.historyView.historyViewHeight;
            }
            if (self.subscribeItems.count > 0) {
                return self.subscribeView.hasSubscribeViewHeight;
            }
            return CGFLOAT_MIN;
        } else {
            return CGFLOAT_MIN;
        }
    } else if (tableView.tag == 2) {
        // 联想词
        return CGFLOAT_MIN;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        //猜你想搜 埋点
        if (indexPath.row - 1 < self.guessYouWantData.count) {
            FHGuessYouWantResponseDataDataModel *model  = self.guessYouWantData[indexPath.row - 1];
            NSInteger rank = indexPath.row - 1;
            NSString *recordKey = [NSString stringWithFormat:@"%ld",rank];
            if (!self.guessYouWantShowTracerDic[recordKey] && self.listController.isCanTrack) {
                // 埋点
                self.guessYouWantShowTracerDic[recordKey] = @(YES);
                NSMutableDictionary *tracerDic = [NSMutableDictionary new];
                tracerDic[@"event_type"] = @"house_app2c_v2";
                tracerDic[@"word"] = model.logPb[@"word"] ? model.logPb[@"word"] : @"be_null";
                tracerDic[@"word_type"] = @"hot";
                tracerDic[@"rank"] = @(rank);
                tracerDic[@"gid"] = model.logPb[@"gid"] ? model.logPb[@"gid"] : @"be_null";
                tracerDic[@"log_pb"] = model.logPb ? model.logPb : @"be_null";
                
                tracerDic[@"recommend_reason"] = model.recommendReason ? [model.recommendReason toDictionary] : @"be_null";
                
                [FHUserTracker writeEvent:@"hot_word_show" params:tracerDic];
            }
        }
    } else if (tableView.tag == 2) {
        // 联想词 associate_word_show 埋点 在 返回数据的地方进行一次性埋点
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 开始拖拽滑动时，收起键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}


// 1、默认
- (NSAttributedString *)processHighlightedDefault:(NSString *)text textColor:(UIColor *)textColor fontSize:(CGFloat)fontSize {
    NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:fontSize],NSForegroundColorAttributeName:textColor};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:attr];
    
    return attrStr;
}

// 2、部分 灰色
- (NSAttributedString *)processHighlightedGray:(NSString *)text2 {
    NSString *retStr = [NSString stringWithFormat:@" (%@)",text2];
    NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:15],NSForegroundColorAttributeName:[UIColor themeGray3]};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:retStr attributes:attr];
    
    return attrStr;
}

// 3、高亮
- (NSAttributedString *)processHighlighted:(NSAttributedString *)text originText:(NSString *)originText textColor:(UIColor *)textColor fontSize:(CGFloat)fontSize {
    if (self.highlightedText.length > 0) {
        NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontRegular:fontSize],NSForegroundColorAttributeName:textColor};
        NSMutableAttributedString * tempAttr = [[NSMutableAttributedString alloc] initWithAttributedString:text];

        NSMutableString *string = [NSMutableString stringWithString:self.highlightedText];

        //左括号
        NSRange rangeLeft = [string rangeOfString:@"("];
        if (rangeLeft.location != NSNotFound) {
            [string insertString:@"[" atIndex:rangeLeft.location];
            [string insertString:@"]" atIndex:rangeLeft.location + 2];
        }

        //右括号
        NSRange rangeRight = [string rangeOfString:@")"];
        if (rangeRight.location != NSNotFound) {
            [string insertString:@"[" atIndex:rangeRight.location];
            [string insertString:@"]" atIndex:rangeRight.location + 2];
        }

        //()在正则表达式有特殊意义——子表达式
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"%@",string] options:NSRegularExpressionCaseInsensitive error:nil];
        
        [regex enumerateMatchesInString:originText options:NSMatchingReportProgress range:NSMakeRange(0, originText.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            [tempAttr addAttributes:attr range:result.range];
        }];
        return tempAttr;
    } else {
        return text;
    }
    return text;
}

#pragma mark - reload

- (void)clearSugTableView {
    if (self.sugHttpTask) {
        [self.sugHttpTask cancel];
    }
    self.sugListData = NULL;
    [self reloadSugTableView];
}

- (void)clearHistoryTableView {
    if (self.historyHttpTask) {
        [self.historyHttpTask cancel];
    }
    self.historyData = NULL;
    if (self.guessHttpTask) {
        [self.guessHttpTask cancel];
    }
    if (self.sugSubscribeTask) {
        [self.sugSubscribeTask cancel];
    }
    [self.subscribeItems removeAllObjects];
    [self.guessYouWantData removeAllObjects];
    self.historyView.hidden = YES;
    self.subscribeView.hidden = YES;
    [self reloadHistoryTableView];
}

- (void)reloadSugTableView {
    if (self.listController.suggestTableView != NULL) {
        self.listController.isLoadingData = NO;
        [self.listController.suggestTableView reloadData];
        if (self.sugListData.count > 0) {
            [self.listController.suggestTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
}

- (void)reloadHistoryTableView {
    if (self.loadRequestTimes >= 3) {
        self.listController.hasValidateData = YES;
        
        if (self.historyData.count > 0) {
            self.historyView.historyItems = self.historyData;
            [self.historyView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.historyView.historyViewHeight);
            }];
            self.historyView.hidden = NO;
        } else {
            self.historyView.hidden = YES;
            [self.historyView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(CGFLOAT_MIN);
            }];
        }
        if (self.subscribeItems.count > 0) {
            self.subscribeView.subscribeItems = self.subscribeItems;
            [self.subscribeView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.subscribeView.hasSubscribeViewHeight);
            }];
             self.subscribeView.hidden = NO;
        } else {
             self.subscribeView.hidden = YES;
            [self.subscribeView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
        }
        
        if (!self.hasShowKeyboard) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.listController.fatherVC) {
                    [self.listController.fatherVC.naviBar.searchInput becomeFirstResponder];
                }
            });
            self.hasShowKeyboard = YES;
        }
        [self.listController.historyTableView reloadData];
        if (self.guessYouWantData.count > 0) {
            [self.listController.historyTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
}

#pragma mark - Request

- (void)requestSearchHistoryByHouseType:(NSString *)houseType {
    if (self.historyHttpTask) {
        [self.historyHttpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.historyHttpTask = [FHHouseListAPI requestSearchHistoryByHouseType:houseType class:[FHSuggestionSearchHistoryResponseModel class] completion:^(FHSuggestionSearchHistoryResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        wself.loadRequestTimes += 1;
        if (model != NULL && error == NULL) {
            // 构建数据源
            wself.historyData = model.data.data;
            wself.historyView.historyItems = wself.historyData;
            [wself.listController.emptyView hideEmptyView];
            [wself reloadHistoryTableView];
        } else {
            wself.historyView.historyItems = NULL;
            if (error && ![error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"the request was cancelled"]) {
                wself.listController.isLoadingData = NO;
                [wself.listController endLoading];
                [wself.listController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            }
        }
    }];
}

- (void)requestSugSubscribe:(NSInteger)cityId houseType:(NSInteger)houseType {
    
    if (self.sugSubscribeTask) {
        [self.sugSubscribeTask cancel];
    }
    __weak typeof(self) wself = self;
    // "subscribe_list_type": 2(搜索页) / 3(独立展示页) 请求总数50
    self.sugSubscribeTask = [FHHouseListAPI requestSugSubscribe:cityId houseType:houseType subscribe_type:2 subscribe_count:50 class:[FHSugSubscribeModel class] completion:^(FHSugSubscribeModel *  _Nonnull model, NSError * _Nonnull error) {
        wself.loadRequestTimes += 1;
        wself.subscribeView.totalCount = 0;
        if (model != NULL && error == NULL) {
            // 构建数据源
            [wself.subscribeItems removeAllObjects];
            if (model.data.items.count > 0) {
                NSMutableArray *tempData = [[NSMutableArray alloc] initWithArray:model.data.items];
                NSString *countStr = model.data.total;
                if (countStr.length > 0) {
                    wself.totalCount = [countStr integerValue];
                } else {
                    wself.totalCount = 0;
                }
                // count 和 数据要一起变
                wself.subscribeView.totalCount = wself.totalCount;
                [wself.subscribeItems addObjectsFromArray:tempData];
                wself.subscribeView.subscribeItems = wself.subscribeItems;
            } else {
                wself.subscribeView.subscribeItems = NULL;
            }
        } else {
            wself.subscribeView.subscribeItems = NULL;
            if (error && ![error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"the request was cancelled"]) {
                wself.listController.isLoadingData = NO;
                [wself.listController endLoading];
                [wself.listController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            }
        }
        [wself reloadHistoryTableView];
    }];
}

- (void)requestGuessYouWant:(NSInteger)cityId houseType:(NSInteger)houseType {
    if (self.guessHttpTask) {
        [self.guessHttpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.guessHttpTask = [FHHouseListAPI requestGuessYouWant:cityId houseType:houseType class:[FHGuessYouWantResponseModel class] completion:^(FHGuessYouWantResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        wself.loadRequestTimes += 1;
        if (model != NULL && error == NULL) {
            wself.guessYouWantData = model.data.data;
            wself.guessYouWantExtraInfo = model.data.extraInfo;
            [wself reloadHistoryTableView];
        }  else {
            if (error && ![error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"the request was cancelled"]) {
                wself.listController.isLoadingData = NO;
                [wself.listController endLoading];
                [wself.listController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            }
        }
    }];
}


- (void)requestSuggestion:(NSInteger)cityId houseType:(NSInteger)houseType query:(NSString *)query {
    if (self.sugHttpTask) {
        [self.sugHttpTask cancel];
    }
    self.highlightedText = query;
    self.associatedCount += 1;
    __weak typeof(self) wself = self;
    self.sugHttpTask = [FHHouseListAPI requestSuggestionCityId:cityId houseType:houseType query:query class:[FHSuggestionResponseModel class] completion:^(FHSuggestionResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        if (model != NULL && error == NULL) {
            // 构建数据源
            wself.sugListData = model.data;
            [wself.listController.emptyView hideEmptyView];
            [wself reloadSugTableView];
            // 埋点 associate_word_show
            [wself associateWordShow];
        } else {
            if (error && ![error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"the request was cancelled"]) {
                wself.listController.isLoadingData = NO;
                [wself.listController endLoading];
                [wself.listController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            }
        }
    }];
}

// 删除历史记录
- (void)requestDeleteHistoryByHouseType:(NSString *)houseType {
    if (self.delHistoryHttpTask) {
        [self.delHistoryHttpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.delHistoryHttpTask = [FHHouseListAPI requestDeleteSearchHistoryByHouseType:houseType class:[FHSuggestionClearHistoryResponseModel class] completion:^(FHSuggestionClearHistoryResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        if (model != NULL && error == NULL) {
            wself.historyData = NULL;
            [wself.listController.emptyView hideEmptyView];
            [wself reloadHistoryTableView];
        } else {
            if (error && ![error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"the request was cancelled"]) {
                wself.listController.isLoadingData = NO;
                [wself.listController endLoading];
                [wself.listController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
            }
        }
    }];
}

@end
