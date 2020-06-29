//
//  FHHouseDetailBaseViewModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHHouseDetailBaseViewModel.h"
#import "FHHouseNeighborhoodDetailViewModel.h"
#import "FHHouseOldDetailViewModel.h"
#import "FHHouseNewDetailViewModel.h"
#import "FHHouseRentDetailViewModel.h"
#import "FHDetailBaseCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <TTAccountLogin/TTAccountLoginManager.h>
#import "FHDetailOldModel.h"
#import "FHDetailRentModel.h"
#import <FHHouseBase/FHEnvContext.h>
#import <FHHouseBase/FHURLSettings.h>
#import "FHHouseDetailAPI.h"
#import <TTReachability/TTReachability.h>
#import "FHDetailQuestionPopView.h"
#import "FHDetailMediaHeaderCorrectingCell.h"
#import "FHHouseErrorHubManager.h"

@interface FHHouseDetailBaseViewModel ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)   NSMutableDictionary       *cellHeightCaches;
@property (nonatomic, strong)   NSMutableDictionary       *elementShowCaches;
//目前背景阴影用图表示,该数组表示模块集合，根据模块内容来添加阴影图片
@property (nonatomic, strong)   NSMutableDictionary *elementShdowGroup;
@property (nonatomic, strong)   NSHashTable               *weakedCellTable;
@property (nonatomic, strong)   NSHashTable               *weakedVCLifeCycleCellTable;
@property (nonatomic, assign)   CGPoint       lastPointOffset;
@property (nonatomic, assign)   BOOL          scretchingWhenLoading;
@property (nonatomic, assign) BOOL floatIconAnimation;
@property (nonatomic, assign) BOOL clickShowIcon;
@property(nonatomic, assign) CGPoint tableviewBeginOffSet;

@end

@implementation FHHouseDetailBaseViewModel

+(instancetype)createDetailViewModelWithHouseType:(FHHouseType)houseType withController:(FHHouseDetailViewController *)viewController tableView:(UITableView *)tableView {
    FHHouseDetailBaseViewModel *viewModel = NULL;
    switch (houseType) {
        case FHHouseTypeSecondHandHouse:
            viewModel = [[FHHouseOldDetailViewModel alloc] initWithController:viewController tableView:tableView houseType:houseType];
            break;
        case FHHouseTypeNewHouse:
            viewModel = [[FHHouseNewDetailViewModel alloc] initWithController:viewController tableView:tableView houseType:houseType];
            break;
        case FHHouseTypeRentHouse:
            viewModel = [[FHHouseRentDetailViewModel alloc] initWithController:viewController tableView:tableView houseType:houseType];
            break;
        case FHHouseTypeNeighborhood:
            viewModel = [[FHHouseNeighborhoodDetailViewModel alloc] initWithController:viewController tableView:tableView houseType:houseType];
            break;
        default:
            break;
    }
    return viewModel;
}

-(instancetype)initWithController:(FHHouseDetailViewController *)viewController tableView:(UITableView *)tableView houseType:(FHHouseType)houseType {
    self = [super init];
    if (self) {
        _detailTracerDic = [NSMutableDictionary new];
        _items = [NSMutableArray new];
        _cellHeightCaches = [NSMutableDictionary new];
        _elementShowCaches = [NSMutableDictionary new];
        _elementShdowGroup = [NSMutableDictionary new];
        _lastPointOffset = CGPointZero;
        _weakedCellTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        _weakedVCLifeCycleCellTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        self.houseType = houseType;
        self.detailController = viewController;
        self.tableView = tableView;
        self.tableView.backgroundColor = [UIColor themeGray7];
        [self configTableView];
    }
    return self;
}

- (NSMutableArray *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    _tableView.backgroundColor = [UIColor colorWithRed:252 green:252 blue:252 alpha:1];
//    self.detailController.view.backgroundColor = [UIColor redColor];
    [self registerCellClasses];
}

