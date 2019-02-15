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
        _items = [NSMutableArray new];
        _cellHeightCaches = [NSMutableDictionary new];
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
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.tableView) {
        return;
    }
    [self.detailController refreshContentOffset:scrollView.contentOffset];
}

@end
