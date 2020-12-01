//
//  FHHouseTableView.m
//  FHHouseList
//
//  Created by bytedance on 2020/11/30.
//

#import "FHHouseTableView.h"
#import "FHHouseNewComponentView.h"
#import "FHHouseNewComponentViewModel.h"
#import "FHHouseCardTableViewCell.h"
#import <ByteDanceKit/UIDevice+BTDAdditions.h>
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>
#import <ByteDanceKit/NSArray+BTDAdditions.h>


@interface FHHouseTableView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation FHHouseTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (void)handleAppWillEnterForground {
    NSArray *tableCells = [self visibleCells];
    if (tableCells) {
        [tableCells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol)]) {
                [(UITableViewCell<FHHouseCardTableViewCellProtocol> *)obj cellWillEnterForground];
            }
        }];
    }
}

- (void)handleAppDidEnterBackground {
    NSArray *tableCells = [self visibleCells];
    if (tableCells) {
        [tableCells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol)]) {
                [(UITableViewCell<FHHouseCardTableViewCellProtocol> *)obj cellDidEnterBackground];
            }
        }];
    }
}

- (NSObject<FHHouseNewComponentViewModelProtocol> *)getViewModelAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *dataList = [self.fhHouse_dataSource fhHouse_dataList];
    if (indexPath == nil || dataList.count <= indexPath.section) return nil;
    NSArray *items = [dataList btd_objectAtIndex:indexPath.section class:NSArray.class];
    if (!items || items.count <= indexPath.row) return nil;
    id item = [items btd_objectAtIndex:indexPath.row];
    if (![item conformsToProtocol:@protocol(FHHouseNewComponentViewModelProtocol)]) return nil;
    return item;
}

- (Class)getCellClassWithViewModel:(NSObject<FHHouseNewComponentViewModelProtocol> *)viewModel {
    if (viewModel == nil) return nil;
    
    NSString *itemClassName = NSStringFromClass(viewModel.class);
    if (itemClassName == nil) return nil;
    
    NSDictionary *supportCellStyles = [self.fhHouse_dataSource fhHouse_supportCellStyles];
    NSString *cellClassName = [supportCellStyles btd_objectForKey:itemClassName default:nil];
    Class cellClass = NSClassFromString(cellClassName);
    return cellClass;
}

- (Class)getCellClassAtIndexPath:(NSIndexPath *)indexPath {
    NSObject<FHHouseNewComponentViewModelProtocol> *viewModel = [self getViewModelAtIndexPath:indexPath];
    return [self getCellClassWithViewModel:viewModel];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *dataList = [self.fhHouse_dataSource fhHouse_dataList];
    return dataList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *dataList = [self.fhHouse_dataSource fhHouse_dataList];
    NSArray *items = [dataList btd_objectAtIndex:section class:NSArray.class];
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject<FHHouseNewComponentViewModelProtocol> *viewModel = [self getViewModelAtIndexPath:indexPath];
    if (viewModel == nil) return [[UITableViewCell alloc] init];
    
    Class cellClass = [self getCellClassWithViewModel:viewModel];
    if (cellClass == nil) return [[UITableViewCell alloc] init];
    
    UITableViewCell *cell = (UITableViewCell<FHHouseCardTableViewCellProtocol> *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass(cellClass)];
    if (![cell isKindOfClass:cellClass] || ![cell conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol)]) return [[UITableViewCell alloc] init];
    
    [(UITableViewCell<FHHouseCardTableViewCellProtocol> *)cell setViewModel:viewModel];
    return cell;
}

///其他delegate按需扩展

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.fhHouse_delegate respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)]) {
        [self.fhHouse_delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
        return;
    }
    
    if ([cell conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol) ]) {
        UITableViewCell<FHHouseCardTableViewCellProtocol> *componentCell = (UITableViewCell<FHHouseCardTableViewCellProtocol> *)cell;
        [componentCell cellWillShowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.fhHouse_delegate respondsToSelector:@selector(tableView:didEndDisplayingCell:forRowAtIndexPath:)]) {
        [self.fhHouse_delegate tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
        return;
    }
    
    if ([cell conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol) ]) {
        UITableViewCell<FHHouseCardTableViewCellProtocol> *componentCell = (UITableViewCell<FHHouseCardTableViewCellProtocol> *)cell;
        [componentCell cellDidEndShowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.fhHouse_delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [self.fhHouse_delegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    NSObject<FHHouseNewComponentViewModelProtocol> *viewModel = [self getViewModelAtIndexPath:indexPath];
    if (viewModel == nil) return 0.0f;
    
    Class cellClass = [self getCellClassWithViewModel:viewModel];
    if (cellClass == nil) return 0.0f;
    
    if (![cellClass conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol)]) return 0.0f;
    return [cellClass viewHeightWithViewModel:viewModel];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.fhHouse_delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [self.fhHouse_delegate tableView:tableView heightForHeaderInSection:section];
    }
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.fhHouse_delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [self.fhHouse_delegate tableView:tableView heightForFooterInSection:section];
    }
    
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.fhHouse_delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.fhHouse_delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol) ]) {
        UITableViewCell<FHHouseCardTableViewCellProtocol> *componentCell = (UITableViewCell<FHHouseCardTableViewCellProtocol> *)cell;
        [componentCell cellDidClickAtIndexPath:indexPath];
    }
}

///其他delegate按需扩展

@end