- (void)reloadData {
    
    CGRect frame = self.tableView.frame;
    [self.tableView reloadData];
    //防止滑动卡顿，测试前关闭
    
    
    
    
    
    
    
//    if (!self.scretchingWhenLoading) {
//        self.tableView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width,10000);//设置大frame 强制计算cell高度
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.tableView.frame = frame;
//        });
//        if (![self currentIsInstantData]) {
//            self.scretchingWhenLoading = YES;
//        }
//    }
    
    
    
    
}

// 回调方法
- (void)vc_viewDidAppear:(BOOL)animated {
    if (self.weakedVCLifeCycleCellTable.count > 0) {
        NSArray *arr = self.weakedVCLifeCycleCellTable.allObjects;
        [arr enumerateObjectsUsingBlock:^(FHDetailBaseCell *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[FHDetailBaseCell class]] && self.detailController) {
                if ([obj conformsToProtocol:@protocol(FHDetailVCViewLifeCycleProtocol)]) {
                    [((id<FHDetailVCViewLifeCycleProtocol>)obj) vc_viewDidAppear:animated];
                }
            }
        }];
    }
    [self addPopLayerNotification];
    [self.contactViewModel vc_viewDidAppear:animated];
}

- (void)vc_viewDidDisappear:(BOOL)animated {
    if (self.weakedVCLifeCycleCellTable.count > 0) {
        NSArray *arr = self.weakedVCLifeCycleCellTable.allObjects;
        [arr enumerateObjectsUsingBlock:^(FHDetailBaseCell *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[FHDetailBaseCell class]] && self.detailController) {
                if ([obj conformsToProtocol:@protocol(FHDetailVCViewLifeCycleProtocol)]) {
                    [((id<FHDetailVCViewLifeCycleProtocol>)obj) vc_viewDidDisappear:animated];
                }
            }
        }];
    }
    [self removePopLayerNotification];
    [self.contactViewModel vc_viewDidDisappear:animated];
}


-(BOOL)currentIsInstantData
{
    return NO;
}

