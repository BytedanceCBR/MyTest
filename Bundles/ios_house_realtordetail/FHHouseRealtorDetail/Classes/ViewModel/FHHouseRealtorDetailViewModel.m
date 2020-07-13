//
//  FHHouseRealtorDetailViewModel.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/12.
//

#import "FHHouseRealtorDetailViewModel.h"
#import "FHHouseDetailUserEvaluationCell.h"
#import "FHHouseRealtorDetailRGCCell.h"
#import "FHHouseRealtorInfoCell.h"
#import "FHHouseRealtorDetailInfoModel.h"
#import "FHHouseRealtorDetailBaseCell.h"
@interface FHHouseRealtorDetailViewModel()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHHouseRealtorDetailController *detailController;
@property(nonatomic, strong) NSMutableArray *dataArr;
@end
@implementation FHHouseRealtorDetailViewModel
- (instancetype)initWithController:(FHHouseRealtorDetailController *)viewController tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
//        _detailTracerDic = [NSMutableDictionary new];
//        _items = [NSMutableArray new];
//        _cellHeightCaches = [NSMutableDictionary new];
//        _elementShowCaches = [NSMutableDictionary new];
//        _elementShdowGroup = [NSMutableDictionary new];
//        _lastPointOffset = CGPointZero;
//        _weakedCellTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
//        _weakedVCLifeCycleCellTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
//        self.houseType = houseType;
        self.detailController = viewController;
        self.tableView = tableView;
//        self.tableView.backgroundColor = [UIColor themeGray7];
        [self configTableView];
    }
    return self;
}

-(void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    _tableView.backgroundColor = [UIColor colorWithRed:252 green:252 blue:252 alpha:1];
//    self.detailController.view.backgroundColor = [UIColor redColor];
    [self registerCellClasses];
}

- (void)registerCellClasses {
    [self.tableView registerClass:[FHHouseDetailUserEvaluationCell class] forCellReuseIdentifier:@"FHHouseRealtorDetailInfoModel"];
    [self.tableView registerClass:[FHHouseRealtorDetailRGCCell class] forCellReuseIdentifier:@"FHHouseRealtorDetailUserEvaluationModel"];
    [self.tableView registerClass:[FHHouseRealtorInfoCell class] forCellReuseIdentifier:@"FHHouseRealtorDetailrRgcModel"];
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        NSMutableArray *dataArr = [[NSMutableArray alloc]init];
        _dataArr = dataArr;
    }
    return _dataArr;
}


#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.dataArr.count) {
        NSObject <FHHouseRealtorDetailProtocol> *dataModel = self.dataArr[row];
        NSString *identifier = NSStringFromClass([dataModel class]);//[self cellIdentifierForEntity:data];
        if (identifier.length > 0) {
            FHHouseRealtorDetailBaseCell*cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell) {
                [cell refreshWithData:dataModel];
                return cell;
            }else{
                NSLog(@"nil cell for data: %@",dataModel);
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
    FHHouseRealtorDetailBaseCell*cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.didClickCellBlk) {
        cell.didClickCellBlk();
    }
}
@end
