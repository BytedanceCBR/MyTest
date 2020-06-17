//
//  FHFindHouseAreaSelectionTableViewVM.m
//  ios_house_filter
//  区域过滤器TableView的ViewModel，支持管理子类别TableView的ViewModel完成
//  联动工作
//  Created by leo on 2018/12/9.
//

#import "FHFindHouseAreaSelectionTableViewVM.h"
#import "FHFilterNodeModel.h"
#import "AreaSelectionItemCell.h"
#import "TransactionIndexPathSet.h"
#import "FHFilterRedDotManagement.h"
#import "DynamicAreaSelectionTableVM.h"

@interface FHFindHouseAreaSelectionTableViewVM ()
{
    NSMutableSet<NSIndexPath*> *_selectedIndexPath;
}
@end

@implementation FHFindHouseAreaSelectionTableViewVM

-(instancetype)initWithTableView:(UITableView*)tableView {
    self = [super init];
    if (self) {
        _isAllowLabelShift = NO;
        _selectedIndexPath = [[NSMutableSet alloc] init];
        _transaction = [[TransactionIndexPathSet alloc] initWithIndexPathSet:_selectedIndexPath];
        _nodes = [[NSMutableArray alloc] init];
        _tableView = tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[AreaSelectionItemCell class] forCellReuseIdentifier:@"item"];
    }
    return self;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _isAllowLabelShift = NO;
        _selectedIndexPath = [[NSMutableSet alloc] init];
        _transaction = [[TransactionIndexPathSet alloc] initWithIndexPathSet:_selectedIndexPath];
        _nodes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setNodes:(NSArray<FHFilterNodeModel *>*)nodes {
    _nodes = [nodes mutableCopy];
    [_tableView reloadData];
}

- (BOOL)hasSelection {
    return [_nodes count] > 0;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView
                 cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"item"];
    if (_cellBackgroundColor != nil) {
        [[cell contentView] setBackgroundColor:_cellBackgroundColor];
    }
    if (cell != nil) {
        if ([cell isKindOfClass:[AreaSelectionItemCell class]]) {
            AreaSelectionItemCell* areaCell = (AreaSelectionItemCell*) cell;
            if (_isAllowLabelShift) {
                areaCell.nameLabel.numberOfLines = 0;
            } else {
                areaCell.nameLabel.numberOfLines = 1;
            }
            FHFilterNodeModel* model = _nodes[indexPath.row];
            areaCell.nameLabel.text = model.label;
            if (_isLeaf) {
                if (model.isEmpty != 0) {
                    [areaCell showCheckbox:NO];
                } else {
                    [areaCell showCheckbox:YES];
                }
            } else {
                [areaCell showCheckbox:NO];
            }
            if ([_selectedIndexPath containsObject:indexPath]) {
                [areaCell setCellSelected:YES];
            } else {
                [areaCell setCellSelected:NO];
            }
            //红点控制
            if (_isShowHotDot) {
                FHFilterRedDotManagement* management = [FHFilterRedDotManagement shareInstance];
                management.delegate = self;
                if ([management shouldShowRedDotForKey:model.key forHouseType:management.houseType]) {
                    [[areaCell redDot] setHidden:NO];
                } else {
                    [[areaCell redDot] setHidden:YES];
                }
            } else {
                [[areaCell redDot] setHidden:YES];
            }
        }

        return cell;
    }
    return [[UITableViewCell alloc] init];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [_nodes count];
    return count;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (_hiddenRows.count > 0) {
//        //如果某行需要隐藏，则把cell高度设置成0
//        NSInteger row = indexPath.row;
//        if ([_hiddenRows containsObject:@(row)]) {
//            return 0;
//        }
//    }
//
//    return 42;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_hiddenRows.count > 0) {
        //如果某行需要隐藏，则把cell高度设置成0
        NSInteger row = indexPath.row;
        if ([_hiddenRows containsObject:@(row)]) {
            return 0;
        }
    }
    
    return 42;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 如果不支持单选，则先去掉所有选项
//    [self onSelectedAtIndexPath:indexPath];
    //禁止cell点击事件
    NSInteger row = indexPath.row;
    if ([_disabledRows containsObject:@(row)]) {
        return;
    }
    
    [self onSelectedAtIndexPath:indexPath];
    [[FHFilterRedDotManagement shareInstance] mark];
}