- (void)setQuestionBtn:(FHDetailQuestionButton *)questionBtn
{
    _questionBtn = questionBtn;
    [_questionBtn.btn addTarget:self action:@selector(questionBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)questionBtnDidClick:(UIButton *)btn
{
    [self addQuickQuestionClickOptionLog:NO];
    FHDetailOldDataModel *dataModel = nil;
    if ([self.detailData isKindOfClass:[FHDetailOldModel class]]) {
        dataModel = [(FHDetailOldModel*)self.detailData data];
    }
    
    if (dataModel.quickQuestion.questionItems.count < 1) {
        return;
    }
    __weak typeof(self)wself = self;
    NSMutableArray *menus = @[].mutableCopy;
    for (NSInteger index = 0; index < dataModel.quickQuestion.questionItems.count; index++) {
        FHDetailDataQuickQuestionItemModel *model = dataModel.quickQuestion.questionItems[index];
        FHDetailQuestionPopMenuItem *item = [[FHDetailQuestionPopMenuItem alloc]init];
        item.index = index;
        item.model = model;
        item.itemClickBlock = ^(FHDetailQuestionPopMenuItem *menuItem) {
            FHDetailDataQuickQuestionItemModel *model = menuItem.model;
            [wself addclickAskQuestionLog:model rank:@(menuItem.index)];
            [wself imAction:model];
        };
        item.title = model.text;
        [menus addObject:item];
    }
    FHDetailQuestionPopView *popView = [[FHDetailQuestionPopView alloc]init];
    [popView updateTitle:dataModel.quickQuestion.buttonContent];
    popView.menus = menus;
    popView.completionBlock = ^{
        wself.questionBtn.hidden = NO;
        wself.questionBtn.isFold = YES;
        [wself addQuickQuestionClickOptionLog:YES];
    };
    UIView *view = self.questionBtn;
    [popView showAtPoint:view.origin parentView:self.detailController.view];
    self.questionBtn.hidden = YES;
}

- (void)imAction:(FHDetailDataQuickQuestionItemModel *)model
{
    // 快捷提问已经下线，后期可以考虑下掉相关代码，因为模块涉及的代码量大，本期只下掉im入口
//    if (![model isKindOfClass:[FHDetailDataQuickQuestionItemModel class]]) {
//        return;
//    }
//    NSMutableDictionary *imExtra = @{}.mutableCopy;
//    imExtra[@"realtor_position"] = @"be_null";
//    imExtra[@"source_from"] = @"house_ask_question";
//    imExtra[@"im_open_url"] = model.openUrl;
//    imExtra[@"question_id"] = model.id;
//    [self.contactViewModel onlineActionWithExtraDict:imExtra];
}

#pragma mark - 需要子类实现的方法
// 注册cell类型
- (void)registerCellClasses {
    // sub implements.........
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}
// cell class
- (Class)cellClassForEntity:(id)model {
    // sub implements.........
    // Donothing
    return [FHDetailBaseCell class];
}
// cell identifier
- (NSString *)cellIdentifierForEntity:(id)model {
    // sub implements.........
    // Donothing
    return @"";
}
// 网络数据请求
- (void)startLoadData {
    // sub implements.........
    // Donothing
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.items.count) {
        id data = self.items[row];
        NSString *identifier = NSStringFromClass([data class]);//[self cellIdentifierForEntity:data];
        if (identifier.length > 0) {
            FHDetailBaseCell *cell = (FHDetailBaseCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (self.houseType == FHHouseTypeSecondHandHouse || self.houseType == FHHouseTypeNeighborhood || self.houseType == FHHouseTypeNewHouse) {
                cell.backgroundColor = [UIColor clearColor];
            }
            if (cell) {
                cell.baseViewModel = self;
                [cell refreshWithData:data];
                return cell;
            }else{
                NSLog(@"nil cell for data: %@",data);
            }
            
        }
    }
    return [[UITableViewCell alloc] init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FHDetailBaseCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.didClickCellBlk) {
        cell.didClickCellBlk();
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    NSNumber *cellHeight = self.cellHeightCaches[tempKey];
    if (cellHeight) {
        return [cellHeight floatValue];
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self currentIsInstantData]) {
        //当前是列表页带入的数据，不上报埋点
        return;
    }
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    NSNumber *cellHeight = [NSNumber numberWithFloat:cell.frame.size.height];
    self.cellHeightCaches[tempKey] = cellHeight;
    CGFloat originY = tableView.contentOffset.y;
    CGFloat cellOriginY = cell.frame.origin.y;
    CGFloat winH = [UIScreen mainScreen].bounds.size.height;
    // 起始位置，超出屏幕时不上报 element_show 埋点
    if (cellOriginY - originY > winH * 1.2 && originY <= 0) {
        // 超出屏幕
        return;
    }
    if ([cell conformsToProtocol:@protocol(FHDetailScrollViewDidScrollProtocol)] && ![self.weakedCellTable containsObject:cell]) {
        [self.weakedCellTable addObject:cell];
    }
    if ([cell conformsToProtocol:@protocol(FHDetailVCViewLifeCycleProtocol)] && ![self.weakedVCLifeCycleCellTable containsObject:cell]) {
        [self.weakedVCLifeCycleCellTable addObject:cell];
    }
    // will display
    if ([cell isKindOfClass:[FHDetailBaseCell class]]) {
        FHDetailBaseCell *tCell = (FHDetailBaseCell *)cell;
        [tCell fh_willDisplayCell];
    }
    // 添加element_show埋点
    if (!self.elementShowCaches[tempKey]) {
        self.elementShowCaches[tempKey] = @(YES);
        FHDetailBaseCell *tempCell = (FHDetailBaseCell *)cell;
        NSString *element_type = [tempCell elementTypeString:self.houseType];
        if ([element_type isEqualToString:@"trade_tips"]) {
            if (!self.contactViewModel.contactPhone.unregistered) {
                [self addLeadShowLog:self.contactViewModel.contactPhone];
            }
        }
        if (element_type.length > 0) {
            // 上报埋点
            NSMutableDictionary *tracerDic = self.detailTracerDic.mutableCopy;
            tracerDic[@"element_type"] = element_type;
            [tracerDic removeObjectForKey:@"element_from"];
            if ([element_type isEqualToString:@"recommend_new"]) {
                tracerDic[@"event_tracking_id"] = @"234883";
            }
            if ([element_type isEqualToString:@"report"]) {
                tracerDic[@"biz_trace"] = self.houseInfoBizTrace;
            }
            
            [FHUserTracker writeEvent:@"element_show" params:tracerDic];
            [[FHHouseErrorHubManager sharedInstance] checkBuryingPointWithEvent:@"element_show" Params:tracerDic errorHubType:FHErrorHubTypeBuryingPoint];
        }
        NSArray *element_array = [tempCell elementTypeStringArray:self.houseType];
        if (element_array.count > 0) {
            for (NSString * element_name in element_array) {
                if ([element_name isKindOfClass:[NSString class]]) {
                    // 上报埋点x
                    NSMutableDictionary *tracerDic = self.detailTracerDic.mutableCopy;
                    tracerDic[@"element_type"] = element_name;
                    [tracerDic removeObjectForKey:@"element_from"];
                    [FHUserTracker writeEvent:@"element_show" params:tracerDic];
                }
            }
        }
        NSDictionary * houseShowDict = [tempCell elementHouseShowUpload];
        if (houseShowDict.allKeys.count > 0) {
            // 上报埋点
            NSMutableDictionary *tracerDic = self.detailTracerDic.mutableCopy;
            [tracerDic addEntriesFromDictionary:houseShowDict];
            [tracerDic removeObjectForKey:@"element_from"];
            [FHUserTracker writeEvent:@"house_show" params:tracerDic];
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath NS_AVAILABLE_IOS(6_0);{
    // end display
    if ([cell isKindOfClass:[FHDetailBaseCell class]]) {
        FHDetailBaseCell *tCell = (FHDetailBaseCell *)cell;
        [tCell fh_didEndDisplayingCell];
    }
}

- (void)showQuestionBtn:(BOOL)isShow
{
    if(isShow && (CGRectGetMaxX(self.questionBtn.frame) - [UIScreen mainScreen].bounds.size.width) < 0){
        return;
    }
    
    if(!isShow && (CGRectGetMaxX(self.questionBtn.frame) - [UIScreen mainScreen].bounds.size.width) > 0){
        return;
    }
    
    if ([self clickShowIcon]) {
        return;
    }
    
    self.floatIconAnimation = YES;
    FHDetailQuestionButton *questionBtn = self.questionBtn;
    CGFloat btnWidth = [questionBtn totalWidth];
    [UIView animateWithDuration:0.2f animations:^{
        
        CGFloat right = isShow ? -20 : btnWidth - 26;
        [self.questionBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(right);
        }];
        [self.detailController.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.floatIconAnimation = NO;
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.clickShowIcon = NO;
    self.tableviewBeginOffSet = scrollView.contentOffset;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.tableView) {
        return;
    }
    
    // 解决类似周边房源列表页的house_show问题，视频播放逻辑
    CGPoint offset = scrollView.contentOffset;
    if (self.weakedCellTable.count > 0) {
        NSArray *arr = self.weakedCellTable.allObjects;
        [arr enumerateObjectsUsingBlock:^(FHDetailBaseCell *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[FHDetailBaseCell class]] && self.detailController) {
                if ([obj conformsToProtocol:@protocol(FHDetailScrollViewDidScrollProtocol)]) {
                    [((id<FHDetailScrollViewDidScrollProtocol>)obj) fhDetail_scrollViewDidScroll:self.detailController.view];
                }
            }
        }];
    }
    self.lastPointOffset = offset;
    
    [self.detailController refreshContentOffset:scrollView.contentOffset];
    
    CGFloat diff = scrollView.contentOffset.y - self.tableviewBeginOffSet.y;
    
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentYoffset = scrollView.contentOffset.y;
    CGFloat distance = scrollView.contentSize.height - height;
    if(fabs(diff) < 1 ){
        return;
    }
    if (contentYoffset <= 0) {
        //        [self showQuestionBtn:NO];
        return;
    }
    if (contentYoffset >= distance) {
        //        [self showQuestionBtn:YES];
        return;
    }
    self.questionBtn.userInteractionEnabled = NO;
    if(fabs(diff) > 10){
        [self showQuestionBtn:NO];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView != self.tableView) {
        return;
    }
    self.questionBtn.userInteractionEnabled = YES;
    [self showQuestionBtn:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView != self.tableView) {
        return;
    }
    if (decelerate) {
        return;
    }
    self.questionBtn.userInteractionEnabled = YES;
    [self showQuestionBtn:YES];
}

#pragma mark - 埋点

- (NSString *)pageTypeString
{
    switch (self.houseType) {
        case FHHouseTypeNewHouse:
            return @"new_detail";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"old_detail";
            break;
        case FHHouseTypeRentHouse:
            return @"rent_detail";
            break;
        case FHHouseTypeNeighborhood:
            return @"neighborhood_detail";
            break;
        default:
            return @"be_null";
            break;
    }
}

- (void)addGoDetailLog
{
    //    1. event_type ：house_app2c_v2
    //    2. page_type（详情页类型）：rent_detail（租房详情页），old_detail（二手房详情页）
    //    3. card_type（房源展现时的卡片样式）：left_pic（左图）
    //    4. enter_from（详情页入口）：search_related_list（搜索结果推荐）
    //    5. element_from ：search_related
    //    6. rank
    //    7. origin_from
    //    8. origin_search_id
    //    9.log_pb
    NSMutableDictionary *params = @{}.mutableCopy;
    if (self.detailTracerDic) {
        [params addEntriesFromDictionary:self.detailTracerDic];
    }
    if (self.houseType == FHHouseTypeNeighborhood || self.houseType == FHHouseTypeSecondHandHouse) {
        params[@"growth_deepevent"] = @(1);
    }
    if(self.houseType == FHHouseTypeSecondHandHouse){
        params[@"biz_trace"] = self.houseInfoOriginBizTrace;
    }
    params[kFHClueExtraInfo] = self.extraInfo;
    if (self.houseId.length) {
        params[@"group_id"] = self.houseId;
    }
    [FHUserTracker writeEvent:@"go_detail" params:params];
}

- (NSDictionary *)subPageParams
{
    NSMutableDictionary *info = @{}.mutableCopy;
    if (self.contactViewModel) {
        info[@"follow_status"] = @(self.contactViewModel.followStatus);
    }
    if (self.contactViewModel.contactPhone) {
        info[@"contact_phone"] = self.contactViewModel.contactPhone;
    }
    if (self.contactViewModel.chooseAgencyList) {
        info[@"choose_agency_list"] = self.contactViewModel.chooseAgencyList;
    }
    info[@"house_type"] = @(self.houseType);
    switch (_houseType) {
        case FHHouseTypeNewHouse:
            info[@"court_id"] = self.houseId;
            break;
        case FHHouseTypeSecondHandHouse:
            info[@"house_id"] = self.houseId;
            break;
        case FHHouseTypeRentHouse:
            info[@"house_id"] = self.houseId;
            break;
        case FHHouseTypeNeighborhood:
            info[@"neighborhood_id"] = self.houseId;
            break;
        default:
            info[@"house_id"] = self.houseId;
            break;
    }
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    [tracerDict addEntriesFromDictionary:self.detailTracerDic];
    info[@"tracer"] = tracerDict;
    return info;
}

- (void)addLeadShowLog:(FHDetailContactModel *)contactPhone
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"event_type"] = @"house_app2c_v2";
    params[@"element_type"] = @"trade_tips";
    params[@"page_type"] = self.detailTracerDic[@"page_type"];
    params[@"card_type"] = self.detailTracerDic[@"card_type"];
    params[@"element_from"] = self.detailTracerDic[@"element_from"];
    params[@"enter_from"] = self.detailTracerDic[@"enter_from"];
    params[@"origin_from"] = self.detailTracerDic[@"origin_from"];
    params[@"origin_search_id"] = self.detailTracerDic[@"origin_search_id"];
    params[@"rank"] = self.detailTracerDic[@"rank"];
    params[@"log_pb"] = self.detailTracerDic[@"log_pb"];
    params[@"click_position"] = @"house_ask_question";
    params[@"is_im"] = !isEmptyString(contactPhone.imOpenUrl) ? @"1" : @"0";
    params[@"is_call"] =  @"0";
    params[@"biz_trace"] = contactPhone.bizTrace;
    params[@"is_report"] = @"0";
    params[@"is_online"] = contactPhone.unregistered?@"1":@"0";
    [FHUserTracker writeEvent:@"lead_show" params:params];
}

- (void)addStayPageLog:(NSTimeInterval)stayTime
{
    //    1. event_type ：house_app2c_v2
    //    2. page_type（详情页类型）：rent_detail（租房详情页），old_detail（二手房详情页）
    //    3. card_type（房源展现时的卡片样式）：left_pic（左图）
    //    4. enter_from（详情页入口）：search_related_list（搜索结果推荐）
    //    5. element_from ：search_related
    //    6. rank
    //    7. origin_from
    //    8. origin_search_id
    //    9.log_pb
    //    10.stay_time
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:self.detailTracerDic];
    params[@"stay_time"] = [NSNumber numberWithInteger:duration];
    params[kFHClueExtraInfo] = self.extraInfo;
    if(self.houseType == FHHouseTypeSecondHandHouse){
        params[@"biz_trace"] = self.houseInfoOriginBizTrace;
    }
    [FHUserTracker writeEvent:@"stay_page" params:params];
    
}

- (void)addclickAskQuestionLog:(FHDetailOldDataModel *)model rank:(NSNumber *)rank
{
    //    1.event_type：house_app2c_v2
    //    2.page_type（页面类型）：old_detail（二手房详情页）
    //    3.element_from ：(与go_detail进入详情页的上传参数保持一致)
    //    4.enter_from：
    //    5. origin_from
    //    6. origin_search_id
    //    7.log_pb
    //    8.rank:
    //    9.question_id：问题id
    NSMutableDictionary *params = @{}.mutableCopy;
    if (self.detailTracerDic) {
        [params addEntriesFromDictionary:self.detailTracerDic];
    }
    params[@"rank"] = rank ? : @"be_null";
    params[@"question_id"] = model.id ? : @"be_null";
    [FHUserTracker writeEvent:@"click_ask_question" params:params];
    
}

- (void)addQuickQuestionClickOptionLog:(BOOL)isFold
{
    //    1.event_type：house_app2c_v2
    //    2.page_type（页面类型）：old_detail（二手房详情页）
    //    3.element_from ：(与go_detail进入详情页的上传参数保持一致)
    //    4.enter_from：
    //    5. origin_from
    //    6. origin_search_id
    //    7.log_pb
    //    8.click_position：house_ask_question（提问按钮）
    //    9.show_type：展示状态：“问题内容展开”：“open”；“问题内容收起”：“close”
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"page_type"] = self.detailTracerDic[@"page_type"];
    params[@"element_from"] = self.detailTracerDic[@"element_from"];
    params[@"enter_from"] = self.detailTracerDic[@"enter_from"];
    params[@"origin_from"] = self.detailTracerDic[@"origin_from"];
    params[@"origin_search_id"] = self.detailTracerDic[@"origin_search_id"];
    params[@"log_pb"] = self.detailTracerDic[@"log_pb"];
    params[@"click_position"] = @"house_ask_question";
    params[@"show_type"] = isFold ? @"close" : @"open";
    [FHUserTracker writeEvent:@"click_options" params:params];
    
}

