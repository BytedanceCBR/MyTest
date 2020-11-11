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
#import "FHEnvContext.h"
#import <ByteDanceKit/ByteDanceKit.h>
#import "FHSuggestionListViewController+FHTracker.h"

@interface FHChildSuggestionListViewModel () <FHSugSubscribeListDelegate>

@property(nonatomic , weak) FHChildSuggestionListViewController *listController;
@property(nonatomic , weak) TTHttpTask *sugHttpTask;
@property(nonatomic , weak) TTHttpTask *historyHttpTask;
@property(nonatomic , weak) TTHttpTask *guessHttpTask;
@property(nonatomic , weak) TTHttpTask *sugSubscribeTask;
@property(nonatomic , weak) TTHttpTask *delHistoryHttpTask;

@property (nonatomic, strong , nullable) NSMutableArray<FHSuggestionResponseItemModel> *sugListData;
@property (nonatomic, strong , nullable) NSMutableArray<FHSuggestionResponseItemModel> *othersugListData;
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
@property (nonatomic, assign)   BOOL       hasExposedHouseFindFloatButton;
@property (nonatomic, assign)   BOOL       hasExposedHouseFindCard;

//键盘遮挡猜你想搜cell影响埋点上报准确性
@property (nonatomic, strong) NSMutableArray *trackerCacheArr;
@property (nonatomic, assign) BOOL isFirstShow;  //标记是否是首次进入页面
@property (nonatomic, assign) BOOL isUploadedPss;

@end

@implementation FHChildSuggestionListViewModel

-(instancetype)initWithController:(FHChildSuggestionListViewController *)viewController {
    self = [super init];
    if (self) {
        self.listController = viewController;
        self.loadRequestTimes = 0;
        self.guessYouWantData = [NSMutableArray<FHGuessYouWantResponseDataDataModel> new];
        self.subscribeItems = [NSMutableArray<FHSugSubscribeDataDataItemsModel> new];
        self.guessYouWantShowTracerDic = [NSMutableDictionary new];
        self.associatedCount = 0;
        self.hasShowKeyboard = NO;
        self.sectionHeaderView = [[UIView alloc] init];
        self.sectionHeaderView.backgroundColor = [UIColor whiteColor];
        self.isFirstShow = YES;
        self.isUploadedPss = NO;

        [self setupSubscribeView];
        [self setupHistoryView];
        [self initNotification];
        [self startCachingTracker];
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

- (void)viewWillDisappear {
    //页面关闭时，如果键盘仍在存在则清空缓存
    if (![self fatherVC].isTrackerCacheDisabled) {
        [self.trackerCacheArr removeAllObjects];
    }
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotifiction:) name:kFHSuggestionKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(houseTypeDidChanged:) name:kFHSuggestionHouseTypeDidChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sugSubscribeNoti:) name:@"kFHSugSubscribeNotificationName" object:nil];
}

- (void)startCachingTracker {
    if (![self fatherVC].isTrackerCacheDisabled) {
        //缓存的埋点在进入页面延时1秒后尝试上报
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self sendEventTrackerInCache];
            self.isFirstShow = NO;
        });
    }
}

- (void)sendEventTrackerInCache {
    NSInteger totalCount = self.trackerCacheArr.count;
    for (NSInteger i = totalCount-1; i >= 0; i--) {
        if (![self shouldSendAtIndex:i]) {
            continue;
        }
        
        NSDictionary *tracerDic = [self.trackerCacheArr objectAtIndex:i];
        if (tracerDic && [tracerDic isKindOfClass:[NSDictionary class]]) {
            [FHUserTracker writeEvent:@"hot_word_show" params:tracerDic];
            
            [self.trackerCacheArr removeObjectAtIndex:i];
        }
    }
}

- (void)sendAllEvent {
    NSInteger totalCount = self.trackerCacheArr.count;
    for (NSInteger i = totalCount-1; i >= 0; i--) {
        NSDictionary *tracerDic = [self.trackerCacheArr objectAtIndex:i];
        if (tracerDic && [tracerDic isKindOfClass:[NSDictionary class]]) {
            [FHUserTracker writeEvent:@"hot_word_show" params:tracerDic];
            
            [self.trackerCacheArr removeObjectAtIndex:i];
        }
    }
}

