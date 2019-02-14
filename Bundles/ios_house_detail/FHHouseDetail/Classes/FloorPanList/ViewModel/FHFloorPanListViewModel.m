//
//  FHFloorPanListViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHFloorPanListViewModel.h"
#import "FHHouseDetailAPI.h"
#import "FHFloorPanListCell.h"

@interface FHFloorPanListViewModel()
@property (nonatomic , strong) UITableView *floorListTable;
@property (nonatomic , strong) UIScrollView *leftFilterView;
@property (nonatomic , strong) UILabel *currentTapLabel;
@property (nonatomic , weak) UIViewController *floorListVC;
@property (nonatomic , strong) NSMutableArray <FHDetailNewDataFloorpanListListModel *> *allItems;
@property (nonatomic , strong) NSMutableArray <FHDetailNewDataFloorpanListListModel *> *currentItems;
@property (nonatomic , strong) NSArray * nameLeftArray;
@end


@implementation FHFloorPanListViewModel

-(instancetype)initWithController:(FHHouseDetailViewController *)viewController tableView:(UITableView *)tableView houseType:(FHHouseType)houseType andLeftScrollView:(UIScrollView *)leftScrollView andItems:(NSMutableArray <FHDetailNewDataFloorpanListListModel *> *)allItems {
    self = [super init];
    if (self) {
        _nameLeftArray = @[@"不限",@"在售",@"待售",@"售罄"];
        _floorListTable = tableView;
        _leftFilterView = leftScrollView;
        _allItems = allItems;
        _floorListVC = viewController;
        _currentItems = _allItems;
        [self configTableView];
        
        [self setUpLeftFilterView];
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
        }else
        {
            labelClick.textColor = [UIColor themeBlue1];
            labelClick.backgroundColor = [UIColor colorWithHexString:@"#f4f5f6"];
        }
        labelClick.font = [UIFont themeFontRegular:15];
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
    
    if (_currentTapLabel) {
        _currentTapLabel.textColor = [UIColor themeBlue1];
        _currentTapLabel.backgroundColor = [UIColor colorWithHexString:@"#f4f5f6"];
    }
    
    if ([tapView isKindOfClass:[UILabel class]]) {
          ((UILabel *)tapView).textColor = [UIColor themeBlue2];
          ((UILabel *)tapView).backgroundColor = [UIColor whiteColor];
          _currentTapLabel = tapView;
    }
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
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestNewDetail:@"6581052152733499652" completion:^(FHDetailNewModel * _Nullable model, NSError * _Nullable error) {
        [wSelf processDetailData:model];
    }];
}

- (void)processDetailData:(FHDetailNewModel *)model {
    // 清空数据源
    [self.items removeAllObjects];
    //    if (model.data.imageGroup) {
    //        FHDetailPhotoHeaderModel *headerCellModel = [[FHDetailPhotoHeaderModel alloc] init];
    //        NSMutableArray *arrayHouseImage = [NSMutableArray new];
    //        for (NSInteger i = 0; i < model.data.imageGroup.count; i++) {
    //            FHDetailNewDataImageGroupModel * groupModel = model.data.imageGroup[i];
    //            for (NSInteger j = 0; j < groupModel.images.count; j++) {
    //                [arrayHouseImage addObject:groupModel.images[j]];
    //            }
    //        }
    //        headerCellModel.houseImage = arrayHouseImage;
    //        [self.items addObject:headerCellModel];
    //    }
    //
    //    //楼盘户型
    //    if (model.data.floorpanList) {
    //        [self.items addObject:model.data.floorpanList];
    //    }
    //
    //    if (model.data.coreInfo.gaodeLat && model.data.coreInfo.gaodeLng) {
    //        FHDetailNearbyMapModel *nearbyMapModel = [[FHDetailNearbyMapModel alloc] init];
    //        nearbyMapModel.gaodeLat = model.data.coreInfo.gaodeLat;
    //        nearbyMapModel.gaodeLng = model.data.coreInfo.gaodeLng;
    //        [self.items addObject:nearbyMapModel];
    //
    //        __weak typeof(self) wSelf = self;
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //            if ((FHDetailNearbyMapCell *)nearbyMapModel.cell) {
    //                ((FHDetailNearbyMapCell *)nearbyMapModel.cell).indexChangeCallBack = ^{
    //                    [self reloadData];
    //                };
    //            }
    //        });
    //    }
    //
    [self reloadData];
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
        [cell refreshWithData:_currentItems[indexPath.row]];
    }
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
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
