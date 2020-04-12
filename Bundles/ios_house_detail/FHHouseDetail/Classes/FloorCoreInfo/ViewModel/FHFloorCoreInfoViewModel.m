//
//  FHFloorTimeLineViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/17.
//

#import "FHFloorCoreInfoViewModel.h"
#import "FHHouseDetailAPI.h"
#import "FHDetailNewTimeLineItemCell.h"
#import "FHDetailNewModel.h"
#import "FHRefreshCustomFooter.h"
#import "FHEnvContext.h"
#import "FHDetailNewCoreDetailModel.h"
#import "FHDetailHouseNameCell.h"
#import "FHFloorPanCorePropertyCell.h"
#import "FHDetailGrayLineCell.h"
#import "FHDetailDisclaimerCell.h"
#import "FHFloorPanCorePermitCell.h"

@interface FHFloorCoreInfoViewModel()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , weak) UITableView *infoListTable;
@property (nonatomic , strong) NSMutableArray *currentItems;
@property (nonatomic , strong) NSString *courtId;
@property(nonatomic , strong) FHDetailHouseNameModel *houseNameModel;
@property(nonatomic , strong) FHDetailDisclaimerModel *disclaimerModel;

@end
@implementation FHFloorCoreInfoViewModel

-(instancetype)initWithController:(FHHouseDetailSubPageViewController *)viewController tableView:(UITableView *)tableView courtId:(NSString *)courtId houseNameModel:(JSONModel *)model housedisclaimerModel:(JSONModel *)disClaimerModel
{
    self = [super init];
    if (self) {
        self.detailController = viewController;
        _infoListTable = tableView;
        _courtId = courtId;
        _currentItems = [NSMutableArray new];
        _houseNameModel = model;
        _disclaimerModel = disClaimerModel;
        [self configTableView];
        
        [self startLoadData];
    
    }
    return self;
}