-(void)onSelectedAtIndexPath:(NSIndexPath*)indexPath {
    if (_isMultiChecked != YES) {
        NSMutableSet* newSelectedIndexPath = [[NSMutableSet alloc] init];
        [_selectedIndexPath enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj.section != indexPath.section) {
                [newSelectedIndexPath addObject:obj];
            }
        }];
        [_selectedIndexPath removeAllObjects];
        [_selectedIndexPath addObjectsFromArray:[newSelectedIndexPath allObjects]];
    }

    //判断是否是不限，不限选项和其他选项是互斥的
    if ([_nodes count] <= indexPath.row) {
        return;
    }
    FHFilterNodeModel* model = _nodes[indexPath.row];
    if (model.isEmpty != 0) {
        [_selectedIndexPath removeAllObjects];
    } else {
        //清除isEmpty == 1 的条件，就是不限
        NSMutableSet* newSelectedIndexPath = [[NSMutableSet alloc] init];
        [_selectedIndexPath enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
            if ([self->_nodes count] > obj.row) {
                FHFilterNodeModel* model = self->_nodes[obj.row];
                if (model.isEmpty == 0) {
                    [newSelectedIndexPath addObject:obj];
                }
            }
        }];
        [_selectedIndexPath removeAllObjects];
        [_selectedIndexPath addObjectsFromArray:[newSelectedIndexPath allObjects]];
    }


    if (![_selectedIndexPath containsObject:indexPath]) {
        [_selectedIndexPath addObject:indexPath];
    } else {
        [_selectedIndexPath removeObject:indexPath];
    }

    [_tableView reloadData];

    if (model.isNoLimit == 1) { // 表示不限
        if (_didSelectedNode) {
            _didSelectedNode();
        }
    } else {
        [_subSelectionTableViewVM setNodes:[self subNodesByIndexPath:indexPath]];
        [_subSelectionTableViewVM setSelectedIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self activiteDueToSelectedNode];
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_shouldTraceScroll) {
        [[FHFilterRedDotManagement shareInstance] mark];
    }
}

-(void)activiteDueToSelectedNode {
    //需要判断是否需要展开扩展
    NSIndexPath* indexPath = [[_selectedIndexPath allObjects] firstObject];
    if ([_nodes count] > indexPath.row) {
        FHFilterNodeModel* model = _nodes[indexPath.row];
        if (_didSelectedNode && [model.children count] != 0) {
            _didSelectedNode();
        }
//        else if (_didSelectedNode && [model.dynamicFetchUrl length] != 0) {
//            if([_subSelectionTableViewVM isKindOfClass:[DynamicAreaSelectionTableVM class]]) {
//                DynamicAreaSelectionTableVM* vm = (DynamicAreaSelectionTableVM*)_subSelectionTableViewVM;
//                [vm resetDynamicDataLink:model.dynamicFetchUrl];
//                NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
//                [_subSelectionTableViewVM setSelectedIndexPath:path];
//                _didSelectedNode();
//            }
//        }
    }
}

- (NSArray<FHFilterNodeModel*>*)subNodesByIndexPath:(NSIndexPath *) indexPath {
    if ([_nodes count] > indexPath.row) {
        return _nodes[indexPath.row].children;
    } else {
        return @[];
    }
}

-(NSSet<NSIndexPath*>*)selectedIndexPath {
    return _selectedIndexPath;
}

-(NSArray<FHFilterNodeModel*>*)selectedNodes {
    NSMutableArray* result = [[NSMutableArray alloc] init];
    [_selectedIndexPath enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([self->_nodes count] > obj.row) {
            [result addObject:self->_nodes[obj.row]];
        }
    }];
    return result;
}

- (void)setSelectedNode:(FHFilterNodeModel*)model {
    NSParameterAssert(model);
    if (model && _nodes) {
        NSUInteger index = [_nodes indexOfObject:model];
        NSIndexPath* path = [NSIndexPath indexPathForRow:index inSection:0];
        [self setSelectedIndexPath:path];
    }
}

- (void)setSelectedIndexPath:(NSIndexPath*)indexPath {
    NSParameterAssert(indexPath);
    [self setSelectedIndexPath:indexPath adjustTableViewOffset:YES];
}

- (void)setSelectedIndexPath:(NSIndexPath*)indexPath adjustTableViewOffset:(BOOL)adjustTableViewOffset {
    NSParameterAssert(indexPath);
    [self onSelectedAtIndexPath:indexPath];

    if (indexPath && _nodes && [_nodes count] > 0) {
        NSArray* index = [_selectedIndexPath sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES]]];
        NSIndexPath* firstIndex = [index firstObject];
        if ([index count] > firstIndex.row && adjustTableViewOffset) {
            [_tableView selectRowAtIndexPath:[index firstObject] animated:NO scrollPosition:UITableViewScrollPositionTop];
        }
    }
    if ([_nodes count] > indexPath.row) {
        [self setSubCategoryOfNode: _nodes[indexPath.row]];
    }
}

