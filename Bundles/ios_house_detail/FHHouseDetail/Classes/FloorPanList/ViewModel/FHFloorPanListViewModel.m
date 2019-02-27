//
//  FHFloorPanListViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHFloorPanListViewModel.h"
#import "FHHouseDetailAPI.h"
#import "FHFloorPanListCell.h"
#import <FHEnvContext.h>
#import "FHHouseDetailSubPageViewController.h"

static const NSString *kDefaultLeftFilterStatus = @"0";
static const NSString *kDefaultTopFilterStatus = @"-1";

@interface FHFloorPanListViewModel()
@property (nonatomic , weak) UITableView *floorListTable;
@property (nonatomic , weak) UIScrollView *leftFilterView;
@property (nonatomic , strong) UILabel *currentTapLabel;
@property (nonatomic , weak) FHHouseDetailSubPageViewController *floorListVC;
@property (nonatomic , strong) NSMutableArray <FHDetailNewDataFloorpanListListModel *> *allItems;
@property (nonatomic , strong) NSMutableArray <FHDetailNewDataFloorpanListListModel *> *currentItems;
@property (nonatomic , assign) NSInteger leftFilterIndex;
@property (nonatomic , strong) NSMutableArray *topRoomCountArray;
@property (nonatomic , weak) HMSegmentedControl *segmentedControl;
@property (nonatomic , strong) NSArray * nameLeftArray;
@property (nonatomic, strong)   NSMutableDictionary       *elementShowCaches;

@end


@implementation FHFloorPanListViewModel

-(instancetype)initWithController:(FHHouseDetailSubPageViewController *)viewController tableView:(UITableView *)tableView houseType:(FHHouseType)houseType andLeftScrollView:(UIScrollView *)leftScrollView andSegementView:(UIView *)segmentView andItems:(NSMutableArray <FHDetailNewDataFloorpanListListModel *> *)allItems {
    self = [super init];
    if (self) {
        _nameLeftArray = @[@"不限",@"在售",@"待售",@"售罄"];
        _floorListTable = tableView;
        _leftFilterView = leftScrollView;
        _elementShowCaches = [NSMutableDictionary new];
        _allItems = allItems;
        _floorListVC = viewController;
        _currentItems = _allItems;
        _segmentedControl = segmentView;
        if (_allItems.count > 0) {
            _segmentedControl.sectionTitles = [self getSegementViewTitlsArray];
        }
        [self configTableView];
        
        [self setUpLeftFilterView];
        
        WeakSelf;
        _segmentedControl.indexChangeBlock = ^(NSInteger index) {
            StrongSelf;
            [self refreshCurrentShowList];
        };
    }
    return self;
}

- (void)configTableView
{
    _floorListTable.delegate = self;
    _floorListTable.dataSource = self;
    [self registerCellClasses];
}

- (void)setUpLeftFilterView
{
    NSMutableArray *labelsArray = [NSMutableArray new];
    
    UIView * previousView = nil;
    
    for (NSInteger i = 0; i < self.nameLeftArray.count; i++) {
        UIView *labelContentView = [UIView new];
        [self.leftFilterView addSubview:labelContentView];
        
        [labelContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i==0) {
                make.top.equalTo(self.leftFilterView);
            }else
            {
                make.top.equalTo(previousView.mas_bottom);
            }
            
            make.left.right.equalTo(self.leftFilterView);
            make.height.mas_equalTo(50);
        }];
        
        previousView = labelContentView;
        
        UILabel *labelClick = [UILabel new];
        labelClick.text = self.nameLeftArray[i];
        if (i == 0) {
            _currentTapLabel = labelClick;
            labelClick.textColor = [UIColor themeBlue2];
            labelClick.backgroundColor = [UIColor whiteColor];
            _leftFilterIndex = 0;
        }else
        {
            labelClick.textColor = [UIColor themeBlue1];
            labelClick.backgroundColor = [UIColor colorWithHexString:@"#f4f5f6"];
        }
        labelClick.font = [UIFont themeFontRegular:15];
        labelClick.tag = i;
        [labelContentView addSubview:labelClick];
        labelClick.textAlignment = NSTextAlignmentCenter;
        labelClick.userInteractionEnabled = YES;
        [labelClick mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(labelContentView);
            make.height.mas_equalTo(50);
            make.width.mas_equalTo(80);
        }];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClickAction:)];
        [labelClick addGestureRecognizer:tapGesture];
        
        [labelsArray addObject:labelContentView];
    }
}

