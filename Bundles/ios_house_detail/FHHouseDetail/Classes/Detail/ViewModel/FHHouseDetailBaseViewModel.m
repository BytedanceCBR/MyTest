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
    [self.tableView reloadData];
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
    NSArray *visableCells = [self.tableView visibleCells];
    [visableCells enumerateObjectsUsingBlock:^(FHDetailBaseCell *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[FHDetailBaseCell class]] && self.detailController) {
            if ([obj conformsToProtocol:@protocol(FHDetailScrollViewDidScrollProtocol)]) {
                [((id<FHDetailScrollViewDidScrollProtocol>)obj) fhDetail_scrollViewDidScroll:self.detailController.view];
            }
        }
    }];
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


@end
