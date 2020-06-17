//
//  FHFindHouseAreaConditionFilterPanel.m
//  ios_house_filter
//
//  Created by leo on 2018/12/9.
//

#import "FHFindHouseAreaSelectionPanel.h"
#import <Masonry/Masonry.h>
#import "UIColor+Theme.h"
//#import "ButtomBarView.h"
#import "FHFilterNodeModel.h"
#import "TransactionIndexPathSet.h"
#import "FHFilterStyleManager.h"

@interface FHFindHouseAreaSelectionPanel ()
{
    NSString* _name;
    UIView* _lineView;
}
@end

@implementation FHFindHouseAreaSelectionPanel

-(instancetype)initWithLastListViewModel:(FHFindHouseAreaSelectionTableViewVM*)lastListViweModel {
    self = [super init];
    if (self) {
        _tables = [[NSMutableArray alloc] init];
        _hotLinks = [[NSMutableArray alloc] init];
        _lastListViewModel = lastListViweModel;
        [self setupUI];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tables = [[NSMutableArray alloc] init];
        _hotLinks = [[NSMutableArray alloc] init];
        [self setupUI];
    }
    return self;
}

// only for testing
- (instancetype)initWithTables:(NSArray<UITableView*>*)tables
                    withModels:(NSArray<FHFindHouseAreaSelectionTableViewVM*>*) models {
    self = [super init];
    if (self) {
        _tables = [tables mutableCopy];
        _hotLinks = [[NSMutableArray alloc] init];
        _selectionViewModels = models;
    }
    return self;
}

-(void)setupUI {
    UILabel* label = [[UILabel alloc] init];
    [self addSubview:label];
    label.text = _name;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
    [self setupButtomBar];
    if ([_tables count] == 0) {
        [self setupSelectionTables];
    }
}

- (void)setupSelectionTables {
    FHFilterStyle* style = [[FHFilterStyleManager shareInstance] currentStyle];
    
    UITableView* tableView = [[UITableView alloc] init];
    tableView.showsVerticalScrollIndicator = NO;
    [_tables addObject:tableView];
    [self addSubview:tableView];
    FHFindHouseAreaSelectionTableViewVM* vm = [[FHFindHouseAreaSelectionTableViewVM alloc] initWithTableView:tableView];
    vm.isMultiChecked = NO;
    vm.isLeaf = NO;
    vm.isShowHotDot = YES;
    vm.name = @"main";


    tableView = [[UITableView alloc] init];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = HEXRGBA(style.grayBGColor);
    [_tables addObject:tableView];
    [self addSubview:tableView];

    FHFindHouseAreaSelectionTableViewVM* subVm = [[FHFindHouseAreaSelectionTableViewVM alloc] initWithTableView:tableView];
    subVm.isMultiChecked = NO;
    subVm.isLeaf = NO;
    subVm.hiddenRows = @[@(0)];  //隐藏行政区第一项“不限”选项
    subVm.cellBackgroundColor = HEXRGBA(style.grayBGColor);

    tableView = [[UITableView alloc] init];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = HEXRGBA(style.grayBGColor);
    subVm.name = @"subVm";
    [_tables addObject:tableView];
    [self addSubview:tableView];
    [self addRightVerticalLineViewToMiddleView:tableView];
    
    FHFindHouseAreaSelectionTableViewVM* extendVm = nil;
    if (_lastListViewModel == nil) {
        extendVm = [[FHFindHouseAreaSelectionTableViewVM alloc] initWithTableView:tableView];
    } else {
        extendVm = _lastListViewModel;
        extendVm.tableView = tableView;
    }
    extendVm.isMultiChecked = NO;
    extendVm.isLeaf = YES;
    extendVm.isAllowLabelShift = YES;
    extendVm.cellBackgroundColor = HEXRGBA(style.grayBGColor);
    extendVm.name = @"extendVm";
    vm.subSelectionTableViewVM = subVm;
    subVm.subSelectionTableViewVM = extendVm;
    // 添加tableView的VM
    _selectionViewModels = @[vm, subVm, extendVm];

    HotLink* hotLink = [HotLink instanceWithHeader:vm withTail:subVm];
    [_hotLinks addObject:hotLink];
    __weak typeof(self) weakSelf = self;
    hotLink.onHotStateChanged = ^() {
        [weakSelf onExtendCategoryDeactivite];
    };
    hotLink = [HotLink instanceWithHeader:subVm withTail:extendVm];
    hotLink.onHotStateChanged = ^() {
        if (subVm.selectedNodes.firstObject.isNoLimit == 1) {
            [weakSelf onExtendCategoryDeactivite];
        } else {
            [weakSelf onExtendCategoryActivite];
        }
    };
    [_hotLinks addObject:hotLink];
    [self initLayoutTables];
}

