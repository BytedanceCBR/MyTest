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
    [self fhHouseCard_registerCellStylesWithDict:[FHHouseCardUtils supportCellStyleMap]];
}

- (void)fhHouseCard_registerCellStylesWithDict:(NSDictionary *)dict {
    for (NSString *cellClassName in [dict allValues]) {
        Class cellClass = NSClassFromString(cellClassName);
        if (cellClass) {
            [self registerClass:cellClass forCellReuseIdentifier:cellClassName];
        }
    }
}

- (UITableViewCell *)fhHouseCard_cellForEntity:(id)entity atIndexPath:(NSIndexPath *)indexPath {
    return [self fhHouseCard_cellForEntity:entity atIndexPath:indexPath withDict:[FHHouseCardUtils supportCellStyleMap]];
}

- (UITableViewCell *)fhHouseCard_cellForEntity:(id)entity atIndexPath:(NSIndexPath *)indexPath withDict:(nonnull NSDictionary *)dict{
    if (!entity) return nil;
    
    NSString *entityClassName = NSStringFromClass(((NSObject *)entity).class);
    if (entityClassName) {
        NSString *cellClassName = [dict btd_stringValueForKey:entityClassName];
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

- (CGFloat)fhHouseCard_heightForEntity:(id)entity atIndexPath:(NSIndexPath *)indexPath withDict:(nonnull NSDictionary *)dict {
    if (!entity) return -1.0f;
    NSString *entityClassName = NSStringFromClass(((NSObject *)entity).class);
    if (entityClassName) {
        NSString *cellClassName = [dict btd_stringValueForKey:entityClassName];
        if (cellClassName) {
            Class cellClass = NSClassFromString(cellClassName);
            if (cellClass && [cellClass conformsToProtocol:@protocol(FHHouseCardTableViewCellProtocol)] && [entity conformsToProtocol:@protocol(FHHouseNewComponentViewModelProtocol)]) {
                return [cellClass viewHeightWithViewModel:entity];
            }
        }
    }
    return -1.0f;
}

- (CGFloat)fhHouseCard_heightForEntity:(id)entity atIndexPath:(NSIndexPath *)indexPath {
    return [self fhHouseCard_heightForEntity:entity atIndexPath:indexPath withDict:[FHHouseCardUtils supportCellStyleMap]];
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