- (void)labelClickAction:(UITapGestureRecognizer *)tap
{
    UIView *tapView = tap.view;
    _leftFilterIndex = tapView.tag;

    if (_currentTapLabel) {
        _currentTapLabel.textColor = [UIColor themeBlue1];
        _currentTapLabel.backgroundColor = [UIColor colorWithHexString:@"#f4f5f6"];
    }
    
    if ([tapView isKindOfClass:[UILabel class]]) {
          ((UILabel *)tapView).textColor = [UIColor themeBlue2];
          ((UILabel *)tapView).backgroundColor = [UIColor whiteColor];
          _currentTapLabel = tapView;
    }
    
    [self refreshCurrentShowList];
}

- (NSArray *)getSegementViewTitlsArray
{
    _topRoomCountArray = [NSMutableArray new];
    for (NSInteger i = 0; i < _allItems.count; i++) {
        FHDetailNewDataFloorpanListListModel * model = _allItems[i];
        if (model.roomCount && ![_topRoomCountArray containsObject:model.roomCount]) {
            [_topRoomCountArray addObject:model.roomCount];
        }
    }
    
    NSMutableArray *titlesArray = [NSMutableArray new];
    if (_topRoomCountArray.count > 0) {
        [_topRoomCountArray sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2){
            if ([obj1 integerValue] < [obj2 integerValue]){
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;}
        }];
        [titlesArray addObject:[NSString stringWithFormat:@"全部(%d)",_allItems.count]];
        
        for (NSInteger i = 0; i < _topRoomCountArray.count; i++) {
            [titlesArray addObject:[NSString stringWithFormat:@"%@室(%d)",_topRoomCountArray[i],_allItems.count]];
        }
    }
    return titlesArray;
}

- (void)refreshCurrentShowList
{
    _currentItems = [self getSelectFilterDataList];
    if (_currentItems.count == 0) {
        [[ToastManager manager] showToast:@"暂无相关房型~"];
    }
    [_floorListTable reloadData];
}

- (NSArray<FHDetailNewDataFloorpanListListModel *> *)getSelectFilterDataList
{
    NSString *roomCuntKey = kDefaultTopFilterStatus;
    if ( _segmentedControl.selectedSegmentIndex != 0 && _topRoomCountArray.count > _segmentedControl.selectedSegmentIndex - 1) {
        roomCuntKey = _topRoomCountArray[_segmentedControl.selectedSegmentIndex - 1];
    }
    
    NSString *status = kDefaultLeftFilterStatus;
    if (self.currentTapLabel.tag != 0) {
       
        if (self.currentTapLabel.tag == 1) {
            //在售
            status = [NSString stringWithFormat:@"%d",2];
        }else if(self.currentTapLabel.tag == 2)
        {
            //待售
            status = [NSString stringWithFormat:@"%d",1];
        }else
        {
            //售磬
            status = [NSString stringWithFormat:@"%d",self.currentTapLabel.tag];
        }
    }
    
    NSMutableArray *currentItemsArray = [NSMutableArray new];
    for(FHDetailNewDataFloorpanListListModel *model in _allItems)
    {
        if([status isEqualToString:kDefaultLeftFilterStatus] && [roomCuntKey isEqualToString:kDefaultTopFilterStatus])
        {
            [currentItemsArray addObject:model];
        }
        else if([status isEqualToString:kDefaultLeftFilterStatus])
        {
            if ([model.roomCount isEqualToString:roomCuntKey] && ![roomCuntKey isEqualToString:kDefaultTopFilterStatus]) {
                [currentItemsArray addObject:model];
            }
        }else if ([roomCuntKey isEqualToString:kDefaultTopFilterStatus]) {
            if ([model.saleStatus.id isEqualToString:status]) {
                [currentItemsArray addObject:model];
            }
        }else
        {
            if ([model.roomCount isEqualToString:roomCuntKey] && [model.saleStatus.id isEqualToString:status]) {
                [currentItemsArray addObject:model];
            }
        }
    }
    return currentItemsArray;
}

