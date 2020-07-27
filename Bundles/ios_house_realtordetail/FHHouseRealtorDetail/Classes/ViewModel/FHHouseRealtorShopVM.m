//
//  FHHouseRealtorShopVM.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/17.
//

#import "FHHouseRealtorShopVM.h"
#import "TTHttpTask.h"
#import "UIViewAdditions.h"
#import "FHRefreshCustomFooter.h"
#import "FHEnvContext.h"
#import <FHHouseBase/FHSearchChannelTypes.h>
#import "FHMainApi.h"
#import "UIDevice+BTDAdditions.h"
#import "UIScrollView+Refresh.h"
#import "ToastManager.h"
#import "FHHouseBaseItemCell.h"
#import "TTReachability.h"
#import "UIImage+FIconFont.h"
#import "FHRealtorEvaluatingPhoneCallModel.h"
#import "NSObject+YYModel.h"
#import "FHUserTracker.h"
@interface FHHouseRealtorShopVM ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, weak)TTHttpTask *requestTask;
@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHHouseRealtorShopVC *detailController;
@property (nonatomic, strong) FHHouseRealtorShopModel *data;
@property(nonatomic, strong)FHRefreshCustomFooter *refreshFooter;
@property (nonatomic, strong) NSMutableArray *showHouseCache;
@property (nonatomic, strong) FHRealtorDetailBottomBar *bottomBar;
@property(nonatomic, strong) FHRealtorEvaluatingPhoneCallModel *realtorPhoneCallModel;
@property(nonatomic, strong) NSMutableArray *dataList;
@property (nonatomic, assign) NSInteger lastOffset;
@property (nonatomic, strong) NSString *currentSearchId;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong) NSDictionary *realtorInfo;
@property (nonatomic, copy) NSString *houseTotal;
@property (nonatomic , strong) NSMutableDictionary *tracerDict;
@end
@implementation FHHouseRealtorShopVM
- (instancetype)initWithController:(FHHouseRealtorShopVC *)viewController tableView:(UITableView *)tableView realtorDic:(NSDictionary *)realtorDic bottomBar:(FHRealtorDetailBottomBar *)bottomBar tracerDic:(NSDictionary *)tracer {
    self = [super init];
    if (self) {
        self.detailController = viewController;
            self.bottomBar = bottomBar;
        self.tracerDict = tracer;
        self.tableView = tableView;
        [self addGoDetailLog];
        self.realtorPhoneCallModel = [[FHRealtorEvaluatingPhoneCallModel alloc]initWithHouseType:nil houseId:nil];
        self.realtorPhoneCallModel.tracerDict = tracer;
        self.realtorPhoneCallModel.belongsVC = viewController;
        __weak typeof(self)ws = self;
          self.bottomBar.imAction = ^{
              [ws imAction];
          };
          self.bottomBar.phoneAction = ^{
              [ws phoneAction];
          };
        //        self.tableView.backgroundColor = [UIColor themeGray7];
        self.realtorInfo = realtorDic;
        self.houseTotal = @"热卖房源";
       
        [self requestRealtorShop];
        //
    }
    return self;
}

- (void)requestRealtorShop {
    if (![TTReachability isNetworkConnected]) {
        [self onNetworError:YES showToast:YES];
        [self updateNavBarWithAlpha:1];
        return;
    }
    NSMutableDictionary *parmas= [NSMutableDictionary new];
    [parmas setValue:self.realtorInfo[@"realtor_id"]?:@"" forKey:@"realtor_id"];
    // 详情页数据-Main
    __weak typeof(self) wSelf = self;
    [FHMainApi requestRealtorShop:parmas completion:^(FHHouseRealtorShopDetailModel * _Nonnull model, NSError * _Nonnull error) {
        if (model && error == NULL) {
            if (model.data) {
                 [self configTableView];
                self.data = model.data;
                [self requestData:YES first:YES];
                [self loadDataForShop:model];
                [self prossHeaderData:model];
//                [self requestData:YES first:YES];
                //                [wSelf updateUIWithData];
                //                    [wSelf processDetailData:model];
            }
        }
    }];
}

- (void)loadDataForShop:(FHHouseRealtorShopDetailModel *)model {
    if (model.data.realtor) {
        NSString *realtorName = model.data.realtor[@"realtor_name"];
        if (realtorName && realtorName.length>0) {
            self.detailController.customNavBarView.title.text = [NSString stringWithFormat:@"%@店铺",model.data.realtor[@"realtor_name"]];
        }
    }
}

