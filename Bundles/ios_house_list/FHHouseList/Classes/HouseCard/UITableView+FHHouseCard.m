//
//  UITableView+FHHouseCard.m
//  ABRInterface
//
//  Created by bytedance on 2020/11/10.
//

#import "UITableView+FHHouseCard.h"
#import "NSDictionary+BTDAdditions.h"
#import "FHHouseCardUtils.h"
#import "FHHouseCardTableViewCell.h"
#import "FHHouseNewComponentViewModel.h"

@implementation UITableView(FHHouseCard)

- (void)fhHouseCard_registerCellStyles {
    NSDictionary *supportCellStyles = [FHHouseCardUtils supportCellStyleMap];
    for (NSString *cellClassName in [supportCellStyles allValues]) {
        Class cellClass = NSClassFromString(cellClassName);
        if (cellClass) {
            [self registerClass:cellClass forCellReuseIdentifier:cellClassName];
        }
    }
}

- (UITableViewCell *)fhHouseCard_cellForEntity:(id)entity atIndexPath:(NSIndexPath *)indexPath {
    if (!entity) return nil;
    
    NSDictionary *supportCellStyles = [FHHouseCardUtils supportCellStyleMap];
    NSString *entityClassName = NSStringFromClass(((NSObject *)entity).class);
    if (entityClassName) {
        NSString *cellClassName = [supportCellStyles btd_stringValueForKey:entityClassName];
        if (cellClassName) {
            UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:cellClassName];
            if ([cell conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol)] && [entity conformsToProtocol:@protocol(FHHouseNewComponentViewModelProtocol)]) {
                ((UITableViewCell<FHHouseCardTableViewCellProtocol> *)cell).viewModel = (id<FHHouseNewComponentViewModelProtocol>)entity;
                return cell;
            }
        };
    }
    
    return nil;
}

- (CGFloat)fhHouseCard_heightForEntity:(id)entity atIndexPath:(NSIndexPath *)indexPath {
    if (!entity) return -1.0f;
    
    NSDictionary *supportCellStyles = [FHHouseCardUtils supportCellStyleMap];
    NSString *entityClassName = NSStringFromClass(((NSObject *)entity).class);
    if (entityClassName) {
        NSString *cellClassName = [supportCellStyles btd_stringValueForKey:entityClassName];
        if (cellClassName) {
            Class cellClass = NSClassFromString(cellClassName);
            if (cellClass && [cellClass conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol)] && [entity conformsToProtocol:@protocol(FHHouseNewComponentViewModelProtocol)]) {
                return [cellClass viewHeightWithViewModel:entity];
            }
        }
    }
    
    return -1.0f;
}

- (BOOL)fhHouseCard_willShowCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (![cell conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol)]) return NO;
    [(UITableViewCell<FHHouseCardTableViewCellProtocol> *)cell cellWillShowAtIndexPath:indexPath];
    return YES;
}

- (BOOL)fhHouseCard_didClickCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (![cell conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol)]) return NO;
    [(UITableViewCell<FHHouseCardTableViewCellProtocol> *)cell cellDidClickAtIndexPath:indexPath];
    return YES;
}

@end