// 注册cell类型
- (void)registerCellClasses {
    [self.floorListTable registerClass:[FHFloorPanListCell class] forCellReuseIdentifier:NSStringFromClass([FHFloorPanListCell class])];
}
// cell class
- (Class)cellClassForEntity:(id)model {
    if ([model isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
        return [FHFloorPanListCell class];
    }
    return [FHDetailBaseCell class];
}
// cell identifier
- (NSString *)cellIdentifierForEntity:(id)model {
    Class cls = [self cellClassForEntity:model];
    return NSStringFromClass(cls);
}

- (void)startLoadData
{
}

- (void)processDetailData:(FHDetailNewModel *)model {
}

#pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _currentItems.count;
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
    FHFloorPanListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHFloorPanListCell class])];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([FHFloorPanListCell class])];
    }
    if ([cell isKindOfClass:[FHFloorPanListCell class]] && _currentItems.count > indexPath.row) {
        if (indexPath.row == 0) {
            ((FHDetailNewDataFloorpanListListModel *)self.currentItems[indexPath.row]).index = indexPath.row;
        }
        [cell refreshWithData:_currentItems[indexPath.row]];
        cell.baseViewModel = self;
    }
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentItems.count > indexPath.row) {
        FHDetailNewDataFloorpanListListModel *model = (FHDetailNewDataFloorpanListListModel *)_currentItems[indexPath.row];
        if ([model isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
            
            NSMutableDictionary *subPageParams = [_floorListVC subPageParams];
            NSDictionary *tracer = subPageParams[@"tracer"];
            NSMutableDictionary *traceParam = [NSMutableDictionary new];
            if (tracer) {
                [traceParam addEntriesFromDictionary:tracer];
            }
            traceParam[@"enter_from"] = @"new_detail";
//            traceParam[@"log_pb"] = self.baseViewModel.listLogPB;
//            traceParam[@"origin_from"] = self.baseViewModel.detailTracerDic[@"origin_from"];
            traceParam[@"card_type"] = @"left_pic";
            traceParam[@"rank"] = @(indexPath.row);
//            traceParam[@"origin_search_id"] = self.baseViewModel.detailTracerDic[@"origin_search_id"];
            traceParam[@"element_from"] = @"related";
            traceParam[@"log_pb"] = model.logPb;
            NSDictionary *dict = @{@"house_type":@(1),
                                   @"tracer": traceParam
                                   };

            NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithDictionary:nil];
            [infoDict setValue:model.id forKey:@"floor_plan_id"];
            [infoDict addEntriesFromDictionary:subPageParams];
            infoDict[@"house_type"] = @(1);
            infoDict[@"tracer"] = traceParam;
            TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];

            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://floor_plan_detail"] userInfo:info];
        } 
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    // 添加element_show埋点
    if (!self.elementShowCaches[tempKey]) {
        self.elementShowCaches[tempKey] = @(YES);
        
        NSMutableDictionary *subPageParams = [_floorListVC subPageParams];
        NSDictionary *tracer = subPageParams[@"tracer"];
        NSMutableDictionary *traceParam = [NSMutableDictionary new];
        if (tracer) {
            [traceParam addEntriesFromDictionary:tracer];
        }
        traceParam[@"card_type"] = @"left_pic";
        traceParam[@"rank"] = @(indexPath.row);
        traceParam[@"element_type"] = @"house_model";
        traceParam[@"page_type"] = @"house_model_list";
        [traceParam removeObjectForKey:@"enter_from"];
        [traceParam removeObjectForKey:@"element_from"];
        [traceParam addEntriesFromDictionary:tracer[@"log_pb"]];
        if (_currentItems.count > indexPath.row) {
            FHDetailNewDataFloorpanListListModel *itemModel = (FHDetailNewDataFloorpanListListModel *)_currentItems[indexPath.row];
            
            if (itemModel.logPb) {
                [traceParam setValue:itemModel.logPb forKey:@"log_pb"];
            }
            
            if (itemModel.searchId) {
                [traceParam setValue:itemModel.searchId forKey:@"search_id"];
            }
            
            if (itemModel.groupId) {
                [traceParam setValue:itemModel.groupId forKey:@"group_id"];
            }else
            {
                [traceParam setValue:itemModel.id forKey:@"group_id"];
            }
            
            if (itemModel.imprId) {
                [traceParam setValue:itemModel.imprId forKey:@"impr_id"];
            }
        }
        
        [FHEnvContext recordEvent:traceParam andEventKey:@"house_show"];
    }
}

@end