-(void)setSubCategoryOfNode:(FHFilterNodeModel*)node {
    if (node.children != nil && [node.children count] > 0) {
        [_subSelectionTableViewVM setNodes:node.children];
        NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
        [_subSelectionTableViewVM setSelectedIndexPath:path];
    } else if (node.dynamicFetchUrl != nil &&
               [node.dynamicFetchUrl length] != 0 &&
               [_subSelectionTableViewVM isKindOfClass:[DynamicAreaSelectionTableVM class]]) {
        DynamicAreaSelectionTableVM* vm = (DynamicAreaSelectionTableVM*)_subSelectionTableViewVM;
        [vm resetDynamicDataLink:node.dynamicFetchUrl];
        NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
        [_subSelectionTableViewVM setSelectedIndexPath:path];
        _didSelectedNode();
    }
}

-(void)scrollTableViewToTop {
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGRect topArea = CGRectMake(0, 0, size.width, size.height);
    [_tableView scrollRectToVisible:topArea animated:NO];
}

- (void)cleanSelectedIndexPath {
    _selectedIndexPath = [[NSMutableSet alloc] init];
}

-(void)setConditions:(NSDictionary*)conditions {
    [_selectedIndexPath removeAllObjects];
    [_nodes enumerateObjectsUsingBlock:^(FHFilterNodeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 由于服务器返回的数据中school在两个数据层级上是重复的，因此回出现必须要屏蔽掉school的最外层判断。
        if ([[conditions allKeys] containsObject:[self arrayTypeKeyString:obj.key]]) {
            if (self->_isShowHotDot && [obj.key isEqualToString:@"school"]) {
                NSArray<FHFilterNodeModel*>* children = obj.children;
                [children enumerateObjectsUsingBlock:^(FHFilterNodeModel * _Nonnull item, NSUInteger itemIdx, BOOL * _Nonnull stop) {
                    if ([[conditions allKeys] containsObject:[self arrayTypeKeyString:item.key]]) {
                        [self setSelectedNode:obj];
                    }
                }];
            } else {
                id cds = conditions[[self arrayTypeKeyString:obj.key]];
                if ([cds isKindOfClass:[NSArray class]]) {
                    NSArray* items = (NSArray*)cds;
                    if([items containsObject:obj.value]) {
                        [self setSelectedNode:obj];
                    }
                } else {
                    if ([cds isEqualToString:obj.value]) {
                        [self setSelectedNode:obj];
                    }
                }
            }
        } else {
            NSArray<FHFilterNodeModel*>* children = obj.children;
            [children enumerateObjectsUsingBlock:^(FHFilterNodeModel * _Nonnull item, NSUInteger itemIdx, BOOL * _Nonnull stop) {
                if ([[conditions allKeys] containsObject:[self arrayTypeKeyString:item.key]]) {
                    [self setSelectedNode:obj];
                }
            }];
        }
    }];
    if ([_selectedIndexPath count] == 0 && [_nodes count] != 0) {
        [self setSelectedNode:[_nodes firstObject]];
    }
    [_transaction commit];
}

-(NSString*)arrayTypeKeyString:(NSString*)key {
    NSString* result = [NSString stringWithFormat:@"%@%%5B%%5D", key];
    return result;
}

-(void)resotreSelectedState {
    [_tableView reloadData];
    if ([@"subVm" isEqualToString:_name]) {
        [self activiteDueToSelectedNode];
    }
    if (_subSelectionTableViewVM != nil && [_selectedIndexPath count] == 1) {
        NSIndexPath* indexPath = [[_selectedIndexPath allObjects] firstObject];
        if ([_nodes count] > indexPath.row) {
            [_subSelectionTableViewVM setNodes:_nodes[indexPath.row].children];
            [_subSelectionTableViewVM resotreSelectedState];
        }
    } else {
        [_subSelectionTableViewVM resotreSelectedState];
    }
}

-(void)commitSelectedState {

}

-(void)selectedTableCellAtIndex {
    if (_nodes == nil || [_nodes count] == 0) {
        return;
    }
    [self activiteDueToSelectedNode];
    NSArray* indexs = [_selectedIndexPath sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES]]];
    if ([indexs count] > 0) {
        NSIndexPath* index = [indexs firstObject];
        [_tableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionTop];
    }
}

-(void)didRedDotStateChanged {
    [_tableView reloadData];
}

@end