-(void)setupButtomBar {
//    _buttomBarView = [[ButtomBarView alloc] init];
//    [self addSubview:_buttomBarView];
//    [_buttomBarView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.mas_equalTo(self);
//        make.height.mas_equalTo(60);
//    }];
//    [_buttomBarView.confirmBtn addTarget:self
//                                  action:@selector(didConfirm:)
//                        forControlEvents:UIControlEventTouchUpInside];
//    [_buttomBarView.resetBtn addTarget:self
//                                  action:@selector(onReset:)
//                        forControlEvents:UIControlEventTouchUpInside];
}

-(void)didConfirm:(id)sender {
    [self commitSelected];
    [self.delegate didSelected:[self selectedNodes]];
    [self.userReactionListener didUserConfirmedWithSource:NO];
}

-(void)onReset:(id)sender {
    [_selectionViewModels enumerateObjectsUsingBlock:^(FHFindHouseAreaSelectionTableViewVM * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setSelectedIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }];
}

-(void)initLayoutTables {
    if ([_tables count] != 3) {
        NSAssert(false, @"列表创建异常");
        return;
    }
    _tables[0].contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    _tables[1].contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    _tables[2].contentInset = UIEdgeInsetsMake(10, 0, 0, 0);

    [_tables[0] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.width.mas_equalTo([self halfWidthOfScreen]);
    }];
    [_tables[1] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self->_tables[0].mas_right);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.width.mas_equalTo([self halfWidthOfScreen]);
    }];
    [_tables[2] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self->_tables[1].mas_right);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.right.mas_equalTo(self);
    }];
}

-(void)onExtendCategoryActivite {
    [self layoutSelectionViews:YES];
}

-(void)onExtendCategoryDeactivite {
    [self layoutSelectionViews:NO];
}

-(void)layoutSelectionViews:(BOOL)isShowExtends {
    if ([_tables count] != 3) {
        NSAssert(false, @"列表创建异常");
        return;
    }
    if (!isShowExtends) {
        [_tables[0] mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(self);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.width.mas_equalTo([self halfWidthOfScreen]);
        }];
        [_tables[1] mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self);
            make.left.mas_equalTo(self->_tables[0].mas_right);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.width.mas_equalTo([self halfWidthOfScreen]);
        }];
    } else {
        [_tables[0] mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(self);
            make.bottom.mas_equalTo(self.mas_bottom);
            CGFloat width = [[UIScreen mainScreen] bounds].size.width / 10 * 2;
            make.width.mas_equalTo(width);
        }];
        [_tables[1] mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self);
            make.left.mas_equalTo(self->_tables[0].mas_right);
            make.bottom.mas_equalTo(self.mas_bottom);
            CGFloat width = [[UIScreen mainScreen] bounds].size.width / 10 * 3;
            make.width.mas_equalTo(width);
        }];
    }

    if (_lineView != nil && [_tables count] == 3) {
        [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self->_tables[1]).mas_offset(0.5);
            make.top.bottom.mas_equalTo(self->_tables[1]);
            make.width.mas_equalTo(0.5);
        }];
    }
}

-(void)setNodes:(NSArray<FHFilterNodeModel*>*)nodes {
    NSParameterAssert(nodes);
    if (nodes && [nodes count] > 0) {
        FHFindHouseAreaSelectionTableViewVM* vm = [_selectionViewModels firstObject];
        [vm setNodes:nodes];
        [vm setSelectedNode:[nodes firstObject]];
    }
}

/**
 展开多级选择列表
 
 @param nodes 模型数组
 @param selectedIndexes 列表选中行
 */