- (BOOL)isMissTitle
{
    return NO;
}
- (BOOL)isMissImage
{
    return NO;
}
- (BOOL)isMissCoreInfo
{
    return NO;
}

// excetionLog
- (void)addDetailCoreInfoExcetionLog
{
    //    detail_core_info_error
    NSMutableDictionary *attr = @{}.mutableCopy;
    NSInteger status = 0;
    if ([self isMissTitle]) {
        attr[@"title"] = @(1);
        attr[@"house_id"] = self.houseId;
        status |= FHDetailCoreInfoErrorTypeTitle;
    }
    if ([self isMissImage]) {
        attr[@"image"] = @(1);
        attr[@"house_id"] = self.houseId;
        status |= FHDetailCoreInfoErrorTypeImage;
    }
    if ([self isMissCoreInfo]) {
        attr[@"core_info"] = @(1);
        attr[@"house_id"] = self.houseId;
        status |= FHDetailCoreInfoErrorTypeCoreInfo;
    }
    attr[@"house_type"] = @(self.houseType);
    if (status != 0) {
        [[HMDTTMonitor defaultManager]hmdTrackService:@"detail_core_info_error" status:status extra:attr];
    }
    
}

- (void)addDetailRequestFailedLog:(NSInteger)status message:(NSString *)message
{
    NSMutableDictionary *attr = @{}.mutableCopy;
    attr[@"message"] = message;
    attr[@"house_type"] = @(self.houseType);
    attr[@"house_id"] = self.houseId;
    [[HMDTTMonitor defaultManager]hmdTrackService:@"detail_request_failed" status:status extra:attr];
}