- (BOOL)shouldSendAtIndex:(NSInteger)index {
    if (index < 0) {
        return NO;
    }
    //非首次进入，根据键盘高度判断是否可以发送
    if (!self.isFirstShow) {
        if ([self fatherVC].keyboardHeight > 0) {
            return NO;
        } else {
            return YES;
        }
    }
    
    //目前只有一个section，第一个cell是“猜你想找”
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index+1 inSection:0];
    FHGuessYouWantCell *cell = [self.listController.historyTableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        CGRect cellFrame = cell.frame;
        //如果得到的cell上边沿低于键盘的高度，那么暂时缓存，待键盘消失再上报埋点
        CGFloat keyboardHeight = [self fatherVC].keyboardHeight;
        if (cellFrame.origin.y >= self.listController.historyTableView.frame.size.height - keyboardHeight) {
            return NO;
        }
    }
    
    return YES;
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
- (NSMutableArray<FHSuggestionResponseItemModel> *)sugListData{
    if(_sugListData == nil){
        _sugListData = [NSMutableArray<FHSuggestionResponseItemModel> new];
    }
    return _sugListData;
}

- (NSMutableArray<FHSuggestionResponseItemModel> *)othersugListData{
    if(_othersugListData == nil){
        _othersugListData = [NSMutableArray<FHSuggestionResponseItemModel> new];
    }
    return _othersugListData;
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
    
    NSString *openUrl = [NSString stringWithFormat:@"fschema://sug_subscribe_list?house_type=%zi",self.houseType];
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
- (void)subscribeItemClick:(FHSugSubscribeDataDataItemsModel *)model {
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
        [self.listController jumpToCategoryListVCByUrl:jumpUrl queryText:nil placeholder:nil infoDict:infos isGoDetail:NO];
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
    if(model.setHistory){
        [self setHistoryWithURl:model.openUrl displayText:model.text extInfo:model.extinfo];
        tracer[@"element_from"] = @"history";
        tracer[@"enter_from"] = @"search_detail";
        tracer[@"card_type"] = @"left_pic";
        tracer[@"log_pb"] = model.logPb;
        tracer[@"rank"] = [NSString stringWithFormat: @"%zi",index];
    }
    infos[@"tracer"] = tracer;
    [self.listController jumpToCategoryListVCByUrl:jumpUrl queryText:model.text placeholder:model.text infoDict:infos isGoDetail:model.setHistory];
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

- (void)guessYouWantCellClick:(FHGuessYouWantResponseDataDataModel *)model rank:(NSInteger)rank{
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
        if(model.setHistory){
            [self setHistoryWithURl:jumpUrl displayText:model.text extInfo:model.extinfo];
            tracer[@"element_from"] = @"hot";
            tracer[@"enter_from"] = @"search_detail";
            tracer[@"log_pb"] = model.logPb;
            tracer[@"card_type"] = @"left_pic";
            tracer[@"rank"] = [NSString stringWithFormat: @"%zi",rank];
        }
        infos[@"tracer"] = tracer;
        [self.listController jumpToCategoryListVCByUrl:jumpUrl queryText:queryText placeholder:queryText infoDict:infos isGoDetail:model.setHistory];
    }
}


// 联想词Cell点击
- (void)associateWordCellClick:(FHSuggestionResponseItemModel *)model rank:(NSInteger)rank {
    
    // 点击埋点
    NSString *impr_id = [model.logPb btd_stringValueForKey:@"impr_id" default:@"be_null"];
    
    NSDictionary *tracerDic = @{
                                @"word_text":model.text.length > 0 ? model.text : @"be_null",
                                @"associate_cnt":@(self.associatedCount),
                                @"associate_type":[[FHHouseTypeManager sharedInstance] traceValueForType:self.houseType],
                                @"word_id":model.info.wordid.length > 0 ? model.info.wordid : @"be_null",
                                @"element_type":@"search",
                                @"impr_id":impr_id ?: @"be_null",
                                @"rank":@(rank)
                                };
    [FHUserTracker writeEvent:@"associate_word_click" params:tracerDic];
    [[self fatherVC] trackSugWordClickWithmodel:model eventName:@"sug_word_click"];
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
    infos[@"pre_house_type"] = @(self.houseType);
    infos[@"jump_house_type"] = @([model.houseType intValue]);
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
    if([model.houseType intValue] != self.houseType){
        tracer[@"element_from"] = [self elementFromNameByHouseType:[model.houseType intValue]];
    }
    if(model.setHistory){
        [self setHistoryWithURl:model.openUrl displayText:model.text extInfo:nil];
        tracer[@"element_from"] = [model.houseType intValue] == self.houseType ? @"associate" : @"related_new_recommend";
        tracer[@"enter_from"] = @"search_detail";
        tracer[@"log_pb"] = model.logPb;
        tracer[@"card_type"] = @"left_pic";
        tracer[@"rank"] = [NSString stringWithFormat: @"%zi",rank];
    }
    infos[@"tracer"] = tracer;
    [self.listController jumpToCategoryListVCByUrl:jumpUrl queryText:model.text placeholder:model.text infoDict:infos isGoDetail:model.setHistory];
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
        FHSuggestionResponseItemModel *item = self.sugListData[index];
        NSDictionary *dic = @{
                              @"text":item.text.length > 0 ? item.text : @"be_null",
                              @"word_id":item.info.wordid.length > 0 ? item.info.wordid : @"be_null",
                              @"rank":@(index)
                              };
        [wordList addObject:dic];
    }
    NSError *error = NULL;
    NSData *data = [NSJSONSerialization dataWithJSONObject:wordList options:0 error:&error];
    NSString *wordListStr = @"";
    if (data && error == NULL) {
        wordListStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    NSString *impr_id = @"be_null";
    if (self.sugListData.count > 0) {
        FHSuggestionResponseItemModel *item = self.sugListData[0];
        impr_id = [item.logPb btd_stringValueForKey:@"impr_id" default:@"be_null"];
    }
    
    NSDictionary *tracerDic = @{
                                @"word_list":wordListStr.length > 0 ? wordListStr : @"be_null",
                                @"associate_cnt":@(self.associatedCount),
                                @"associate_type":[[FHHouseTypeManager sharedInstance] traceValueForType:self.houseType],
                                @"word_cnt":@(wordList.count),
                                @"element_type":@"search",
                                @"impr_id":impr_id ?: @"be_null",
                                };

    if (_isAssociatedCanTrack) {
        [FHUserTracker writeEvent:@"associate_word_show" params:tracerDic];
    }
}

- (NSString *)createQueryCondition:(id)conditionDic {
    NSString *retStr = @"";
    if ([conditionDic isKindOfClass:[NSString class]]) {
        retStr = conditionDic;
        return retStr;
    }
    NSError *error = NULL;
    NSData *data = [NSJSONSerialization dataWithJSONObject:conditionDic options:0 error:&error];
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

- (NSString *)elementFromNameByHouseType:(NSInteger)houseType{
    if(houseType == FHHouseTypeNewHouse){
        return @"related_new_recommend";
    }else if(houseType == FHHouseTypeSecondHandHouse){
        return @"related_old_recommend";
    }else if(houseType == FHHouseTypeRentHouse){
        return @"related_renting_recommend";
    }else{
        return @"be_null";
    }
        
}
//跳转到帮我找房
- (void)jump2HouseFindPageWithUrl:(NSString *)url from:(NSString *)from {
    if (url.length > 0) {
        //帮我找房埋点修正需要增加origin_from字段
        NSString *originFrom = self.listController.tracerDict[@"origin_from"] ?: @"be_null";
        NSDictionary *tracerInfo = @{
            @"element_from": from.length > 0 ? from : @"be_null",
            @"enter_from": @"search_detail",
            @"origin_from":  originFrom,
        };
        NSURL *openUrl = [NSURL URLWithString:url];
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] init];
        userInfo.allInfo = @{@"tracer": tracerInfo};
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

#pragma mark - Action

- (void)keyboardWillHideNotifiction:(NSNotification *)notification {
    NSNumber *value = notification.object;
    if (value) {
        NSInteger houseType = [value integerValue];
        if ((FHHouseType)houseType == self.houseType) {
            [self sendAllEvent];
        }
    }
}

- (void)houseTypeDidChanged:(NSNotification *)notification {
    if (self.isFirstShow) {
        return;
    }
    
    NSNumber *value = notification.object;
    if (value) {
        NSInteger houseType = [value integerValue];
        if ((FHHouseType)houseType == self.houseType) {
            [self sendEventTrackerInCache];
        }
    }
}

- (FHSuggestionListViewController *)fatherVC {
    return self.listController.fatherVC;
}

#pragma mark - tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 + (self.othersugListData.count > 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        // 猜你想搜
        return self.guessYouWantData.count > 0 ? self.guessYouWantData.count + 1 : 0;
    } else if (tableView.tag == 2) {
        // 联想词
        if (self.sugListData.count + self.othersugListData.count == 0 && !self.listController.isLoadingData && self.listController.fatherVC.naviBar.searchInput.text.length != 0) {
            return 1;
        }
        if(section == 0){
            return self.sugListData.count;
        }
        else if(section == 1){
            return self.othersugListData.count;
        }
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
                [weakSelf jump2HouseFindPageWithUrl:url from:@"driving_find_house_float"];
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
        if (self.sugListData.count == 0 && self.othersugListData.count == 0) {
            //空页面
            FHSuggestionEmptyCell *cell = (FHSuggestionEmptyCell *)[tableView dequeueReusableCellWithIdentifier:@"suggetEmptyCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        NSMutableArray<FHSuggestionResponseItemModel>  *nowsugListData = indexPath.section == 0 ?self.sugListData:self.othersugListData;
        if(nowsugListData.count <= indexPath.row || nowsugListData.count <0){
            return [[UITableViewCell alloc] init];
        }
        //服务端会同时下发cardType=9和cardType=16mcardType=15三种类型的卡片数据
        FHSuggestionResponseItemModel *model = nowsugListData[indexPath.row];
        if(model.cardType == 18){
            FHRecommendtHeaderViewCell *cell = (FHRecommendtHeaderViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RecommendtHeaderCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.label.text = model.text;
            return cell;
        }else if (model.cardType == 9) {
            FHHouseListRecommendTipCell *tipCell = (FHHouseListRecommendTipCell *)[tableView dequeueReusableCellWithIdentifier:@"tipcell" forIndexPath:indexPath];
            FHSearchGuessYouWantTipsModel *tipModel = [[FHSearchGuessYouWantTipsModel alloc] init];
            tipModel.text = model.text;
            [tipCell refreshWithData:tipModel];
            return tipCell;
        } else if (model.cardType == 15) {
            __weak typeof(self) weakSelf = self;
            FHFindHouseHelperCell *helperCell = (FHFindHouseHelperCell *)[tableView dequeueReusableCellWithIdentifier:@"helperCell" forIndexPath:indexPath];
            helperCell.cellTapAction = ^(NSString *url) {
                [weakSelf jump2HouseFindPageWithUrl:url from:@"driving_find_house_card"];
            };
            [helperCell updateWithData:model];
            return helperCell;
        }else if(model.cardType == 16) {
            // 新房
            if (model.houseType.intValue == FHHouseTypeNewHouse) {
                FHSuggestionNewHouseItemCell *cell = (FHSuggestionNewHouseItemCell *)[tableView dequeueReusableCellWithIdentifier:@"suggestNewItemCell" forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                NSAttributedString *text1 = [self processHighlightedDefault:model.text font:[UIFont themeFontSemibold:16] textColor:[UIColor themeGray1]];
                NSAttributedString *text2 = [self processHighlightedDefault:model.text2 font:[UIFont themeFontRegular:14] textColor:[UIColor themeGray3]];
                
                cell.label.attributedText = [self processHighlighted:text1 originText:model.text textColor:[UIColor themeOrange1] fontSize:16.0];
                cell.subLabel.attributedText = [self processHighlighted:text2 originText:model.text2 textColor:[UIColor themeOrange1] fontSize:14.0];
                if(indexPath.row == nowsugListData.count - 1){
                    cell.sepLine.hidden =YES;
                }
                if(model.newtip){
                    cell.secondaryLabel.text = model.newtip.content;
                    cell.secondaryLabel.backgroundColor = [UIColor colorWithHexStr:model.newtip.backgroundcolor];
                    cell.secondaryLabel.textColor = [UIColor colorWithHexStr:model.newtip.textcolor];
                    [cell.secondaryLabel setNeedsLayout];
                    [cell.secondaryLabel layoutIfNeeded];
                    cell.secondaryLabel.textContainerInset = UIEdgeInsetsMake(0, 5, 0, 5);
                }
                cell.secondarySubLabel.text = model.tips2;
                return cell;
            }else if(model.houseType.intValue == FHHouseTypeSecondHandHouse) {// 二手房
                FHOldSuggestionItemCell *cell = (FHOldSuggestionItemCell *)[tableView dequeueReusableCellWithIdentifier:@"FHOldSuggestionItemCell" forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.highlightedText = self.highlightedText;
                if(indexPath.row == nowsugListData.count - 1){
                    cell.sepLine.hidden =YES;
                }
                cell.model = model;
                return cell;
            }else {
                FHSuggestionItemCell *cell = (FHSuggestionItemCell *)[tableView dequeueReusableCellWithIdentifier:@"suggestItemCell" forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                NSString *originText = model.text;
                NSAttributedString *text1 = [self processHighlightedDefault:model.text font:[UIFont themeFontRegular:15.0] textColor:[UIColor themeGray1]];
                NSMutableAttributedString *resultText = [[NSMutableAttributedString alloc] initWithAttributedString:text1];
                if (model.text2.length > 0) {
                    originText = [NSString stringWithFormat:@"%@ (%@)", originText, model.text2];
                    NSAttributedString *text2 = [self processHighlightedGray:model.text2];
                    [resultText appendAttributedString:text2];
                }
                cell.label.attributedText = [self processHighlighted:resultText originText:originText textColor:[UIColor themeOrange1] fontSize:15.0];
                cell.secondaryLabel.text = model.tips;
                if (indexPath.row == nowsugListData.count - 1) {
                    // 末尾
                    [cell.label mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_equalTo(cell.contentView).offset(-20);
                    }];
                } else {
                    [cell.label mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.bottom.mas_equalTo(cell.contentView).offset(0);
                    }];
                }
                return cell;
            }
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
            [self guessYouWantCellClick:model rank:indexPath.row - 1];//
            
        }
    } else if (tableView.tag == 2) {
        // 联想词
        NSMutableArray<FHSuggestionResponseItemModel>  *nowsugListData = indexPath.section == 0 ?self.sugListData:self.othersugListData;
        if (indexPath.row < nowsugListData.count) {
            FHSuggestionResponseItemModel *model  = nowsugListData[indexPath.row];
            if(model.cardType == 16){
                [self associateWordCellClick:model rank:model.rank];
            }
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
        if (self.sugListData.count + self.othersugListData.count == 0) {
            return self.listController.suggestTableView.frame.size.height;
        }else {
            NSMutableArray<FHSuggestionResponseItemModel>  *nowsugListData = indexPath.section == 0 ? self.sugListData:self.othersugListData;
            if(nowsugListData.count <= indexPath.row || nowsugListData.count < 0){
                return 0;
            }
            FHSuggestionResponseItemModel *model = nowsugListData[indexPath.row];
            if(model.cardType == 18){//相关推荐高度
                return 42;
            }else if (model.cardType == 9) {//tips高度
                return 60;
            }else if (model.cardType == 15) {  //帮我找房卡片高度
                return 93;
            }else if (model.houseType.intValue == FHHouseTypeNewHouse) {// 新房
                return 67;
            } else  if (model.houseType.intValue == FHHouseTypeSecondHandHouse) {// 二手房
                return 68;
            }else {
                if (indexPath.row == nowsugListData.count - 1) {
                    return 61;
                } else {
                    return 41;
                }
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
            NSString *recordKey = [NSString stringWithFormat:@"%zi",rank];
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
                
                //有键盘遮挡时，先缓存埋点
                if (![self fatherVC].isTrackerCacheDisabled || self.isFirstShow) {
                    [self.trackerCacheArr addObject:tracerDic];
                } else {
                    [FHUserTracker writeEvent:@"hot_word_show" params:tracerDic];
                }
            }
        }
        //帮我找房浮动按钮埋点
        if ([cell isKindOfClass:[FHSuggestHeaderViewCell class]]) {
            if (!self.guessYouWantExtraInfo || self.hasExposedHouseFindFloatButton) {
                return;
            }
            
            //帮我找房浮动按钮埋点值上报一次
            self.hasExposedHouseFindFloatButton = YES;
            
            NSDictionary *tracerDict = @{
                @"event_type": @"house_app2c_v2",
                @"page_type": @"search_detail",
                @"element_type": @"driving_find_house_float",
            };
            
            [FHUserTracker writeEvent:@"element_show" params:tracerDict];
        }
    } else if (tableView.tag == 2) {
        // 联想词 associate_word_show 埋点 在 返回数据的地方进行一次性埋点
        
        //帮我找房卡片埋点
        if ([cell isKindOfClass:[FHFindHouseHelperCell class]]) {
            if (self.hasExposedHouseFindCard) {
                return;
            }
            
            //帮我找房卡片只曝光一次
            self.hasExposedHouseFindCard = YES;
            
            NSDictionary *tracerDict = @{
                @"event_type": @"house_app2c_v2",
                @"page_type": @"search_detail",
                @"element_type": @"driving_find_house_card",
            };
            
            [FHUserTracker writeEvent:@"element_show" params:tracerDict];
        }
        NSMutableArray<FHSuggestionResponseItemModel>  *nowsugListData = indexPath.section == 0 ? self.sugListData:self.othersugListData;
        if (indexPath.row < nowsugListData.count) {
            FHSuggestionResponseItemModel *model  = nowsugListData[indexPath.row];
            if(model.cardType == 16){
            [[self fatherVC] trackSugWordClickWithmodel:model eventName:@"search_detail_show"];
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 开始拖拽滑动时，收起键盘
    self.listController.fatherVC.collectionView.scrollEnabled = NO;
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}


// 1、默认
- (NSAttributedString *)processHighlightedDefault:(NSString *)text font:(UIFont *)textFont textColor:(UIColor *)textColor {
    NSDictionary *attr = @{NSFontAttributeName:textFont,NSForegroundColorAttributeName:textColor};
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
        NSDictionary *attr = @{NSFontAttributeName:[UIFont themeFontSemibold:fontSize],NSForegroundColorAttributeName:textColor};
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
        if (!self.isUploadedPss && ([[NSDate date] timeIntervalSince1970] - [self startTime] > 0.05) && self.houseType == FHHouseTypeSecondHandHouse) {
            _isUploadedPss = YES;
            [FHMainApi addUserOpenVCDurationLog:@"pss_search" resultType:FHNetworkMonitorTypeSuccess duration:[[NSDate date] timeIntervalSince1970] - [self startTime]];
        }
    }
}

#pragma mark - Request

- (NSTimeInterval) startTime {
    return self.listController.fatherVC.startMonitorTime;
}

-(void)setHistoryWithURl:(NSString *)openUrl displayText:(NSString *)displayText extInfo:(NSString *)extinfo {
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"house_type"] = @(FHHouseTypeNewHouse);
    paramDic[@"display_text"] = displayText ?: @"";
    paramDic[@"open_url"] = openUrl ?: @"";
    paramDic[@"extinfo"] = extinfo ?: @"";
    NSString *cityid = [FHEnvContext getCurrentSelectCityIdFromLocal];
    if(cityid){
        paramDic[@"city_id"] = @([cityid intValue]);
    }
    
    [FHHouseListAPI requestAddHistory:paramDic.copy completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        
    }];
}

- (void)requestSearchHistoryByHouseType:(NSString *)houseType {
    if (self.historyHttpTask) {
        [self.historyHttpTask cancel];
    }
    __weak typeof(self) wself = self;
    self.historyHttpTask = [FHHouseListAPI requestSearchHistoryByHouseType:houseType class:[FHSuggestionSearchHistoryResponseModel class] completion:(FHMainApiCompletion)^(FHSuggestionSearchHistoryResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        wself.loadRequestTimes += 1;
        if (model != NULL && error == NULL) {
            // 构建数据源
            wself.historyData = model.data.data;
            wself.historyView.historyItems = wself.historyData;
            [wself.listController.emptyView hideEmptyView];
            [wself reloadHistoryTableView];
        } else {
            wself.historyView.historyItems = nil;
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
    self.sugSubscribeTask = [FHHouseListAPI requestSugSubscribe:cityId houseType:houseType subscribe_type:2 subscribe_count:50 class:[FHSugSubscribeModel class] completion:(FHMainApiCompletion)^(FHSugSubscribeModel *  _Nonnull model, NSError * _Nonnull error) {
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
    self.guessHttpTask = [FHHouseListAPI requestGuessYouWant:cityId houseType:houseType class:[FHGuessYouWantResponseModel class] completion:(FHMainApiCompletion)^(FHGuessYouWantResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        wself.loadRequestTimes += 1;
        if (model != NULL && error == NULL) {
            __strong typeof(wself) strongSelf = wself;
            strongSelf.guessYouWantData = [NSMutableArray<FHGuessYouWantResponseDataDataModel> arrayWithArray:model.data.data];
            strongSelf.guessYouWantExtraInfo = model.data.extraInfo;
            [strongSelf reloadHistoryTableView];
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
    self.sugHttpTask = [FHHouseListAPI requestSuggestionCityId:cityId houseType:houseType query:query class:[FHSuggestionResponseModel class] completion:(FHMainApiCompletion)^(FHSuggestionResponseModel *  _Nonnull model, NSError * _Nonnull error) {
        if (model != NULL && error == NULL) {
            self.jumpHouseType = model.data.jumpHouseType;// 构建数据源
            [wself.sugListData removeAllObjects];
            [wself.othersugListData removeAllObjects];
            [wself.sugListData addObjectsFromArray:model.data.items];
            if(model.data.otherItems.count > 0){
                FHSuggestionResponseItemModel *tepmodel = [[FHSuggestionResponseItemModel alloc] init];
                tepmodel.cardType = 18;
                FHSuggestionResponseItemModel *firstmodel = model.data.otherItems[0];
                tepmodel.text = [self getTitletext:[firstmodel.houseType intValue]];
                [wself.othersugListData addObject:tepmodel];
                [wself.othersugListData addObjectsFromArray:model.data.otherItems];
            }
            [wself.listController.emptyView hideEmptyView];
            [wself reloadSugTableView];
            [wself.listController.fatherVC trackSuggestionWithWord:query houseType:houseType result:model];
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
    self.delHistoryHttpTask = [FHHouseListAPI requestDeleteSearchHistoryByHouseType:houseType class:[FHSuggestionClearHistoryResponseModel class] completion:(FHMainApiCompletion)^(FHSuggestionClearHistoryResponseModel *  _Nonnull model, NSError * _Nonnull error) {
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

- (NSMutableArray *)trackerCacheArr {
    if (!_trackerCacheArr) {
        _trackerCacheArr = [[NSMutableArray alloc] init];
    }
    
    return _trackerCacheArr;;
}

- (NSString *)getTitletext:(NSInteger)housetype{
    if(housetype == FHHouseTypeNewHouse){
        return @"相关新房推荐";
    }else if(housetype == FHHouseTypeSecondHandHouse){
        return @"相关二手房推荐";
    }else if(housetype == FHHouseTypeRentHouse){
        return  @"相关租房推荐";
    }else if(housetype == FHHouseTypeNeighborhood){
        return @"相关小区推荐";
    }else {
        return @"";
    }
}
@end
