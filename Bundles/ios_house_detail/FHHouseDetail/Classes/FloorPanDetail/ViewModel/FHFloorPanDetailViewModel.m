//
//  FHFloorTimeLineViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/17.
//

#import "FHFloorPanDetailViewModel.h"
#import "FHHouseDetailAPI.h"
#import "FHDetailNewTimeLineItemCell.h"
#import "FHDetailNewModel.h"
#import <FHRefreshCustomFooter.h>
#import <FHEnvContext.h>
#import "FHDetailNewCoreDetailModel.h"
#import "FHDetailHouseNameCell.h"
#import "FHFloorPanCorePropertyCell.h"
#import "FHDetailGrayLineCell.h"
#import "FHDetailFloorPanDetailInfoModel.h"
#import "FHDetailPhotoHeaderCell.h"
#import "FHFloorPanTitleCell.h"
#import "FHFloorPanDetailPropertyCell.h"
#import "FHFloorPanDetailMutiFloorPanCell.h"

@interface FHFloorPanDetailViewModel()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , weak) UITableView *infoListTable;
@property (nonatomic , strong) NSMutableArray *currentItems;
@property (nonatomic , strong) NSString *floorPanId;
@property (nonatomic , strong) FHDetailFloorPanDetailInfoModel *currentModel;
@end
@implementation FHFloorPanDetailViewModel

-(instancetype)initWithController:(FHHouseDetailViewController *)viewController tableView:(UITableView *)tableView floorPanId:(NSString *)floorPanId
{
    self = [super init];
    if (self) {
        _infoListTable = tableView;
        _floorPanId = floorPanId;
        _currentItems = [NSMutableArray new];
        [self configTableView];
        
        [self startLoadData];
    }
    return self;
}

// 注册cell类型
- (void)registerCellClasses {
    [self.infoListTable registerClass:[FHDetailPhotoHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPhotoHeaderCell class])];
    
    [self.infoListTable registerClass:[FHFloorPanTitleCell class] forCellReuseIdentifier:NSStringFromClass([FHFloorPanTitleCell class])];
    
    [self.infoListTable registerClass:[FHFloorPanDetailPropertyCell class] forCellReuseIdentifier:NSStringFromClass([FHFloorPanDetailPropertyCell class])];

    [self.infoListTable registerClass:[FHDetailHouseNameCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseNameCell class])];
    
    [self.infoListTable registerClass:[FHDetailGrayLineCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailGrayLineCell class])];
    
    [self.infoListTable registerClass:[FHFloorPanDetailMutiFloorPanCell class] forCellReuseIdentifier:NSStringFromClass([FHFloorPanDetailMutiFloorPanCell class])];
}
// cell class
- (Class)cellClassForEntity:(id)model {
    // 图片头部
    if ([model isKindOfClass:[FHDetailPhotoHeaderModel class]]) {
        return [FHDetailPhotoHeaderCell class];
    }
    
    // 标题
    if ([model isKindOfClass:[FHFloorPanTitleCellModel class]]) {
        return [FHFloorPanTitleCell class];
    }
    
    // 灰色分割线
    if ([model isKindOfClass:[FHDetailGrayLineModel class]]) {
        return [FHDetailGrayLineCell class];
    }

    // 属性信息
    if ([model isKindOfClass:[FHFloorPanDetailPropertyCellModel class]]) {
        return [FHFloorPanDetailPropertyCell class];
    }
    
    //楼盘推荐
    if ([model isKindOfClass:[FHFloorPanDetailMutiFloorPanCellModel class]]) {
        return [FHFloorPanDetailMutiFloorPanCell class];
    }
    
    return [FHDetailBaseCell class];
}
// cell identifier
- (NSString *)cellIdentifierForEntity:(id)model {
    Class cls = [self cellClassForEntity:model];
    return NSStringFromClass(cls);
}

- (void)configTableView
{
    [self registerCellClasses];
    _infoListTable.delegate = self;
    _infoListTable.dataSource = self;
}

- (void)startLoadData
{
    if (_floorPanId) {
        __weak typeof(self) wSelf = self;
        [FHHouseDetailAPI requestFloorPanDetailCoreInfoSearch:_floorPanId completion:^(FHDetailFloorPanDetailInfoModel * _Nullable model, NSError * _Nullable error) {
            if(model.data)
            {
                [wSelf processDetailData:model];
            }
        }];
    }
}

- (NSString *)checkPValueStr:(NSString *)str
{
    if ([str isKindOfClass:[NSString class]]) {
        return str;
    }else
    {
        return @"-";
    }
}

- (void)processDetailData:(FHDetailFloorPanDetailInfoModel *)model {
    NSMutableArray *itemsArray = [NSMutableArray new];
    
    self.currentModel = model;
    
    if (model.data.images) {
        FHDetailPhotoHeaderModel *headerCellModel = [[FHDetailPhotoHeaderModel alloc] init];
        headerCellModel.houseImage = model.data.images;
        [self.currentItems addObject:headerCellModel];
    }
    
    if (model.data) {
        FHFloorPanTitleCellModel *cellModel = [[FHFloorPanTitleCellModel alloc] init];
        cellModel.title = model.data.title;
        cellModel.pricing = model.data.pricing;
        cellModel.pricingPerSqm = model.data.pricingPerSqm;
        [self.currentItems addObject:cellModel];
    }
    
    if (model.data.baseInfo) {
        FHFloorPanDetailPropertyCellModel *cellModel = [[FHFloorPanDetailPropertyCellModel alloc] init];
        cellModel.baseInfo = model.data.baseInfo;
        [self.currentItems addObject:cellModel];
    }
    
    //楼盘户型
    if (model.data.recommend) {
        FHFloorPanDetailMutiFloorPanCellModel *mutiDataModel = [[FHFloorPanDetailMutiFloorPanCellModel alloc] init];
        mutiDataModel.recommend = model.data.recommend;
        [self.currentItems addObject:mutiDataModel];
    }
    
    [_infoListTable reloadData];
}


#pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_currentItems count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.currentItems.count) {
        id data = self.currentItems[row];
        NSString *identifier = [self cellIdentifierForEntity:data];
        if (identifier.length > 0) {
            FHDetailBaseCell *cell = (FHDetailBaseCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[NSClassFromString(identifier) alloc] init];
            }
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