- (void)enableController:(BOOL)enabled
{
    TTNavigationController *nav = self.detailController.navigationController;
    nav.panRecognizer.enabled = enabled;
}
#pragma mark - poplayer

- (void)addPopLayerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShowPoplayerNotification:) name:DETAIL_SHOW_POP_LAYER_NOTIFICATION object:nil];
}
- (void)removePopLayerNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DETAIL_SHOW_POP_LAYER_NOTIFICATION object:nil];
}
- (void)onShowPoplayerNotification:(NSNotification *)notification
{
    
}

- (FHDetailHalfPopLayer *)popLayer
{
    FHDetailHalfPopLayer *poplayer = [[FHDetailHalfPopLayer alloc] initWithFrame:self.detailController.view.bounds];
    __weak typeof(self) wself = self;
    poplayer.reportBlock = ^(id  _Nonnull data) {
        [wself popLayerReport:data];
    };
    poplayer.feedBack = ^(NSInteger type, id  _Nonnull data, void (^ _Nonnull compltion)(BOOL)) {
        [wself poplayerFeedBack:data type:type completion:compltion];
    };
    poplayer.dismissBlock = ^{
        [wself enableController:YES];
        wself.tableView.scrollsToTop = YES;
    };
    
    [self.detailController.view addSubview:poplayer];
    return poplayer;
}