-(void)setSelectedNodes:(NSArray<FHFilterNodeModel *> *)nodes selectedIndexes:(NSArray<NSNumber *> *)selectedIndexes {
    NSParameterAssert(nodes);
    NSParameterAssert(selectedIndexes);
    NSAssert(selectedIndexes.count <= _selectionViewModels.count, @"请确保selectedIndexes数量小于viewModel数量！");
    
    __block NSArray<FHFilterNodeModel *> *currentNodes = nodes;
    [selectedIndexes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger childIndex = obj.integerValue;
        if (childIndex >= currentNodes.count || idx >= _selectionViewModels.count) {
            *stop = YES;
            return;
        }
        
        FHFilterNodeModel *node = [currentNodes objectAtIndex:childIndex];
        FHFindHouseAreaSelectionTableViewVM *vm = [_selectionViewModels objectAtIndex:idx];
        [vm setNodes:currentNodes];
        [vm setSelectedNode:node];
        
        currentNodes = node.children;
    }];
}

-(void)setConditions:(NSDictionary*)conditions {
    [_selectionViewModels enumerateObjectsUsingBlock:^(FHFindHouseAreaSelectionTableViewVM * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setConditions:conditions];
    }];
    [self commitSelected];
    [self.delegate didSelected:[self selectedNodes]];
}

-(void)addRightVerticalLineViewToMiddleView:(UIView*)target {
    _lineView = [[UIView alloc] init];
    [self addSubview:_lineView];
    _lineView.backgroundColor = [UIColor themeGray6];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(target).mas_offset(0.5);
        make.top.bottom.mas_equalTo(target);
        make.width.mas_equalTo(0.5);
    }];
}

-(void)resetCondition:(NSDictionary*)params {
    [_selectionViewModels enumerateObjectsUsingBlock:^(FHFindHouseAreaSelectionTableViewVM * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setConditions:params];
    }];
    [self commitSelected];
}

- (NSArray<FHFilterNodeModel *> *)selectedNodes {
    NSEnumerator<FHFindHouseAreaSelectionTableViewVM*> * enumator = [_selectionViewModels reverseObjectEnumerator];
    FHFindHouseAreaSelectionTableViewVM* viewModel = [enumator nextObject];
    while (viewModel) {
        NSArray* selectedNodes = [viewModel selectedNodes];
        if (selectedNodes != nil && [selectedNodes count] > 0) {
            //要判断一下是否是不限，如果是不限，就需要parent nodes
            if ([selectedNodes count] == 1) {
                FHFilterNodeModel* item = [selectedNodes firstObject];
                if (item.isEmpty != 1) {
                    return selectedNodes;
                }
            } else {
                return selectedNodes;
            }
        }
        viewModel = [enumator nextObject];
    }
    return nil;
}

-(void)commitSelected {
    [_selectionViewModels enumerateObjectsUsingBlock:^(FHFindHouseAreaSelectionTableViewVM * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.transaction commit];
        // 由于B端造成需要提交回滚conditionCache
        [obj commitSelectedState];
    }];
}

-(void)rollbackSelected {
    [_selectionViewModels enumerateObjectsUsingBlock:^(FHFindHouseAreaSelectionTableViewVM * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.transaction rollback];
    }];
    [[_selectionViewModels firstObject] resotreSelectedState];
//    [[_selectionViewModels lastObject] resotreSelectedState];
}

-(CGFloat)halfWidthOfScreen {
    return [[UIScreen mainScreen] bounds].size.width / 2;
}

-(CGFloat)minWidth {
    return [[UIScreen mainScreen] bounds].size.width / 10 * 3;
}

-(void)viewWillDisplay {
//    NSLog(@"viewWillDisplay %@", _name);
    [_selectionViewModels enumerateObjectsUsingBlock:^(FHFindHouseAreaSelectionTableViewVM * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj selectedTableCellAtIndex];
    }];
}

-(void)viewDidDisplay {
//    NSLog(@"viewDidDisplay %@", _name);
    [_selectionViewModels enumerateObjectsUsingBlock:^(FHFindHouseAreaSelectionTableViewVM * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.shouldTraceScroll = YES;
    }];
}

-(void)viewWillDismiss {
//    NSLog(@"viewWillDismiss %@", _name);
}

-(void)viewDidDismiss {
//    NSLog(@"viewDidDismiss %@", _name);
//    NSLog(@"table: %@", _name);
    [self rollbackSelected];
    [_selectionViewModels enumerateObjectsUsingBlock:^(FHFindHouseAreaSelectionTableViewVM * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.shouldTraceScroll = NO;
    }];
}

@end
