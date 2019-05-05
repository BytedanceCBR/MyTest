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

@interface FHHouseDetailBaseViewModel ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)   NSMutableDictionary       *cellHeightCaches;
@property (nonatomic, strong)   NSMutableDictionary       *elementShowCaches;
@property (nonatomic, strong)   NSHashTable               *weakedCellTable;
@property (nonatomic, assign)   CGPoint       lastPointOffset;

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
        _lastPointOffset = CGPointZero;
        _weakedCellTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        self.houseType = houseType;
        self.detailController = viewController;
        self.tableView = tableView;
        [self configTableView];
    }
    return self;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self registerCellClasses];
}

- (void)reloadData {
    
    CGRect frame = self.tableView.frame;
    [self.tableView reloadData];
    self.tableView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width,10000);//设置大frame 强制计算cell高度
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tableView.frame = frame;
    });
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
        NSString *identifier = [self cellIdentifierForEntity:data];
        if (identifier.length > 0) {
            FHDetailBaseCell *cell = (FHDetailBaseCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            cell.baseViewModel = self;
            [cell refreshWithData:data];
            return cell;
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
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    NSNumber *cellHeight = [NSNumber numberWithFloat:cell.frame.size.height];
    self.cellHeightCaches[tempKey] = cellHeight;
    if ([cell conformsToProtocol:@protocol(FHDetailScrollViewDidScrollProtocol)] && ![self.weakedCellTable containsObject:cell]) {
        [self.weakedCellTable addObject:cell];
    }
    // 添加element_show埋点
    if (!self.elementShowCaches[tempKey]) {
        self.elementShowCaches[tempKey] = @(YES);
        FHDetailBaseCell *tempCell = (FHDetailBaseCell *)cell;
        NSString *element_type = [tempCell elementTypeString:self.houseType];
        if (element_type.length > 0) {
            // 上报埋点
            NSMutableDictionary *tracerDic = self.detailTracerDic.mutableCopy;
            tracerDic[@"element_type"] = element_type;
            [tracerDic removeObjectForKey:@"element_from"];
            [FHUserTracker writeEvent:@"element_show" params:tracerDic];
        }
        
        NSArray *element_array = [tempCell elementTypeStringArray:self.houseType];
        if (element_array.count > 0) {
            for (NSString * element_name in element_array) {
                if ([element_name isKindOfClass:[NSString class]]) {
                    // 上报埋点
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.tableView) {
        return;
    }
    // 解决类似周边房源列表页的house_show问题
    CGPoint offset = scrollView.contentOffset;
    if (offset.y > self.lastPointOffset.y) {
        // 向上滑动
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
    }
    self.lastPointOffset = offset;
    
    [self.detailController refreshContentOffset:scrollView.contentOffset];
}

#pragma mark - 埋点
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
    [FHUserTracker writeEvent:@"go_detail" params:self.detailTracerDic];

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
    if (self.contactViewModel.chosenAgencyNum) {
        info[@"chosen_agency_num"] = self.contactViewModel.chosenAgencyNum;
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
    [FHUserTracker writeEvent:@"stay_page" params:params];
    
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

@end