-(void)popLayerReport:(id)model
{
    NSString *enterFrom = @"be_null";
    if ([model isKindOfClass:[FHDetailDataBaseExtraOfficialModel class]]) {
        enterFrom = @"official_inspection";
    }else if ([model isKindOfClass:[FHDetailDataBaseExtraDetectiveModel class]]){
        enterFrom = @"happiness_eye";
        FHDetailDataBaseExtraDetectiveModel *detective = (FHDetailDataBaseExtraDetectiveModel *)model;
        if (detective.fromDetail) {
            enterFrom = @"happiness_eye_detail";
        }
    }else if ([model isKindOfClass:[FHRentDetailDataBaseExtraModel class]]){
        enterFrom = @"transaction_remind";
    }
    
    NSMutableDictionary *tracerDic = self.detailTracerDic.mutableCopy;
    tracerDic[@"enter_from"] = enterFrom;
    tracerDic[@"log_pb"] = self.listLogPB ?: @"be_null";
    [FHUserTracker writeEvent:@"click_feedback" params:tracerDic];
    
    if(self.houseType == FHHouseTypeSecondHandHouse)
    {
        [self gotoReportVC:model];
    }else
    {
        if ([TTAccountManager isLogin]) {
            [self gotoReportVC:model];
        } else {
            [self gotoLogin:model enterFrom:enterFrom];
        }
    }
}