- (void)prossHeaderData:(FHHouseRealtorShopDetailModel *)model {
    NSMutableDictionary *dic = @{}.mutableCopy;
    [dic setObject:model.data.realtor ?:@""forKey:@"realtor"];
    [dic setObject:model.data.houseCount ?:@""forKey:@"house_count"];
    [dic setObject:model.data.chatOpenUrl?:@"" forKey:@"chat_open_url"];
    [dic setObject:model.data.topNeighborhood?:@"" forKey:@"top_neighborhood"];
    [dic setObject:model.data.certificationIcon?:@"" forKey:@"certification_icon"];
    [dic setObject:model.data.certificationPage?:@"" forKey:@"certification_page"];
    [dic setObject:@{@"realtor_id":self.realtorInfo[@"realtor_id"]?:@"",@"screen_width":@([UIScreen mainScreen].bounds.size.width)} forKey:@"common_params"];
    [dic setObject:self.tracerDict?:@"" forKey:@"report_params"];
    if (self.tracerDict) {
         NSString *lynxReortParams= [self.tracerDict yy_modelToJSONString];
             lynxReortParams = [lynxReortParams stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
             
             NSString *unencodedString = lynxReortParams;
             NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                             (CFStringRef)unencodedString,
                                                                                                             NULL,
                                                                                                             (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                             kCFStringEncodingUTF8));
          [dic setObject:lynxReortParams forKey:@"encoded_report_params"];
         }
    [self.detailController.headerView reloadDataWithDic:dic];
    self.detailController.headerView.height = self.detailController.headerView.viewHeight;
     self.tableView.tableHeaderView = self.detailController.headerView;
    if (model.data.houseImage) {
        NSString *imageUrl = model.data.houseImage[@"url"];
        if (imageUrl.length>0) {
            self.detailController.headerView.bacImageUrl = imageUrl;
        }
    }
    [self refNav];
}

-(void)onNetworError:(BOOL)showEmpty showToast:(BOOL)showToast{
    if(showEmpty){
        [self.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        UIImage *whiteBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor blackColor]);
        self.detailController.customNavBarView.title.text = [UIColor blackColor];
        [self.detailController.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateNormal];
        [self.detailController.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateHighlighted];
    }
    if(showToast){
        [[ToastManager manager] showToast:@"网络异常"];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat alpha = offset / (80.0f);
    alpha = fminf(fmaxf(0.0f, alpha), 1.0f);
    [self updateNavBarWithAlpha:alpha];
}
- (void)updateNavBarWithAlpha:(CGFloat)alpha {
    UIImage *whiteBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor whiteColor]);
    UIImage *blackBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]);
    alpha = fminf(fmaxf(0.0f, alpha), 1.0f);
    if (alpha <= 0.1f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.detailController.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateNormal];
        [self.detailController.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateHighlighted];
        self.detailController.customNavBarView.title.textColor = [UIColor whiteColor];
    } else if (alpha > 0.1f && alpha < 0.9f) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        self.detailController.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.detailController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateNormal];
        [self.detailController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateHighlighted];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [self.detailController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateNormal];
        [self.detailController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateHighlighted];
    }
    if(self.detailController.emptyView.hidden == NO) {
        [self.detailController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateNormal];
        [self.detailController.customNavBarView.leftBtn setBackgroundImage:blackBackArrowImage forState:UIControlStateHighlighted];
    }
     self.detailController.customNavBarView.bgView.alpha = alpha;
}

- (void)configTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self registerCellClasses];
    __weak typeof(self) wself = self;
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself requestData:NO first:NO];
    }];
    self.tableView.mj_footer = self.refreshFooter;
}