// 注册cell类型
- (void)registerCellClasses {
    [self.infoListTable registerClass:[FHDetailHouseNameCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseNameCell class])];
    
    [self.infoListTable registerClass:[FHDetailGrayLineCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailGrayLineCell class])];
    
    [self.infoListTable registerClass:[FHFloorPanCorePropertyCell class] forCellReuseIdentifier:NSStringFromClass([FHFloorPanCorePropertyCell class])];
    
    [self.infoListTable registerClass:[FHFloorPanCorePermitCell class] forCellReuseIdentifier:NSStringFromClass([FHFloorPanCorePermitCell class])];

    [self.infoListTable registerClass:[FHDetailDisclaimerCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailDisclaimerCell class])];
}
// cell class
- (Class)cellClassForEntity:(id)model {
    // 标题
    if ([model isKindOfClass:[FHDetailHouseNameModel class]]) {
        return [FHDetailHouseNameCell class];
    }
    
    // 灰色分割线
    if ([model isKindOfClass:[FHDetailGrayLineModel class]]) {
        return [FHDetailGrayLineCell class];
    }
    
    // 属性信息
    if ([model isKindOfClass:[FHFloorPanCorePropertyCellModel class]]) {
        return [FHFloorPanCorePropertyCell class];
    }
    
    // 准字信息
    if ([model isKindOfClass:[FHFloorPanCorePermitCellModel class]]) {
        return [FHFloorPanCorePermitCell class];
    }
    
    // 版权信息
    if ([model isKindOfClass:[FHDetailDisclaimerModel class]]) {
        return [FHDetailDisclaimerCell class];
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
    
    if (![TTReachability isNetworkConnected]) {
        [self.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkNotRefresh];
        return;
    }
    
    if (_courtId) {
        [self.detailController startLoading];
        __weak typeof(self) wSelf = self;
        [FHHouseDetailAPI requestFloorCoreInfoSearch:_courtId completion:^(FHDetailNewCoreDetailModel * _Nullable model, NSError * _Nullable error) {
            if(model.data && !error)
            {
                [wSelf.detailController.emptyView hideEmptyView];
                wSelf.detailController.hasValidateData = YES;
                [wSelf processDetailData:model];
            }else
            {
                wSelf.detailController.hasValidateData = NO;
                [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
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

- (void)processDetailData:(FHDetailNewCoreDetailModel *)model {
    NSMutableArray *itemsArray = [NSMutableArray new];
    
    // 添加标题
    if (_houseNameModel) {
        _houseNameModel.isHiddenLine = YES;
        [self.currentItems addObject:_houseNameModel];
    }
    
    FHFloorPanCorePropertyCellModel *companyModel = [self createCompanyInfoModel:model];
    // 添加分割线--当存在某个数据的时候在顶部添加分割线
    FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] initWithHeight:16];
    [self.currentItems addObject:grayLine];
    [self.currentItems addObject:companyModel];

    
    FHFloorPanCorePropertyCellModel *addressModel = [self createAddressInfoModel:model];
    [self.currentItems addObject:grayLine];
    [self.currentItems addObject:addressModel];
    
    
    FHFloorPanCorePropertyCellModel *historyModel = [self createHistoryInfoModel:model];
    [self.currentItems addObject:grayLine];
    [self.currentItems addObject:historyModel];
    
    
    FHFloorPanCorePropertyCellModel *waterModel = [self createWaterInfoModel:model];
    [self.currentItems addObject:grayLine];
    [self.currentItems addObject:waterModel];

    
    if (model.data.permitList.count > 0) {
        [self.currentItems addObject:grayLine];
        
        FHFloorPanCorePermitCellModel *permitModel = [self createPermitInfoModel:model.data.permitList.firstObject];
        [self.currentItems addObject:permitModel];
    }
    
    if (_disclaimerModel) {
        [self.currentItems addObject:_disclaimerModel];
    }
    
    [_infoListTable reloadData];
    _infoListTable.contentOffset = CGPointMake(0, -15);
}

- (FHFloorPanCorePropertyCellModel *)createWaterInfoModel:(FHDetailNewCoreDetailModel *)model
{
    FHFloorPanCorePropertyCellModel *companyInfoModel = [[FHFloorPanCorePropertyCellModel alloc] init];
    
    NSArray *pNameArray = [NSArray arrayWithObjects:@"物业公司",@"物业费用",@"水电燃气",@"供暖方式",@"绿化率",@"车位情况",@"容积率",@"楼栋信息", nil];
    
    NSMutableArray *pItemsArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pNameArray.count; i++) {
        FHFloorPanCorePropertyCellItemModel *pItemModel = [[FHFloorPanCorePropertyCellItemModel alloc] init];
        pItemModel.propertyName = pNameArray[i];
        switch (i) {
            case 0:
                pItemModel.propertyValue = [self checkPValueStr:model.data.propertyName];
                break;
            case 1:
                pItemModel.propertyValue = [self checkPValueStr:model.data.propertyPrice];
                break;
            case 2:
                pItemModel.propertyValue = [self checkPValueStr:model.data.powerWaterGasDesc];
                break;
            case 3:
                pItemModel.propertyValue = [self checkPValueStr:model.data.heating];
                break;
            case 4:
                pItemModel.propertyValue = [self checkPValueStr:model.data.greenRatio];
                break;
            case 5:
                pItemModel.propertyValue = [self checkPValueStr:model.data.parkingNum];
                break;
            case 6:
                pItemModel.propertyValue = [self checkPValueStr:model.data.plotRatio];
                break;
            case 7:
                pItemModel.propertyValue = [self checkPValueStr:model.data.buildingDesc];
                break;
            default:
                break;
        }
        [pItemsArray addObject:pItemModel];
    }
    companyInfoModel.list = pItemsArray;
    
    return companyInfoModel;
}

- (FHFloorPanCorePropertyCellModel *)createHistoryInfoModel:(FHDetailNewCoreDetailModel *)model
{
    FHFloorPanCorePropertyCellModel *companyInfoModel = [[FHFloorPanCorePropertyCellModel alloc] init];
    
    NSArray *pNameArray = [NSArray arrayWithObjects:@"物业类型",@"项目特色",@"建筑类别",@"装修状况",@"建筑类型",@"产权年限", nil];
    
    NSMutableArray *pItemsArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pNameArray.count; i++) {
        FHFloorPanCorePropertyCellItemModel *pItemModel = [[FHFloorPanCorePropertyCellItemModel alloc] init];
        pItemModel.propertyName = pNameArray[i];
        switch (i) {
            case 0:
                pItemModel.propertyValue = [self checkPValueStr:model.data.propertyType];
                break;
            case 1:
                pItemModel.propertyValue = [self checkPValueStr:model.data.featureDesc];
                break;
            case 2:
                pItemModel.propertyValue = [self checkPValueStr:model.data.buildingCategory];
                break;
            case 3:
                pItemModel.propertyValue = [self checkPValueStr:model.data.decoration];
                break;
            case 4:
                pItemModel.propertyValue = [self checkPValueStr:model.data.buildingType];
                break;
            case 5:
                pItemModel.propertyValue = [self checkPValueStr:model.data.propertyRight];
                break;
                
            default:
                break;
        }
        [pItemsArray addObject:pItemModel];
    }
    companyInfoModel.list = pItemsArray;
    
    return companyInfoModel;
}

- (FHFloorPanCorePropertyCellModel *)createAddressInfoModel:(FHDetailNewCoreDetailModel *)model
{
    FHFloorPanCorePropertyCellModel *companyInfoModel = [[FHFloorPanCorePropertyCellModel alloc] init];
    
    NSArray *pNameArray = [NSArray arrayWithObjects:@"楼盘地址",@"售楼地址", nil];
    NSMutableArray *pItemsArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pNameArray.count; i++) {
        FHFloorPanCorePropertyCellItemModel *pItemModel = [[FHFloorPanCorePropertyCellItemModel alloc] init];
        pItemModel.propertyName = pNameArray[i];
        switch (i) {
            case 0:
                pItemModel.propertyValue = [self checkPValueStr:model.data.generalAddress];
                break;
            case 1:
                pItemModel.propertyValue = [self checkPValueStr:model.data.saleAddress];
                break;
    
            default:
                break;
        }
        [pItemsArray addObject:pItemModel];
    }
    companyInfoModel.list = pItemsArray;
    
    return companyInfoModel;
}

- (FHFloorPanCorePropertyCellModel *)createCompanyInfoModel:(FHDetailNewCoreDetailModel *)model
{
    FHFloorPanCorePropertyCellModel *companyInfoModel = [[FHFloorPanCorePropertyCellModel alloc] init];
    
    NSArray *pNameArray = [NSArray arrayWithObjects:@"开发商",@"楼盘状态",@"参考价格",@"开盘时间",@"交房时间", nil];
    NSMutableArray *pItemsArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pNameArray.count; i++) {
        FHFloorPanCorePropertyCellItemModel *pItemModel = [[FHFloorPanCorePropertyCellItemModel alloc] init];
        pItemModel.propertyName = pNameArray[i];
        switch (i) {
            case 0:
                pItemModel.propertyValue = [self checkPValueStr:model.data.developerName];
                break;
            case 1:
                pItemModel.propertyValue = [self checkPValueStr:model.data.saleStatus];
                break;
            case 2:
                pItemModel.propertyValue = [self checkPValueStr:model.data.pricingPerSqm];
                break;
            case 3:
                pItemModel.propertyValue = [self checkPValueStr:model.data.openDate];
                break;
            case 4:
                pItemModel.propertyValue = [self checkPValueStr:model.data.deliveryDate];
                break;
            default:
                break;
        }
        [pItemsArray addObject:pItemModel];
    }
    companyInfoModel.list = pItemsArray;
    
    return companyInfoModel;
}

- (FHFloorPanCorePropertyCellModel *)createPermitInfoModel:(FHDetailNewCoreDetailDataPermitListModel *)model
{
    FHFloorPanCorePropertyCellModel *companyInfoModel = [[FHFloorPanCorePropertyCellModel alloc] init];
    
    NSArray *pNameArray = [NSArray arrayWithObjects:@"预售许可证",@"发证信息",@"绑定信息", nil];
    NSMutableArray *pItemsArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pNameArray.count; i++) {
        FHFloorPanCorePropertyCellItemModel *pItemModel = [[FHFloorPanCorePropertyCellItemModel alloc] init];
        pItemModel.propertyName = pNameArray[i];
        switch (i) {
            case 0:
                pItemModel.propertyValue = [self checkPValueStr:model.permit];
                break;
            case 1:
                pItemModel.propertyValue = [self checkPValueStr:model.permitDate];
                break;
            case 2:
                pItemModel.propertyValue = [self checkPValueStr:model.bindBuilding];
                break;
            default:
                break;
        }
        [pItemsArray addObject:pItemModel];
    }
    companyInfoModel.list = pItemsArray;
    
    return companyInfoModel;
}


#pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentItems count];
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