- (void)gotoLogin:(id)model enterFrom:(NSString *)enterFrom
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:enterFrom forKey:@"enter_from"];
    [params setObject:@"feedback" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(NO) forKey:@"need_pop_vc"];
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                [wSelf gotoReportVC:model];
            }
            // 移除登录页面
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [wSelf delayRemoveLoginVC];
            });
        }
    }];
}

// 二手房-房源问题反馈
- (void)gotoReportVC:(id)model
{    
    NSString *reportUrl = nil;
    if ([model isKindOfClass:[FHDetailDataBaseExtraOfficialModel class]]) {
        reportUrl = [(FHDetailDataBaseExtraOfficialModel *)model dialogs].reportUrl;
    }else if ([model isKindOfClass:[FHDetailDataBaseExtraDetectiveModel class]]){
        reportUrl = [(FHDetailDataBaseExtraDetectiveModel *)model dialogs].reportUrl;
    }else if ([model isKindOfClass:[FHRentDetailDataBaseExtraModel class]]){
        reportUrl = [(FHRentDetailDataBaseExtraModel *)model securityInformation].dialogs.reportUrl;
    }
    
    if(reportUrl.length == 0){
        return;
    }
    
    JSONModel *dataModel = nil;
    if ([self.detailData isKindOfClass:[FHDetailOldModel class]]) {
        dataModel = [(FHDetailOldModel*)self.detailData data];
    }else if ([self.detailData isKindOfClass:[FHRentDetailResponseModel class]]){
        dataModel = [(FHRentDetailResponseModel *)self.detailData data];
    }else if([self.detailData respondsToSelector:@selector(data)]){
        dataModel = [self.detailData performSelector:@selector(data)];
    }else{
        dataModel = self.detailData;
    }
    
    NSDictionary *jsonDic = [dataModel toDictionary];
    if (jsonDic) {
        
        NSString *openUrl = @"sslocal://webview";
        NSDictionary *pageData = @{@"data":jsonDic};
        NSDictionary *commonParams = [[FHEnvContext sharedInstance] getRequestCommonParams];
        if (commonParams == nil) {
            commonParams = @{};
        }
        NSDictionary *commonParamsData = @{@"data":commonParams};
        NSDictionary *jsParams = @{@"requestPageData":pageData,
                                   @"getNetCommonParams":commonParamsData
                                   };
        NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",host,reportUrl];
        NSDictionary *info = @{@"url":urlStr,@"fhJSParams":jsParams,@"title":@"房源问题反馈"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:openUrl] userInfo:userInfo];
    }
}