- (void)registerCellClasses {
    [self.tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:@"FHHomeSmallImageItemCell"];
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
    if (self.requestTask) {
        [self.requestTask cancel];
        self.detailController.isLoadingData = NO;
    }
    if(self.detailController.isLoadingData){
        return;
    }
    self.detailController.isLoadingData = YES;
    
    if(isFirst){
        [self.detailController startLoading];
    }
    __weak typeof(self) wself = self;
    NSMutableDictionary *requestDictonary = [NSMutableDictionary new];
    [requestDictonary setValue:[FHEnvContext getCurrentSelectCityIdFromLocal] forKey:@"city_id"];
    NSInteger offsetValue = self.lastOffset;
    if (isFirst || isHead) {
        [requestDictonary setValue:@(0) forKey:@"offset"];
    }else
    {
        if(self.currentSearchId)
        {
            [requestDictonary setValue:self.currentSearchId forKey:@"search_id"];
        }
        [requestDictonary setValue:@(offsetValue) forKey:@"offset"];
        
    }
    [requestDictonary setValue:@(10) forKey:@"count"];
    [requestDictonary setValue:self.realtorInfo[@"realtor_id"]?:@"" forKey:@"realtor_id"];
    requestDictonary[CHANNEL_ID] = CHANNEL_ID_REALTOR_DETAIL_HOUSE;
    self.requestTask = nil;
    self.requestTask = [FHMainApi requestRealtorHomeRecommend:requestDictonary completion:^(FHHomeHouseModel * _Nonnull model, NSError * _Nonnull error) {
        wself.detailController.isLoadingData = NO;
        [wself.detailController endLoading];
        if (error) {
            //TODO: show handle error
            if(isFirst){
                if(error.code != -999){
                    wself.refreshFooter.hidden = YES;
                }
            }else{
                wself.refreshFooter.hidden = YES;
                [[ToastManager manager] showToast:@"网络异常"];
                [wself updateTableViewWithMoreData:YES];
            }
            [self.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            return;
        }
        if (model.data.items.count > 0) {
            self.detailController.emptyView.hidden = YES;
            [wself updateTableViewWithMoreData:model.data.hasMore];
            if (isFirst) {
                self.dataList = [NSMutableArray arrayWithArray:model.data.items];
                self.lastOffset = model.data.items.count;
            }else {
                [self.dataList addObjectsFromArray:model.data.items];
                self.lastOffset += model.data.items.count;
            }
            if (model.data.total) {
                self.houseTotal = [NSString stringWithFormat:@"热卖房源(%@)",model.data.total];
            }
            [self.tableView reloadData];
        }else {
            [self.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
        }
    }];
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (hasMore) {
        [self.tableView.mj_footer endRefreshing];
    }else {
        [self.refreshFooter setUpNoMoreDataText:@"- 我是有底线的哟 -" offsetY:-3];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, view.width - 30, 28)];
    label.textColor = [UIColor themeGray1];
    label.font = [UIFont themeFontMedium:20];
    label.text = self.houseTotal;
    [view addSubview:label];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 86;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //to do 房源cell
    NSString *identifier = @"FHHomeSmallImageItemCell";
    FHHouseBaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.delegate = self;
    if (indexPath.row < self.dataList.count) {
        JSONModel *model = self.dataList[indexPath.row];
        [cell refreshTopMargin:([UIDevice btd_isIPhoneXSeries]) ? 4 : 0];
        [cell updateHomeSmallImageHouseCellModel:model andType:FHHouseTypeSecondHandHouse];
        [cell hiddenCloseBtn];
    }
    [cell refreshIndexCorner:(indexPath.row == 0) withLast:(indexPath.row == (self.dataList.count - 1))];
    [cell.contentView setBackgroundColor:[UIColor themeHomeColor]];
    return cell;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        NSMutableArray *dataList = [[NSMutableArray alloc]init];
        _dataList = dataList;
    }
    return _dataList;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataList.count>indexPath.row) {
        [self jumpToDetailPage:indexPath];
    }
}
#pragma mark - 详情页跳转
-(void)jumpToDetailPage:(NSIndexPath *)indexPath {
    if (self.dataList.count > indexPath.row) {
        FHHomeHouseDataItemsModel *theModel = self.dataList[indexPath.row];
        
        NSMutableDictionary *traceParam = [NSMutableDictionary new];
        [traceParam addEntriesFromDictionary:self.tracerDict];
        [traceParam setObject:traceParam[@"page_type"] forKey:@"enter_from"];
        NSMutableDictionary *dict = @{@"house_type":@(2),
                                      @"tracer": traceParam
        }.mutableCopy;
        //        dict[INSTANT_DATA_KEY] = theModel;
        dict[@"biz_trace"] = theModel.bizTrace;
        NSURL *jumpUrl = nil;
        jumpUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",theModel.idx]];
        
        if (jumpUrl != nil) {
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:jumpUrl userInfo:userInfo];
        }
    }
}

- (void)imAction{
    FHFeedUGCCellRealtorModel *realtorModel =  [[FHFeedUGCCellRealtorModel alloc]init];
    realtorModel.associateInfo = [self.data.associateInfo copy];
    realtorModel.realtorId = self.realtorInfo[@"realtor_id"];
    realtorModel.chatOpenurl = self.data.chatOpenUrl;
    realtorModel.realtorLogpb = @"";
    [self.realtorPhoneCallModel imchatActionWithPhone:realtorModel realtorRank:0 extraDic:self.tracerDict];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[FHHouseBaseItemCell class]]) {
        FHHomeHouseDataItemsModel *model = self.dataList[indexPath.row];
        [self addHouseShow:model ];
    }
}

- (void)phoneAction{
//     NSDictionary *houseInfo = dataModel.extraDic;
     NSMutableDictionary *extraDict = self.tracerDict.mutableCopy;
     extraDict[@"realtor_id"] = self.realtorInfo[@"realtor_id"];
     extraDict[@"realtor_rank"] = @"be_null";
     extraDict[@"realtor_logpb"] = @"be_null";
     extraDict[@"realtor_position"] = @"realtor_evaluate";
//     extraDict[@"from_gid"] = cellModel.groupId;
     NSDictionary *associateInfoDict = self.data.associateInfo.phoneInfo;
     extraDict[kFHAssociateInfo] = associateInfoDict;
     FHAssociatePhoneModel *associatePhone = [[FHAssociatePhoneModel alloc]init];
     associatePhone.reportParams = extraDict;
     associatePhone.associateInfo = associateInfoDict;
     associatePhone.realtorId = self.realtorInfo[@"realtor_id"];
//     associatePhone.searchId = houseInfo[@"searchId"];
//     associatePhone.imprId = houseInfo[@"imprId"];
//     associatePhone.showLoading = NO;
//     if ([self.currentData isKindOfClass:[FHhouseDetailRGCListCellModel class]]) {
//           FHhouseDetailRGCListCellModel *cellModel = (FHhouseDetailRGCListCellModel *)self.currentData;
//         if (cellModel.houseInfoBizTrace) {
//             associatePhone.extraDict = @{@"biz_trace":cellModel.houseInfoBizTrace};
//         }
//       }
     [self.realtorPhoneCallModel phoneChatActionWithAssociateModel:associatePhone];
}

- (void)addGoDetailLog {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
    params[@"event_type"] = @"house_app2c_v2";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"click";
    params[@"log_pb"] = self.tracerDict[@"log_pb"] ?: @"be_null";
    params[@"rank"] = self.tracerDict[@"rank"] ?: @"be_null";
    params[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    params[@"group_id"] = self.tracerDict[@"group_id"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"realtor_id"] = self.realtorInfo[@"realtor_id"] ?: @"be_null";
    [FHUserTracker writeEvent:@"go_detail" params:params];
}

- (NSMutableArray *)showHouseCache {
    if (!_showHouseCache) {
        _showHouseCache = [NSMutableArray array];
    }
    return _showHouseCache;
}

- (void)addHouseShow:(FHHomeHouseDataItemsModel *)model {
    if (!model.id) {
        return;
    }
    if ([self.showHouseCache containsObject:model.id]) {
        return;
    }
    [self.showHouseCache addObject:model.id];
    NSMutableDictionary *tracerDic = self.tracerDict.mutableCopy;
    tracerDic[@"house_type"] = @"old";
    tracerDic[@"log_pb"] = model.logPb?:@"be_null";
    tracerDic[@"group_id"] = model.id;
    tracerDic[@"element_type"] = @"hot_house";
    TRACK_EVENT(@"house_show", tracerDic);
}
- (void)refNav {
    UIImage *whiteBackArrowImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor whiteColor]);
    self.detailController.customNavBarView.title.textColor = [UIColor whiteColor];
    [self.detailController.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateNormal];
    [self.detailController.customNavBarView.leftBtn setBackgroundImage:whiteBackArrowImage forState:UIControlStateHighlighted];
    [self.detailController.customNavBarView setNaviBarTransparent:YES];
}
@end