- (void)delayRemoveLoginVC {
    UINavigationController *navVC = self.detailController.navigationController;
    NSInteger count = navVC.viewControllers.count;
    if (navVC && count >= 2) {
        NSMutableArray *vcs = [[NSMutableArray alloc] initWithArray:navVC.viewControllers];
        if (vcs.count == count) {
            [vcs removeObjectAtIndex:count - 2];
            [self.detailController.navigationController setViewControllers:vcs];
        }
    }
}

-(void)poplayerFeedBack:(id)model type:(NSInteger)type completion:(void (^)(BOOL success))completion
{
    if (![TTReachability isNetworkConnected]) {
        SHOW_TOAST(@"网络异常");
        completion(NO);
        return;
    }
    NSString *source = nil;
    NSString *agencyId = nil;
    if ([model isKindOfClass:[FHDetailDataBaseExtraOfficialModel class]]) {
        source = @"official";
        agencyId = [(FHDetailDataBaseExtraOfficialModel *)model agency].agencyId;
    }else if ([model isKindOfClass:[FHDetailDataBaseExtraDetectiveModel class]]){
        source = @"detective";
    }else if ([model isKindOfClass:[FHRentDetailDataBaseExtraModel class]]){
        source = @"safety_tips";
    }else if ([model isKindOfClass:[FHDetailDataBaseExtraDetectiveReasonInfo class]]){
        source = @"skyeye_price_abnormal";
    }
    
    [FHHouseDetailAPI requstQualityFeedback:self.houseId houseType:self.houseType source:source feedBack:type agencyId:agencyId completion:^(bool succss, NSError * _Nonnull error) {
        
        if (succss) {
            completion(succss);
        }else{
            if (![TTReachability isNetworkConnected]) {
                SHOW_TOAST(@"网络异常");
            }else{
                SHOW_TOAST(error.domain);
            }
            completion(NO);
        }
        
    } ];
    
}

@end

NSString *const DETAIL_SHOW_POP_LAYER_NOTIFICATION = @"_DETAIL_SHOW_POP_LAYER_NOTIFICATION_"; //详情页点击显示半屏弹窗
